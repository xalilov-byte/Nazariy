# Nazariy — to'liq tahlil

To'rtta mustaqil tekshiruv: **kod sifati**, **UX**, **tezlik va xavfsizlik**,
**mahsulot**. Har biri loyihani alohida ko'rib chiqdi, natijalar shu yerda
birlashtirilgan.

**Qanday tekshirildi.** UX — brauzerda haqiqiy ilova ochilib, ekranlar
bosib chiqildi. Xavfsizlik — mahalliy PostgreSQL 16 ko'tarilib, migratsiya
qo'llanib, **haqiqiy hujum so'rovlari bajarildi**. Tezlik — headless
Chromium'da o'lchandi. Mahsulot — kod va hujjatlar solishtirildi.

**Nima tasdiqlandi.** Quyidagi barcha OG'IR va O'RTA topilmalar
fayl/satr darajasida qayta tekshirildi. Tekshirilmagan yoki
taxminiy bo'lgan joylar alohida belgilangan.

**O'lchov chegarasi.** Tezlik raqamlari ish stoli protsessorida olingan.
O'rta darajali Android WebView odatda 3–6× sekinroq — bu **quyi chegara**,
telefondagi haqiqiy raqam emas.

---

## ⚙️ BAJARILISH HOLATI

> Bu hisobot tekshiruv paytidagi holatni tasvirlaydi. Quyidagi jadval
> shundan keyin nima qilinganini ko'rsatadi — hisobotning matni esa
> o'zgarmagan, chunki u nima uchun tuzatilganini tushuntiradi.

**Bajarildi (24 ta):** 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26.

| # | Qanday yopildi |
|---|---|
| 1, 12, 15 | `supabase/migrations/0003_guard.sql` + `supabase/tests/0003_guard.sql` — uchta hujum doimiy test bo'ldi |
| 3 | `src/data.js` — `sane()`, kesh faqat tekshiruvdan keyin, buzuq nusxa o'chiriladi |
| 4, 7, 8 | Profildagi yutuqlar, mavzular va foydalanuvchi ismi haqiqiy manbadan |
| 5, 20 | Ball: bir savol uchun bir marta; imtihon bonusi faqat imtihonda |
| 6 | `--success-on-fill`, `--green-on-fill`, `--muted-foreground` — ikkala temada 0 ta WCAG yiqilishi |
| 9 | Mavzu tanlash ekrani + `startQuizMode` filtri |
| 10 | Soat 0:00 da imtihon avtomatik yopiladi |
| 11 | Javoblar navbati birlashtirildi — 50 javob → 2 yozuv (ilgari 50) |
| 13 | `valsMoney` / `valsProfile` ajratildi; mobil build'dan pul MANTIG'I ham kesiladi |
| 14 | Gradle `preBuild` to'sig'i — eskirgan assets bilan APK yig'ilmaydi |
| 16 | Sessiya uzilganda import yuborilmaydi va xato ko'rsatiladi |
| 17 | Liga sarlavhasi hisoblanadi (`{0} liga · top` qolipi) |
| 18 | `EXAM_SIZE`/`EXAM_PER_Q`/`EXAM_MAX_WRONG` — bitta manba, `tools/source.mjs` generatorlar uchun |
| 19 | Tayyorlik faqat imtihon rejimidagi javoblardan |
| 21 | Kirish oynasi ochiqda orqadagi ekran berkitiladi — 488px → 390px |
| 22, 26 | Modul ro'yxati va `REJA.md` kodga moslandi |
| 23 | `Object.create(null)` — prototip kalitlari endi ro'yxatni o'chirmaydi |
| 24 | Telegram Stars tavsifi har qanday muhitda to'g'ri |
| 25 | `head()` — `rightAt`, sehrli `99` yo'q |

**Testlar:** 36 ta JS testi (`npm test`) + 2 ta SQL to'plami. Har biri
himoya olib tashlanganda haqiqatan yiqilishi alohida tekshirildi.

**Ochiq qolgani:**

| # | Nima | Nega hali yo'q |
|---|---|---|
| **2** | Savollar bazasi 10 → 600 | **Yarmi bajarildi.** Rasmiy avtotest hujjatidan 301 ta savol (140 tasi rasm bilan) olindi va bazaga yozildi — `tools/mkbank.mjs`, `supabase/seed/0005_bank.sql`. Hammasi `draft`: javob kaliti hujjatda matn bilan yozilmagan, u yashil nuqtaning koordinatasidan hisoblandi. 280 tasida o'zbekcha va ruscha nuqta bir xil javobni ko'rsatdi, 21 tasi kalitsiz. Nashr etish uchun **odam tasdiqlashi shart** (`0004_bank.sql`). Qolgani: admin panelda 301 ta savolni ko'rib chiqish |
| 27 | `tg_id` cast xatosi | Haqiqiy Telegram auth oqimi qurilganda tekshiriladi |
| 11-o'rin | «Reyting» → «Mavzular» tabi | Mahsulot qarori, bug emas |

---

## Uchta takrorlangan xulosa

Uchala texnik tekshiruv **mustaqil ravishda** bir xil naqshni topdi, va
u loyihaning o'z yozma qoidasini buzadi:

> *«O'zi ishlamagan 12 480 ballni ko'rgan odam undan keyingi hech qaysi
> raqamga ishonmaydi»* — `src/progress.js` sarlavhasi

Landing va bosh ekrandagi yolg'on raqamlar tozalangan edi, lekin
**profil ekrani va reyting sarlavhasi qolib ketgan**. Bu tasodif emas:
tozalash markup'dagi ko'rinadigan raqamlardan boshlangan, `renderVals()`
ichidagi qattiq massivlargacha yetmagan.

Ikkinchi takrorlangan naqsh: **himoya "yozilgan" deb hisoblanadi, lekin
sinalmagan.** To'rt ko'z qoidasi, pul qatlamini kesish tekshiruvi va
kesh validatsiyasi — uchalasi ham o'zi haqida ishonchli xabar beradi,
lekin uchalasida ham teshik bor.

---

# QO'SHISH KERAK

## YUQORI

