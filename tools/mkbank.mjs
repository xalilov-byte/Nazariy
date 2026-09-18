/* ══════════════════════════════════════════════════════════════════════
   WORD HUJJATIDAN SAVOLLAR BANKI  →  content/bank.json + content/images/

       node tools/mkbank.mjs <hujjat.docx>

   ─── Javob kaliti haqida ────────────────────────────────────────────
   Hujjatda to'g'ri javob MATN bilan belgilanmagan: na qalin harf, na
   rang, na tagchiziq — hech biri yo'q (tekshirilgan). To'g'ri javob
   faqat variant yonidagi YASHIL NUQTA rasmi bilan ko'rsatilgan, u esa
   sahifaga nisbatan aniq (x, y) koordinata bilan qo'yilgan.

   Shuning uchun kalit GEOMETRIYA bilan ochiladi: docx-layout.mjs
   Word'ning satrlarni qayerga qo'yishini qayta hisoblaydi, keyin har
   nuqta qaysi variant satrida turgani topiladi.

   ─── Nega bunga ishonish mumkin ─────────────────────────────────────
   Har savolda IKKITA nuqta bor: bittasi o'zbekcha blokda, bittasi
   ruschada. Ular bir-biridan mustaqil o'lchov: matn uzunligi boshqa,
   satrlar soni boshqa, joylashuvi boshqa. Ikkalasi bir xil variant
   raqamini ko'rsatsagina kalit yoziladi. Mos kelmasa — `correct: null`
   va `keyWhy` da sababi.

   TAXMIN QILINMAYDI. Noto'g'ri javob kaliti — bu loyihada qilinishi
   mumkin bo'lgan eng katta zarar: odam imtihonga noto'g'ri bilim bilan
   boradi. Shubhali savol kalitsiz qoladi va admin panelda odam
   tasdiqlaguncha nashr etilmaydi (0004_bank.sql).
   ══════════════════════════════════════════════════════════════════════ */
import { readFileSync, writeFileSync, mkdirSync, rmSync } from 'fs';
import { join } from 'path';
import { inflateRawSync } from 'zlib';
import sharp from 'sharp';
import { parseParagraphs, layoutDocument, charWidth, unknownChars } from './docx-layout.mjs';

/* ── Rasm o'lchami ────────────────────────────────────────────────────
   Hujjatdagi rasmlar bosma uchun: eng kengi 1397 px, jami 7 MB. Ilova
   ularni telefon ekranida ~360 dp kenglikda ko'rsatadi, ya'ni 3x
   ekranda ham 1080 px yetadi. 7 MB esa APK'ga to'g'ridan-to'g'ri
   qo'shiladi va offline ishlash uchun hammasi ichida turishi kerak.
   Shuning uchun rasmlar shu yerda WebP'ga o'giriladi: sifat sezilmaydi,
   hajm bir necha barobar kichrayadi. Kattalashtirilmaydi — kichik rasm
   o'z o'lchamida qoladi. */
const IMG_MAX_W = 1000;
const IMG_QUALITY = 82;

/* ── ZIP o'qish ────────────────────────────────────────────────────────
   .docx — oddiy ZIP. Node'da zip kutubxonasi yo'q, lekin zlib bor va
   ZIP formatining kerakli qismi kichkina: markaziy katalogni o'qiymiz,
   har bir yozuv uchun lokal sarlavhadan keyingi baytlarni ochamiz.
   Tashqi bog'liqlik qo'shmaslik uchun shu yo'l tanlandi. */
