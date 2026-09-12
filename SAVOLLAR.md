# Savollar bazasini to'ldirish

Bu loyihaning **eng katta to'siqi**: hozir 10 ta savol bor, kerak —
bir necha yuz. Kod tayyor, ish esa kontentda. Bu hujjat savollarni
qanday tayyorlash va bazaga kiritishni aytadi.

Shablon: **`savollar-shablon.csv`** — uni Excel yoki Google Sheets'da
ochib, ustidan yozib ketasiz.

---

## 1. Qanday ishlaydi — uch qadam

1. **Jadvalda tayyorlanadi** (Excel / Google Sheets / LibreOffice).
   Har bir savol — bitta qator.
2. **CSV sifatida saqlanadi**, ajratgich **nuqtali vergul (`;`)**.
   Google Sheets: *Fayl → Yuklab olish → CSV*, keyin ajratgichni
   tekshirib oling. Excel: *Save As → CSV (semicolon delimited)*.
3. **Admin panelga qo'yiladi**: Boshqaruv → Savollar → «Ommaviy
   qo'shish» → «Fayldan qo'yish…» → matnni qo'yib «Tekshirish».

Panel har qatorni alohida tekshiradi va nima noto'g'ri ekanini
aytadi. **Bitta xato butun importni to'xtatmaydi** — faqat o'sha
qator o'tmaydi.

Qabul qilingan savollar **qoralama** holatida qo'shiladi. Ular
foydalanuvchiga darhol chiqmaydi: avval ko'rib chiqiladi va nashr
etiladi.

---

## 2. Ustunlar

| Ustun | Shartmi | Nima |
|---|---|---|
| `mavzu` | ✅ | Mavzu **nomi** — bazadagi nom bilan aynan bir xil (§3) |
| `savol` | ✅ | Savol matni. Kamida 15 belgi |
| `A` `B` `C` `D` | ✅ | To'rtta variant. Bo'sh bo'lishi mumkin emas, takrorlanmasligi kerak |
| `togri` | ✅ | To'g'ri javob harfi: `A`, `B`, `C` yoki `D` |
| `izoh` | ⚠️ | **Nima uchun** shunday. Pastga qarang |
| `belgi` | — | Yo'l belgisi savollari uchun (§4) |
| `id` | — | Savol raqami (`#142`). Yozmasangiz baza o'zi beradi |

**Ustunlar nomi bo'yicha o'qiladi, tartibi muhim emas.** Ustun
qo'shsangiz yoki joyini almashtirsangiz ham to'g'ri o'qiladi. Faqat
birinchi qator sarlavha bo'lishi shart.

### Izoh haqida — eng muhim tavsiya

Izoh **shart emas**, lekin uni bo'sh qoldirish ilovaning asosiy
qiymatini yo'q qiladi. Imtihonga tayyorlanayotgan odam javobni
yodlab olsa, imtihonda savol boshqacha yozilgan bo'lsa yana
xato qiladi. Izoh esa **qoidani** tushuntiradi.

Yaxshi izoh: qoida bandini va sababni aytadi.

> YHQ 8-bandi: manyovr boshlashdan oldin yo'nalish ko'rsatkichi bilan
> signal berilishi va manyovr xavfsiz bo'lishi shart.

Yomon izoh: javobni takrorlaydi.

> To'g'ri javob — B.

Import paneli izohsiz qatorlarni **sanab ko'rsatadi** (sariq
"N ta izohsiz") va har bir qator ostida "izoh yo'q" deb yozadi —
shunda ular jimgina qo'shilib ketmaydi.

---

## 3. Mavzu nomlari

Mavzu nomi bazadagi nom bilan **aynan** bir xil bo'lishi kerak,
aks holda qator o'tkazib yuboriladi ("mavzu topilmadi") va panel
buni aytadi.

Hozirgi mavzular:

```
Umumiy qoidalar
Yoʻl belgilari
Tezlik rejimi
Chorrahalar
Svetofor
Quvib oʻtish
Toʻxtab turish
Birinchi yordam
```

**Diqqat: `ʻ` belgisi.** Bu oddiy apostrof (`'`) emas, balki
U+02BB (`ʻ`). "Yo'l belgilari" ≠ "Yoʻl belgilari" — birinchisi
topilmaydi. Eng ishonchli yo'l: mavzu nomini shu hujjatdan
**nusxalab** qo'yish.