### 1. Savollar bazasi: 10 → kamida 600, rasm quvuri bilan birga
**Muammo:** bankda aynan 10 ta savol (`src/Main.dc.html:1915–1946`),
8 mavzu, 3 rasmli. Butun texnik quvur (CSV import, to'rt ko'z, DIF/DIS,
RLS) shu 10 ta savol ustida turibdi.

**Ta'siri:** ilova imtihonga tayyorlamaydi — u 10 ta savolni yodlatadi.
Foydalanuvchi 2–3 kunda bank tugaganini sezadi. Play'dagi birinchi
sharhlar shundan keyin tiklanmaydi.

**Yechim:** mavzuga 60–80 savol, har biriga YHQ bandiga havolali izoh.
Kod ishi 0, kontent ishi ~15–25 kun (taxmin). **Rasm quvuri matn
yozilishidan OLDIN qurilishi shart** — 600 savol yozilib bo'lgach
rasmlarni orqadan ulash ikki barobar qimmat.

### 2. Rasmli savollar quvuri
**Muammo:** belgi rasmlari **kodga qo'lda SVG bo'lib chizilgan**
(`Main.dc.html:806–823`). `SAVOLLAR.md §4` aniq aytadi: yangi belgi
kerak bo'lsa u avval ilovaga chizilishi kerak — ya'ni har bir belgi
dasturchi ishi. Chorraha sxemalari uchun umuman yo'l yo'q.

**Ta'siri:** CSV import 600 ta matnli savolni bir kechada qabul qiladi,
lekin **rasmli savol qo'sha olmaydi**. YHQ imtihonining katta qismi
rasmli — bank o'sganda ham imtihonning bir qismi qoplanmaydi.

**Yechim:** `questions.image_url` (Supabase Storage), admin panelga rasm
yuklash, CSV'ga `rasm` ustuni. Chizilgan SVG belgilar zaxira bo'lib
qoladi. ~4–6 kun (taxmin).

### 3. To'rt ko'z qoidasini haqiqatan majburlash
**Muammo:** guard uch yo'l bilan chetlab o'tiladi — batafsili
TUZATISH §1–3.

**Yechim:** `questions_guard` ga INSERT va `options` shoxlari;
`question_translations` ga guard + audit trigger.

### 4. Uchta yangi RLS testi
**Muammo:** mavjud 311 qatorlik `supabase/tests/0001_rls.sql` **to'liq
o'tadi**, lekin uchta haqiqiy teshikni ko'rmaydi: INSERT bilan nashr
etish, `options` almashtirish, tarjima orqali chetlab o'tish.

**Ta'siri:** himoya sinalgan deb hisoblanadi. Bu aynan testning o'z
sarlavhasida ogohlantirilgan xato.

**Yechim:** uchta yangi `do $$ … $$` bloki — hujum so'rovlari
tekshiruvda allaqachon yozilgan, shundoq ko'chirish mumkin.

### 5. JS mantig'i uchun avtomatik test
**Muammo:** `runtime.js`, `progress.js`, `data.js` va butun `Component`
klassi uchun birorta test yo'q. `package.json` da `test` skripti yo'q.

⚠️ **Tuzatish:** baza testlari **repoda bor** va CI'da ishlaydi
(`supabase/tests/`, `.github/workflows/db.yml`). Faqat frontend
mantig'i sinovsiz.

**Ta'siri:** quyidagi ball eksploiti (TUZATISH §5) va kesh qulfi
(§4) — ikkalasi ham bitta unutilgan shart, va ikkalasi ham sinovsiz
kod bazasida osongina yashirinib qolgan.

**Yechim:** `progress.js` (streak, kun almashishi, ref↔indeks) va
`runtime.js` (morph) uchun Node unit testlari + CI qadami.

### 6. Content-Security-Policy
**Muammo:** `dist/site/_headers` da `nosniff`, `Referrer-Policy`,
`X-Frame-Options` bor, **CSP yo'q**.

**Ta'siri:** admin panel `refresh_token` ni `localStorage` da saqlaydi
(`src/admin-api.js:20,35`). Bugun XSS yo'li topilmadi (build'da
`innerHTML`/`eval` **0 marta**), lekin bittasi paydo bo'lsa token
istalgan xostga chiqariladi.

**Yechim:**
`connect-src 'self' https://<loyiha>.supabase.co; base-uri 'none'; object-src 'none'; form-action 'none'; frame-ancestors 'self'`

### 7. `data.js` da qator shakli tekshiruvi
**Muammo:** `readCache()` (`src/data.js:55`) faqat `Array.isArray` ni
ko'radi, ichidagi qatorni emas. Batafsili TUZATISH §4.

**Yechim:** `options` — 4 elementli massiv, `correct` — 0..3 butun son,
`ref` — satr. Shart bajarilmasa keshni o'chirib tarmoqqa qaytish.

### 8. Mavzu tanlash ekrani
**Muammo:** «Mavzular» rejimi mavzu bo'yicha **umuman filtrlamaydi**
(TUZATISH §9).

**Ta'siri:** tayyorlanishning eng asosiy usuli — «chorrahalarda
qoqilyapman, faqat shuni yechay» — ilovada yo'q.

**Yechim:** mavzular ro'yxati + har mavzuga progress. Ma'lumot bor
(`q.topic`), faqat ekran yo'q. ~2–3 kun.

### 9. Bilet generatori (tasodifiy 20 savol)
**Muammo:** aralashtirish **umuman yo'q**. Har imtihon bir xil
savollarni bir xil tartibda beradi; pool esa butun bank.

**Ta'siri:** takroriy mashq bilim emas, tartibni yodlashga aylanadi.
Bank 600 ta bo'lganda «imtihon» 600 savolga aylanadi.

**Yechim:** `pool = shuffle(ALL_INDICES).slice(0, EXAM_SIZE)`,
`EXAM_SIZE`/`EXAM_TIME` bitta konstantada. ~yarim kun.

## O'RTA

