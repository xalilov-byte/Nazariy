/* ─────────────────────────────────────────────────────────────────────────
   src/Main.dc.html (dizayn manbasi)  →  www/ (Capacitor oladigan web ilova)

   Ishga tushirish:  node build.mjs

   Dizayn fayli TAHRIR QILINMAYDI. Bu skript uning nusxasini olib, faqat
   maketga xos ikki narsani moslaydi (chrome yashiriladi, ramka ekranga
   cho'ziladi) va shriftlarni offline qiladi. Har bir almashtirish
   assert bilan tekshiriladi — manba o'zgarsa, skript jim qolmay yiqiladi.
   ───────────────────────────────────────────────────────────────────── */

import { readFileSync, writeFileSync, mkdirSync, copyFileSync, rmSync } from 'fs';
import { join } from 'path';

const SRC = 'src';
const OUT = 'www';

const src = readFileSync(join(SRC, 'Main.dc.html'), 'utf8');

function must(hay, needle, what) {
  const n = hay.split(needle).length - 1;
  if (n !== 1) throw new Error(`[build] "${what}" ${n} marta topildi (1 kutilgan). Manba o'zgargan — build.mjs yangilansin.`);
}

/* ── 1. Bo'laklarni ajratish ─────────────────────────────────────────── */
/* Diqqat: CSS izohlarining ichida ham "<style>" so'zi uchraydi, shuning
   uchun split() emas, birinchi ochilish + birinchi yopilish kesimi. */
const cssStart = src.indexOf('<style>') + '<style>'.length;
const cssEnd = src.indexOf('</style>', cssStart);
if (cssStart < 8 || cssEnd < 0) throw new Error('[build] <style> bloki topilmadi');
const styleCss = src.slice(cssStart, cssEnd);

let markup = src.split('</helmet>')[1].split('<script type="text/x-dc"')[0];
markup = markup.replace(/<\/x-dc>\s*$/, '').trim();

const logic = src.split('data-dc-script')[1].split('>').slice(1).join('>').split('</script>')[0];

/* ── 2. Maketni qurilma ekraniga moslash (klass qo'shish) ────────────── */
const T = [
  ['maket chromi (Mini App / Web sayt / Admin)',
   '<div style="display:flex;align-items:center;justify-content:space-between;gap:12px;padding:14px 20px;position:sticky;top:0;z-index:50;background:var(--background);border-bottom:1px solid var(--hairline)">',
   '<div class="nz-chrome" style="display:none">'],

  ['markazlashtiruvchi o\'ram',
   '<div style="display:flex;justify-content:center;padding:24px 16px 48px">',
   '<div class="nz-appwrap" style="display:flex;justify-content:center;padding:24px 16px 48px">'],

  ['telefon ramkasi',
   '<div style="width:390px;max-width:100%;min-height:800px;background:var(--background);border:1px solid var(--hairline);border-radius:28px;box-shadow:var(--shadow);overflow:hidden;position:relative;display:flex;flex-direction:column">',
   '<div class="nz-frame" style="width:390px;max-width:100%;min-height:800px;background:var(--background);border:1px solid var(--hairline);border-radius:28px;box-shadow:var(--shadow);overflow:hidden;position:relative;display:flex;flex-direction:column">'],

  ['ekranlar maydoni',
   '<div style="flex:1;overflow:hidden;display:flex;flex-direction:column">',
   '<div class="nz-screens" style="flex:1;overflow:hidden;display:flex;flex-direction:column">'],

  ['test ekrani maydoni',
   '<sc-if value="{{ quizOn }}" hint-placeholder-val="{{ false }}">\n      <div style="flex:1;display:flex;flex-direction:column;background:var(--background)">',
   '<sc-if value="{{ quizOn }}" hint-placeholder-val="{{ false }}">\n      <div class="nz-screens-quiz" style="flex:1;display:flex;flex-direction:column;background:var(--background)">'],

  ['Pro ekrani maydoni',
   '<sc-if value="{{ proOn }}" hint-placeholder-val="{{ false }}">\n      <div style="flex:1;display:flex;flex-direction:column;background:var(--background)">',
   '<sc-if value="{{ proOn }}" hint-placeholder-val="{{ false }}">\n      <div class="nz-screens-quiz" style="flex:1;display:flex;flex-direction:column;background:var(--background)">'],

  ['pastki tab paneli',
   '<div style="position:absolute;left:0;right:0;bottom:0;height:68px;background:var(--surface);border-top:1px solid var(--hairline);display:grid;grid-template-columns:repeat(4,1fr);align-items:center">',
   '<div class="nz-nav" style="position:absolute;left:0;right:0;bottom:0;height:68px;background:var(--surface);border-top:1px solid var(--hairline);display:grid;grid-template-columns:repeat(4,1fr);align-items:center">'],
];

