# Nazariy — ishlab chiqish rejasi

Bu hujjat loyihaning **dizayndan keyingi** bosqichini boshqaradi. Maqsad:
admin panel orqali savollarni boshqarish, saytni tugatish, Play Market'ga
chiqish, Telegram Web App sifatida ishlash va uchala ilovani bitta hisob
ostida bog'lash.

Hujjat tartibi: avval **hozir nima bor** (aniq faktlar), keyin **asosiy
arxitektura qarori**, keyin **bosqichlar**. Har bir bosqichning "tayyor"
mezoni bor — mezon bajarilmasa bosqich tugagan hisoblanmaydi.

---

## 1. Hozirgi holat — aniq manzara

### Bor narsalar

| Narsa | Holati | Manba |
|---|---|---|
| Dizayn (barcha ekranlar) | ✅ Tugallangan | `src/Main.dc.html` (3634 qator) |
| Render runtime | ✅ Ishlaydi | `src/runtime.js` (187 qator, `sc-if` / `sc-for` / `{{ }}`) |
| Android APK | ✅ Yig'iladi | Capacitor 8, `uz.nazariy.app`, minSdk 24, target 36 |
| CI (APK/AAB) | ✅ Ishlaydi | `.github/workflows/android.yml` |
| Admin panel **dizayni** | ✅ Tugallangan | `valsAnalytics()`, `valsManage()` |
| To'lov oqimi **dizayni** | ✅ Tugallangan | Stars, Click, Payme, Uzum, UZCARD/HUMO |

Foydalanuvchi ilovasining tablari: `home`, `tasks`, `league`, `profile`.
Admin ikki rejimda: `analytics` (Tahlil) va `manage` (Boshqaruv).

### Yo'q narsalar — bu rejaning ish maydoni

1. **Backend yo'q.** Kodda bitta ham `fetch()`, `localStorage` yoki
   `IndexedDB` yo'q — buni tekshirib ko'rdim, nol marta uchraydi.
2. **Hech narsa saqlanmaydi.** Barcha holat `state` ichida, xotirada.
   Ilova yopilsa — ballar, streak, xatolar ro'yxati, saqlangan savollar,
   hammasi nolga qaytadi.
3. **Savollar kodga yozib qo'yilgan.** `QUESTIONS` massivida **10 ta**
   savol bor. README'da esa "700+ savol" deb yozilgan — bu hozircha
   marketing matni, haqiqat emas.
4. **Admin paneldagi ma'lumot butunlay mock.** `ADMIN_QUESTIONS` (8 ta),
   `ADMIN_USERS` (8 ta), `AUDIT_SEED` (5 ta), `DAU_90` — barchasi
   namunaviy konstantalar. Tugmalar `state`'ni o'zgartiradi, lekin ilova
   yopilsa yo'qoladi.
5. **Hisob (auth) yo'q.** Foydalanuvchi kim ekani ma'lum emas.
6. **Sayt yo'q.** Faqat APK ichidagi web ilova bor.

### Xavfsizlik: admin panel ilova ichida edi ✅ TUZATILDI

`src/Main.dc.html:282` da shunday qator bor:

```html
<button onClick="{{ showAdmin }}" style="{{ tabAdminStyle }}">Admin</button>
```

Ya'ni **admin panel foydalanuvchi ilovasining ichida** edi va unga oddiy
tugma bilan kirilardi. O'sha paytda bu zararsiz edi (ma'lumot mock),
lekin admin panel haqiqiy API'ga ulangandan keyin to'g'ridan-to'g'ri
teshik bo'lardi: APK'ni ochgan har bir odam admin ekranlarini ko'radi va
so'rovlarni qo'lda yuborib ko'rishga urinadi.

**Bajarildi (Faza 0):** dizayn manbasi o'zgartirilmadi — `build.mjs`
mobil va sayt build'ida admin qatlamini **kesib tashlaydi**. Bu shunchaki
tugmani yashirish emas: admin markup'i, ma'lumoti va metodlari yig'ilgan
faylda umuman yo'q. Batafsil — pastdagi Faza 0 bo'limida.

---

## 2. Asosiy arxitektura qarori

### Muammo

Ilovaning hozirgi kuchli tomoni — **to'liq offline**: savollar APK ichida,
internet umuman kerak emas. Lekin admin panel orqali savol qo'shish
buning teskarisini talab qiladi: savollar serverdan kelishi kerak.

Ikkisini qarshi qo'yish shart emas.

### Yechim: versiyalangan kontent paketi

```
┌─────────────────┐
│  ADMIN PANEL    │  savol yoziladi, ko'rib chiqiladi, nashr etiladi
│  (faqat web)    │
└────────┬────────┘
         │  "nashr etish" → yangi paket versiyasi (v42)
         ▼
┌─────────────────┐
│  BACKEND + DB   │  savollar, hisoblar, progress, to'lovlar, audit
└────────┬────────┘
         │  GET /content/manifest → { version: 42, checksum, url }
         ▼
┌────────────────────────────────────────────────────┐
│  KLIENTLAR — hammasi bitta API bilan gaplashadi    │
│                                                    │
│  Android (APK)   Sayt (web)   Telegram Web App     │
│       │              │              │              │
│       └──── bitta hisob, bitta progress ───────────┘
└────────────────────────────────────────────────────┘
```

**Ishlash tartibi:**

1. APK ichida **boshlang'ich paket** turadi (masalan v1, 300 savol).
   Ilova birinchi ochilishda internetsiz ham to'liq ishlaydi.
2. Internet bo'lganda ilova `manifest`ni so'raydi. Server versiyasi
   kattaroq bo'lsa — yangi paketni yuklab olib, qurilmada saqlaydi
   (IndexedDB).
3. Shundan keyin yana offline: savollar qurilmada.
4. Progress (javoblar, ballar) navbatga yoziladi va internet paydo
   bo'lganda serverga yuboriladi.

Shu sxema beshta talabni bir vaqtda bajaradi: admin savol qo'shadi →
paket yangilanadi → uchala ilovada ko'rinadi → offline saqlanadi →
progress sinxronlanadi.

### Tavsiya etilgan stack

| Qatlam | Tanlov | Sabab |
|---|---|---|
| DB + Auth + Storage | **Supabase** (Postgres) | SQL, qatorlar darajasida xavfsizlik (RLS), bepul tarif kifoya, admin uchun tayyor |
| Server mantiq | Supabase Edge Functions (Deno) | Telegram `initData` tekshiruvi, to'lov webhook'lari, paket yig'ish |
| Admin panel | Vite + hozirgi runtime | Dizayn tayyor — uni shunchaki API'ga ulaymiz, qayta yozmaymiz |
| Sayt | Bir xil kod bazasi, boshqa build maqsadi | `build.mjs` allaqachon shunga yaqin |
| Hosting (sayt/admin) | Cloudflare Pages yoki Vercel | Bepul, tez, SSL avtomatik |

**Muqobillar:** Cloudflare Workers + D1 (arzonroq, lekin auth'ni o'zimiz
yozamiz) yoki VPS + Node/Fastify + Postgres (to'liq nazorat, eng ko'p
ish). Supabase'ni tavsiya qilaman, chunki auth, RLS va storage tayyor —
bu yakka ishlayotgan jamoa uchun bir necha hafta tejaydi.

