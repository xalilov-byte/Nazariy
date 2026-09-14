/* ══════════════════════════════════════════════════════════════════════
   Eng kichik WOFF o'qigich — faqat belgi kengliklari kerak.

   Nega kerak: hujjatdagi savollar Calibri 28pt bilan terilgan va biz
   Word satrlarni qayerda uzganini aniq bilishimiz shart (pastdagi
   docx-layout.mjs ga qarang). Buning uchun har bir belgining kengligi
   kerak. Calibri — Microsoft shrifti, uni tarqatib bo'lmaydi; Carlito
   esa u bilan O'LCHAMDOSH (metric-compatible): har glifning kengligi
   Calibri'dagi bilan bitta ham EMU farq qilmaydi. Shuning uchun
   @fontsource/carlito devDependency sifatida qo'shilgan.

   Faqat uchta jadval o'qiladi: head (unitsPerEm), hhea+hmtx (kenglik),
   cmap format 4 (belgi → glif).
   ══════════════════════════════════════════════════════════════════════ */
import { readFileSync } from 'node:fs';
import { inflateSync } from 'node:zlib';
import { createRequire } from 'node:module';

const SUBSETS = ['latin', 'latin-ext', 'cyrillic', 'cyrillic-ext'];

function tables(buf) {
  if (buf.toString('latin1', 0, 4) !== 'wOFF') throw new Error('WOFF fayli emas');
  const n = buf.readUInt16BE(12), out = {};
  for (let i = 0; i < n; i++) {
    const o = 44 + i * 20;
    const tag = buf.toString('latin1', o, o + 4);
    const off = buf.readUInt32BE(o + 4);
    const comp = buf.readUInt32BE(o + 8), orig = buf.readUInt32BE(o + 12);
    const raw = buf.subarray(off, off + comp);
    out[tag] = comp === orig ? raw : inflateSync(raw);
  }
  return out;
}

/* Carlito fayllari node_modules ichidan topiladi. Topilmasa — baland
   ovozda to'xtaydi: shriftsiz o'lchov noto'g'ri bo'ladi, noto'g'ri
   o'lchov esa noto'g'ri javob kalitiga olib keladi. */
function files() {
  const req = createRequire(import.meta.url);
  let dir;
  try {
    dir = req.resolve('@fontsource/carlito/package.json').replace(/package\.json$/, 'files/');
  } catch {
    throw new Error(
      '@fontsource/carlito topilmadi. `npm i` ni ishga tushiring — ' +
      'bu shrift Calibri bilan o\'lchamdosh va matn o\'lchash uchun shart.');
  }
  return SUBSETS.map(s => dir + `carlito-${s}-400-normal.woff`);
}

export function metrics() {
  const width = new Map();
  let upem = 2048;
  for (const f of files()) {
    const t = tables(readFileSync(f));
    upem = t.head.readUInt16BE(18);
    const numH = t.hhea.readUInt16BE(34);
    const advance = g => t.hmtx.readUInt16BE(Math.min(g, numH - 1) * 4);

    const cm = t.cmap, nt = cm.readUInt16BE(2);
    let sub = null;
    for (let i = 0; i < nt; i++) {
      const pid = cm.readUInt16BE(4 + i * 8), eid = cm.readUInt16BE(6 + i * 8);
      const off = cm.readUInt32BE(8 + i * 8);
      if (cm.readUInt16BE(off) === 4 && pid === 3 && (eid === 1 || eid === 0)) { sub = off; break; }
    }
    if (sub === null) continue;
    const segX2 = cm.readUInt16BE(sub + 6), seg = segX2 / 2;
    const endO = sub + 14, startO = endO + segX2 + 2;
    const deltaO = startO + segX2, rangeO = deltaO + segX2;
    for (let s = 0; s < seg; s++) {
      const end = cm.readUInt16BE(endO + s * 2), start = cm.readUInt16BE(startO + s * 2);
      const delta = cm.readInt16BE(deltaO + s * 2), ro = cm.readUInt16BE(rangeO + s * 2);
      if (start === 0xffff) continue;
      for (let c = start; c <= end && c !== 0x10000; c++) {
        let g;
        if (ro === 0) g = (c + delta) & 0xffff;
        else {
          const gi = rangeO + s * 2 + ro + (c - start) * 2;
          if (gi + 1 >= cm.length) continue;
          g = cm.readUInt16BE(gi);
          if (g) g = (g + delta) & 0xffff;
        }
        if (g && !width.has(c)) width.set(c, advance(g));
      }
    }
  }
  if (width.size < 500) throw new Error('shrift jadvali juda kichik — fayl buzilgan');
  return { width, upem };
}
