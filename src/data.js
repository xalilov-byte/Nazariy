/* ─────────────────────────────────────────────────────────────────────────
   SAVOLLAR MANBASI — bazadan olish, qurilmada saqlash, offline ishlash

   ASOSIY QAROR: ilova bazaga BOGʻLIQ EMAS.

   APK ichida savollar toʻplami allaqachon bor (dizayn faylidagi QUESTIONS
   massivi). Bu qatlam uni ALMASHTIRADI — lekin faqat almashtirishga
   haqiqatan muvaffaq boʻlsa. Ya'ni:

     · internet yoʻq            → APK ichidagi toʻplam bilan ishlaydi
     · baza hali sozlanmagan    → APK ichidagi toʻplam bilan ishlaydi
     · baza javob bermadi       → oxirgi saqlangan nusxa, boʻlmasa APK'dagi
     · hammasi yaxshi           → bazadagi eng yangi savollar

   Shuning uchun bazani sozlash ilovani ishga tushirish uchun SHART EMAS —
   u faqat savollarni markazdan boshqarish imkonini beradi.

   NIMA UCHUN QURILMADA SAQLANADI: ilovaning asosiy kuchi offline ishlash.
   Bir marta yuklab olingan savollar keyin internetsiz ham ishlaydi.
   ───────────────────────────────────────────────────────────────────── */