### 10. «Guvohnoma olish yo'li» bo'limi
**Muammo:** foydalanuvchi yo'lining to'rt bosqichidan ilova faqat
bittasini qoplaydi (qoidalarni o'rganish). Hujjatlar, tibbiy
ma'lumotnoma, avtomaktab, narx, davlat boji, imtihonga yozilish —
ilova matnida **bittasi ham yo'q** (grep bilan tekshirildi).

**Ta'siri:** ilova imtihon kunidan keyin o'chiriladi. Va bu aynan
**kirish nuqtasi**: odam «prava olish» deb qidiradi, «test yechish»
deb emas. Hozir bu trafik raqobatchilarning blog sahifalariga ketyapti.

**Yechim:** 5–7 statik sahifa. Saytda SEO uchun, ilovada offline.
Raqamlar rasmiy manbadan, **sana bilan** belgilanadi. ~3–4 kun,
asosan yozish — dasturchini band qilmaydi.

### 11. Toifa tanlash (A / B / C / D)
**Muammo:** ilovada va bankda toifa tushunchasi yo'q.

**Ta'siri:** B toifaga tayyorlanayotgan odam C toifa savollarini
yechadi.

**Yechim:** `questions.category` + birinchi ochilishda bitta savol.
**Bazaga ustun qo'shish 600 savol yozilgunga qadar arzon, keyin
qimmat.**

### 12. `--success-on-fill` tokeni
**Muammo:** `--destructive-on-fill` aniq maqsad bilan yaratilgan,
`--success` uchun juftlik yo'q.

**Ta'siri:** har safar kimdir `var(--success)` fonida oq matn yozsa,
xuddi shu kontrast xatosi qaytadi (TUZATISH §6).

### 13. Imtihondan chiqishda tasdiqlash
**Muammo:** `exitQuiz` (`Main.dc.html:2894`) darhol
`setState({quiz:null})` qiladi. Yuqori chap burchakdagi tugma
(`:760`) — barmoq tasodifan tegadigan joy.

**Ta'siri:** 10 savoldan 9 tasiga javob berib, tasodifan bosilsa,
butun urinish ogohlantirishsiz yo'qoladi.

**Yechim:** kamida 1 javob berilgan bo'lsa tasdiq oynasi. `confirm`
holati ilovada allaqachon bor.

### 14. Android backup qoidalari
**Muammo:** `AndroidManifest.xml:5` da `allowBackup="true"`, lekin
`dataExtractionRules` yo'q.

**Ta'siri:** WebView `localStorage` (progress + 221 KB gacha yetadigan
navbat) Google Drive'ga zaxiralanadi. Sir emas, lekin foydalanuvchi
so'ramagan ko'chirish.

### 15. `.gitignore` ga `.env`
**Muammo:** `*.keystore`, `*.jks`, `keystore.properties` bor, `.env`
**yo'q**. Hozir `.env` fayl yo'q — sizish bo'lmagan. Lekin
`SUPABASE_DB_URL` bilan mahalliy ish boshlansa, birinchi `.env` jimgina
commit'ga tushadi.

### 16. Hujjat ↔ kod moslik tekshiruvi
**Muammo:** fayl xaritasidagi modul ro'yxati koddagi haqiqiy
chaqiruvlar bilan hech qachon solishtirilmaydi (TUZATISH §22).

## PAST

### 17. Admin ro'yxatlarida «limitdan oshdi» ko'rsatkichi
`src/admin-api.js:270–277` — savollar 500, audit 200 bilan cheklangan,
UI'da «yana bor» degan belgi yo'q. Bank o'sganda admin sezmaydi.

### 18. CI'da tezlik byudjeti
Bugungi 243 KB / FCP 160 ms yaxshi, lekin uni ushlab turadigan narsa
yo'q. `build.mjs` allaqachon hajmni chop etadi — chegara qo'yish oson.

---

# OLIB TASHLASH KERAK

### 1. Profildagi «Yutuqlar» bo'limi
**Nima uchun ortiqcha:** butunlay qattiq yozilgan
(`Main.dc.html:3847–3852`), imtihondan o'tishga yordam bermaydi, va
hozirgi holida **yolg'on ma'lumot beradi** (TUZATISH §7).
**Muqobil:** olib tashlash yoki haqiqiy holatdan hisoblash
(`totalExams>=1`, `longest>=7`, `totalAnswered>=500`) — `taskList()`
vazifalar uchun qilingani kabi.

### 2. `nz-attempts` javoblar navbati
**Nima uchun ortiqcha:** `progress.js:331–342` navbatni to'ldiradi,
lekin yagona o'quvchi `queued()` **butun loyihada hech qayerda
chaqirilmaydi** (tasdiqlandi). Server sinxronizatsiyasi — Faza 4,
hali yo'q.
**Narxi:** har foydalanuvchida 2000 × ~110 bayt = **221 KB** hech kim
o'qimaydigan ma'lumot, va u har javobda qayta yoziladi (TUZATISH §11).
**Muqobil:** Faza 4 gacha o'chirish yoki `QUEUE_MAX` ni 200 ga tushirish.

### 3. `valsMoney()` — APK'dagi o'lik pul qatlami
**Nima uchun ortiqcha:** markup kesilgan, **mantiq qolgan** — 20 587
bayt. O'lchandi: `valsMoney()` **23.8 µs**, butun `renderVals()`
**39.8 µs**. Ya'ni APK'da har bosishda qilinadigan ishning **60% i
hech qachon chizilmaydigan ekran uchun**.
**Muqobil:** admin kesish ro'yxatidek, `!CFG.money` da chaqiruvni ham,
metodni ham kesish.

