/* ─────────────────────────────────────────────────────────────────────────
   SAVOLLARNI SQL SEED'GA AYLANTIRISH

   Ishga tushirish:  node tools/mkseed.mjs
   Chiqish:          supabase/seed/0002_questions.sql

   Nima uchun generator, qo'lda yozilgan SQL emas: savollar hozir
   `src/Main.dc.html` dagi QUESTIONS massivida, rus tarjimalari esa
   `src/i18n-ru.js` lug'atida. Ikkisini qo'lda SQL'ga ko'chirish bir
   marta ishlaydi va keyin darhol eskiradi. Generator esa har doim
   manbadagi holatni beradi.

   Savollar DB'ga ko'chgach bu skript KERAK BO'LMAYDI — u faqat bir
   martalik ko'chirish uchun (REJA.md Faza 2). Shundan keyin manba DB
   bo'ladi va lug'atdagi savol tarjimalari o'sha yerga ko'chadi.
   ───────────────────────────────────────────────────────────────────── */

import { readFileSync, writeFileSync, mkdirSync } from 'fs';
import { join } from 'path';

const SRC = 'src';
const OUT_DIR = join('supabase', 'seed');
const OUT = join(OUT_DIR, '0002_questions.sql');

/* ── 1. Manbadan QUESTIONS massivini olish ───────────────────────────── */
/* Qavslarni hisoblab kesamiz: satr va izohlar chetlab o'tiladi, aks holda
   savol matnidagi qavs ("(1-guruh)") hisobni buzadi. */
function extractArray(code, marker) {
  const i = code.indexOf(marker);
  if (i === -1) throw new Error(`[seed] "${marker}" topilmadi`);
  const open = code.indexOf('[', i);
  let depth = 0, st = 'code';
  for (let k = open; k < code.length; k++) {
    const c = code[k], n = code[k + 1];
    if (st === 'code') {
      if (c === '"') st = 'dq';
      else if (c === "'") st = 'sq';
      else if (c === '/' && n === '/') st = 'lc';
      else if (c === '/' && n === '*') st = 'bc';
      else if (c === '[') depth++;
      else if (c === ']' && --depth === 0) return code.slice(open, k + 1);
    }
    else if (st === 'dq') { if (c === '\\') k++; else if (c === '"') st = 'code'; }
    else if (st === 'sq') { if (c === '\\') k++; else if (c === "'") st = 'code'; }
    else if (st === 'lc') { if (c === '\n') st = 'code'; }
    else if (st === 'bc') { if (c === '*' && n === '/') { k++; st = 'code'; } }
  }
  throw new Error('[seed] massiv yopilmadi');
}

const design = readFileSync(join(SRC, 'Main.dc.html'), 'utf8');
const questions = new Function(`return ${extractArray(design, 'const QUESTIONS = [')};`)();

/* ── 2. Rus lug'atini olish ──────────────────────────────────────────── */
const ruSrc = readFileSync(join(SRC, 'i18n-ru.js'), 'utf8');
const ru = new Function('window', `${ruSrc}; return window.nzRu;`)({});

/* ── 3. Mavzular ─────────────────────────────────────────────────────── */
/* Slug lotin harflarga keltiriladi: o'zbek harflari (ʻ, ʼ) va kirill
   emas, faqat [a-z0-9-] — URL va kalit sifatida ishlatish uchun. */
