/* ─────────────────────────────────────────────────────────────────────────
   src/progress.js — qurilma xotirasining tekshiruvi

   Bu qatlam `localStorage` dan o'qiydi, ya'ni ISHONCHSIZ manbadan:
   foydalanuvchi uni brauzer konsolidan qo'lda o'zgartirishi mumkin, eski
   versiya esa boshqa shakldagi ma'lumot qoldirishi mumkin. Buzilgan bitta
   maydon tufayli ilova ochilmay qolmasligi kerak.

   Ishga tushirish:  npm test
   ───────────────────────────────────────────────────────────────────── */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import fs from 'node:fs';

const SRC = fs.readFileSync(new URL('../src/progress.js', import.meta.url), 'utf8');
const KEY = 'nz-progress';

/* node:vm boshqa realm — u yerda yaratilgan massiv host'dagi Array'dan
   meros olmaydi va deepEqual prototip bo'yicha farq ko'radi. JSON orqali
   o'tkazish qiymatni o'zgartirmaydi, faqat shu farqni olib tashlaydi. */
const plain = x => JSON.parse(JSON.stringify(x));

function env(saved) {
  const store = new Map();
  if (saved !== undefined) store.set(KEY, typeof saved === 'string' ? saved : JSON.stringify(saved));

  const ctx = {
    window: {},
    localStorage: {
      getItem: k => (store.has(k) ? store.get(k) : null),
      setItem: (k, v) => { store.set(k, String(v)); },
      removeItem: k => { store.delete(k); },
    },
    setTimeout, clearTimeout,
    console: { info() {}, warn() {}, error() {} },
    crypto: globalThis.crypto,
    addEventListener() {},
    document: { addEventListener() {}, visibilityState: 'visible' },
  };
  vm.createContext(ctx);
  vm.runInContext(SRC, ctx);
  return { p: ctx.window.nzProgress, disk: () => JSON.parse(store.get(KEY) || 'null') };
}

/* Bugungi kunda javob berilgan deb ko'rsatish uchun — sane() `day` ni
   satr sifatida oladi, kunlik hisoblagichlar esa boshqa kunda nolga
   tushadi. Umrbod hisoblagichlar bunga bog'liq emas. */
function saqlangan(x) {
  return Object.assign({
    v: 1, points: 0, marathonBest: 0,
    totalAnswered: 0, totalCorrect: 0, totalExams: 0,
    streak: 0, longest: 0, lastActiveDay: null,
    topics: {}, wrong: [], saved: [], day: null,
    answered: 0, exams: 0, signs: [], tasks: [],
    soundOn: null, notifOn: null,
  }, x);
}


test('bo\'sh xotira: hech qanday raqam o\'ylab topilmaydi', () => {
  const { p } = env();
  const st = p.stats();
  assert.equal(st.answered, 0);
  assert.equal(st.exams, 0);
  assert.equal(st.accuracy, null, '0 javobdan foiz chiqarib bo\'lmaydi — "0%" yolgʻon boʻlardi');
  assert.deepEqual(plain(p.topicStats()), []);
});


test('mavzu kesimi javoblardan yigʻiladi', () => {
  const { p } = env();
  for (let i = 0; i < 4; i++) p.answered({ ref: '#00' + i, topic: 'Svetofor', correct: i < 3 });
  for (let i = 0; i < 4; i++) p.answered({ ref: '#01' + i, topic: 'Belgilar', correct: false });

  const t = p.topicStats();
  assert.equal(t.length, 2);
  assert.deepEqual(plain(t.map(x => [x.name, x.pct])), [['Belgilar', 0], ['Svetofor', 75]],
    'eng zaif mavzu birinchi turishi kerak');
  assert.equal(p.stats().topicsTouched, 2);
});