### 4. «Ball evaziga Pro» kursi
**Nima uchun ortiqcha:** `DEFAULT_PRICING.coin = 12000` — 12 000 ball
= 1 oy Pro. Ball har to'g'ri javobga +10, marafon esa bankni cheksiz
aylantiradi. 10 ta yodlangan savolni 1200 marta bosgan odam bir oylik
Pro'ni tekinga oladi.
**Hozir zararsiz** (pul qatlami APK'dan kesilgan), lekin bu **Faza 7 ga
qo'yilgan mina**.

### 5. Pro tarifining hozirgi va'dalari
Beshta va'dadan **uchtasi yolg'on** (`Main.dc.html:2394–2400`):

| Va'da | Haqiqat |
|---|---|
| «Cheksiz imtihon — kuniga 3 tadan emas» | Kunlik chegara **kodda yo'q** |
| «Reklamasiz» | Ilovada reklama hech qachon bo'lmagan |
| «Offline rejim» | Hamma uchun bepul — `data.js` ning butun mavzusi |

**Muqobil:** Pro'ni bank tayyor bo'lgunga qadar muzlatish. Qaytganda:
**savollarni yopish adolatsiz** — imtihondan o'tish xavfsizlik masalasi.
Pulli qilish mumkin bo'lgani: chuqur tahlil, rasmli/video izohlar,
o'qituvchi tekshiruvi. **Kontentni emas, xizmatni sotish.**

### 6. `fmt` / `nfmt` takrorlanishi — 9 joyda
Bir xil `.toLocaleString("ru-RU").replace(...)` **to'qqizta joyda**
(tasdiqlandi). `nfmt()` metodining izohida «nusxalanmasligi uchun
metod qilib chiqarilgan» deyilgan, lekin `fmt()` allaqachon bor edi —
ya'ni izoh yozilgan paytda ham nusxa yaratilgan.
**Muqobil:** faqat `fmt()` qoldirish.

### 7. Cordova qoldiqlari
- `android/app/src/main/res/xml/config.xml` — ichida
  `<access origin="*" />`. Capacitor uni o'qimaydi (zarar yo'q), lekin
  auditda «hamma domenga ruxsat» bo'lib ko'rinadi.
- `FileProvider` + `file_paths.xml` — `<external-path path="." />`
  butun tashqi xotira ildizi. `exported="false"`, ilovada fayl ulashish
  yo'q — hozir suiiste'mol yo'li yo'q, lekin keraksiz.

### 8. `android/app/src/main/assets/public/` eski nusxasi
Batafsili TUZATISH §14.

### 9. `i18n.js:65` — takroriy qator
`["ʼ", "ъ"], ["ʼ", "ъ"]` — ikkalasi belgi darajasida aynan bir xil.
Zarar yo'q, lekin izoh ikkinchi variant kutilganini ko'rsatadi.

---

## Qaror talab qiladigan taklif: «Reyting» tabi

Bu **bug emas, mahsulot qarori** — shuning uchun alohida.

**Argument:** to'rtta pastki navigatsiya uyasidan bittasi hech narsa
qilmaydigan ekranga ketgan. Ichida: 6 pog'onali liga, namunaviy
7 kishilik ro'yxat (oxirida hamon `{ rank: 142, name: "Sardor (siz)" }`,
`Main.dc.html:3788`), qo'lda yozilgan guruh kartasi va ikkita o'chirilgan
«Tez kunda» tugmasi. Haqiqiy reyting server, hisob va anti-chit talab
qiladi — eng erta 3–4 oy.

Va reyting **imtihondan o'tishga yordam bermaydi**: odam boshqalar bilan
raqobat qilmaydi, u 2 ta xatoga sig'ishga harakat qiladi. Yuqorida
turgan begonalar ro'yxati eng ko'p turtki kerak bo'lgan — ya'ni eng
yomon yechayotgan — odamning ko'nglini qoldiradi.