function unzip(buf) {
  const files = new Map();
  let eocd = -1;
  for (let i = buf.length - 22; i >= 0 && i > buf.length - 66000; i--) {
    if (buf.readUInt32LE(i) === 0x06054b50) { eocd = i; break; }
  }
  if (eocd < 0) throw new Error('[bank] ZIP markaziy katalogi topilmadi');
  const n = buf.readUInt16LE(eocd + 10);
  let off = buf.readUInt32LE(eocd + 16);
  for (let k = 0; k < n; k++) {
    if (buf.readUInt32LE(off) !== 0x02014b50) throw new Error('[bank] katalog yozuvi buzuq');
    const method = buf.readUInt16LE(off + 10);
    const csize = buf.readUInt32LE(off + 20);
    const nameLen = buf.readUInt16LE(off + 28);
    const extraLen = buf.readUInt16LE(off + 30);
    const cmtLen = buf.readUInt16LE(off + 32);
    const lho = buf.readUInt32LE(off + 42);
    const name = buf.toString('utf8', off + 46, off + 46 + nameLen);
    const start = lho + 30 + buf.readUInt16LE(lho + 26) + buf.readUInt16LE(lho + 28);
    const raw = buf.subarray(start, start + csize);
    files.set(name, method === 0 ? Buffer.from(raw) : inflateRawSync(raw));
    off += 46 + nameLen + extraLen + cmtLen;
  }
  return files;
}

const EMU = 914400;          // 1 dyum
const TWIP = 1440;           // 1 dyum
const DOT_MAX_IN = 0.7;      // javob nuqtasi 0.41″, eng kichik mazmunli rasm 1″ dan katta

/* Bir necha xil apostrof bitta ko'rinishga keltiriladi — aks holda bir
   xil savol ikki xil yozilib, taqqoslash va qidiruv buziladi. */
/* Hujjatning bir necha sahifasida matn harf-oralatib yozilgan:
   "S a n a b o ‘ t i l g a n". Bu PDF'dan aylantirishning nuqsoni.
   Ketma-ket 5 tadan ortiq BITTA belgili bo'lak topilsa, oradagi
   bo'shliqlar olib tashlanadi. 5 chegara ataylab baland: "o", "и",
   "в" kabi haqiqiy bir harfli so'zlar tasodifan yopishib qolmasin. */
const unspace = s => s.replace(
  /(?:(?:^|(?<= ))\S ){5,}\S(?![^\s])/gu,
  m => m.split(' ').every(t => [...t].length === 1) ? m.replace(/ /g, '') : m);

