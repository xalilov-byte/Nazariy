/* ══════════════════════════════════════════════════════════════════════
   content/bank.json  →  supabase/seed/0005_bank.sql

       node tools/mkbankseed.mjs

   Savollar 'draft' holatida yoziladi. Ataylab: kalit hujjatdagi yashil
   nuqtadan olingan (key_source = 'docx-geometry'), uni odam
   tasdiqlamaguncha savol foydalanuvchiga ko'rinmaydi. Buni sxema ham
   majburlaydi — 0004_bank.sql dagi questions_published_key.

   Fayl qo'lda tahrir qilinmaydi: har safar shu generator bilan
   qaytadan yasaladi.
   ══════════════════════════════════════════════════════════════════════ */
import { readFileSync, writeFileSync } from 'fs';

const bank = JSON.parse(readFileSync('content/bank.json', 'utf8'));
if (!Array.isArray(bank) || bank.length < 100)
  throw new Error('[seed] content/bank.json bo‘sh yoki juda kichik — avval mkbank.mjs');

/* SQL satri. Qo'shtirnoq ikkilantiriladi — boshqa hech qanday
   "tozalash" yo'q: matnni o'zgartirish savolni buzadi. */
const q = s => "'" + String(s).replace(/'/g, "''") + "'";
const arr = a => 'array[' + a.map(q).join(', ') + ']';

/* Mavzular: 0002 dagilarga uchtasi qo'shiladi. */
const TOPICS = [
  ['umumiy-qoidalar', 'Umumiy qoidalar', 1],
  ['yol-belgilari', 'Yoʻl belgilari', 2],
  ['tezlik-rejimi', 'Tezlik rejimi', 3],
  ['chorrahalar', 'Chorrahalar', 4],
  ['svetofor', 'Svetofor', 5],
  ['quvib-otish', 'Quvib oʻtish', 6],
  ['toxtab-turish', 'Toʻxtab turish', 7],
  ['birinchi-yordam', 'Birinchi yordam', 8],
  ['manyovr', 'Manyovr va burilish', 9],
  ['shatak-yuk', 'Shatak, tirkama va yuk', 10],
  ['texnik-holat', 'Texnik holat va jihoz', 11],
];
const known = new Set(TOPICS.map(t => t[0]));
for (const item of bank)
  if (!known.has(item.topic)) throw new Error('[seed] notanish mavzu: ' + item.topic);

const out = [];
const keyed = bank.filter(b => b.correct !== null).length;

out.push(`-- ═══════════════════════════════════════════════════════════════════════
--  NAZARIY — 0005: rasmiy avtotest savollari (${bank.length} ta)
--
--  BU FAYL QO'LDA TAHRIR QILINMAYDI — u generator bilan yasaladi:
--      node tools/mkbank.mjs <hujjat.docx>   → content/bank.json
--      node tools/mkbankseed.mjs             → shu fayl
--
--  Hammasi 'draft' holatida yoziladi va FOYDALANUVCHIGA KO'RINMAYDI.
--  Sababi: javob kaliti hujjatda matn bilan berilmagan, u variant
--  yonidagi yashil nuqtaning koordinatasidan hisoblab topilgan
--  (key_source = 'docx-geometry'). ${keyed} ta savolda o'zbekcha va
--  ruscha nuqta bir xil variantni ko'rsatdi — shuning uchun ularga
--  kalit yozilgan. Qolgan ${bank.length - keyed} tasida kalit null:
--  ikki o'lchov mos kelmadi yoki nuqta aniq satrga tushmadi.
--
--  Savolni nashr etish uchun odam admin panelda kalitni tekshiradi.
--  0004_bank.sql shuni MAJBURLAYDI: key_source = 'human' bo'lmaguncha
--  savol 'published' bo'la olmaydi.
--
--  0001, 0003, 0004 migratsiyalaridan KEYIN ishga tushiriladi.
-- ═══════════════════════════════════════════════════════════════════════

begin;

-- ── Mavzular ───────────────────────────────────────────────────────────
insert into public.topics (slug, name, sort_order) values
${TOPICS.map(([s, n, o]) => `  (${q(s)}, ${q(n)}, ${o})`).join(',\n')}
on conflict (slug) do update set name = excluded.name, sort_order = excluded.sort_order;

-- ── Savollar ───────────────────────────────────────────────────────────`);

const noRu = [];
for (const b of bank) {
  out.push(`
insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select ${q(b.ref)}, t.id, ${q(b.uz.text)},
       ${arr(b.uz.options)}, ${b.correct === null ? 'null' : b.correct}, ${b.image ? q(b.image) : 'null'}, 'draft', 'docx-geometry'
from public.topics t where t.slug = ${q(b.topic)}
on conflict (ref) do nothing;`);

  /* Tarjima variantlari soni asl savolnikiga teng bo'lishi shart
     (0004_bank.sql dagi trigger ham shuni talab qiladi). Hujjatning bir
     nechta sahifasida ruscha blokdan bitta "F3." tushib qolgan —
     bunday savol ruscha tarjimasiz yoziladi, matnni TAXMIN QILMAYMIZ.
     Bu savollar baribir kalitsiz va 'draft' — odam ikkalasini birga
     tuzatadi. */
  if (b.uz.options.length !== b.ru.options.length) { noRu.push(b.ref); continue; }
  out.push(`insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', ${q(b.ru.text)}, ${arr(b.ru.options)}
from public.questions where ref = ${q(b.ref)}
on conflict (question_id, lang) do nothing;`);
}

out.push(`
commit;
`);

writeFileSync('supabase/seed/0005_bank.sql', out.join('\n'));
console.log(`→ supabase/seed/0005_bank.sql`);
console.log(`   savol: ${bank.length}, kalit bilan: ${keyed}, kalitsiz: ${bank.length - keyed}`);
console.log(`   rasm bilan: ${bank.filter(b => b.image).length}`);
if (noRu.length) console.log(`   ruscha tarjimasiz: ${noRu.length} (${noRu.join(', ')})`);