**Taklif:** tabni «Mavzular» ga almashtirish (QO'SHISH §8). Liga hisobi
(`leagueOf`) qolsin — u balldan hisoblanadi va halol; profildagi bitta
nishon yetarli.

**Guruhlar haqida:** avtomaktablar so'ragani haqida **hech qanday dalil
topilmadi** — na kodda, na hujjatlarda. Agar bu yo'nalish jiddiy bo'lsa,
u alohida mahsulot (o'qituvchi paneli), pastki navigatsiyadagi tab emas.

---

# TUZATISH KERAK

## OG'IR

### 1. To'rt ko'z qoidasi INSERT bilan butunlay chetlab o'tiladi
`supabase/migrations/0001_init.sql:169`

**Muammo:** `if tg_op = 'UPDATE' then` — nashr etish tekshiruvi faqat
UPDATE ichida. INSERT'da hech narsa tekshirilmaydi.

**Ta'siri (haqiqiy so'rov bilan tasdiqlandi):** bitta moderator sifatida
```sql
insert into public.questions (ref, topic_id, text, options, correct, state)
values ('#999', …, 'published');
→ holat=published, reviewed_by=NULL
```
Savol darhol `published_questions` ga tushdi va **anon uni o'qidi**.
Bitta moderator hisobini qo'lga kiritgan odam ikkinchi odam tasdig'isiz
istalgan javob kalitini ilovaga chiqaradi.

**Yechim:** `if tg_op = 'INSERT' and new.state = 'published' then raise
exception …`, yoki `questions_staff_insert` siyosatiga
`with check (state in ('draft','review'))`.

### 2. Variantlarni almashtirish javob kalitini o'zgartiradi, guard ko'rmaydi
`supabase/migrations/0001_init.sql:171`

**Muammo:** guard `correct` **indeksini** kuzatadi, lekin `correct` —
`options` massividagi o'rin. Massiv ichini almashtirish indeksni
o'zgartirmaydi.

**Ta'siri (tasdiqlandi):**
```
oldin:  correct=1 → "Manyovr niyatini yoʻnalish koʻrsatkichi bilan…"  (to'g'ri)
keyin:  correct=1 → "Faqat ovoz signalini berish"                     (noto'g'ri)
holat:  published — o'zgarmadi, ko'rib chiqishga qaytmadi
```
Bitta moderator nashr etilgan savolning javobini **jimgina** noto'g'riga
aylantiradi — aynan trigger izohida yozilgan zarar.

**Yechim:**
`if new.correct is distinct from old.correct or new.options is distinct from old.options then`

### 3. `question_translations` — na to'rt ko'z, na audit
Jadval `0001_init.sql:144`; migratsiyadagi 3 ta triggerning **hech
biri** unga tegishli emas (tasdiqlandi).

**Muammo:** `question_translations.options` ham javob varianti, lekin
uni hech narsa qo'riqlamaydi.

**Ta'siri (tasdiqlandi):** moderator ruscha variantlarni almashtirdi →
savol holati `published` bo'lib qoldi, **`audit_log` ga yozuv
qo'shilmadi**. Rus tilida ishlatayotgan foydalanuvchi uchun javob
kaliti o'zgardi, hech kim tasdiqlamadi, jurnalda iz yo'q. Bu
migratsiya boshidagi «jurnalga tushmaydigan o'zgarish bo'lmaydi»
qoidasining to'g'ridan-to'g'ri buzilishi.

### 4. Zaharlangan kesh ilovani abadiy qulflaydi
`src/data.js:165` (swap `try/catch` dan tashqarida), `:183`
(`writeCache` tekshiruvdan **oldin**), `src/bootstrap.js:185`
(`.catch()` yo'q)

**Ta'siri (o'lchandi):** baza bir marta ichida `null` bo'lgan javob
qaytardi:
```
1-ochilish: bank=10 (zaxira)  status=error   API=2  → LEKIN kesh YOZILDI
2-ochilish: bank=10           status=bundled API=0  ← tarmoqqa UMUMAN chiqmaydi
            xato: "Cannot read properties of null (reading 'ref')"
```
Ilova yiqilmaydi, lekin **abadiy APK ichidagi 10 savolda qoladi**.
Yagona chiqish — Android sozlamalaridan ilova ma'lumotini tozalash, u
esa butun progressni ham o'chiradi. **Bitta noto'g'ri deploy o'sha
oynada ilova ochgan hamma foydalanuvchining kontent quvurini o'ldiradi.**

**Yechim:** `swap` ni `try/catch` ga olib, xatoda keshni o'chirib
2-bosqichga davom etish; `writeCache` ni faqat validatsiyadan keyin.

### 5. Ball eksploiti — imtihon bonusi rejimga qaramasdan beriladi
`src/Main.dc.html:4191`

```js
const wasExam = cur.mode === "exam" || !cur.mode;
...
points: st.points + (st.quiz.wrong <= 2 ? 100 : 0),   // ← wasExam TEKSHIRILMAGAN
examsDone: st.examsDone + (wasExam ? 1 : 0)           // ← bu yerda tekshirilgan
```

**Muammo:** `wasExam` bir satr yuqorida hisoblanadi va `examsDone` ga
to'g'ri qo'llanadi, `+100 ball` ga esa **qo'llanmagan**.

**Ta'siri:** «Xatolarim» yoki «Saqlangan» da 1–2 savol bo'lsa (odatiy
holat), ularni yechib «Qayta yechish» ni cheksiz bosib har safar
+100 ball olish mumkin. Liga, reyting va «haqiqiy raqam» tamoyili shu
orqali qalbakilashtiriladi.

**Yechim:** `points: st.points + (wasExam && st.quiz.wrong <= 2 ? 100 : 0)`

### 6. Tungi rejimda javob plitkasi o'qilmaydi — WCAG buzilishi
`src/Main.dc.html:4146` (asosiy), shuningdek `:3179`, `:3410`, `:3433`,
`:3551`

**Muammo:** `color: "#fff"` och rangli fon ustida. Hisoblandi:

| Fon (tungi) | Oq matn kontrasti | WCAG AA |
|---|---|---|
| `--success` `#3DDB8F` | **1.79 : 1** | 4.5 : 1 |
| `--destructive` `#FF6B6B` | **2.78 : 1** | 4.5 : 1 |

**Yechim allaqachon loyihada bor:** `--destructive-on-fill` (`#1C1B29`)
aynan shu uchun yaratilgan va **6.11 : 1** beradi; xuddi shu siyoh
yashil ustida **9.47 : 1**. U faqat `err1Style`/`err2Style` ga
qo'llangan, javob berilgandagi harf plitkasiga — **ilovaning eng
tez-tez takrorlanadigan lahzasiga** — qo'llanmagan.

**Yechim:** `"#fff"` o'rniga `var(--destructive-on-fill)` va yangi
`--success-on-fill`.

### 7. Profildagi «Yutuqlar» — yangi hisobda ham «olingan»
`src/Main.dc.html:3847–3852` (render `:674`)

**Muammo:** `achievements` butunlay qattiq massiv —
`{ label: "500 savol yechildi", earned: true }`.

**Ta'siri (brauzerda ko'rilgan):** 0 imtihon, 0 savol, 0 kunlik streak
bo'lgan yangi hisobda uchta yutuq yashil ✓ bilan «olingan» ko'rinadi.
Ilova birinchi ochilishidayoq «siz 500 ta savol yechgansiz» deydi.

**Yechim:** xuddi shu ekranda `profileStats` (`:3805–3819`) **to'g'ri**
qilingan — `nzProgress.stats()` dan hisoblanadi va bo'sh holatda «—»
ko'rsatadi. Naqsh tayyor, ko'chirish kerak.

### 8. Profildagi «Mavzular bo'yicha» — qattiq yozilgan foizlar
`src/Main.dc.html:3824–3830`

**Muammo:** `raw = [{name:"Yoʻl belgilari", n:94}, …]` — statik massiv.
Ustiga «Tezlik va joylashish» bankdagi mavzu ham emas (bankda «Tezlik
rejimi»).

**Ta'siri:** yangi foydalanuvchiga «Birinchi yordam mavzusida zaifsiz
(42%)» deydi, holbuki u birorta savolga javob bermagan.

**Yechim:** mavzu kesimidagi haqiqiy hisob (`nz-attempts` da har javob
`ref` bilan turibdi) yoki 0 javobda «—».

### 9. «Mavzular» rejimi mavzu bo'yicha filtrlamaydi
`src/Main.dc.html:2524`

**Muammo:** `startQuizMode` da `topics` uchun shox **yo'q** — u
`ALL_INDICES.slice()` ga tushadi. Ya'ni imtihon bilan aynan bir xil,
faqat soatsiz. Kartada «8 mavzu» yozilgan (`:411`), landing'da
«8 bo'lim, har biri alohida progress bilan» (`:3957`) — ikkalasi ham
noto'g'ri.