const tidy = s => unspace(s)
  .replace(/[‘’ʼʹ'`´]/g, '‘')
  .replace(/[“”]/g, '"')
  .replace(/ /g, ' ')
  .replace(/\s+/g, ' ')
  .trim();

/* Sahifadagi rasmlar: yashil "javob nuqtasi" (kichik) va mazmunli rasm
   (katta). Ikkalasi ham guruh ichida, sahifa koordinatasida. */
function picturesOf(anchorXml) {
  const dots = [], images = [];
  const re = /(?:r:embed="(rId\d+)"[\s\S]*?)?<a:off x="(-?\d+)" y="(-?\d+)"\/><a:ext cx="(\d+)" cy="(\d+)"\/>/g;
  let m;
  while ((m = re.exec(anchorXml)) !== null) {
    const item = {
      rid: m[1] || null,
      x: +m[2] / EMU, y: +m[3] / EMU,
      w: +m[4] / EMU, h: +m[5] / EMU,
    };
    if (item.w > 12) continue;                 // guruhning o'zi — butun sahifa
    (item.w < DOT_MAX_IN ? dots : images).push(item);
  }
  return { dots, images };
}

const cyrShare = s => {
  const letters = s.match(/\p{L}/gu) || [];
  return letters.length ? letters.filter(c => /[Ѐ-ӿ]/.test(c)).length / letters.length : 0;
};
const middle = box => (box ? (box.top + box.bot) / 2 : 0);

/* Bir tilning satrlaridan savol matnini va variantlarni yig'adi.
   Variant boshi — "F1." / "F2." … belgisi. Har variant uchun uning
   sahifadagi bo'lagi (top/bot/x0/x1) ham saqlanadi: nuqta aynan shu
   bo'lakka tushishi kerak. */
function buildPart(rows) {
  const question = [], options = [], spans = [];
  for (const r of rows) {
    if (!r.marks.length) {
      if (options.length) {
        options[options.length - 1] += ' ' + r.text;
        spans.push({ top: r.top, bot: r.bot, x0: r.x0, x1: Infinity, opt: options.length - 1 });
      } else question.push(r.text);
      continue;
    }
    const head = r.text.slice(0, r.marks[0].at).trim();
    if (head) {
      if (options.length) {
        options[options.length - 1] += ' ' + head;
        spans.push({ top: r.top, bot: r.bot, x0: r.x0, x1: r.marks[0].x, opt: options.length - 1 });
      } else question.push(head);
    }
    for (let k = 0; k < r.marks.length; k++) {
      const m = r.marks[k], next = r.marks[k + 1];
      options.push(r.text.slice(m.at + m.len, next ? next.at : undefined).trim());
      spans.push({ top: r.top, bot: r.bot, x0: m.x, x1: next ? next.x : Infinity, opt: options.length - 1 });
    }
  }
  return { text: tidy(question.join(' ')), options: options.map(tidy), spans };
}

/* ── Mavzuga ajratish ──────────────────────────────────────────────────
   Kalit so'zlar bo'yicha. Tartib muhim: birinchi mos kelgani olinadi,
   shuning uchun torroq mavzular yuqorida turadi. Hech biriga tushmasa —
   'umumiy-qoidalar'. Bu taxminiy tasnif, admin panelda tuzatiladi. */
const TOPICS = [
  ['birinchi-yordam', /birinchi yordam|jarohat|qon ketish|shikastlan|nafas ol|jabrlan/i],
  ['svetofor', /svetofor|chiroq ishorasi|sariq chiroq|yashil chiroq|qizil chiroq|tartibga soluvchi/i],
  ['yol-belgilari', /belgi|ko‘rsatkich|razmetka|chiziq(lar)?i/i],
  ['chorrahalar', /chorraha|kesishma|aylanma harakat|birinchi bo‘lib|ikkinchi bo‘lib/i],
  ['quvib-otish', /quvib o‘tish|o‘zib o‘tish|qarama-qarshi oqim/i],
  ['tezlik-rejimi', /tezlik|km\/s|masofa|tormoz/i],
  ['toxtab-turish', /to‘xta|qo‘yish joyi|parkovka|stoyanka/i],
  ['manyovr', /manyovr|burilish|orqaga yurish|qayrilish|yo‘nalish ko‘rsatkich/i],
  ['shatak-yuk', /shatak|tirkama|yuk tashish|yo‘lovchi tashish/i],
  ['texnik-holat', /texnik|nosoz|g‘ildirak|chiroqlar ishla|jihoz|quticha|o‘t o‘chirgich/i],
];
const topicOf = q => {
  const hay = q.uz.text + ' ' + q.uz.options.join(' ');
  for (const [slug, re] of TOPICS) if (re.test(hay)) return slug;
  return 'umumiy-qoidalar';
};

/* ── Ishga tushirish ───────────────────────────────────────────────── */
const src = process.argv[2];
if (!src) {
  console.error('Foydalanish: node tools/mkbank.mjs <hujjat.docx>');
  process.exit(1);
}
const zip = unzip(readFileSync(src));
const doc = zip.get('word/document.xml');
if (!doc) throw new Error('[bank] word/document.xml topilmadi — bu .docx emas');
const xml = doc.toString('utf8');

const rels = (zip.get('word/_rels/document.xml.rels') || Buffer.from('')).toString('utf8');
const relMap = new Map();
for (const m of rels.matchAll(/Id="(rId\d+)"[^>]*Target="([^"]+)"/g)) relMap.set(m[1], m[2]);

const paras = parseParagraphs(xml);
const lines = layoutDocument(paras);

/* Har savol sahifasi — bitta <wp:anchor> (rasmlar guruhi). U qaysi
   bo'limda (sahifada) — o'sha sahifaning satrlari savolga tegishli. */
const parPage = new Map();
for (const l of lines) if (!parPage.has(l.par)) parPage.set(l.par, l.page);
const drawPar = [];
for (let i = 0; i < paras.length; i++) if (paras[i].hasDrawing) drawPar.push(i);
const anchors = [...xml.matchAll(/<wp:anchor[\s\S]*?<\/wp:anchor>/g)].map(m => m[0]);
if (anchors.length !== drawPar.length)
  throw new Error(`[bank] anchor (${anchors.length}) va rasmli paragraf (${drawPar.length}) soni teng emas`);

const byPage = new Map();
for (const l of lines) {
  if (!byPage.has(l.page)) byPage.set(l.page, []);
  byPage.get(l.page).push(l);
}

const OUT_DIR = 'content';
const IMG_DIR = join(OUT_DIR, 'images');
/* Papka tozalanadi: hujjat o'zgarsa savol raqamlari siljiydi va eski
   nomdagi rasm yetim qolib, ilovaga noto'g'ri rasm tushardi. */
rmSync(IMG_DIR, { recursive: true, force: true });
mkdirSync(IMG_DIR, { recursive: true });
let imgBytesIn = 0, imgBytesOut = 0;

const bank = [];
const skipped = [];

for (let a = 0; a < anchors.length; a++) {
  const pageLines = (byPage.get(parPage.get(drawPar[a])) || []).filter(l => l.chars.length);
  if (!pageLines.length) { skipped.push({ a, why: 'sahifada matn yo‘q' }); continue; }

  /* Har satr: matni, "Fn." belgilarining o'rni (matnda va sahifada). */
  const rows = pageLines.map(l => {
    const text = l.chars.map(c => c.ch).join('');
    const marks = [];
    /* Odatda "F2." Ba'zi sahifalarda aylantirgich harflarni oralatib
       yozgan — "F 2 ." Ikkalasi ham ushlanadi, aks holda variant
       oldingisiga qo'shilib ketadi. */
    for (const m of text.matchAll(/\bF\s?(\d)\s?\.(?=\s|$)/g)) {
      let x = l.x0;
      for (let k = 0; k < m.index; k++) x += charWidth(l.chars[k]);
      marks.push({ n: +m[1], at: m.index, len: m[0].length, x });
    }
    return { text: text.trim(), marks, top: l.top, bot: l.top + l.h, x0: l.x0, col: l.col };
  }).sort((p, q) => p.col - q.col || p.top - q.top);

  /* O'zbekcha va ruscha bloklar: ikki ustunli sahifada — ustun bo'yicha,
     bitta ustunlida — birinchi kirillcha satrdan boshlab. */
  const twoCol = rows.some(r => r.col === 1);
  let uzRows, ruRows;
  if (twoCol) {
    uzRows = rows.filter(r => r.col === 0);
    ruRows = rows.filter(r => r.col === 1);
  } else {
    let cut = rows.findIndex(r => cyrShare(r.text) > 0.5);
    if (cut <= 0) cut = rows.length;
    uzRows = rows.slice(0, cut);
    ruRows = rows.slice(cut);
  }
  const uz = buildPart(uzRows), ru = buildPart(ruRows);
  if (!uz.text || uz.options.length < 2) {
    skipped.push({ a, why: 'savol yoki variantlar ajratilmadi', text: uz.text.slice(0, 60) });
    continue;
  }

  const boxOf = rs => rs.length
    ? { top: Math.min(...rs.map(r => r.top)), bot: Math.max(...rs.map(r => r.bot)), x0: Math.min(...rs.map(r => r.x0)) }
    : null;
  const uzBox = boxOf(uzRows), ruBox = boxOf(ruRows);
  const { dots, images } = picturesOf(anchors[a]);

  /* ── Javob kaliti ───────────────────────────────────────────────── */
  const sideOf = d => {
    const cx = (d.x + d.w / 2) * TWIP, cy = (d.y + d.h / 2) * TWIP;
    if (twoCol) return cx < (uzBox.x0 + ruBox.x0) / 2 ? 'uz' : 'ru';
    return Math.abs(cy - middle(uzBox)) <= Math.abs(cy - middle(ruBox)) ? 'uz' : 'ru';
  };
  const hitOf = (d, part) => {
    const ty = d.y * TWIP, cx = (d.x + d.w / 2) * TWIP;
    let best = null, bestKey = Infinity;
    for (const s of part.spans) {
      const dy = Math.abs(ty - s.top);
      const dx = cx < s.x0 ? s.x0 - cx : cx > s.x1 ? cx - s.x1 : 0;
      const key = dy * 3 + dx;          // satr muhimroq, ustun ikkinchi
      if (key < bestKey) { bestKey = key; best = { opt: s.opt, dy, dx }; }
    }
    return best;
  };

  let correct = null, keyWhy = 'javob nuqtasi ikkita emas';
  if (dots.length === 2) {
    const sides = dots.map(sideOf);
    if (sides[0] === sides[1]) keyWhy = 'ikkala nuqta bitta tilda';
    else {
      const A = hitOf(dots[sides[0] === 'uz' ? 0 : 1], uz);
      const B = hitOf(dots[sides[0] === 'uz' ? 1 : 0], ru);
      if (!A || !B) keyWhy = 'nuqta hech qaysi variantga tushmadi';
      else if (A.opt !== B.opt) keyWhy = `o‘zbekcha ${A.opt + 1}, ruscha ${B.opt + 1} — mos emas`;
      else if (A.dy > 500 || B.dy > 500) keyWhy = 'nuqta variant satridan uzoq';
      else if (A.opt >= uz.options.length || A.opt >= ru.options.length) keyWhy = 'variant chegaradan tashqarida';
      else { correct = A.opt; keyWhy = 'ikkala til bir xil variantni ko‘rsatdi'; }
    }
  }

  /* Mazmunli rasm — eng kattasi (sahifada bittadan ortiq bo'lsa ham). */
  let image = null;
  if (images.length) {
    const big = images.slice().sort((p, q) => q.w * q.h - p.w * p.h)[0];
    const target = big.rid && relMap.get(big.rid);
    if (target) {
      const data = zip.get('word/' + target.replace(/^\.\//, ''));
      if (data) {
        const name = `q${String(bank.length + 1).padStart(3, '0')}.webp`;
        const meta = await sharp(data).metadata();
        const out = await sharp(data)
          .resize({ width: Math.min(meta.width || IMG_MAX_W, IMG_MAX_W), withoutEnlargement: true })
          .webp({ quality: IMG_QUALITY })
          .toBuffer();
        writeFileSync(join(IMG_DIR, name), out);
        imgBytesIn += data.length; imgBytesOut += out.length;
        image = name;
      }
    }
  }

  const q = {
    ref: '#A' + String(bank.length + 1).padStart(3, '0'),
    page: a,
    uz: { text: uz.text, options: uz.options },
    ru: { text: ru.text, options: ru.options },
    image,
    correct,
    keyWhy,
  };
  q.topic = topicOf(q);
  bank.push(q);
}

writeFileSync(join(OUT_DIR, 'bank.json'), JSON.stringify(bank, null, 1) + '\n');

/* ── Hisobot ───────────────────────────────────────────────────────── */
const count = (list, f) => list.reduce((a, x) => (a[f(x)] = (a[f(x)] || 0) + 1, a), {});
const keyed = bank.filter(q => q.correct !== null);
console.log('sahifa (anchor):    ' + anchors.length);
console.log('savol olindi:       ' + bank.length);
console.log('rasm bilan:         ' + bank.filter(q => q.image).length
  + ' (' + (imgBytesIn / 1048576).toFixed(1) + ' MB → '
  + (imgBytesOut / 1048576).toFixed(1) + ' MB WebP)');
console.log('ruscha to‘liq:      ' + bank.filter(q => q.ru.text && q.ru.options.length).length);
console.log('variantlar soni:    ' + JSON.stringify(count(bank, q => q.uz.options.length)));
console.log('JAVOB KALITI:       ' + keyed.length + ' / ' + bank.length + ' tasdiqlandi');
console.log('  taqsimoti:        ' + JSON.stringify(count(keyed, q => q.correct + 1)));
console.log('mavzular:           ' + JSON.stringify(count(bank, q => q.topic)));
if (keyed.length < bank.length) {
  console.log('\nkalitsiz qolgan ' + (bank.length - keyed.length) + ' savol (odam tekshiradi):');
  for (const [why, n] of Object.entries(count(bank.filter(q => q.correct === null), q => q.keyWhy)))
    console.log('  · ' + n + ' × ' + why);
}
if (skipped.length) {
  console.log('\no‘tkazib yuborildi: ' + skipped.length);
  for (const s of skipped) console.log('  · sahifa ' + s.a + ' — ' + s.why);
}
if (unknownChars().size)
  console.log('\nshriftda topilmagan belgilar: ' + [...unknownChars().keys()].join(' '));
console.log('\n→ content/bank.json');
console.log('→ content/images/');