test('kam javob berilgan mavzu ko\'rsatilmaydi — 1 ta savol tasodif', () => {
  const { p } = env();
  p.answered({ ref: '#001', topic: 'Svetofor', correct: false });
  p.answered({ ref: '#002', topic: 'Svetofor', correct: false });
  assert.deepEqual(plain(p.topicStats()), [], '2 ta javobdan "0%" chiqarish ma\'lumot emas');

  p.answered({ ref: '#003', topic: 'Svetofor', correct: true });
  assert.equal(p.topicStats().length, 1);
  assert.equal(p.topicStats()[0].pct, 33);
});


test('mavzusiz javob hisobni buzmaydi', () => {
  const { p } = env();
  p.answered({ ref: '#001', correct: true });
  p.answered({ ref: '#002', topic: '', correct: true });
  p.answered({ ref: '#003', topic: null, correct: true });
  assert.deepEqual(plain(p.topicStats()), []);
  assert.equal(p.stats().answered, 3, 'umumiy hisob baribir yurishi kerak');
});


test('buzilgan mavzu yozuvlari tashlanadi', () => {
  /* Foydalanuvchi localStorage'ni qo'lda tahrirlashi mumkin. */
  const { p } = env(saqlangan({
    topics: {
      'Yaxshi': [10, 7],
      'Toʻgʻri javob koʻp': [5, 50],     // 1000% chiqardi
      'Massiv emas': 42,
      'Uzunligi notoʻgʻri': [3],
      'Manfiy': [-5, -2],
      ['x'.repeat(61)]: [10, 5],          // juda uzun nom
    },
  }));

  const t = p.topicStats();
  assert.deepEqual(plain(t.map(x => x.name)), ['Yaxshi', 'Toʻgʻri javob koʻp']);
  assert.equal(t.find(x => x.name === 'Toʻgʻri javob koʻp').pct, 100,
    'toʻgʻri javob soni umumiy sondan katta boʻlolmaydi');
});


test('topics butunlay yoʻq boʻlsa ham ochiladi (eski saqlangan holat)', () => {
  const eski = saqlangan({ totalAnswered: 12, totalCorrect: 9 });
  delete eski.topics;
  const { p } = env(eski);
  assert.deepEqual(plain(p.topicStats()), []);
  assert.equal(p.stats().answered, 12, 'eski progress yoʻqolmasligi kerak');
});


test('buzilgan JSON: ilova ochiladi, progress noldan boshlanadi', () => {
  const { p } = env('{bu json emas');
  assert.equal(p.stats().answered, 0);
  assert.deepEqual(plain(p.topicStats()), []);
});


test('umrbod hisoblagichlar va aniqlik', () => {
  const { p } = env();
  for (let i = 0; i < 10; i++) p.answered({ ref: '#' + i, topic: 'Svetofor', correct: i < 7 });
  p.examFinished();

  const st = p.stats();
  assert.equal(st.answered, 10);
  assert.equal(st.correct, 7);
  assert.equal(st.accuracy, 70);
  assert.equal(st.exams, 1);
});


test('streak birinchi javobda 1 dan boshlanadi', () => {
  const { p } = env();
  p.answered({ ref: '#001', topic: 'Svetofor', correct: true });
  assert.equal(p.streak(), 1);
  assert.equal(p.stats().longest, 1);
  // Bir kunda ikkinchi javob streak'ni oshirmaydi.
  p.answered({ ref: '#002', topic: 'Svetofor', correct: true });
  assert.equal(p.streak(), 1);
});


test('reset(): hammasi tozalanadi, mavzular ham', () => {
  const { p, disk } = env();
  for (let i = 0; i < 5; i++) p.answered({ ref: '#' + i, topic: 'Svetofor', correct: true });
  p.flush();
  assert.ok(disk(), 'diskka yozilgan boʻlishi kerak');

  p.reset();
  assert.equal(p.stats().answered, 0);
  assert.deepEqual(plain(p.topicStats()), []);
  assert.equal(disk(), null);
});