### 10. Imtihon soati tugaganda hech narsa bo'lmaydi
`src/Main.dc.html:2496`

**Muammo:** `if (!q || q.finished || q.time <= 0) return;` — soat 0:00
ga yetganda **shunchaki to'xtaydi**. Testni tugatadigan kod yo'q.

**Ta'siri:** vaqt bosimi — imtihon simulyatsiyasining butun mazmuni.
Ilova «haqiqiy simulyatsiya» deb va'da berib eng muhim shartni
bajarmaydi.

## O'RTA

### 11. Har javobda 221 KB `localStorage` yozuvi
`src/progress.js:331–342`

**Muammo:** progress yozuvlari 400 ms bilan birlashtirilgan (bu
**to'g'ri ishlaydi** — 50 `setState` → 0 yozuv), lekin `nz-attempts`
navbati birlashtirilmagan: har javobda butun navbat parse qilinib
qaytadan yoziladi.

**Ta'siri (o'lchandi), navbat to'lganda:**
```
navbat hajmi:            220 891 bayt
answered() bir chaqiruv: 1.58 ms  (asosiy oqimda, sinxron)
55 ta javob:             12.1 MB yozildi
```
20 savollik imtihonda ~4.4 MB yoziladi va ~32 ms asosiy oqim
bloklanadi — aynan javob bosilgan paytda. Telefonda 3–6× ko'proq.
Kuniga 50 savol yechadigan talaba ~40 kunda shu holatga tushadi.

### 12. `tg_id` egallash — signup meta tekshirilmaydi
`supabase/migrations/0001_init.sql:65`

**Muammo:** `handle_new_user` `raw_user_meta_data` dan `tg_id` ni
to'g'ridan-to'g'ri oladi; bu maydonni klient `signUp()` da o'zi
to'ldiradi.

**Ta'siri (tasdiqlandi):** `role` to'g'ri e'tiborsiz qoldirilgan, lekin
`tg_id` qoldirilgan. Ikki zarar:
1. **Hisobni oldindan egallash** — hujumchi boshqa odamning Telegram
   id'sini yozib qo'yadi; Telegram kirishi `tg_id` bo'yicha moslasa
   hisob hujumchiniki bo'ladi.
2. **Egasini bloklash** — haqiqiy odamning ro'yxatdan o'tishi
   `duplicate key … profiles_tg_id_key` bilan butunlay yiqiladi.
   Hujumchi 1000 tg_id yozib 1000 odamni to'sib qo'yadi.

**Yechim:** `tg_id` ni signup meta'dan **umuman olmaslik** — faqat
serverda Telegram imzosi tekshirilgandan keyin yozilsin.

### 13. Build'ning pul qatlami tekshiruvi faqat markup'ga qaraydi
`build.mjs:551`

**Muammo:** izohda «unga kirish YO'LI qolmasligi kerak» deyilgan, lekin
tekshiruv `markup.indexOf(bad)`. Admin tekshiruvi (`:573`) esa
`logicCode` ustida ishlaydi — aynan shuning uchun kuchli.

**Ta'siri:** build «kesildi — pul qatlami» deb chop etadi, lekin
`www/index.html` da beshta ishlov beruvchi turibdi. Bugun zararsiz
(kirish nuqtasi yo'q), lekin **tasdiq yolg'on**. Xavfsizlik chegarasi
o'zi haqida noto'g'ri xabar bermasligi kerak.

### 14. APK ichidagi nusxa eskirgan — kesilgan to'lov oqimi hali ichida
`android/app/src/main/assets/public/index.html`

**Muammo:** mahalliy nusxa `50edfe9` («taqlid to'lov oqimi kesildi»)
commit'idan **oldingi** holatda. Unda `openPro`, `openPay`,
`openRedeem`, `payStepMethod` markup'i hali bor; `www/index.html` da
birortasi yo'q.

**Ta'siri:** kim `npm run sync` qilmasdan to'g'ridan-to'g'ri
`./gradlew assembleRelease` desa, **Play rad etadigan taqlid to'lov
oqimi bilan APK chiqadi**. CI xavfsiz — u `build.mjs` + `cap sync`
qiladi.

### 15. Savol matni uzunligiga chegara yo'q
`src/Main.dc.html:2351` (faqat `q.length < 15`); bazada ham maksimum
yo'q (`0001_init.sql:132`)

**Ta'siri (o'lchandi):** 2 MB'lik bitta hujayrali CSV **`ok=true`**
bilan qabul qilindi. U bazaga, u yerdan har bir foydalanuvchiga
tushadi; klient keshi ~5 MB chegarasiga urilib `writeCache` jimgina
yiqiladi — **butun foydalanuvchi bazasining offline rejimi o'chadi**.

**Yechim:** `parseBulk` da `q.length > 500` → xato; bazada
`check (char_length(text) between 15 and 500)`.

### 16. Bulk import — sessiya uzilganda jimgina yo'qoladigan «muvaffaqiyat»
`src/Main.dc.html:3443–3470`

**Muammo:** `connected()` `false` bo'lsa (token yangilanmagan bo'lsa),
kod bazaga hech narsa yubormasdan mahalliy soxta `#501, #502…` ID'li
qatorlar qo'shadi va muvaffaqiyat ko'rsatadi.

**Ta'siri:** admin «700 savol qo'shdim» deb ishonadi, sahifa
yangilanishi bilan hammasi yo'qoladi. Xato xabari yo'q.

### 17. «Kumush liga · top» qattiq yozilgan sarlavha
`src/Main.dc.html:543`

**Ta'siri:** foydalanuvchi bir ekranda ikkita zid liga nomini ko'radi —
yuqorida to'g'ri hisoblangan «Boshlovchi», pastda doim «Kumush liga».
**Har bir yangi foydalanuvchi** buni ko'radi (hamma «Boshlovchi» dan
boshlaydi). Uch tilda ham tasdiqlandi.

**Yechim:** `{{ leagueName }}` — `valsShell` da qiymat allaqachon bor.