**Diqqat:** Telegram Supabase'da tayyor auth provayderi emas. Telegram
`initData`'ni HMAC bilan tekshirib, Supabase JWT beradigan Edge Function
yozamiz (Faza 1). Bu ma'lum va sinalgan yo'l.

---

## 3. Ma'lumot modeli

Jadvallar hozirgi kodda allaqachon mavjud tushunchalarga moslangan —
yangi tushuncha o'ylab topilmadi.

### Kontent

```sql
topics            (id, name, slug, sort_order)
questions         (id, topic_id, text, options jsonb, correct, explain,
                   sign, state, author_id, updated_at,
                   key_changed_at, reviewed_by)
question_packs    (id, version, published_at, published_by,
                   checksum, size_bytes, question_count)
pack_questions    (pack_id, question_id)          -- paket tarkibi
question_stats    (question_id, attempts, correct_count,
                   dif, dis, nfd, updated_at)
```

`state` — kodda allaqachon belgilangan holat mashinasi:
`draft → review → published → archived`.

**Muhim qoida (kodda izohlangan, saqlanadi):** javob kaliti o'zgarsa,
savol qanday holatda bo'lsa ham **majburan** `review`ga qaytadi va
**boshqa odam** tasdiqlashi shart ("to'rt ko'z" qoidasi). Noto'g'ri
kalit — imtihonga tayyorlanayotgan odam uchun eng og'ir zarar.

### Foydalanuvchi

```sql
profiles          (id, tg_id, phone, name, username, avatar_url,
                   role, created_at, last_seen_at)
user_progress     (user_id, points, streak_days, streak_updated_at,
                   marathon_best)
attempts          (id, client_uuid, user_id, question_id, chosen,
                   is_correct, mode, session_id, created_at)
quiz_sessions     (id, user_id, mode, started_at, finished_at,
                   correct_count, wrong_count)
saved_questions   (user_id, question_id, created_at)
wrong_questions   (user_id, question_id, created_at)
groups            (id, name, owner_id, invite_code, created_at)
group_members     (group_id, user_id, joined_at)
```

`attempts.client_uuid` — **idempotentlik kaliti**. Offline navbatdan
ikki marta yuborilsa, ikkinchisi e'tiborsiz qoldiriladi. Progress
sinxronizatsiyasining butun ishonchliligi shu ustunga tayanadi.

`attempts` jadvali ikki vazifani bajaradi: foydalanuvchining
"Xatolarim" ro'yxati **va** admin paneldagi DIF/DIS statistikasi
(`question_stats`) — ikkisi ham bir manbadan hisoblanadi.

### Pul va boshqaruv

```sql
pricing           (id, plan, price_uzs, is_active, updated_by, updated_at)
subscriptions     (user_id, plan, status, valid_until,
                   provider, provider_ref)
payments          (id, user_id, provider, amount, currency, status,
                   provider_ref, raw_payload jsonb, created_at)
audit_log         (id, actor_id, actor_role, action, resource,
                   before, after, reason_code, ip, created_at)
```

**Rollar** kodda tayyor (`ROLES`): `owner`, `moderator`, `support`,
`auditor`. Ruxsatlar: `pro`, `points`, `block`, `anonymize`, `content`,
`publish`, `log`, `pii`.

**Sabablar kod bilan** (`REASONS`) — erkin matn emas. Kodda shunday
izohlangan: erkin matn jurnalni qidirib bo'lmaydigan qiladi. Buni
saqlaymiz: `audit_log.reason_code` — enum.

**Qoida:** har qanday yozuv amali (foydalanuvchi, savol, narx)
`audit_log`ga tushadi. Jurnalga tushmaydigan o'zgarish bo'lmasligi
kerak. Bu server tomonida majburlanadi (trigger yoki RPC), klientga
ishonilmaydi.

---

## 4. Bosqichlar

Har bosqich oldingisiga tayanadi. Tartibni o'zgartirish mumkin, lekin
Faza 0 va 1 birinchi bo'lishi shart.

### Faza 0 — Poydevor va admin'ni ajratish ✅ BAJARILDI

**Nima uchun birinchi:** admin kodi APK'da qolsa, keyingi hamma ish
xavfsizlik qarzini oshiradi.

- [x] `build.mjs` maqsadli: `--target=mobile|web|admin`
      (`npm run build` / `build:web` / `build:admin` / `build:all`)
- [x] Mobil va sayt build'ida admin qatlami **kesiladi**: markup bo'limi,
      13 ta konstanta, 5 ta funksiya, 4 ta metod — jami 22 ta nom, ularning
      izohlari bilan birga
