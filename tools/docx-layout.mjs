/* ══════════════════════════════════════════════════════════════════════
   Word hujjatidagi har bir satrning sahifadagi o'rnini qayta hisoblash.

   NEGA BU KERAK
   Savollar to'plamida to'g'ri javob matn bilan belgilanmagan — u faqat
   variant yonidagi YASHIL NUQTA rasmi bilan ko'rsatilgan. Rasm sahifaga
   nisbatan aniq (x, y) bilan qo'yilgan, matn esa oqimda. Nuqta qaysi
   variantni ko'rsatayotganini bilish uchun matn satrlarining (x, y)
   o'rnini bilish shart.

   BU YERDA TAXMIN YO'Q
   Hujjat PDF'dan aylantirilgan, shuning uchun aylantirgich hamma narsani
   aniq yozib qo'ygan:
     · har paragrafda aniq `w:spacing` (before/after/line),
     · har yugurishda aniq `w:spacing w:val` — belgilar orasidagi
       qo'shimcha (twip), PDF'dagi joylashuvni takrorlash uchun,
     · har bo'limda aniq ustun kengligi (`w:cols`),
     · satr uzilishi kerak joyda `w:ind w:right` bilan majburlangan.
   Qolgani — belgi kengliklari (docx-font.mjs) va Word'ning oddiy
   ochko'z satr uzish qoidasi.

   O'LCHOV BIRLIGI: twip (1/1440 dyum). Shrift o'lchami ham twipda.
   ══════════════════════════════════════════════════════════════════════ */
import { metrics } from './docx-font.mjs';

const { width: WIDTH, upem: UPEM } = metrics();
const LINE_EM = 2500 / 2048;   // Calibri tabiiy satr balandligi (asc+desc)
const QMARK = 0x3f;

const seen = new Map();
export const unknownChars = () => seen;

/* Bitta belgining oldinga siljishi: glif kengligi + yugurishning
   qo'shimcha oralig'i. */
export function charWidth(c) {
  const code = c.ch.codePointAt(0);
  let u = WIDTH.get(code);
  if (u === undefined) { seen.set(c.ch, (seen.get(c.ch) || 0) + 1); u = WIDTH.get(QMARK); }
  return u * c.sz / UPEM + c.sp;
}

const ENT = { '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"', '&apos;': "'" };
const unesc = s => s.replace(/&(amp|lt|gt|quot|apos);/g, m => ENT[m]);
const int = (s, re) => { const m = (s || '').match(re); return m ? parseInt(m[1], 10) : null; };

function columns(sectXml) {
  const c = (sectXml.match(/<w:cols[^>]*>[\s\S]*?<\/w:cols>|<w:cols[^>]*\/>/) || [''])[0];
  const list = [...c.matchAll(/<w:col w:w="(\d+)"(?: w:space="(\d+)")?\/>/g)]
    .map(m => ({ w: +m[1], space: +(m[2] || 0) }));
  return list.length ? list : null;
}

/* document.xml → paragraflar ro'yxati. */
export function parseParagraphs(xml) {
  const body = xml.slice(xml.indexOf('<w:body>'), xml.lastIndexOf('</w:body>'));
  const out = [];
  const pRe = /<w:p(?:\s[^>]*)?>([\s\S]*?)<\/w:p>|<w:p(?:\s[^>]*)?\/>/g;
  let pm;
  while ((pm = pRe.exec(body))) {
    const p = pm[1] || '';
    const pPr = (p.match(/<w:pPr>[\s\S]*?<\/w:pPr>/) || [''])[0];
    const sectXml = (pPr.match(/<w:sectPr>[\s\S]*?<\/w:sectPr>/) || [null])[0];
    const head = pPr.replace(/<w:sectPr>[\s\S]*?<\/w:sectPr>/, '');
    const markSz = int(head, /<w:rPr><w:sz w:val="(\d+)"\/>/);

    const runs = [];
    let colBreak = false;
    const rRe = /<w:r(?:\s[^>]*)?>([\s\S]*?)<\/w:r>/g;
    let rm;
    while ((rm = rRe.exec(p))) {
      const r = rm[1];
      if (/<w:br w:type="column"\/>/.test(r)) colBreak = true;
      const rPr = (r.match(/<w:rPr(?:\/>|>[\s\S]*?<\/w:rPr>)/) || [''])[0];
      const sz = (int(rPr, /<w:sz w:val="(\d+)"\/>/) ?? 56) * 10;  // yarim-punkt → twip
      const sp = int(rPr, /<w:spacing w:val="(-?\d+)"\/>/) ?? 0;
      let t = '';
      for (const g of r.match(/<w:t(?:\s[^>]*)?>([\s\S]*?)<\/w:t>/g) || [])
        t += unesc(g.replace(/^<w:t(?:\s[^>]*)?>/, '').replace(/<\/w:t>$/, ''));
      if (t) runs.push({ t, sz, sp });
    }
    out.push({
      before: int(head, /w:before="(\d+)"/) ?? 0,
      after: int(head, /w:after="(\d+)"/) ?? 0,
      line: int(head, /w:line="(\d+)"/),
      rule: ((head || '').match(/w:lineRule="(\w+)"/) || [])[1] || null,
      left: int(head, /<w:ind[^>]*?w:left="(\d+)"/) ?? 0,
      right: int(head, /<w:ind[^>]*?w:right="(\d+)"/) ?? 0,
      hasDrawing: /<w:drawing>/.test(p),
      colBreak,
      markSz: markSz ? markSz * 10 : null,
      sect: sectXml ? {
        type: (sectXml.match(/<w:type w:val="(\w+)"\/>/) || [])[1] || 'nextPage',
        top: int(sectXml, /w:top="(-?\d+)"/),
        bottom: int(sectXml, /w:bottom="(-?\d+)"/) ?? 0,
        pageH: int(sectXml, /w:h="(\d+)"/),
        left: int(sectXml, /w:left="(-?\d+)"/),
        right: int(sectXml, /w:right="(-?\d+)"/),
        pageW: int(sectXml, /w:w="(\d+)"/),
        cols: columns(sectXml),
      } : null,
      runs,
    });
  }
  return out;
}