### 18. Marketing va'dasi ilovaga mos kelmaydi
`Main.dc.html:3953`, `:3956`, `tools/mkog.mjs:80`, `tools/mkplay.mjs:99`
↔ `:2531`, `:399`

**Muammo:** landing, OG rasmi va Play grafikasi «20 savol · 25 daqiqa»
deydi; ilovada `time: 750` (12.5 daqiqa) va pool = butun bank (10 ta).

Ustiga landing `:3961` da «Tezkor test · 10 savol, 5 daqiqa» rejimini
reklama qiladi — bunday rejim ilovada **yo'q**.

### 19. Tayyorlik foizi takrorlarni ham hisoblaydi
`src/Main.dc.html:2740`

**Muammo:** `readiness()` umrbod aniqlikni oladi — «Xatolarim»
takrorlari ham ichida. Bir savolni uch marta to'g'ri yechsa
«tayyorligi» oshadi.

**Ta'siri:** imtihondan oldingi eng muhim raqam sistematik ravishda
haqiqatdan yuqori chiqadi — odamni tayyor bo'lmagan holda imtihonga
yuboradi.

### 20. Ball inflyatsiyasi
`src/Main.dc.html:2697` — `+10` har to'g'ri javobga, **rejimdan qat'i
nazar**, jumladan takrorlar va marafonning cheksiz aylanishida.

### 21. Admin login ekrani 390px da gorizontal scroll
**O'lchandi:** `scrollWidth` = 488px (390px o'rniga). Login oynasi
ostida analitika paneli `repeat(4,1fr)` bilan chizilgan;
`shell-admin.css` da `@media` qoidasi yo'q.

**Yechim:** kirish oynasi ochiq bo'lganda orqadagi ekranni render
qilmaslik.

## KICHIK

### 22. Hujjatdagi modul ro'yxati kodga mos emas
`src/Main.dc.html:133–139`, `:1897–1899` ↔ `:2764`

«`renderVals()` faqat beshta modulni yig'adi» deyilgan, haqiqiy kod
oltinchisini ham chaqiradi — `this.valsTasks(s)`.

### 23. Prototip kalitlari saqlangan ro'yxatni jimgina o'chiradi
`src/progress.js:186`, `src/Main.dc.html:2334`

**Muammo:** `const m = {}` — `Object.prototype` kalitlari
`m[r] !== undefined` tekshiruvidan o'tib ketadi.

**Ta'siri (ajratib takrorlandi):**
```js
toIndices(['constructor','#1'], Q) → [ƒ Object, 0]   // indeks o'rniga FUNKSIYA
orphansOf(['constructor'], Q)      → []              // yetim ham deb hisoblanmaydi
```
`ref` i `constructor` yoki `__proto__` bo'lgan savol «Saqlangan» dan
**butunlay va qaytarib bo'lmas** o'chadi. `ref` — erkin matn,
`parseBulk` uni cheklamaydi.

**Yechim:** `Object.create(null)`.

### 24. Telegram Stars tavsifi saytda noto'g'ri
`src/Main.dc.html:2055` — «Telegram ichida, ilovadan chiqmasdan», lekin
`PAY_METHODS` build maqsadiga qarab filtrlanmaydi.

### 25. `head()` yordamchisidagi keraksiz murakkablik
`src/Main.dc.html:3144` — `i >= rightFrom && i <= rightFrom + 0`
amalda `i === rightFrom`; chaqirishda sehrli `99`.

### 26. `REJA.md` 1-bo'limi eskirgan
`REJA.md:30–46` — «Backend yo'q, bitta ham `fetch()` yo'q… Sayt yo'q».
Uchalasi ham endi noto'g'ri va keyingi «✅ BAJARILDI» fazalariga zid.

### 27. `tg_id` cast xatosi — tekshirish kerak
`0001_init.sql:65` — `::bigint` sonli bo'lmagan matnda istisno tashlaydi.
Real auth oqimi qurilganda tekshirilsin.

---

# Raqobatchilar

⚠️ **Tarmoq cheklovi.** Bu muhitda `play.google.com`, `avtotest.uz`,
`osonprava.uz`, `apkpure.com`, `t.me` va boshqa o'nlab manzil
**bloklangan**. Qidiruv indeksi ishladi — ya'ni ilova **mavjudligini**
va uning **o'z da'vosini** tasdiqlay oldim, lekin **reyting,
o'rnatishlar soni, narx va sharhlarni birorta ilova uchun ham ko'ra
olmadim**. «Savollar» ustuni — ishlab chiquvchining **o'z da'vosi**.

| Ilova / sayt | Savollar | Ustunligi | Zaifligi |
|---|---|---|---|
| **Nazariy** (biz) | **10** ✅ koddan | Uch til, offline, halol raqam tamoyili, tayyor kontent quvuri va admin | Bank bo'sh; rasmli savol qo'sha olmaydi; mavzu tanlash yo'q |
| Oson Prava (ilova + sayt + bot) | «1260+» *da'vo* | Uch kanal; **ovozli izoh**; saytda «prava narxi» blogi — bizda yo'q SEO trafigi | *tekshirilmadi* |
| Avto Exam 2 | «1000+» *da'vo* | Hajm bilan pozitsiyalanadi | *tekshirilmadi* |
| AvtoTest Uz | «1200+» *da'vo* | lex.uz ga havola *(da'vo)* | *tekshirilmadi* |
| Avtotest 2026 | *tekshirilmadi* | «Reklamasiz» *da'vo* | *tekshirilmadi* |
| ПДД Узбекистан | «1020» *da'vo* | Rus auditoriyasi | *tekshirilmadi* |
| Автодром ПДД Uz | — | **Amaliy imtihon** simulyatori — bizda umuman yo'q segment | *tekshirilmadi* |
| Rossiya: Билеты ПДД, Drom | «40 bilet · 800 savol» *da'vo* | Bilet tuzilmasi, mutaxassis izohlari | O'zbek YHQ'siga taalluqli emas |