(function () {
  const CACHE_KEY = 'nz-questions';
  const CACHE_VERSION = 1;
  const TIMEOUT_MS = 8000;
  /* Saqlangan nusxa shu muddatdan yosh boʻlsa, tarmoqqa UMUMAN
     chiqilmaydi. Sabab: savollar bazasi kuniga bir necha marta
     oʻzgarmaydi, ilova esa kuniga bir necha marta ochiladi. Har
     ochilishda soʻrov yuborish — behuda trafik va batareya, sekin
     internetda esa ilovaning birinchi soniyalarini ogʻirlashtiradi. */
  const FRESH_MS = 6 * 60 * 60 * 1000;   // 6 soat

  const cfg = window.nzSupabase || null;     // build.mjs joylashtiradi

  /* Holat — sozlamalar yoki diagnostika uchun:
       bundled — APK ichidagi toʻplam
       cache   — qurilmada saqlangan nusxa
       live    — bazadan hozir olingan
       error   — bazaga murojaat muvaffaqiyatsiz (toʻplam oʻzgarmadi) */
  let status = 'bundled';
  let raw = null;            // { rows, ru }  — bazadan kelgani

  function log(msg) {
    // Konsolga faqat muhim narsa: ishlab chiqishda foydali, foydalanuvchiga
    // koʻrinmaydi.
    try { console.info('[nzData] ' + msg); } catch (e) {}
  }

  /* ── Qurilmada saqlash ─────────────────────────────────────────────── */
  function readCache() {
    try {
      const s = localStorage.getItem(CACHE_KEY);
      if (!s) return null;
      const d = JSON.parse(s);
      if (!d || d.v !== CACHE_VERSION || !Array.isArray(d.rows)) return null;
      return d;
    } catch (e) { return null; }
  }

  function writeCache(rows, ru) {
    try {
      localStorage.setItem(CACHE_KEY, JSON.stringify({
        v: CACHE_VERSION, at: Date.now(), rows: rows, ru: ru || {},
      }));
    } catch (e) {
      // Joy yetmasa (localStorage ~5 MB) — saqlamaymiz, ilova baribir
      // ishlaydi, faqat keyingi ochilishda yana bazaga murojaat qiladi.
      log('saqlab boʻlmadi: ' + (e && e.name));
    }
  }

  /* ── Bazadan olish ─────────────────────────────────────────────────── */
  async function get(path) {
    const url = cfg.url + '/rest/v1/' + path;
    const ctrl = typeof AbortController !== 'undefined' ? new AbortController() : null;
    const timer = ctrl ? setTimeout(() => ctrl.abort(), TIMEOUT_MS) : null;
    try {
      const res = await fetch(url, {
        headers: { apikey: cfg.publishableKey, Accept: 'application/json' },
        signal: ctrl ? ctrl.signal : undefined,
      });
      if (!res.ok) throw new Error('HTTP ' + res.status);
      return await res.json();
    } finally {
      if (timer) clearTimeout(timer);
    }
  }

  async function fetchAll() {
    // Savollar va rus tarjimalari — ikki soʻrov. Koʻrinish (view) FK
    // ma'lumotini saqlamaydi, shuning uchun ichma-ich select ishlamaydi.
    const rows = await get(
      'published_questions?select=id,ref,text,options,correct,explain,sign,topic_name,sort_order' +
      '&order=sort_order.asc,ref.asc');
    if (!Array.isArray(rows) || !rows.length) throw new Error('bazada nashr etilgan savol yoʻq');

    let ru = {};
    try {
      const tr = await get('question_translations?select=question_id,text,options,explain&lang=eq.ru');
      if (Array.isArray(tr)) tr.forEach(t => { ru[t.question_id] = t; });
    } catch (e) {
      // Tarjima olinmasa savollar baribir oʻzbekcha ishlaydi.
      log('rus tarjimalari olinmadi: ' + (e && e.message));
    }
    return { rows: rows, ru: ru };
  }

  /* ── Ilovaning savol bankini almashtirish ──────────────────────────── */
  /* QUESTIONS, ALL_INDICES va SIGN_INDICES dizayn faylida const, lekin
     massiv — ichidagini almashtirish mumkin. Shu yoʻl tanlangani uchun
     dizayn mantiqida birorta joy oʻzgartirilmadi: u qanday ishlagan
     boʻlsa, shundayligicha ishlaydi, faqat bank boshqa manbadan keladi. */
  function toItem(row, ru, lang) {
    const t = (lang === 'ru' && ru[row.id]) ? ru[row.id] : null;
    return {
      topic: row.topic_name,
      text: t ? t.text : row.text,
      options: (t && Array.isArray(t.options) && t.options.length === 4) ? t.options : row.options,
      correct: row.correct,
      explain: t ? (t.explain || row.explain) : row.explain,
      sign: row.sign || undefined,
    };
  }

  function swap(items) {
    if (typeof QUESTIONS === 'undefined') return false;
    QUESTIONS.length = 0;
    items.forEach(x => QUESTIONS.push(x));

    ALL_INDICES.length = 0;
    QUESTIONS.forEach((_, i) => ALL_INDICES.push(i));

    SIGN_INDICES.length = 0;
    QUESTIONS.forEach((q, i) => { if (q.sign) SIGN_INDICES.push(i); });
    return true;
  }

  window.nzData = {
    status: function () { return status; },
    count: function () { return (typeof QUESTIONS === 'undefined') ? 0 : QUESTIONS.length; },

    /* Joriy til uchun bankni qayta yigʻadi (til almashganda chaqiriladi).
       Bazadan maʼlumot kelmagan boʻlsa hech narsa qilmaydi — APK ichidagi
       toʻplam oʻz oʻrnida qoladi. */
    applyLang: function (lang) {
      if (!raw) return false;
      return swap(raw.rows.map(r => toItem(r, raw.ru, lang)));
    },

    /* Bazadan olib, bankni almashtiradi.
       onSwap — almashtirish amalga oshsa chaqiriladi (ekranni qayta
       chizish uchun). canSwap — hozir almashtirish xavfsizmi (test
       davomida bank oʻzgarsa, indekslar buziladi). */
    sync: async function (lang, canSwap, onSwap) {
      // 1) Avval saqlangan nusxa — darhol va tarmoqsiz.
      const cached = readCache();
      if (cached && canSwap()) {
        raw = { rows: cached.rows, ru: cached.ru || {} };
        if (swap(cached.rows.map(r => toItem(r, raw.ru, lang)))) {
          status = 'cache';
          log('saqlangan nusxadan ' + cached.rows.length + ' savol');
          onSwap();
        }
      }

      // 2) Keyin bazadan — yangilanish bo'lsa oladi.
      if (!cfg || !cfg.url || !cfg.publishableKey) {
        log('baza sozlanmagan — APK ichidagi toʻplam ishlatiladi');
        return status;
      }
      if (cached && cached.at && (Date.now() - cached.at) < FRESH_MS) {
        log('saqlangan nusxa yangi — tarmoqqa chiqilmadi');
        return status;
      }
      try {
        const got = await fetchAll();
        writeCache(got.rows, got.ru);
        raw = got;
        if (canSwap()) {
          if (swap(got.rows.map(r => toItem(r, got.ru, lang)))) {
            status = 'live';
            log('bazadan ' + got.rows.length + ' savol');
            onSwap();
          }
        } else {
          // Test davom etyapti — yangi bank keyingi ochilishda qoʻllanadi
          // (saqlangan nusxa allaqachon yozildi).
          status = 'cache';
          log('test davom etyapti — yangilanish keyingi safar qoʻllanadi');
        }
      } catch (e) {
        if (status === 'bundled') status = 'error';
        log('bazaga ulanib boʻlmadi: ' + (e && e.message) + ' — mavjud toʻplam saqlanadi');
      }
      return status;
    },
  };
})();