const SLUG_MAP = { 'ʻ': '', 'ʼ': '', '’': '', "'": '', 'ʼ': '' };
function slugify(name) {
  return name
    .split('').map(ch => (ch in SLUG_MAP ? SLUG_MAP[ch] : ch)).join('')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

const topics = [];
for (const q of questions) {
  if (!topics.some(t => t.name === q.topic)) {
    topics.push({ name: q.topic, slug: slugify(q.topic), order: topics.length + 1 });
  }
}
for (const t of topics) {
  if (!t.slug) throw new Error(`[seed] "${t.name}" uchun slug bo'sh chiqdi`);
}

/* ── 4. SQL ──────────────────────────────────────────────────────────── */
const q = s => "'" + String(s).replace(/'/g, "''") + "'";
const arr = a => 'array[' + a.map(q).join(', ') + ']';

let sql = `-- ═══════════════════════════════════════════════════════════════════════
--  NAZARIY — 0002: boshlang'ich savollar (${questions.length} ta) va mavzular
--
--  BU FAYL QO'LDA TAHRIR QILINMAYDI — u generator bilan yasaladi:
--      node tools/mkseed.mjs
--  Manba: src/Main.dc.html (QUESTIONS) va src/i18n-ru.js (rus tarjimasi).
--
--  Ishga tushirish: Supabase → SQL Editor → nusxalab qo'yib "Run".
--  0001_init.sql dan KEYIN ishga tushiriladi.
--
--  Savollar darhol 'published' holatida qo'yiladi: bular ilovada
--  allaqachon ishlab turgan, tekshirilgan savollar. Yangi savollar esa
--  admin panel orqali 'draft' dan boshlanadi va to'rt ko'z qoidasidan
--  o'tadi.
-- ═══════════════════════════════════════════════════════════════════════

begin;

-- ── Mavzular ───────────────────────────────────────────────────────────
insert into public.topics (slug, name, sort_order) values
`;

sql += topics.map(t => `  (${q(t.slug)}, ${q(t.name)}, ${t.order})`).join(',\n');
sql += `
on conflict (slug) do update set name = excluded.name, sort_order = excluded.sort_order;

-- ── Savollar ───────────────────────────────────────────────────────────
`;

questions.forEach((item, i) => {
  const ref = '#' + String(i + 1).padStart(3, '0');
  const topic = topics.find(t => t.name === item.topic);
  sql += `
insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select ${q(ref)}, t.id, ${q(item.text)},
       ${arr(item.options)}, ${item.correct}, ${item.explain ? q(item.explain) : 'null'},
       ${item.sign ? q(item.sign) : 'null'}, 'published'
from public.topics t where t.slug = ${q(topic.slug)}
on conflict (ref) do nothing;
`;

  /* Rus tarjimasi — lug'atda bo'lsa. Savol matni, variantlar va izoh
     alohida kalitlar bilan saqlanadi, shuning uchun har birini alohida
     qaraymiz. Birortasi topilmasa, tarjima qo'yilmaydi: yarim tarjima
     to'liq tarjimasizdan yomonroq. */
  const rText = ru[item.text];
  const rOpts = item.options.map(o => ru[o]);
  const rExplain = item.explain ? ru[item.explain] : null;
  const complete = rText && rOpts.every(Boolean) && (!item.explain || rExplain);

  if (complete) {
    sql += `insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', ${q(rText)}, ${arr(rOpts)}, ${rExplain ? q(rExplain) : 'null'}
from public.questions where ref = ${q(ref)}
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();
`;
  } else {
    const missing = [];
    if (!rText) missing.push('savol matni');
    rOpts.forEach((v, k) => { if (!v) missing.push(`variant ${'ABCD'[k]}`); });
    if (item.explain && !rExplain) missing.push('izoh');
    sql += `-- ${ref}: rus tarjimasi to'liq emas (yo'q: ${missing.join(', ')}) — qo'yilmadi\n`;
  }
});

sql += `
commit;

-- ── Nazorat ────────────────────────────────────────────────────────────
-- Ishga tushirgandan keyin shuni bajarib tekshiring:
--   select count(*) from public.topics;                        -- ${topics.length}
--   select count(*) from public.questions;                     -- ${questions.length}
--   select count(*) from public.question_translations;          -- rus tarjimasi soni
--   select count(*) from public.published_questions;            -- ${questions.length}
`;

mkdirSync(OUT_DIR, { recursive: true });
writeFileSync(OUT, sql);

const translated = questions.filter(item =>
  ru[item.text] && item.options.every(o => ru[o]) && (!item.explain || ru[item.explain])).length;

console.log(`${OUT}`);
console.log(`  mavzular        — ${topics.length} ta (${topics.map(t => t.slug).join(', ')})`);
console.log(`  savollar        — ${questions.length} ta`);
console.log(`  rus tarjimasi   — ${translated} ta to'liq, ${questions.length - translated} ta yo'q`);
console.log(`  belgi savollari — ${questions.filter(x => x.sign).length} ta`);