**Xulosa:** bozor to'la — kamida 10 ta o'zbek ilovasi, deyarli hammasi
sarlavhasida **savol soni** bilan raqobat qiladi. Bizda 10 ta. **Hajm
bo'yicha kirish yo'li yopiq**; yagona ochiq yo'l — **sifat**: izoh,
rasm, mavzu bo'yicha aniq mashq va guvohnoma yo'lining to'liq
qoplanishi.

**Bajarilmay qolgan eng qimmatli ish:** yetakchi ilovalarning 1–2
yulduzli sharhlarini o'qish. Buni tarmoq ochiq muhitda qo'lda
takrorlash kerak — u bu hisobotdagi barcha taxminlardan ko'ra ko'proq
narsa berishi mumkin.

---

# O'lchov jadvali

| | www (APK) | dist/web | dist/admin |
|---|---|---|---|
| index.html | 243 KB (gz 70) | 265 KB (gz 72) | 326 KB (gz 93) |
| shriftlar | 172 KB / 20 fayl | 172 KB | 172 KB |
| **jami** | **491 KB** | 513 KB | 574 KB |

**Ishga tushish (www):** first-paint 36 ms · FCP **160 ms** ·
DOMContentLoaded 122 ms · 159 DOM tugun. Bloklovchi ish topilmadi.
**Ochilishdagi so'rovlar:** 9 ta, takroriy so'rov yo'q.
**Kesh:** 1-ochilish 2 API → 2-ochilish **0 API** → 6 soatdan keyin
yana 2. Hujjatdagidek. 700 savol = 127 KB kesh.
**`renderVals()`:** 39.8 µs (10 savol) / 86–108 µs (700 savol) —
massiv o'lchamiga sezilarli bog'liq emas. Taqsimot: valsMoney 23.8 ·
i18n.deep 23.3 · valsShell 4.2 · valsTasks 2.6 · valsQuiz 0.2 µs.
**`parseBulk`:** 1 000 qator 6.1 ms · 20 000 qator (2 MB) 76 ms.
Buzilgan qatorlar ilovani yiqitmadi.

**Toza chiqqan joylar:** `service_role`, parol, `postgres://`, JWT —
na ishchi nusxada, na **git tarixining 211 ta blobida**. Rolni o'ziga
ko'tarish to'silgan. `audit_log` o'zgarmas. `innerHTML`/`eval` build'da
**0 marta** — XSS yo'li yo'q. `SCHEDULE_EXACT_ALARM` haqiqatan olib
tashlangan. 6 soatlik kesh hujjatdagidek ishlaydi.

---

# ENG MUHIM 10 TA ISH

Tartib: zarar × ehtimollik × arzonlik.

| # | Ish | Nima uchun birinchi | Qayerda |
|---|---|---|---|
| **1** | **To'rt ko'z qoidasini haqiqatan majburlash** — INSERT, `options`, tarjima | Uch mustaqil yo'l bilan chetlab o'tiladi (uchalasi ham haqiqiy so'rov bilan tasdiqlandi). Bitta moderator hisobi noto'g'ri javob kalitini ilovaga chiqaradi — bu mahsulotning o'ziga zarba | `0001_init.sql:169,171,144` |
| **2** | **Savollar bazasi 10 → 600, rasm quvuri bilan** | Qolgan hamma qaror bank hajmiga bog'liq. Rasm quvuri matn yozilishidan **oldin** ulanishi shart | kontent + `image_url` |
| **3** | **Zaharlangan keshdan chiqish yo'li** | Bitta buzuq deploy ilovani abadiy 10 savolga qulflaydi; o'lchandi — keyingi ochilishlarda **0 ta** so'rov. Chiqish yo'li faqat ma'lumotni tozalash, u esa progressni o'chiradi | `data.js:165,183`, `bootstrap.js:185` |
| **4** | **Profildagi soxta statistika** — «Yutuqlar» va «Mavzular bo'yicha» | Uchala tekshiruv mustaqil topdi. Yangi hisobda «500 savol yechildi ✓» ko'rinadi. Tuzatish naqshi **shu ekranning o'zida** tayyor (`profileStats`) | `Main.dc.html:3824–3852` |
| **5** | **Ball eksploiti** — `wasExam &&` qo'shish | Bitta so'z, lekin hozir liga va reyting tizimi ochiq eshikdan buziladi | `Main.dc.html:4191` |
| **6** | **Tungi rejimda kontrast** — 1.79:1 va 2.78:1 | Ilovaning eng tez-tez takrorlanadigan lahzasi o'qilmaydi. Token allaqachon mavjud, faqat qo'llanmagan | `Main.dc.html:4146` + 4 joy |
| **7** | **Imtihon yaxlitligi**: soat 0 da tugasin · aralashtirish · «Mavzular» filtrlasin | Uchalasi «haqiqiy simulyatsiya» va'dasining asosi; hozir uchalasi ham yo'q. Birgalikda ~3 kun | `:2496`, `:2524`, `:2531` |
| **8** | **`tg_id` ni signup meta'dan olib tashlash** | Hujumchi boshqa odamning Telegram hisobini oldindan egallaydi va haqiqiy egasining ro'yxatdan o'tishini butunlay to'sadi (tasdiqlandi). Telegram auth qurilishidan **oldin** tuzatilsin | `0001_init.sql:65` |
| **9** | **JS mantig'i uchun testlar + uchta yangi RLS testi** | 5 va 3-bandlar sinovsiz kod bazasida yashirinib qolgan. Mavjud RLS testi to'liq o'tadi va uchta teshikni ko'rmaydi — «sinalgan» degan yolg'on tuyg'u | `package.json`, `supabase/tests/` |
| **10** | **Marketing va'dalarini haqiqatga keltirish** | Landing, OG rasmi va Play grafikasi «20 savol · 25 daqiqa» deydi, ilovada 10 savol · 12:30. Mavjud bo'lmagan «Tezkor test» reklama qilinadi. Play'ga chiqishdan oldin | `:3953`, `:3961`, `mkog.mjs:80`, `mkplay.mjs:99` |

**11-o'rin (qaror talab qiladi):** «Reyting» tabini «Mavzular» ga
almashtirish. Bu bug emas — mahsulot qarori, yuqoridagi alohida
bo'limga qarang.