/* Paragrafni ko'rinadigan satrlarga bo'ladi. Word ochko'z: so'z sig'masa
   satr uziladi. Har satr — belgilar ro'yxati (har biri o'z o'lchami va
   oralig'i bilan). */
function wrapParagraph(par, width) {
  if (!par.runs.length) return [[]];
  const chars = [];
  for (const r of par.runs) for (const ch of r.t) chars.push({ ch, sz: r.sz, sp: r.sp });
  const sum = a => a.reduce((s, c) => s + charWidth(c), 0);
  const lines = [];
  let cur = [], word = [];
  for (const c of chars) {
    if (/\s/.test(c.ch)) { cur = cur.concat(word); word = []; cur.push(c); continue; }
    word.push(c);
    if (sum(cur) + sum(word) > width && cur.some(x => !/\s/.test(x.ch))) {
      while (cur.length && /\s/.test(cur[cur.length - 1].ch)) cur.pop();
      lines.push(cur); cur = [];
    }
  }
  lines.push(cur.concat(word));
  return lines;
}

/* Butun hujjatni satrlarga joylashtiradi.
   Har satr: { page, col, top, h, x0, chars, par }  — hammasi twipda. */
export function layoutDocument(paras) {
  const sections = [];
  let start = 0;
  for (let i = 0; i < paras.length; i++)
    if (paras[i].sect) { sections.push({ from: start, to: i, s: paras[i].sect }); start = i + 1; }

  const lines = [];
  let page = -1, y = 0;
  for (const S of sections) {
    const sec = S.s;
    /* w:type bo'lim QAYERDAN BOSHLANISHINI aytadi (ECMA-376 17.6.22).
       "continuous" — oldingi bo'lim tugagan joydan, o'sha sahifada.
       Shu qoida tufayli rasm uchun joy qoldiruvchi bo'sh paragraflar
       keyingi bo'limni pastga suradi — matn aynan PDF'dagi joyiga
       tushadi. */
    if (sec.type === 'continuous' && page >= 0) { /* y davom etadi */ }
    else { page++; y = sec.top; }

    const cols = sec.cols || [{ w: sec.pageW - sec.left - sec.right, space: 0 }];
    const colX = [];
    let cx = sec.left;
    for (const c of cols) { colX.push(cx); cx += c.w + c.space; }

    let col = 0;
    const yTop = y;
    for (let i = S.from; i <= S.to; i++) {
      const p = paras[i];
      if (p.colBreak) { col = Math.min(col + 1, cols.length - 1); y = yTop; }
      const sz = p.runs.length ? Math.max(...p.runs.map(r => r.sz)) : (p.markSz ?? 560);
      const natural = Math.round(sz * LINE_EM);
      const h = p.rule === 'exact' ? p.line
        : p.rule === 'atLeast' ? Math.max(p.line, natural)
        : Math.round(natural * (p.line ?? 240) / 240);
      y += p.before;
      for (const l of wrapParagraph(p, cols[col].w - p.left - p.right)) {
        lines.push({ page, col, top: y, h, x0: colX[col] + p.left, chars: l, par: i });
        y += h;
      }
      y += p.after;
    }
  }
  return lines;
}