- [x] Admin tugmasi (`src/Main.dc.html:282`) mobil build'dan chiqdi
- [x] `src/shell-admin.css` — admin uchun alohida qobiq (matn tanlanadi,
      zoom taqiqlanmaydi, telefon ramkasi yo'q)
- [x] Build o'z-o'zini tekshiradi: o'chirilgan nom qolgan kodda ishlatilsa
      yoki admin nomi mobil build'da qolsa — build yiqiladi
- [x] CI uchala maqsadni har push'da yig'adi

**Natija:**

| Ko'rsatkich | Oldin | Keyin |
|---|---|---|
| Mobil build hajmi | 254 KB | **147 KB** |
| Admin kodi APK'da | bor | **yo'q** |
| Build maqsadlari | 1 | 3 |

**Tekshirildi:** uchala build brauzerda konsol xatosiz ochiladi; mobil
ilovaning 5 ta ekrani (bosh, vazifalar, reyting, profil, test) eski
build bilan **piksel darajasida aynan bir xil**.

Repo hozircha bitta papkada qoldi (`apps/` ga bo'linmadi) — bitta manba
fayl va bitta build skripti uchun bu ortiqcha murakkablik bo'lardi.
Backend qo'shilganda qayta ko'rib chiqiladi.

### Faza 0.5 — Dizayn kamchiliklari ✅ BAJARILDI

Dizayn ko'rib chiqilgandan keyin topilgan beshta kamchilik. Ularning
to'rttasi tuzatildi; til almashtirish alohida faza sifatida pastda.

**Umumiy qoida (dizaynning o'z naqshi):** ekranda ko'rinadigan har bir
element ikki holatdan birida bo'lishi kerak — **ishlaydi**, yoki
**bosilmaydi va "Tez kunda" deb belgilangan**. Ishlamaydigan narsa
ishlaydigandek ko'rinmasligi kerak. Bu naqsh dizaynda "Guruh yaratish"
tugmasi uchun allaqachon ishlatilgan edi; endi hamma joyda.

#### 1. Ovoz va tebranish ✅

Ilgari `soundOn` faqat "Yoniq"/"O'chiq" yozuvini tanlardi — ovoz kodi
umuman yo'q edi (`AudioContext`, `navigator.vibrate` — nol marta).

`src/feedback.js` — ovoz WebAudio bilan **joyida sintez** qilinadi:

| Hodisa | Ovoz | Tebranish |
|---|---|---|
| To'g'ri javob | 784 → 1175 Hz (ko'tariluvchi) | qisqa |
| Xato javob | 196 → 165 Hz (past, to'mtoq) | uch zarb |
| Test tugadi | 1047 → 1319 → 1568 Hz | naqsh |

Ovoz fayli ataylab ishlatilmadi: `.mp3` aktivlari APK'ga 50–200 KB
qo'shardi, sintez esa nol bayt.

#### 2. Bildirishnoma ✅

`@capacitor/local-notifications` o'rnatildi, `src/notify.js` yozildi.
Har kuni 19:00 ga takroriy bildirishnoma qo'yiladi.

Uchta halollik qoidasi: plagin yo'q joyda (sayt, Telegram) sozlama
qatori **ko'rsatilmaydi**; ilova ochilishida ruxsat **so'ralmaydi**
(faqat foydalanuvchi tugmani bosganda); ruxsat berilmasa sozlama o'zi
o'chadi va sabab aytiladi.

**Play Market uchun muhim:** plagin standart holatda *aniq* alarm
qo'yadi, bu Android 12+ da `SCHEDULE_EXACT_ALARM` ruxsatini talab
qiladi, Google esa uni faqat budilnik va kalendar ilovalariga beradi.
Mashq eslatmasiga daqiqagacha aniqlik kerak emas, shuning uchun
`isExactNotification: false` qo'yildi va ruxsat birlashtirilgan
manifestdan olib tashlandi (`tools:node="remove"`).

#### 3. Vazifalar paneli ✅

Ilgari markup'da bitta ham `onClick` yo'q edi va progress qo'lda
yozilgan matn edi ("Bugun · 8/20", "184/240 belgi").

Endi `taskList(s)` — **bitta manba**, undan ko'rsatish ham, mukofot ham
oziqlanadi. Hisoblagichlar: `answeredCount`, `examsDone`,
`signsAnswered`, `tasksAwarded` (mukofot bir marta beriladi).

Bosh ekrandagi "Bugun 20 savol yech" kartasi ham shu hisoblagichdan
oziqlanadi. Bajarib bo'lmaydigan uchta vazifa "Tez kunda" holatida.

#### 4. Profil ekrani ✅

O'lchangan muammo: umumiy balandlik 1441px (ekran 844px), sozlamalar
1228px da — til almashtirish uchun uzoq scroll.

Ixcham sarlavha (avatar 80→56px, gorizontal joylashuv), sarlavhada
sozlamalarga olib boruvchi tishli g'ildirak, takroriy "Do'st taklif
qiling" kartasi olib tashlandi (Vazifalar ekranida bor).

Natija: 1441 → **1190px**, yutuqlar bo'limi endi birinchi ekran ichida,
sozlamalar bir bosishda.

#### Qolgan narsa

Hisoblagichlar **sessiya ichida** yashaydi — ilova yopilsa nolga
qaytadi. Shuning uchun "Har kun yangilanadi · 04:00 da" sarlavhasi
olib tashlandi (progress saqlanmasa kunlik yangilanish ham yo'q).
Davomiylik — Faza 4.

### Faza 0.6 — Uch til (o'zbek lotin / kirill / rus) ✅ BAJARILDI

**Uchala til to'liq ishlaydi.** Interfeysda tarjimasiz qolgan matn
yo'q — buni taxmin qilmasdan o'lchadim (pastda).

Tanlangan yechim: **manba satr bilan kalitlash**. Dizayn faylida birorta
matn kalitga almashtirilmadi (`{{ t.homeTitle }}` yo'q) — matn joyida
qoladi, tarjima chizish paytida qo'llanadi. Ikki mexanizm:

| Til | Mexanizm | Lug'at kerakmi? |
|---|---|---|
| O'zbek (lotin) | manba tili | — |
| Ўзбек (кирилл) | avtomatik transliteratsiya | **yo'q** |
| Русский | lug'at (`i18n-ru.js`) | ha |

Kirill uchun lug'at kerak emasligi eng katta tejamkorlik: yuzlab satrni
qo'lda o'girish kerak emas va **yangi matn qo'shilganda o'zi ishlaydi**.

Ulanish nuqtalari: `runtime.js` markup matnini o'giradi (binding aralash
tugunlar ham — `"{{ streak }} kun"` → `"5 кун"`), `renderVals()` chiqishi
esa `nzI18n.deep()` orqali o'tadi. Til `localStorage` da saqlanadi.

**Ikki tuzatilgan xato (transliteratsiya nozikliklari):**

1. `Yoʻl` → `Ёʻл` bo'lib qolardi; to'g'risi `Йўл`. Sabab: `yo` digrafi
   `oʻ` dan oldin tekshirilardi. `yoʻ` qoidasi qo'shildi.
2. SVG chizma yo'llari ham o'girilardi (`M9 11l3 3` → `M9 11л3 3`) —
   brauzer "Expected path command" xatosi berib, ikonkalar chizilmasdi.
   Endi qiymat shakliga qarab (kalit nomiga emas) SVG yo'llari, CSS
   qiymatlari va uslub obyektlari chetlab o'tiladi.

**Shrift — tekshirilgan va hal qilingan:**

| Shrift | Qayerda | Kirill |
|---|---|---|
| Manrope | asosiy matn | ✅ `cyrillic` + `cyrillic-ext` |
| Space Grotesk | sarlavhalar | ❌ yo'q |

Ikki topilma bu yerda muhim bo'ldi:

- O'zbek kirillidagi **`қ`, `ғ`, `ҳ` harflari `cyrillic` subsetda YO'Q** —
  ular `cyrillic-ext` da (U+049B, U+0493, U+04B3). Faqat `cyrillic`
  qo'shilsa, o'zbekchada eng ko'p uchraydigan uchta harf tushib qolardi.
- Sarlavhalar uslubi `'Space Grotesk', Manrope, …` tartibida yozilgan,
  brauzer esa zaxira shriftni **har bir belgi uchun alohida** tanlaydi —
  shuning uchun kirill harflar o'zi Manrope'ga tushadi. Qo'shimcha CSS
  shart emas (avvalgi rejadagi "sarlavhalar tizim shriftiga tushadi"
  degan xulosam noto'g'ri edi — u faqat Manrope kirilli yuklanmagan
  holatda to'g'ri).

Yana bir tuzatilgan latent xato: `@font-face` qoidalarida
`unicode-range` yo'q edi. Bir xil shrift va og'irlik uchun bir necha
fayl e'lon qilinganda ular bir-birini bekor qiladi. Endi diapazon
fontsource'ning **o'z CSS'idan o'qiladi** (qo'lda yozilsa eskiradi).

#### Rus tili — qanday tekshirildi

Tarjimani "ko'z bilan" tekshirish ishonchsiz: bitta satrni unutish oson.
Shuning uchun **avtomatik tekshiruv** yozildi: ilovaning bir xil
ekranlari avval o'zbek, keyin rus tilida chiziladi va ko'rinadigan
matn tugunlari solishtiriladi. Ikki tilda **aynan bir xil** qolgan
matn — tarjimasi yo'q.

Tekshiruv 12 ekranni (4 tab, guruh segmenti, Pro, to'lov, test va
natija) bosib o'tadi va 273 ta ko'rinadigan matnni yig'adi.

Natija: **tarjimasiz qolgan 0**, konsol xatosi 0.

Tarjima qilinmaydigan narsalar ataylab chetlab o'tiladi: raqamlar,
brendlar (Nazariy, Pro, Telegram, Click…), foydalanuvchi nomlari
(@sardor_t), havolalar va **atoqli nomlar** — odam va guruh ismi tilga
qarab o'zgarmaydi (i18n amaliyotining standart qoidasi).

Qo'shib yasaladigan satrlar (`have + "/20 savol"`) uchun `T()`
yordamchisi qo'shildi: butun natijani lug'atdan topib bo'lmaydi, shuning
uchun faqat matn bo'lagi o'giriladi — `n + "/20 " + T("savol")`.
`T()` i18n qatlami bo'lmasa matnni o'zgarmagan holda qaytaradi, ya'ni
dizayn fayli kanvasda ham ishlaydi.

Lug'atda 300 dan ortiq kalit. Demo savollari ham tarjima qilindi —
aks holda "Русский" yarim yolg'on bo'lardi. Ular DB'ga ko'chganda
(Faza 2) `question_translations` jadvaliga o'tadi va lug'atdan
chiqariladi (lug'atda alohida belgilangan).

#### Qolgan ish

- [ ] Savollar tarjimasi DB'ga ko'chirilishi (Faza 2 bilan birga)

**Admin panel faqat o'zbek tilida qoladi** — bu qaror, kamchilik emas.
U ichki ish quroli va uni faqat jamoa ishlatadi, shuning uchun uch tilda
saqlash ortiqcha yuk bo'lardi (har bir yangi admin ekrani uchun tarjima
kerak bo'lib qolardi). Lug'at faqat foydalanuvchi ilovasini qamraydi.

#### Eski reja (ma'lumot uchun)

Eng katta ish: hozir **i18n qatlami umuman yo'q**, barcha matnlar
o'zbekcha holda markup ichiga yozilgan. Sozlamalardagi "Til" qatori
`onClick: null` bilan turadi (dizaynerning o'z izohi bor: "haqiqiy til
tanlagich hali qurilmagan").

**Asosiy qulaylik:** lotin ↔ kirill **avtomatik o'giriladi**
(transliteratsiya), ya'ni qo'lda tarjima faqat **rus tili** uchun kerak.

Reja:

- [x] Interfeys tarjimasi mexanizmi (manba satr bilan kalitlash)
- [x] Lotin→kirill transliterator
- [x] `state.lang` va til tanlagich (sozlamalardagi qator ishlaydi)
- [x] Tanlangan til qurilmada saqlanadi (serverga ko'chirish — Faza 4)
- [x] Shrift subsetlari va `unicode-range` — yuqorida batafsil

**Savollar ham tarjima talab qiladi** — bu DB sxemasiga ta'sir qiladi:

```sql
questions              -- asosiy matn: o'zbek (lotin)
question_translations  (question_id, lang, text, options, explain)
                       -- faqat 'ru' uchun; kirill transliteratsiya bilan
```

Admin panelda har bir savol uchun rus tilidagi variant maydoni kerak
bo'ladi (Faza 3 ga qo'shiladi).

### Faza 1/2 — Baza sxemasi va RLS ✅ BAJARILDI

Supabase loyihasi ulandi (`supabase/config.json` — URL va publishable
kalit; ular ommaviy va git'da turishi kerak, chunki mobil ilovadan
kalitni yashirib bo'lmaydi).

**Bajarilgan:**

| Narsa | Fayl |
|---|---|
| Sxema: profillar, mavzular, savollar, tarjimalar, paketlar, audit | `supabase/migrations/0001_init.sql` |
| Boshlang'ich ma'lumot: 8 mavzu, 10 savol, 10 rus tarjimasi | `supabase/seed/0002_questions.sql` (generator yasaydi) |
| RLS va "to'rt ko'z" tekshiruvi | `supabase/tests/0001_rls.sql` |
| Seed generatori | `tools/mkseed.mjs` |
| CI: migratsiya + seed + testlar har push'da | `.github/workflows/db.yml` |

**Nima uchun RLS bu yerda eng muhim narsa:** klient publishable kalit
bilan ishlaydi va u kalit hammaga ko'rinadi — APK'ni ochgan odam uni
topadi. Ya'ni ma'lumotni kalit emas, **faqat RLS** himoya qiladi.
Shuning uchun har bir jadvalda RLS yoqilgan, standart holat "hech
kimga ruxsat yo'q", va bu **tekshiriladi** — "RLS yozdim" degan gap
yetarli emas.

**Ikki qoida klientda emas, BAZADA majburlanadi** (klient kodini
chetlab o'tish mumkin, bazani esa yo'q):

1. **To'rt ko'z** — javob kaliti o'zgarsa savol majburan ko'rib
   chiqishga qaytadi, o'zgartirgan odam o'zi nashr eta olmaydi.
2. **Jurnalga tushmaydigan o'zgarish bo'lmaydi** — audit yozuvini
   trigger qo'yadi, klient emas; jurnal o'zgartirilmaydi (UPDATE/DELETE
   siyosati yo'q).

**Qanday tekshirildi:** bu muhitdan Supabase'ga ulanib bo'lmaydi
(domen tarmoq siyosati bilan bloklangan), shuning uchun tekshiruv lokal
PostgreSQL 16 da o'tkazildi — Supabase'ning `auth` sxemasi taqlid
qilinib (`tests/_stub.sql`). O'tgan tekshiruvlar:

- anon faqat nashr etilganini ko'radi; qoralama **ko'rinmaydi**
- anon va oddiy foydalanuvchi savol qo'sha olmaydi
- foydalanuvchi **o'ziga `owner` rolini bera olmaydi**
- anon audit jurnalini va boshqalarning profilini ko'rmaydi
- moderator qo'shadi, lekin **o'z o'zgarishini o'zi nashr eta olmaydi**;
  boshqa moderator nashr etadi va `reviewed_by` unga yoziladi
- javob kaliti o'zgarsa holat `review`ga qaytadi, tasdiq bekor bo'ladi
- audit yozuvi trigger bilan tushadi va o'chirilmaydi
- ma'lumot butunligi: 3 variantli savol, diapazondan tashqari kalit va
  juda qisqa matn rad etiladi

**Sizdan kerak:** `supabase/README.md` §1 bo'yicha ikki SQL faylni
Supabase SQL Editor'da ishga tushirish va o'zingizga `owner` rolini
berish. Shundan keyin CI jonli tekshiruvni ham o'tkazadi.

#### Klient bazaga ulandi ✅

`src/data.js` — savollar manbasi. **Asosiy qaror: ilova bazaga bog'liq
emas.** APK ichidagi to'plam o'z o'rnida qoladi va faqat almashtirishga
haqiqatan muvaffaq bo'lsa almashtiriladi:

| Holat | Nima bo'ladi |
|---|---|
| Internet yo'q | APK ichidagi to'plam |
| Baza hali sozlanmagan | APK ichidagi to'plam |
| Baza javob bermadi | Oxirgi saqlangan nusxa, bo'lmasa APK'dagi |
| Hammasi yaxshi | Bazadagi eng yangi savollar |

Shuning uchun **bazani sozlash ilovani ishga tushirish uchun shart
emas** — u faqat savollarni markazdan boshqarish imkonini beradi.

Ikki muhim tafsilot:

- **Test davomida bank almashtirilmaydi.** Savol indekslari pool'ga
  bog'langan; bank o'rtada o'zgarsa foydalanuvchi boshqa savolga javob
  bergan bo'lib qoladi. Bunday holda yangilanish saqlanadi va keyingi
  ochilishda qo'llanadi.
- **Saqlangan nusxa 6 soatdan yosh bo'lsa tarmoqqa umuman chiqilmaydi.**
  Savollar bazasi kuniga bir necha marta o'zgarmaydi, ilova esa kuniga
  bir necha marta ochiladi.

Tekshirildi (brauzerda, tarmoq taqlid qilinib): baza yo'q → 10 ta
o'rnatilgan savol, xatosiz; baza javob berdi → 3 ta bazadagi savol,
belgi soni qayta hisoblandi; tarmoq uzildi → saqlangan nusxa ishladi;
test davomida yangilanish keldi → bank almashmadi, keyingi safarga
saqlandi.

#### Faza 3 — Admin panel bazaga ulandi ✅

Panel endi haqiqiy bazada ishlaydi: kirish, savollar ro'yxati, holat
o'zgartirish, javob kalitini tuzatish, ommaviy qo'shish va audit jurnali.

| Fayl | Vazifasi |
|---|---|
| `src/admin-api.js` | Supabase Auth va REST (SDK'siz, oddiy `fetch`) |
| `src/admin-boot.js` | Kirish oynasi, holat tasmasi, yozuv amallari |

Ikkalasi ham **faqat admin build'iga** kiradi — mobil build'da
`nzAdmin` 0 marta uchraydi (tekshirilgan).

**Ikki qat'iy qoida:**

1. **Namunaviy ma'lumot ko'rsatilmaydi.** Dizayndagi 8 soxta savol va 8
   soxta foydalanuvchi panel ochilishi bilan tozalanadi. Xodim soxta
   savolni haqiqiy deb o'ylab, mavjud bo'lmagan narsani tahrirlashga
   urinmasligi kerak. Baza ulanmagan bo'lsa — bo'sh ro'yxat va sabab.
2. **Holat har doim ko'rinib turadi.** Yuqoridagi tasma: kim kirgan,
   nechta savol yuklandi, xato bo'lsa nima.

**Yozuv amallari serverda bajariladi, mahalliy emas.** Sabab: baza
amalni rad etishi mumkin (huquq yo'q yoki to'rt ko'z qoidasi), interfeys
esa "o'zgardi" deb ko'rsatib turardi. Endi: server → keyin qayta o'qish.

Baza rad etganda uning **o'z xabari** ko'rsatiladi. Masalan to'rt ko'z
qoidasi ishlaganda tasmada shunday yoziladi:

> Bajarilmadi: to'rt ko'z qoidasi: o'zingiz kiritgan o'zgarishni
> o'zingiz nashr eta olmaysiz

Yo'l-yo'lakay tuzatilgan yolg'on affordans: **"Rol (demo)"
almashtirgichi**. Panel bazaga ulangandan keyin u interfeysda boshqa rol
huquqlarini ko'rsatardi, baza esa baribir haqiqiy rolni qo'llaydi (RLS).
Endi joriy rol shunchaki yoziladi.

**Tekshirildi** (Supabase javoblari taqlid qilinib): kirilmagan → kirish
oynasi va tozalangan ro'yxat; noto'g'ri parol → tushunarli xato; rol
`user` → rad etiladi; rol `owner` → bazadagi savollar (qoralama ham);
nashr etish → `PATCH questions?id=eq.…` `{state:'published'}` va qayta
o'qish; baza rad etsa → xabar tasmada; ommaviy qo'shish → `POST` bilan
`state:'draft'`, mavzu nomi id'ga o'giriladi, topilmagan mavzular
o'tkazib yuboriladi va soni aytiladi. Konsol xatosi 0.

#### Admin panelda hali ulanmagan qismlar

- **Foydalanuvchilar bo'limi** — obuna va ball jadvallari hali yo'q.
  Soxta ro'yxat ko'rsatmaslik uchun bo'sh turadi.
- **Tahlil (DIF/DIS, DAU, voronka)** — `attempts` jadvali kerak
  (Faza 4). Sarlavhada "barcha raqamlar namunaviy" deb yozilgan.
- **Narxlar** — `pricing` jadvali bor, lekin ulanmagan (Faza 7).

#### Qolgan ish (Faza 1/2 ning ikkinchi yarmi)

- [ ] Migratsiyani Supabase'ga qo'llash — **`SUPABASE_DB_URL` secret'i
      kerak** (`.github/workflows/db-apply.yml`)
- [ ] Telegram `initData` ni HMAC bilan tekshiruvchi Edge Function
      (Supabase JWT beradi) — **bot tokeni kerak**
- [ ] Telefon + SMS OTP zaxira yo'li
- [ ] Paket yig'uvchi: nashr etilgan savollardan versiyalangan JSON
      (hozircha to'g'ridan-to'g'ri `published_questions` dan o'qiladi —
      savollar soni o'sganda paket kerak bo'ladi)

#### Faza 4 (birinchi yarmi) — Progress saqlanadi ✅

Shu ishgacha ilova **hech narsani saqlamasdi**: ballar, streak,
"Xatolarim", "Saqlangan", marafon rekordi — hammasi xotirada edi va ilova
yopilishi bilan nolga qaytardi. Imtihonga tayyorlanish bir kunlik ish
emas, shuning uchun bu eng katta kamchilik edi.

| Fayl | Vazifasi |
|---|---|
| `src/progress.js` | Qurilma xotirasi, kun hisobi, streak, javoblar navbati |

**Uch qaror:**

1. **Saqlanadigani indeks emas, `ref`.** Ro'yxatlar dizaynda `QUESTIONS`
   massivi indekslari bilan ishlaydi. Indeksni diskda saqlash jimgina
   buzilardi: bazaga o'rtaga bitta savol qo'shilsa indeks 4 boshqa
   savolga ko'rsata boshlaydi va odam o'zi saqlamagan savolni ko'radi.
   Shu sababli har bir savolga barqaror `ref` berildi (`#001`…) va u
   bazadagi `questions.ref` bilan **aynan bir xil** — seed generatori
   endi refni dizayn faylidan oladi, o'zi hisoblamaydi, ya'ni ikkisi
   ajralib keta olmaydi.
2. **Birinchi ochilishda hammasi nol.** Dizayndagi 12 480 ball, 47
   rekord, 5 kunlik streak va profildagi "1 248 / 87% / 36 / 9 kun" —
   maket uchun chizilgan raqamlar edi. O'zi ishlamagan 12 480 ballni
   ko'rgan odam undan keyingi hech qaysi raqamga ishonmaydi. Demo
   qiymatlar faqat Design Canvas'da qoldi.
3. **Kun 04:00 da almashadi, yarim kechada emas.** Kechqurun 23:50 da
   boshlab 00:10 da tugatgan odam ikki xil kunga tushib qolardi va
   streak'i buzilardi.

**Yo'l-yo'lakay tuzatilgan ikki kamchilik:**

- **Bankda yo'q `ref` yo'qolib ketardi.** Odam internetda bazadagi 500
  savoldan birini saqlab, keyin internetsiz ochsa (bank APK ichidagi 10
  savolga tushadi) — o'sha savol indeksga o'girilmaydi va keyingi
  yozuvda ro'yxatdan **butunlay** o'chib ketardi. Endi moslanmagan
  ref'lar chetga yig'iladi va yozishda qaytariladi: ko'rinmaydi, lekin
  yo'qolmaydi.
- **"Kunlik kirish" mukofoti saqlanmasdi.** U `componentDidMount`da
  beriladi, ya'ni saqlash o'rami o'rnatilishidan oldin — ilovani ochib
  javob bermasdan yopgan odam +30 ballini yo'qotardi.

**Javoblar navbati.** Har javob `client_uuid` bilan navbatga yoziladi
(`nz-attempts`, 2000 ta chegara — eng qadimgilari tashlanadi). Navbatni
bo'shatuvchi server tomoni hali yo'q (foydalanuvchi hisobi Telegram yoki
SMS orqali keladi), lekin javoblar **hozirdan** yig'ilishi kerak: aks
holda sinxronizatsiya kelganda tarix bo'sh bo'lardi.

**Nima saqlanmaydi:** javob berilayotgan test. Ilova o'rtada yopilsa test
boshidan boshlanadi — ataylab: yarim tugagan imtihonni tiklash uning
vaqt bosimini yo'qotadi.

**Tekshirildi** (brauzerda, oltita holat): birinchi ochilishda hammasi
nol; javob berib yopib qayta ochilganda ball, xatolar, saqlanganlar va
rekord joyida (diskda ref bilan, indeks bilan emas); streak — birinchi
javob 1, kecha yechilgan 4 ekranda 4 va javobdan keyin 5, uch kun
tanaffus ekranda 0 va javobdan keyin 1 (eng uzuni 9 bo'lib qoladi), bir
kunda uch javob streak'ni oshirmaydi; kun almashganda kunlik
hisoblagichlar nolga, umrbodlari va ro'yxatlar joyida; bank almashganda
`#007` to'g'ri indeksga tushadi va `#300` yo'qolmaydi; profil raqamlari
haqiqiy (10 / 70% / 1 / 5 kun); localStorage bloklanganda ilova
saqlamasdan ishlaydi. Konsol xatosi 0.

#### Faza 4 da qolgan ish

- [ ] `POST /sync/attempts` — to'plamli, idempotent (navbatni bo'shatadi)
- [ ] Ballar/streak **serverda** qayta hisoblanadi (klientga ishonilmaydi)
- [ ] Reyting: shaxsiy va guruh — hozir ro'yxat namunaviy
- [ ] `attempts` jadvali migratsiyaga qo'shiladi (admin paneldagi
      DIF/DIS ham shundan hisoblanadi)

### Faza 1 — Backend va hisob (eski reja, ma'lumot uchun)

- [ ] Supabase loyihasi, `profiles` + `user_progress` jadvallari
- [ ] RLS siyosatlari: foydalanuvchi faqat o'z qatorini ko'radi
- [ ] Telegram auth: Edge Function `initData`'ni HMAC bilan tekshiradi
      (bot tokeni bilan), Supabase JWT qaytaradi
- [ ] Telefon + SMS OTP zaxira yo'li (Telegram'i yo'q foydalanuvchi uchun)
- [ ] Hisoblarni bog'lash: bir odam Telegram va telefon bilan kirsa,
      bitta `profile` bo'lishi kerak (`tg_id` va `phone` bir qatorda)
- [ ] Admin rollari va ruxsat tekshiruvi server tomonida

**Tayyor mezoni:** uchala klientdan ham kirib, bir xil `user_id`
olinadi; RLS'ni chetlab o'tishga urinish 403 qaytaradi.

### Faza 2 — Kontent quvuri

Bu **admin panelning poydevori**. Bu bosqichsiz admin panel savol
qo'sha olmaydi.

- [ ] `topics`, `questions`, `question_packs` jadvallari
- [ ] Hozirgi 10 savolni `QUESTIONS`'dan DB'ga ko'chirish (migratsiya skripti)
- [ ] Paket yig'uvchi: `published` savollardan JSON paket + checksum
- [ ] `GET /content/manifest` va paket yuklab olish
- [ ] Klient tomoni: IndexedDB'da paketni saqlash, versiyani solishtirish,
      fon rejimida yangilash
- [ ] Boshlang'ich paketni APK ichiga joylash (offline birinchi ochilish)
- [ ] Yo'l belgilari rasmlari uchun storage (hozir `sign` faqat kalit so'z)

**Tayyor mezoni:** admin DB'da savolni `published` qiladi → paket
versiyasi oshadi → telefon internetga chiqqanda yangi savolni ko'radi →
internetni uzsak, savol hali ham joyida.

### Faza 3 — Admin panel (mukammal holatga)

Dizayn tayyor — bu bosqich uni **haqiqiy API'ga ulash**.

**Savollar bo'limi:**
- [ ] Ro'yxat: DB'dan, filtr (holat/mavzu), qidiruv, sahifalash
- [ ] Yaratish / tahrirlash / arxivlash — haqiqiy yozuv
- [ ] Holat mashinasi: `draft → review → published → archived`
- [ ] "To'rt ko'z" qoidasi: kalit o'zgarsa `review`ga qaytadi,
      o'zgartirgan odam o'zi tasdiqlay olmaydi (server majburlaydi)
- [ ] Ommaviy import: `parseBulk()` allaqachon yozilgan va yaxshi —
      qatorlab tekshiradi, bitta xato butun importni to'xtatmaydi.
      Uni serverga ko'chirish kerak (klient tekshiruviga ishonilmaydi)
- [ ] CSV eksport: `toCsv()` tayyor
- [ ] Rasm yuklash (yo'l belgilari savollari uchun)

**Tahlil bo'limi:**
- [ ] DIF/DIS/NFD haqiqiy `attempts`'dan hisoblanadi (kunlik ish)
- [ ] Savol sifati bayrog'i: `DIS < 0` → "javob kaliti xato bo'lishi
      mumkin" — bu allaqachon dizaynda bor va eng qimmatli funksiya
- [ ] DAU, voronka, kohortalar — haqiqiy ma'lumotdan

**Foydalanuvchilar bo'limi:**
- [ ] Ro'yxat, qidiruv, Pro berish/olish, ball tuzatish, bloklash
- [ ] PII (telefon) faqat `pii` ruxsati bilan ochiladi va **ochilishi
      jurnalga tushadi** (dizaynda shunday — saqlanadi)
- [ ] Anonimlashtirish (ma'lumotni o'chirish so'rovi uchun)

**Audit:**
- [ ] `audit_log` haqiqiy, o'zgartirib bo'lmaydigan (faqat INSERT)
- [ ] Filtr: kim / nima / qachon, eksport

**Tayyor mezoni:** moderator savol qo'shadi, egasi nashr etadi, har
ikki amal jurnalda ko'rinadi, telefonda yangi savol chiqadi. Moderator
o'zi o'zgartirgan kalitni o'zi tasdiqlay olmaydi.

### Faza 4 — Ilovalarni bog'lash (progress sinxronizatsiyasi)

- [ ] Klientda offline navbat: javoblar `client_uuid` bilan navbatga
- [ ] `POST /sync/attempts` — to'plamli, idempotent
- [ ] Ballar/streak serverda hisoblanadi (klientga ishonilmaydi —
      aks holda ball qalbakilashtiriladi)
- [ ] Reyting: shaxsiy va guruh (`groups`, `group_members`)
- [ ] Konflikt: `attempts` faqat qo'shiladi, shuning uchun konflikt
      deyarli yo'q; `saved_questions` uchun "oxirgi yozgan g'olib"

**Tayyor mezoni:** telefonda 10 savol yechib, saytga kirilsa — ballar,
streak va xatolar ro'yxati bir xil. Offline yechilgan javoblar internet
paydo bo'lgach serverga tushadi.

### Faza 5 — Telegram Web App

- [ ] Bot yaratish, Web App tugmasi, `initData` bilan avtomatik kirish
      (login ekrani ko'rsatilmaydi — bu Telegram'ning asosiy afzalligi)
- [ ] Telegram tema o'zgaruvchilarini o'z temamizga bog'lash
      (`themeParams`) — foydalanuvchining Telegram temasiga ergashadi
- [ ] `BackButton`, `MainButton`, `HapticFeedback`, `expand()`
- [ ] Viewport: `viewportStableHeight` (klaviatura ochilganda maket buzilmasligi)
- [ ] `CloudStorage` — kichik sozlamalar uchun
- [ ] Bot xabarlari: streak eslatmasi, kunlik vazifa
      (foydalanuvchi ruxsat bergan bo'lsa)

**Tayyor mezoni:** Telegram'da bot ochiladi, hisob avtomatik ulanadi,
telefondagi progress darhol ko'rinadi, orqaga tugmasi Telegram'ning
o'zi bilan ishlaydi.

### Faza 6 — Sayt

- [ ] Landing: nima uchun kerak, ekran suratlari (`skrinshotlar/` tayyor),
      yuklab olish tugmalari
- [ ] Web ilova: `/app` — brauzerda to'liq ishlaydigan versiya
- [ ] **Maxfiylik siyosati** — Play Market uchun majburiy
- [ ] Foydalanish shartlari, aloqa
- [ ] Ma'lumotni o'chirish so'rovi sahifasi (Play Market talabi)
- [ ] SEO, Open Graph, `sitemap.xml`
- [ ] PWA manifest (saytni telefonga o'rnatish imkoniyati)

**Tayyor mezoni:** domen ishlaydi, siyosat sahifasi ochiq URL bilan
mavjud (Play Console'ga shu havola kiritiladi).

#### Faza 6 (birinchi yarmi) — Sayt boshlandi ✅

`node tools/mksite.mjs` (yoki `npm run site`) → `dist/site/` — hostingga
shu papkani qo'yish kifoya, build mashinasi kerak emas. CI har push'da
yig'adi va `nazariy-sayt` nomi bilan yuklab olish uchun saqlaydi.

```
dist/site/
  index.html                landing + brauzerdagi ilova
  maxfiylik/                maxfiylik siyosati      ← Play MAJBURIY
  shartlar/                 foydalanish shartlari
  aloqa/                    aloqa                   ← Play MAJBURIY
  malumot-ochirish/         ma'lumotni o'chirish    ← Play MAJBURIY
  manifest.webmanifest      telefonga o'rnatish (PWA)
  og.jpg                    havola ko'rinishi (Telegram, ijtimoiy tarmoq)
  robots.txt, sitemap.xml
```

**Matn sahifalarida JS yo'q** (8–12 KB). Ilova bundle'i 259 KB —
maxfiylik siyosatini o'qish uchun odam (yoki Play Console tekshiruvchisi)
butun ilovani yuklab olmasligi kerak.

**Maxfiylik siyosati kodni tekshirib yozilgan**, umumiy shablondan
ko'chirilmagan: `localStorage` kalitlari, `fetch` chaqiruvlari va uchinchi
tomon kutubxonalari sanab chiqilgan. Hozirgi haqiqat — hisob yo'q,
analitika yo'q, reklama yo'q, xatolik hisoboti yo'q, shriftlar ichkarida
(Google Fonts'ga chiqilmaydi), internetga faqat savollarni olish uchun
chiqiladi va bu so'rovda foydalanuvchiga tegishli hech narsa
yuborilmaydi. Play "Data safety" anketasi uchun ham shu javoblar.

#### Yo'l-yo'lakay tuzatilgan uchta yolg'on

1. **"700+ savol · 18 mavzu · 240 belgi"** — aslida 10 / 8 / 3. Bu
   raqamlar landing'da (ommaviy sahifa) va ilovaning bosh ekranida
   qo'lda yozilgan edi. Endi ular **bankdan hisoblanadi**, ya'ni har
   doim to'g'ri va kontent qo'shilganda o'zi o'sadi — bazadan bank
   yangilanganda ham.
2. **`t.me/NazariyBot`** — bot hali yaratilmagan, ya'ni landing'ning
   ASOSIY tugmasi o'lik havola edi. Endi Telegram tugmalari
   `site.config.json` dagi `telegramBot` bo'sh bo'lsa **umuman
   ko'rsatilmaydi**, asosiy amal "Brauzerda ochish" bo'ladi va badge
   "Telegram Mini App" o'rniga "Avtotest" deydi. Bot nomi qo'yilsa
   hammasi qaytadi (ikkala holat ham tekshirilgan).
3. **Saytning bosh sahifasi ilova edi.** `dist/web` ilovadan
   boshlanardi, landing'ga esa faqat ilova ichidagi tugma orqali
   kirilardi — ya'ni saytga kirgan odam va qidiruv tizimi landing'ni
   umuman ko'rmasdi. Endi boshlang'ich ko'rinish build sozlamasidan
   keladi (`nzSite.startView`): sayt → landing, APK → ilova,
   admin → admin panel.

Yana: **ovoz va bildirishnoma sozlamasi endi saqlanadi.** Ovozni
o'chirgan odam ilovani qayta ochganda ovoz yana yonib turardi —
sozlama foydalanuvchining aytgan gapi, uni har safar unutish uni
e'tiborsiz qoldirish. (Bu maxfiylik siyosatidagi "sozlamalar saqlanadi"
jumlasini ham haqiqatga aylantirdi.)

#### Sizdan kerak — `site.config.json`

Build bularsiz ham ishlaydi, lekin har safar ogohlantiradi:

- [ ] **`contactEmail`** — hozir `PLACEHOLDER@…`. Play Console maxfiylik
      siyosatida **haqiqiy** aloqa manzilini talab qiladi.
- [ ] **`domain` + `domainConfirmed: true`** — tasdiqlanmaguncha
      `sitemap.xml`, `canonical` va `og:image` **yozilmaydi** va
      `robots.txt` indekslashni **taqiqlaydi**. Sababi: mavjud bo'lmagan
      domen bilan sitemap berish qidiruv tizimiga yolg'on manzillarni
      indekslatadi.
- [ ] **`telegramBot`** — bot yaratilgach (Faza 5).

#### Faza 6 da qolgan ish

- [ ] Hosting: Cloudflare Pages yoki Vercel (`_headers` tayyor)
- [ ] `/app` alohida manzil bo'lishi (hozir landing va ilova bitta
      faylda, ilova ichida almashadi)
- [ ] Landing'ni oldindan chizib qo'yish: hozir u ilova bundle'ini
      (259 KB) talab qiladi, holbuki mazmuni statik matn
- [ ] Ekran suratlari bo'limi (`skrinshotlar/` da 14 ta tayyor)
- [ ] Play'ga chiqqach yuklab olish tugmalari (`playUrl`)

### Faza 7 — To'lovlar

⚠️ **Bu bosqichda muhim siyosat masalasi bor — 5-bo'limni o'qing.**

- [ ] Narx serverda (`pricing`), klient faqat ko'rsatadi
- [ ] Telegram Stars — Telegram Web App ichida
- [ ] Click / Payme / Uzum — sayt ichida (merchant hisobi kerak)
- [ ] Webhook'lar: to'lov tasdiqlansa `subscriptions` yangilanadi
- [ ] Idempotentlik: bir to'lov ikki marta hisoblanmasligi
- [ ] Obuna tugashi, uzaytirish, qaytarish oqimi

**Tayyor mezoni:** test to'lovi o'tadi, Pro faollashadi, muddati
tugagach avtomatik o'chadi, hammasi jurnalda.

### Faza 8 — Play Market

- [ ] Imzo kaliti va 4 ta GitHub secret (`README.md` §3 da yozilgan)
- [ ] `versionCode` / `versionName` boshqaruvi
- [ ] Do'kon sahifasi: nom, tavsif, 512×512 ikonka,
      1024×500 feature grafika, kamida 2 ta telefon skrinshoti
- [ ] **Data safety anketasi** — 5-bo'limga qarang, javob o'zgardi
- [ ] Kontent reytingi anketasi
- [ ] Maxfiylik siyosati havolasi (Faza 6)
- [ ] Internal testing → closed testing → production

**Tayyor mezoni:** ilova do'konda, yangilanish quvuri ishlaydi.

---

## 5. Ikki muhim ogohlantirish

Bularni oldindan bilish kerak — keyin bilib qolish qimmat turadi.

### 5.1. Google Play va to'lovlar

Google Play siyosatiga ko'ra, **Play orqali tarqatilgan ilova ichida**
raqamli mahsulot (Pro obuna) sotilsa, odatda **Google Play Billing**
ishlatilishi shart. Click/Payme/Uzum/Stars'ni APK ichiga qo'yish
ilovaning do'kondan olib tashlanishiga olib kelishi mumkin.

Bu dizaynga tegmaydi — to'lov oyna dizayni juda yaxshi. Lekin
**qaysi to'lov qayerda ishlaydi** degan savol tug'iladi:

| Kanal | To'lov usuli |
|---|---|
| Sayt (brauzer) | Click, Payme, Uzum, karta — cheklov yo'q |
| Telegram Web App | Telegram Stars (Telegram'ning o'z tizimi) |
| Android APK (Play) | Google Play Billing, yoki APK ichida umuman sotmaslik |

Eng xavfsiz yo'l: APK ichida Pro **sotilmaydi**, faqat "Pro holati"
ko'rsatiladi; sotib olish saytda yoki Telegram'da bo'ladi. Ko'p ilovalar
shunday qiladi.

**Diqqat:** Google Play siyosatlari o'zgarib turadi va mintaqaga qarab
farq qiladi. Faza 7'ni boshlashdan oldin joriy siyosatni rasmiy
manbadan tekshirish kerak — bu rejadagi eng katta noaniqlik.

### 5.2. Data safety anketasi o'zgaradi

README'da hozir shunday yozilgan:

> **Data safety** (bu ilova internetga hech narsa yubormaydi —
> "No data collected")

Faza 1'dan keyin bu **to'g'ri bo'lmay qoladi**: hisob, progress,
telefon raqami — hammasi serverga boradi. Play Console'da yolg'on
javob berish ilovani do'kondan chiqarib tashlashga olib keladi.

Faza 6'da maxfiylik siyosati yozilganda va Faza 8'da anketa
to'ldirilganda yangi haqiqatni aks ettirish kerak: qanday ma'lumot
yig'iladi, nima uchun, qancha saqlanadi, qanday o'chiriladi.

---

## 6. Eng katta to'siq — kontent

Kodda **10 ta savol** bor, README'da "700+" deb yozilgan. Texnik ish
qanchalik yaxshi bo'lsa ham, 10 savol bilan ilova foydasiz.

Bu **kod muammosi emas** — admin panel va ommaviy import tayyor bo'lgach,
savol yozish alohida ish sifatida qoladi. Reja:

- Faza 3 tugagach CSV shablon bilan ommaviy kiritish (`parseBulk` tayyor)
- Mavzular bo'yicha maqsad: har mavzuda kamida 40 savol
- Har bir savolga izoh (`explain`) majburiy — bu ilovaning asosiy
  qiymati, shunchaki test emas
- Nashrdan keyin DIF/DIS statistikasi yomon savollarni o'zi ko'rsatadi

**Huquqiy jihat:** rasmiy imtihon savollarini ko'chirish mumkin emas.
Savollar YHQ matniga asoslangan, lekin **o'z so'zlarimiz bilan**
yozilishi kerak. Har bir savolda YHQ bandiga havola bo'lsa yaxshi —
bu ham huquqiy jihatdan, ham o'quv jihatdan foydali.

---

## 7. Nima qilmaymiz (hozircha)

Qamrovni ushlab turish uchun ataylab qoldirilgan narsalar:

- iOS ilovasi (Capacitor imkon beradi, lekin Apple hisobi + boshqa
  siyosatlar = alohida loyiha)
- Video darslar, jonli imtihon, o'qituvchi paneli
- Ko'p tillilik (rus tili keyin qo'shilishi mumkin — DB'da
  `questions.text` uchun tarjima jadvali o'ylab qo'yilgan)
- Push bildirishnomalar (Telegram bot xabarlari arzonroq va samaraliroq)
- Mikroservislar, Kubernetes va shunga o'xshash narsalar

---

## 8. Sizdan kerak bo'lgan qarorlar

Bosqichlarni boshlashdan oldin to'rtta savolga javob kerak. Ularsiz
ham boshlash mumkin, lekin keyin qaytarib o'zgartirish qimmat turadi.

1. **Backend:** Supabase (tavsiyam) — yoki boshqa xohishingiz bormi?
2. **Domen:** sayt uchun domen bormi, yoki olish kerakmi?
3. **Telegram bot:** bot mavjudmi? Yo'q bo'lsa nom tanlash kerak.
4. **To'lov:** Click/Payme merchant hisobi bormi? (Stars uchun kerak
   emas, sayt to'lovlari uchun shart.)

Va bitta tartib savoli: **qaysi bosqichdan boshlaymiz?** Mening
tavsiyam — **Faza 0 + Faza 2**, ya'ni avval admin'ni APK'dan ajratib,
keyin savollarni DB'ga ko'chirish. Shundan keyin admin panelni ulash
(Faza 3) tez ketadi, chunki dizayn allaqachon tayyor.

---

## 9. Qisqa xulosa

Loyihaning **dizayn va Android qismi tugagan**. Qolgan ish — bitta
backend qo'shish va uchala klientni unga ulash. Dizaynda o'ylab
qo'yilgan narsalar (holat mashinasi, to'rt ko'z qoidasi, sabab
kodlari, audit jurnali, DIF/DIS) juda yaxshi — ularni qayta o'ylash
kerak emas, shunchaki serverga ko'chirish kerak.

Eng katta xavflar texnik emas: **Google Play to'lov siyosati** va
**savollar yozilishi**.