Yangi mavzu kerak bo'lsa u avval bazaga qo'shiladi (hozircha SQL
orqali — admin panelda mavzu qo'shish oynasi hali yo'q).

---

## 4. Yo'l belgisi savollari

`belgi` ustuniga kalit yoziladi va ilova o'sha belgini **chizadi**.
Faqat to'rtta kalit ishlaydi:

| Kalit | Belgi |
|---|---|
| `priority` | Bosh yo'l |
| `noentry` | Kirish taqiqlangan |
| `warning` | Ogohlantiruvchi (qizil hoshiyali uchburchak) |
| `stop` | To'xtash |

Boshqa kalit yozilsa qator **xato** deb belgilanadi. Sababi: savol
"belgi savoli" bo'lib qolardi, lekin rasm chizilmasdi — foydalanuvchi
*"Rasmda ko'rsatilgan belgi nimani anglatadi?"* degan savolni
**rasmsiz** ko'rardi.

Belgi kerak bo'lmasa ustunni bo'sh qoldiring.

Kerakli belgi ro'yxatda bo'lmasa, u avval ilovaga chizilishi kerak —
kalitni o'zboshimchalik bilan yozib qo'yish ishlamaydi.

---

## 5. Nuqtali vergul va qo'shtirnoq

Matn ichida `;` yoki `"` bo'lsa, butun katakni qo'shtirnoq ichiga
oling va ichidagi qo'shtirnoqni ikkilantiring:

```
"YHQ 6-bandi; ""qizil"" signal — toʻxtash"
```

Excel va Google Sheets buni **o'zi** qiladi — jadvalda oddiy yozasiz,
CSV'ga saqlaganda to'g'ri chiqadi.

Admin paneldan **eksport** qilingan fayl ham shu qoida bilan yoziladi,
ya'ni eksport → tahrir → import aylanishi matnni buzmaydi.

---

## 6. Tekshirish nima deydi

| Xabar | Ma'nosi |
|---|---|
| `sarlavha qatorida ustun yo'q: …` | Birinchi qator noto'g'ri yoki ajratgich `;` emas |
| `mavzu bo'sh` | Mavzu ustuni to'ldirilmagan |
| `savol matni juda qisqa` | 15 belgidan kam — deyarli har doim yarim yozilgan savol |
| `variant bo'sh` | To'rtta variantdan biri yo'q |
| `variantlar takrorlangan` | Ikki variant bir xil |
| `to'g'ri javob A–D emas` | `togri` ustunida A/B/C/D dan boshqa narsa |
| `noma'lum belgi kaliti` | `belgi` ustunida ro'yxatdan tashqari kalit (§4) |
| `ID bazada mavjud` | Shu `id` bilan savol allaqachon bor |
| `faylda takrorlangan ID` | Bitta `id` faylda ikki marta |
| `izoh yo'q` (sariq) | **Xato emas** — ogohlantirish. Savol qo'shiladi |

---

## 7. Amaliy maslahatlar

- **Kichik to'plamlardan boshlang.** 700 tani birdan qo'yishdan oldin
  20 ta bilan sinab ko'ring: format to'g'riligini bir marta
  tekshirib olish 700 qatorni qayta tahrirlashdan arzon.
- **Mavzu bo'yicha guruhlab kiriting.** Bitta mavzuni to'liq
  tugatib, keyin keyingisiga o'tish ko'rib chiqishni osonlashtiradi.
- **Manbani yozib boring.** Qaysi savol qaysi qoida bandidan
  olinganini alohida ustunda saqlash (import qilinmaydi, lekin
  jadvalda qoladi) keyin xatolarni tekshirishda juda yordam beradi.
- **Javob kalitiga ikki marta qaraysiz.** Noto'g'ri kalit — imtihonga
  tayyorlanayotgan odam uchun eng og'ir zarar. Shu sababli baza
  «to'rt ko'z» qoidasini majburlaydi: kalit o'zgarsa savol ko'rib
  chiqishga qaytadi va **o'zgartirgan odam o'zi nashr eta olmaydi**.

---

## 8. Keyin nima bo'ladi

Import → **qoralama** → ko'rib chiqish → **nashr etilgan** → ilovada
ko'rinadi.

Nashr etilgan savollar foydalanuvchilarga internet orqali yetadi
(`published_questions`), qurilmada saqlanadi va internetsiz ham
ishlaydi. Ilova ichidagi boshlang'ich to'plam esa zaxira bo'lib
qoladi — baza yo'q bo'lsa ham ilova ishlaydi.