for (const [what, from, to] of T) {
  must(markup, from, what);
  markup = markup.replace(from, to);
}

/* ── 3. Offline shriftlar ────────────────────────────────────────────── */
const FONTS = [
  ['Manrope', 'manrope', [500, 600, 700, 800]],
  ['Space Grotesk', 'space-grotesk', [600, 700]],
];
const SUBSETS = ['latin', 'latin-ext'];

rmSync(OUT, { recursive: true, force: true });
mkdirSync(join(OUT, 'fonts'), { recursive: true });

let fontCss = '';
for (const [family, slug, weights] of FONTS) {
  for (const w of weights) {
    for (const sub of SUBSETS) {
      const file = `${slug}-${sub}-${w}-normal.woff2`;
      copyFileSync(join('node_modules', '@fontsource', slug, 'files', file), join(OUT, 'fonts', file));
      fontCss += `@font-face{font-family:'${family}';font-style:normal;font-weight:${w};font-display:swap;src:url(./fonts/${file}) format('woff2')}\n`;
    }
  }
}

/* ── 4. index.html ───────────────────────────────────────────────────── */
const runtime = readFileSync(join(SRC, 'runtime.js'), 'utf8');
const shellCss = readFileSync(join(SRC, 'shell.css'), 'utf8');
const bootstrap = readFileSync(join(SRC, 'bootstrap.js'), 'utf8');

const html = `<!DOCTYPE html>
<html lang="uz">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">
<meta name="theme-color" content="#F5F3FF">
<meta name="color-scheme" content="light dark">
<title>Nazariy</title>
<style>
${fontCss}</style>
<style>
${styleCss}</style>
<style>
${shellCss}</style>
</head>
<body>
<div id="nz-root"></div>
<template id="nz-tpl">
${markup}
</template>
<script>
${runtime}
</script>
<script>
${logic}
</script>
<script>
${bootstrap}
</script>
</body>
</html>
`;

/* ── 5. Nazorat: kesish paytida hech narsa tushib qolmadimi ──────────── */
for (const need of ['.nz-card-reyting{', '.nz-card-hafta{', 'url(./reyting-bg.jpg)', 'url(./hafta-bg.jpg)',
                    'class Component extends DCLogic', 'nz-nav', 'nz-frame', 'renderVals()']) {
  if (html.indexOf(need) === -1) throw new Error(`[build] yig'ilgan faylda "${need}" yo'q — kesish noto'g'ri`);
}

writeFileSync(join(OUT, 'index.html'), html);
for (const img of ['reyting-bg.jpg', 'hafta-bg.jpg']) copyFileSync(join(SRC, img), join(OUT, img));

const kb = n => (n / 1024).toFixed(0) + ' KB';
console.log(`www/index.html — ${kb(html.length)}`);
console.log(`www/fonts     — ${FONTS.reduce((a, f) => a + f[2].length, 0) * SUBSETS.length} ta woff2`);
console.log('www/*.jpg     — 2 ta fon surati');
