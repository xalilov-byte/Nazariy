-- ═══════════════════════════════════════════════════════════════════════
--  NAZARIY — 0005: rasmiy avtotest savollari (301 ta)
--
--  BU FAYL QO'LDA TAHRIR QILINMAYDI — u generator bilan yasaladi:
--      node tools/mkbank.mjs <hujjat.docx>   → content/bank.json
--      node tools/mkbankseed.mjs             → shu fayl
--
--  Hammasi 'draft' holatida yoziladi va FOYDALANUVCHIGA KO'RINMAYDI.
--  Sababi: javob kaliti hujjatda matn bilan berilmagan, u variant
--  yonidagi yashil nuqtaning koordinatasidan hisoblab topilgan
--  (key_source = 'docx-geometry'). 280 ta savolda o'zbekcha va
--  ruscha nuqta bir xil variantni ko'rsatdi — shuning uchun ularga
--  kalit yozilgan. Qolgan 21 tasida kalit null:
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
  ('umumiy-qoidalar', 'Umumiy qoidalar', 1),
  ('yol-belgilari', 'Yoʻl belgilari', 2),
  ('tezlik-rejimi', 'Tezlik rejimi', 3),
  ('chorrahalar', 'Chorrahalar', 4),
  ('svetofor', 'Svetofor', 5),
  ('quvib-otish', 'Quvib oʻtish', 6),
  ('toxtab-turish', 'Toʻxtab turish', 7),
  ('birinchi-yordam', 'Birinchi yordam', 8),
  ('manyovr', 'Manyovr va burilish', 9),
  ('shatak-yuk', 'Shatak, tirkama va yuk', 10),
  ('texnik-holat', 'Texnik holat va jihoz', 11)
on conflict (slug) do update set name = excluded.name, sort_order = excluded.sort_order;

-- ── Savollar ───────────────────────────────────────────────────────────

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A001', t.id, 'Yengil avtomobilning tormoz yo‘li tormoz tizimiga ega bo‘lmagan tirkama bilan harakatlanayotganda qanday o‘zgaradi?',
       array['Kamayadi, chunki tirkama harakatlanishga qo‘shimcha qarshilik ko‘rsatadi', 'O‘zgarmaydi', 'Ortadi'], null, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как изменяется длина тормозного пути легкового автомобиля при движении с прицепом, не имеющим тормозной системы?', array['Уменьшается, так как прицеп оказывает дополнительное сопротивление движению', 'Не изменяется', 'Увеличивается']
from public.questions where ref = '#A001'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A002', t.id, 'Qaysi belgi tartibga solinmagan piyodalar o‘tish joyiga yaqinlashayotganlik haqida ogohlantiradi?',
       array['"A" va "Б"', '"A"', 'Hammasi'], 1, 'q002.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак предупреждает о приближении к нерегулируемому пешеходному переходу?', array['"A" и "Б"', '"A"', 'Все']
from public.questions where ref = '#A002'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A003', t.id, 'Old chiroqlar va orqa gabarit chiroqlari ishlamayotgan transport vositasi harakatini davom ettirishi taqiqlanadi?',
       array['Faqat yetarli ko‘rinmaslikda ,', 'Faqat kunning qorong‘i vaqtida', 'Barcha javoblarda ko‘rsatilgan holatlarda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Дальнейшее движение транспортного средства при неработающих Фарах и задних габаритных огнях запрещается:', array['Только в условиях недостаточной видимости.', 'Только в темное время суток.', 'В обоих перечисленных случаях.']
from public.questions where ref = '#A003'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A004', t.id, 'Qatnov qismi yo‘l chiziqlari bilan ajratilgan bo‘lsa haydovchilar qanday holatlarda qat‘iy bo‘laklar bo‘yicha harakatlanishlari kerak?',
       array['Faqat harakatlanish bo‘laklari uzliksiz sidirg‘a chiziqlar bilan ajratilgan bo‘lsa', 'Faqat harakatlanish serqatnov bo‘lganda', 'Barcha holatlarda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких случаях на дорогах, проезжая часть которых разделена линиями разметки, водители обязаны двигаться строго по полосам?', array['Только если полосы движения обозначены сплошными линиями разметки', 'Только при интенсивном движении', 'Во всех случаях']
from public.questions where ref = '#A004'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A005', t.id, 'Chorrahdan birinchi bo‘lib kesib o‘tadi',
       array['Ko‘k avtomobil', 'Yashil avtomobil', 'Qizil avtomobil'], 1, 'q005.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Первым проедет перекресток:', array['Синий автомобиль', 'Зелёный автомобиль', 'Красный автомобиль']
from public.questions where ref = '#A005'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A006', t.id, 'Chorrahadan ikkinchi bo‘lib qaysi transport vositasi kesib o‘tadi?',
       array['Yashil avtomobil tramvay bilan bir vaqtda', 'Yashil avtomobil', 'Qizil avtomobil'], 0, 'q006.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Вторым проедет перекресток:', array['Зелёный автомобиль вместе с трамваем одновременно', 'Зелёный автомобиль', 'Красный автомобиль']
from public.questions where ref = '#A006'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A007', t.id, 'Ko‘rsatilgan belgilardan qaysilarining talabi bevosita o‘rnatilgan joyidan kuchga kiradi?',
       array['Faqat Б', 'А va Б', 'Hammasi'], 1, 'q007.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Требования каких знаков из указанных вступают в силу непосредственно в том месте, где они установлены?', array['Только Б', 'А и Б', 'Всех']
from public.questions where ref = '#A007'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A008', t.id, 'Tartibga solinmagan chorrahada qaysi belgi albatta to‘xyashni talab qiladi?',
       array['Faqat А', 'Faqat Б', 'Б va В', 'Hammasi'], 1, 'q008.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из указанных знаков требуют обязательной остановки на нерегулируемом перекрестке?', array['Только А', 'Только Б', 'Б и В', 'Все']
from public.questions where ref = '#A008'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A009', t.id, 'Asosiy yo‘l –',
       array['Tuproqli yo‘lga nisbatan qattiq qoplamali (asfalt va sement-betonli, tosh va shunga o‘xshash qoplamali)', 'Toshli yo‘lga nisbatan asfalt qoplamali yo‘l', 'Ikki bo‘lakli yo‘lga nisbatan uch yoki undan ko‘p bo‘lakli yo‘l', 'Barcha javoblar to‘g‘ri'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Главная дорога:', array['Дорога с твердым покрытием по отношению к грунтовой дороге.', 'Дорога с асфальтобетонным покрытием по отношению к дороге, покрытой брусчаткой.', 'Дорога с тремя или более полосами движения по отношению к дороге с двумя полосами.', 'Во всех перечисленных ответах.']
from public.questions where ref = '#A009'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A010', t.id, 'Qaysi transport vositalari yo‘nalishli transport vositalari hisoblanadi',
       array['Belgilangan yo‘nalishi va bekatlari bo‘lgan, yo‘lovchi tashish uchun mo‘ljallangan umum foydalanishdagi transport vositalalari', 'Avtobuslar', 'Yo‘lovchilarni tashuvchi istalgan transport vositalari'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие транспортные средства относятся к маршрутным транспортным средствам', array['Транспортное средство общего пользования, предназначенное для перевозки пассажиров и имеющее установленный маршрут с остановочными пунктами (остановками)', 'Автобусы', 'Любые транспортные средства, перевозящие пассажиров']
from public.questions where ref = '#A010'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A011', t.id, 'Qo‘l oyoq uchlari (tirsakdan past qismi, boldir) sinishida transport shinalari yoki ularni qo‘lda yasash uchun vositalar bo‘lmasa birinchi tibbiy yordam qanday ko‘rsatiladi?',
       array['Qo‘llarni tana bo‘ylab cho‘zgan holda tanaga bog‘lash, oyoqlarni orasiga yumshoq mato qo‘yib bir-biriga bog‘lash', 'Qo‘llarni tirsakdan bukib, ro‘molga osgan holda tanaga bog‘lash, oyoqlarni orasiga albatta yumshoq mato qo‘yib bir-biriga bog‘lash', 'Qo‘llarni tirsakdan bukib, ro‘molga osgan holda tanaga bog‘lash, oyoqlarni bir-biriga yaxshilab jipslab tekkazib bog‘lash'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как оказывается первая помощь при переломах конечностей, если отсутствуют транспортные шины и подручные средства для их изготовления?', array['Верхнюю конечность, вытянутую вдоль тела, прибинтовывают к туловищу. Нижние конечности прибинтовывают друг к другу, проложив между ними мягкую ткань', 'Верхнюю конечность, согнутую в локте, подвешивают на косынке и прибинтовывают к туловищу. Нижние конечности прибинтовывают друг к другу, обязательно проложив между ними мягкую ткань', 'Верхнюю конечность, согнутую в локте, подвешивают на косынке и прибинтовывают к туловищу. Нижние конечности плотно прижимают друг к другу и прибинтовывают']
from public.questions where ref = '#A011'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A012', t.id, 'Qaysi rasmdagi avtomobil haydovchisi yuk tashish qoidasini buzayapti?',
       array['"Б"', '"A"', '"A" , "Б"'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком рисунке изображен автомобиль, водитель которого нарушает правила перевозки грузов?', array['Только на Б', 'Только на А', 'На обоих']
from public.questions where ref = '#A012'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A013', t.id, 'Qaysi holatlarda aholi punktlarida tovushli ishoralardan foydalanish mumkin?',
       array['Faqat zarur bo‘lgan hollarda yo‘l-transport hodisasining oldini olish uchun', 'Faqat boshqa haydovchilarni quvib o‘tish haqida ogohlantirish uchun', 'Barcha javoblarda ko‘rsatilgan holatlarda'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'quvib-otish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких случаях разрешено применять звуковые сигналы в населенных пунктах?', array['Только для предотвращения дорожно-транспортного происшествия', 'Только для предупреждения о намерении произвести обгон', 'В обоих перечисленных случаях']
from public.questions where ref = '#A013'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A014', t.id, 'Chorrahadan uchinchi bo‘lib qaysi avtomobil kesib o‘tadi?',
       array['Yashil avtomobil', 'Qizil avtomobil', 'Ko‘k avtomobil'], 1, 'q014.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой автомобиль проедет перекресток третьим', array['Зелёный автомобиль', 'Красный автомобиль', 'Синий автомобиль']
from public.questions where ref = '#A014'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A015', t.id, 'Chorrahadan birinchi bo‘lib qaysi transport vositasi kesib o‘tadi?',
       array['Yashil avtomobil', 'Ko‘k avtomobil', 'Qizil avtomobil'], 0, 'q015.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Первым проедет перекресток', array['Зелёный автомобиль', 'Синий автомобиль', 'Красный автомобиль']
from public.questions where ref = '#A015'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A016', t.id, 'Ushbu "50" yozuvli yo‘l belgisi nimani bildradi?',
       array['Yo‘l yoki marshrut raqamini', 'Yo‘lning ushbu qismida tavsiya berilgan tezlikni', 'Yo‘lning ushbu qismida ruxsat berilgan eng yuqori tezlikni'], 2, 'q016.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что обозначает эта разметка с надписью "50"?', array['Номер дороги или маршрута.', 'Рекомендуемую скорость движения на данном участке дороги', 'Разрешенную максимальную скорость движения на данном участке дороги']
from public.questions where ref = '#A016'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A017', t.id, 'Ko‘rsatilgan belgilardan qaysi biri ruxsat etilgan to‘la vazni 3,5 tonnadan oshmaydigan yuk avtomobillariga harakatlanishga ruxsat beradi?',
       array['А va В', 'А va Б', 'В'], 0, 'q017.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из указанных знаков разрешают движение грузовым автомобилям с разрешенной максимальной массой не более 3,5 т?', array['А и В', 'А и Б', 'В']
from public.questions where ref = '#A017'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A018', t.id, 'Ko‘rsatilgan belgilardan qaysi biri texnik tavsifnomasiga yoki holatiga ko‘ra tezligi soatiga 40 kilometrdan kam bo‘lgan transport vositalarining harakatlanishini taqiqlaydi?',
       array['Только А', 'Только В', 'А и Б'], 0, 'q018.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из указанных знаков запрещают движение транспортных средств, скорость которых по технической характеристике или их состоянию менее 40 км/ч?', array['Только А', 'Только В', 'А и Б']
from public.questions where ref = '#A018'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A019', t.id, 'Turar joy dahalarida piyodalar yo‘lning qaysi qismida harakatlanishilari kerak?',
       array['Faqat trotuar bo‘yicha', 'Qatnov qismi chetida bir qator bo‘lib', 'Trotuardan yoki qatnov qismidan'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Где могут двигаться пешеходы в жилой зоне?', array['Только по тротуарам', 'В один ряд по краю проезжей части', 'По тротуарам и по проезжей части']
from public.questions where ref = '#A019'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A020', t.id, 'Ruxsat etilgan to‘la vazni bu - ...',
       array['Transport vositasining yuki, haydovchi va yo‘lovchilari bilan birgalikdagi vazni', 'Aslahalangan transport vositasining ishlab chiqargan korxona tomonidan belgilangan, yuksiz, haydovchisiz va yo‘lovchilarsiz eng yuqori vazni (o‘lchovi)', 'Aslahalangan transport vositasining ishlab chiqargan korxona tomonidan belgilangan, yuk, haydovchi va yo‘lovchilari bilan birgalikdagi eng yuqori vazni (o‘lchovi)'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что называется разрешенной максимальной массой транспортного средства', array['Масса транспортного средства с грузом, водителем и пассажирами', 'Максимальная масса (величина) снаряженного транспортного средства без груза, без водителя и без пассажирами, установленная предприятием- изготовителем', 'Максимальная масса (величина) снаряженного транспортного средства с грузом, водителем и пассажирами, установленная предприятием- изготовителем']
from public.questions where ref = '#A020'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A021', t.id, 'To‘la vazni 3,5 tonnadan oshmaydigan yuk avtomobillarini quyidagilar bilan jihozlanmagan bo‘lsa ham foydalanishga ruxsat etiladi:',
       array['Tibbiyot qutichasi', 'O‘t o‘chirgich', 'Majburiy to‘xtaganini bildiruvchi belgi (yoki miltillovchi qizil chiroq)', 'O‘zi yurib ketishidan saqlovchi, g‘ildirak diametriga muvofiq (kamida 2ta) tirgak'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'svetofor'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается эксплуатация грузовых автомобилей с разрешенной максимальной массой не более 3.5 тн. при отсутствии:', array['Аптечки', 'Огнетушителя', 'Знака аварийной остановки', 'Противооткатного устройства соответствующего диаметру колеса (минимум 2)']
from public.questions where ref = '#A021'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A022', t.id, 'Qaysi holatlarda jabrlanuvchiga yurak-o‘pka reanimatsiyasini boshlash kerak?',
       array['Yurak sohasida og‘riq sezilganda va nafas olish qiyinlashganda', 'Hushidan ketishda, nafas olish faoliyatidan qat‘iy nazar', 'Hushidan ketishda, nafas olish faoliyati va qon aylanishi to‘xtaganda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких случаях следует начинать сердечно-легочную реанимацию пострадавшего?', array['При наличии болей в области сердца и затрудненного дыхания', 'При отсутствии у пострадавшего сознания, независимо от наличия дыхания', 'При отсутствии у пострадавшего сознания, дыхания и кровообращения']
from public.questions where ref = '#A022'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A023', t.id, 'Kunning yorug‘ vaqtida harakatlanayotgan qaysi rasmdagi avtomobil haydovchisi yuk tashish qoidasini buzayapti?',
       array['Faqat А', 'Har ikki rasmda', 'Hech kim buzmayapti'], 2, 'q023.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком рисунке изображен автомобиль, водитель которого нарушает правила перевозки грузов при движении в светлое время суток?', array['Только на А', 'На обоих рисунках', 'Никто не нарушает']
from public.questions where ref = '#A023'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A024', t.id, 'Avtomagistralda to‘xtashga ruxsat etiladi:',
       array['Faqat qatnov qismini chetini bildiruvchi chiziqdan chetda', '5.15 yoki 6.11 yo‘l belgilari bilan belgilangan maxsus to‘xtab turish maydonchalarida', 'Qatnov qismini chetda barcha joyda'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Остановка на автомагистрали разрешена:', array['Только правее линии разметки, обозначающей край проезжей части', 'Только на специальных площадках для стоянки, обозначенными знаками 5.15 или 6.11', 'В любых местах за пределами проезжей части']
from public.questions where ref = '#A024'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A025', t.id, 'Chorrahani ikkinchi bo‘lib kesib o‘tadi',
       array['Tramvay', 'Mototsikl', 'Avtomobil'], 2, 'q025.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Вторым проедет перекресток:', array['Трамвай', 'Мотоцикл', 'Автомобиль']
from public.questions where ref = '#A025'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A026', t.id, 'Chorrahadan oxirgi bo‘lib qaysi transport vositasi kesib o‘tadi',
       array['Velosiped', 'Avtobus', 'Avtomobil'], 2, 'q026.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Последним проедет перекресток', array['Велосипед', 'Автобус', 'Автомобиль']
from public.questions where ref = '#A026'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A027', t.id, 'Agar piyodalar o‘tish joylaridan keyin tirbandlik paydo bo‘lsa haydovchi qayerga to‘xtashi kerak?',
       array['Bevosita piyodalar o‘tish joyi oldida', 'Piyodalar o‘tish joyida, agar piyodalar bo‘lmasa', 'Piyodalar o‘tish joyiga 5 m yetmasdan'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Где необходимо остановиться водителю, если сразу за пешеходным переходом образовался затор?', array['Непосредственно перед пешеходным переходом', 'На пешеходном переходе, если нет пешеходов', 'Не ближе 5 м до пешеходного перехода']
from public.questions where ref = '#A027'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A028', t.id, 'Ko‘rsatilgan qaysi yo‘l belgisi yengil yo‘nalishsiz taksilarga yo‘lovchilarni tushirish-chiqarish (yuklarni ortish- tushirish) vaqtida ta‘sir qilmaydi?',
       array['Faqat "A"', 'Faqat "Б"', 'Faqat "Б" "C" "Д"', 'Hammasi'], 3, 'q028.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из этих указанных знаков не действует на легковые немаршрутные такси при посадке — высадке пассажиров (погрузке — выгрузке грузов)?', array['Только "A"', 'Только "Б"', 'Только "Б" "C" "Д"', 'Все знаки']
from public.questions where ref = '#A028'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A029', t.id, 'Bu qo‘shimcha-axborot yo‘l belgisi qaysi yo‘l belgisi bilan birgalikda qo‘llaniladi?',
       array['А', 'Б', 'С'], 1, 'q029.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'С каким дорожным знаком применяется эта табличка?', array['А', 'Б', 'С']
from public.questions where ref = '#A029'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A030', t.id, 'Trotuar va piyodalar yo‘lkasi bo‘lmaganda bolalar guruhini yo‘lda qanday tartibda olib yurish mumkin?',
       array['Qatnov qismi chetidan katta yoshdagilar kuzatuvida olib yurishga ruxsat etiladi', 'Yo‘l yoqasidan faqat kunduzi va katta yoshdagilar kuzatuvida olib yurishga ruxsat etiladi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как водить группы детей при отсутствии пешеходных дорожек и тротуара', array['С края проезжей части в сопровождении взрослых', 'По обочинам, только в светлое время суток и в сопровождении взрослых']
from public.questions where ref = '#A030'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A031', t.id, 'Harakatlanish bo‘lagidagi uchburchak shaklidagi chiziq',
       array['Yo‘lning xavfli qismini bildiradi', 'Yo‘l berishingiz kerak bo‘lgan joy yaqinlashayotganligi haqida ogohlantiradi', 'To‘xtashingiz zarur bo‘lgan joyni bildiradi'], null, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A032', t.id, 'Harakatlanish bo‘lagidagi uchburchak shaklidagi chiziq',
       array['Yo‘lning xavfli qismini bildiradi', 'Yo‘l berishingiz kerak bo‘lgan joy yaqinlashayotganligi haqida ogohlantiradi', 'To‘xtashingiz zarur bo‘lgan joyni bildiradi'], null, 'q032.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A033', t.id, 'Siz to‘g‘ri yo‘lga harakatlanayotib to‘satdan yo‘lning qisman katta bo‘lmagan sirpanchiq qismiga duch keldingiz. Bunda qanday ehtiyot choralarini ko‘rasiz?',
       array['Avtomobilni ohista to‘xtatish', 'Rulni burib sirpanchiqdan chiqib ketish', 'Harakat yo‘nalishini va tezlikni o‘zgartirmasdan ehtiyotkorlik bilan o‘tib ketish'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Двигаясь в прямом направлении, Вы внезапно попали на небольшой участок скользкой дороги. Что следует предпринять?', array['Плавно затормозить', 'Повернуть руль, чтобы съехать с этого участка дороги', 'Проехать не меняя траектории и скорости движения']
from public.questions where ref = '#A033'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A034', t.id, 'Mexanik transport vositalarini shatakka olishda egiluvchan ulagichga kamidan nechta ogohlantiruvchi qurilma o‘rnatiladi?',
       array['Kamida ikkita', 'Kamida uchta', 'Kamida bitta'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Не менее скольких предупредительных устройств должно устанавливаться при буксировке на гибкой сцепке?', array['Не менее двух', 'Не менее трех', 'Не менее одного']
from public.questions where ref = '#A034'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A035', t.id, 'Temir yo‘l kesishmalari va ularga yaqin joylarda quvib o‘tishga tegishli qanday yo‘l harakati qoidalari amal qiladi?',
       array['Temir yo‘l kesishmalarida va ularga 100 m dan kam masofa qolganda quvib o‘tish taqiqlanadi', 'Quvib o‘tish faqat temir yo‘l kesishmalaridan keyin taqiqlanadi', 'Temir yo‘l kesishmalarida va ularga 100 m dan kam masofa qolganda va temir yo‘l keshimalaridan keyin 100 metr davomida quvib o‘tish taqiqlanadi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие ограничения, относящиеся к обгону, действуют на железнодорожных переездах и вблизи них?', array['Обгон запрещен на переезде и ближе чем за 100 м перед ним.', 'Обгон запрещен только на переезде.', 'Обгон запрещен на переезде и на расстоянии 100 м до и после него.']
from public.questions where ref = '#A035'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A036', t.id, 'Sariq avtomobil chorrahani nechanchi bo‘lib kesib o‘tadi?',
       array['Uchinchi bo‘lib', 'Ikkinchi bo‘lib', 'Oxirgi bo‘lib'], 2, 'q036.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Жёлтый автомобиль проедет перекресток:', array['Третьим', 'Вторым', 'Последним']
from public.questions where ref = '#A036'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A037', t.id, 'Turar joy dahasidan yo‘lga chiqishda yo‘l berish zarur:',
       array['O‘ng tomondan yaqinlashib kelayotgan transport vositalariga', 'Chap tomondan yaqinlashib kelayotgan transport vositalariga', 'Ko‘k rangli yalt-yalt etuvchi chiroqcha-mayoqcha yoqilgan transport vositalariga', 'Barcha transport vositalariga'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При выезде из жилой зоны необходимо уступить Дорогу:', array['Только транспортным средствам, приближающимся справа', 'Только транспортным средствам, приближающимся слева', 'Только транспортным средствам с включенным синим проблесковым маячком', 'Всем транспортным средствам']
from public.questions where ref = '#A037'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A038', t.id, 'Svetofor ishoralari imtiyoz belgilari talablariga zid kelgan hollarda:',
       array['Haydovchilar svetofor ishoralariga amal qilishlari kerak', 'Haydovchilar imtiyoz belgilariga amal qilishlari kerak'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'svetofor'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В случае, если значение сигналов светофора противоречат требованиям дорожных знаков приоритета:', array['Водители должны руководствоваться сигналами светофора', 'Водители должны руководствоваться требованиям знаков приоритета']
from public.questions where ref = '#A038'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A039', t.id, 'Ko‘rsatilgan belgilardan qaysi biri faqat shu belgi o‘rnatilgan bo‘lakka ta‘sir qiladi?',
       array['Б va В', 'Faqat Б', 'Faqat А'], 2, 'q039.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из указанных знаков распространяет свое действие только на ту полосу, над которой он установлен?', array['Б и В', 'Только Б', 'Только А']
from public.questions where ref = '#A039'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A040', t.id, 'Yo‘lovchilarga taqiqlanadi:',
       array['Transport vositalari harakatlanayotgan vaqtda haydovchi boshqaishdan chalg‘itish va unga xalaqit berish', 'Harakatlanayotgan bortli yuk avtomobillarida tik turish, bortlarda yoki undan yuqori yuk ustida o‘tirish', 'Transport vositasi harakatlanayotgan vaqtda uning eshini ochish', 'Barcha ko‘rsatilgan javoblar to‘g‘ri'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Пассажирам запрещается:', array['Отвлечение внимания и создание препятствий водителю во время движения автомобиля', 'Стоя прямо в движущемся бортовом грузовике, сидя на борту или на грузе над ним', 'Откройте двери автомобиля во время его движения', 'Все показанные ответы верны']
from public.questions where ref = '#A040'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A041', t.id, 'Harakatlanish tasmasi:',
       array['Yo‘lning relssiz transport vositalari harakati uchun mo‘ljallangan qismi', 'Yo‘lning yonma-yon joylashgan qatnov qismlarini ajratuvchi, transport vositalari harakatlanishi yoki to‘xtashi uchun mo‘jallanmagan, yo‘l sathidan baland va (yoki) 1,1 yotiq chizig‘i bilan belgilangan qismi', 'Avtomobillarning bir qator bo‘lib harakatlanishi uchun yetarlicha keng bo‘lgan, yo‘l chiziqlari bilan belgilangan yoki belgilanmagan yo‘l qatnov qismining har qanday bo‘ylama bo‘lagi'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Полоса движения:', array['Часть дороги, предназначенная для движения безрельсовых транспортных средств', 'Элемент дороги, разделяющий смежные проезжие части и не предназначенный для движения и остановки транспортных средств, расположенный выше уровня дороги и (или) обозначенный дорожной разметкой 1.1', 'Любая из продольных полос проезжей части, обозначенная или необозначенная дорожной разметкой и имеющая ширину, достаточную для движения автомобилей в один ряд']
from public.questions where ref = '#A041'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A042', t.id, 'M toifadagi transport vositalari bu:',
       array['Kamida to‘rt g‘ildirakka ega bo‘lgan va yo‘lovchilarni tashish uchun foydalaniladigan mexanik transport vositalari', 'Yuk tashish uchun mo‘ljallangan, eng katta vazni 3,5 t dan oshmaydigan avtotransport vositalari', 'Tirkamalar (yarim tirkamalar ham)'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Автотранспортное средство категории М:', array['Механические автотранспортные средства, имеющие не менее четырех колес и используемые для перевозки пассажиров', 'Автотранспортные средства, предназначенные для перевозки грузов, максимальная масса которых не превышает 3,5 т', 'Прицепы (включая полуприцепы)']
from public.questions where ref = '#A042'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A043', t.id, 'Qaysi rasmdagi avtomobil haydovchisi yuk tashish qoidasini buzayapti?',
       array['А', 'Б', 'А va Б'], null, 'q043.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком рисунке изображен автомобиль, водитель которого нарушает правила перевозки ГРУЗ', array['А', 'Б', 'А и Б']
from public.questions where ref = '#A043'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A044', t.id, 'O‘ng tomondagi yondosh hududan foydalanib qayrilib olishning ko‘rsatilgan qaysi usuli harakat xavfsizligini ta‘minlaydi:',
       array['Faqat chap tomondagi suratda', 'Faqat o‘ng tomondagi suratda', 'Har ikki suratda'], 0, 'q044.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Способ разворота с использованием прилегающей территории справа. обеспечивающий безопасность движения, показан:', array['Только на левом рисунке', 'Только на правом рисунке', 'На обоих рисунках']
from public.questions where ref = '#A044'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A045', t.id, 'Chorrahani oxirgi bo‘lib qaysi transport vositasi kesib o‘tadi',
       array['Ko‘k avtomobil', 'Qizil avtomobil', 'Yashil avtomobil'], 1, 'q045.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Последним проедет перекресток', array['Синий автомобиль', 'Красный автомобиль', 'Зелёный автомобиль']
from public.questions where ref = '#A045'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A046', t.id, 'Balandlika yo‘l chetida to‘siq mavjud bo‘lganda to‘xtagan avtomobilni joyidan g‘ildirab ketishini oldini olish uchun oldingi g‘ildiraklarni burib qo‘yish usuli qaysi javobda to‘g‘ri:',
       array['А ва Г', 'А ва В', 'Б ва В', 'Б ва Г'], 1, 'q046.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В случае остановки на подъеме при наличии тротуара можно предотвратить самопроизвольное скатывание автомобиля, повернув его передние колеса в положение:', array['А и Г', 'А и В', 'Б и В', 'Б и Г']
from public.questions where ref = '#A046'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A047', t.id, 'Chapga burilayotgan sariq avtomobil haydovchisi qaysi bo‘lakni egallashi kerak?',
       array['O‘ng bo‘lakni', 'Chap bo‘lakni', 'O‘rta bo‘lakni', 'Istalgan bo‘lakni'], 3, 'q047.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Жёлтый автомобиль поворачивая налево какую полосу должен занимать?', array['Правую полосу', 'Левую полосу', 'Среднюю полосу', 'Любую полосу']
from public.questions where ref = '#A047'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A048', t.id, 'Qaysi yo‘l belgilari yo‘nalishsiz transport vositalariga chapga burilishni taqiqlaydi?',
       array['Faqat "A"', '"A" va "Б"', '"A" va "B"', 'Hammasi'], 2, 'q048.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из указанных знаков запрещают поворот налево?', array['Только А', 'А и Б', 'А и В', 'Все']
from public.questions where ref = '#A048'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A049', t.id, 'Ushbu yo‘l belgisi qanday nomlanadi:',
       array['Xavfli yuk tashiyotgan transport vositasining harakati taqiqlangan', 'Katta o‘lchamli yuklarni tashish taqiqlangan', 'Yuk avtomobillari bilan quvib o‘tish taqiqlangan'], 0, 'q049.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как называется этот дорожный знак:', array['Движение транспортного средств перевозящего опасные грузы, запрещено', 'Перевозка крупногабаритных грузов запрещена', 'Обгон грузовых автомобилей запрещен']
from public.questions where ref = '#A049'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A050', t.id, 'Yo‘lning qatnov qismi-...',
       array['Yo‘lning relssiz transport vositalari harakati uchun mo‘ljallagan qismi', 'Yo‘lning transport vositalari harakati uchun mo‘ljallagan qismi', 'Yo‘lning avtomobillar harakati uchun mo‘ljallagan qismi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Проезжая часть дороги:', array['Часть дороги, предназначенная для движения безрельсовых транспортных средств', 'Часть дороги, предназначенная для движения транспортных средств', 'Часть дороги, предназначенная для движения автомобилей']
from public.questions where ref = '#A050'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A051', t.id, 'Haydovchi yo‘lning relssiz transport vositalari harakatlanayotgan bo‘laklar sonini belgilaydigan chiziqlar yoki yo‘l belgilari bo‘lmasa, bo‘laklar sonini qanday aniqlash kerak?',
       array['Qantov qismining kengligi, transport vositalari orasidagi zarur yonlama oraliq masofani va ularning gabarit o‘lchamlarini hisobga olgan holda o‘zi aniqlidi', 'Bunday yo‘lni ikki bo‘lakli qarama qarshi harakat tashkil qilingan yo‘l deb qabul qilish kerak'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как водителю определять количество полос движения дороги, если нет разметки или дорожных знаков, указывающей количество полос движения для безрельсовых транспортных средств?', array['Самими водителями, с учётом ширины проезжей части, габаритов транспортных средств и необходимых интервалов между ними', 'Такую дорогу следует рассматривать как двух полосная дорога, на котором организовано двустороннее движение']
from public.questions where ref = '#A051'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A052', t.id, 'Qaysi javobda orqaga harakatlanish taqiqlangan joylar ko‘rsatilgan?',
       array['Piyodalarning o‘tish joyida', 'Tunnellarda', 'Chorrahalarda', 'Barcha javoblar to‘g‘ri'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком ответе правильно указан места где запрещается движение задним ходом?', array['На пешеходных переходах', 'В тоннелях', 'На перекрестках', 'Во всех перечисленных случаях']
from public.questions where ref = '#A052'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A053', t.id, 'Shatakka olingan avtobusda odam tashishga ruxsat etiladimi?',
       array['Ruxsat beriladi', 'Taqiqlanadi', 'Faqat o‘tirgan holda tashishga ruxsat beriladi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли перевозить людей в буксируемом автобусе?', array['Разрешается', 'Запрещается', 'Разрешается только сидячим пассажирам']
from public.questions where ref = '#A053'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A054', t.id, '108 km/s tezlikda harakatlanayotgan avtomobil 1 sekundda qancha masofani bosib o‘tadi?',
       array['15 m', '25 m', '30 m'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какое расстояние проедет транспортное средство за одну секунду при скорости движения 108 км/ч?', array['15 м', '25 м', '30 м']
from public.questions where ref = '#A054'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A055', t.id, 'Chap tomondagi yondosh hududdan foydalanib qayrilib olishning ko‘rsatilgan qaysi usuli harakat xavfsizligini ta‘minlaydi:',
       array['Faqat chap tomondagi rasmda', 'Faqat o‘ng tomondagi rasmda', 'Ikkisida ham'], 1, 'q055.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Способ разворота с использованием прилегающей территории слева, обеспечивающий безопасность движения, показан:', array['Только на левом рисунке', 'Только на правом рисунке', 'На обоих рисунках']
from public.questions where ref = '#A055'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A056', t.id, 'Chorrahadan oxirgi bo‘lib qaysi transport vositasi kesib o‘tadi:',
       array['Qizil avtomobil', 'Oq avtomobil sariq bilan bir vaqtda', 'Sariq avtomobil'], 1, 'q056.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Последним проедет перекресток:', array['Красный автомобиль', 'Белый автомобиль одновременно с желтым автомобилем', 'Желтый автомобиль']
from public.questions where ref = '#A056'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A057', t.id, 'Yengil avtomobil burilishda ag‘darilib ketishga qarshi turg‘unroq:',
       array['Yo‘lovchisiz va yuksiz', 'Yo‘lovchisiz, biroq yuqori yukxonasidagi yuki bilan', 'Yo‘lovchilari va yuksiz', 'Yo‘lovchi va yuki bilan'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Более устойчив против опрокидывания на повороте легковой автомобиль:', array['Без пассажиров и груза', 'Без пассажиров, но с грузом на верхнем багажнике', 'С пассажирами, но без груза', 'С пассажирами и грузом']
from public.questions where ref = '#A057'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A058', t.id, 'Qaysi transport vositasiga harakatlanish taqiqlangan?',
       array['Motosiklga', 'Hech kimga taqiqlanmagam', 'Yuk avtomobiliga'], 2, 'q058.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какому транспортному средству движение запрещено?', array['Мотоциклу', 'Никому не запрещено', 'Грузовому автомобилю']
from public.questions where ref = '#A058'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A059', t.id, 'Piyodalar to‘xtab turgan avtobus va trolleybusning qaysi tomonidan yo‘lni kesib o‘tishlari kerak?',
       array['Oldi tomonidan', 'Orqa tomonidan', 'Istalgan tomonidan'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Пешеходы при пересечении дороги с какой стороны обязаны обходить стоящий автобус и троллейбус?', array['Спереди', 'Сзади', 'С любой стороны']
from public.questions where ref = '#A059'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A060', t.id, 'Ushbu yo‘l belgisi:',
       array['Qatnov qismida to‘suvchi qurilma borligini bildiradi', 'Temir yo‘l kesishmasi oldida to‘suvchi qurilma borligini bildiradi', 'Chorraha oldida to‘suvchi qurilma borligini bildiradi'], 1, 'q060.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Этот дорожный знак:', array['Обозначает что, на проезжей части имеется заградительное устройство', 'Обозначает что, перед железнодорожным переездам заградительное устройство', 'Обозначает что, перед перекрестком заградительное устройство']
from public.questions where ref = '#A060'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A061', t.id, 'Haydovchi o‘zidan oldinda harakatlanayotgan transport vositasi bilan qancha oraliq masofa saqlab harakatlanishi kerak?',
       array['20 m', '50 m', 'Haydovchi o‘zidan oldinda harakatlanayotgan transport vositasi keskin tormoz berganida to‘qnashib ketmasligi kafolatini beradigan darajada oraliq masofani saqlash kerak'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какую дистанцию должен соблюдать водитель до движущегося впереди транспортного средства?', array['20 м', '50 м', 'Водитель должен соблюдать такую дистанцию до движущегося впереди транспортного средства, которая гарантировала бы избежание столкновения в случае его экстренной остановки']
from public.questions where ref = '#A061'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A062', t.id, 'Rasmda ko‘rsatilgan chorahha-...',
       array['Tartibga solinmagan, teng ahamiyatga ega bo‘lmagan yo‘llar kesishgan chorraha', 'Tartibga solinmagan, teng ahamiyatga ega bo‘lgan yo‘llar kesishgan chorraha', 'Tartibga solingan chorraha'], 2, 'q062.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На рисунке изображена:', array['Нерегулируемый перекресток неравнозначных дорог', 'Нерегулируемый, равнозначный перекресток', 'Регулируемый перекресток']
from public.questions where ref = '#A062'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A063', t.id, 'Avtomobil haydovchisi qayrilib olmoqchi:',
       array['Chorrahaga birinchi bo‘lib o‘tadi', 'Tramvayga yo‘l berib qayrilib oladi'], 1, 'q063.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Водитель автомобиля намерен развернуться:', array['Проедет перекресток первым', 'Выполняет разворот, уступив дорогу трамваю']
from public.questions where ref = '#A063'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A064', t.id, 'Yo‘lning xavfli burilishlarida oldingi uzatmali avtomobilning orqa o‘qi yon tomonga sirpanayotganda siz qanday harakat qilasiz?',
       array['Gaz berishni kamaytirib rul chambaragi bilan boshqaruvni barqarorlashtirasiz', 'Tormozlab turib rul chambaragini sirpangan tomonga burasiz', 'Gaz pedalini ohista bosib, avtomobilni rul chambaragini to‘g‘irlab, avtomobil sirpanishdan olib chiqib ketasiz', 'Gaz pedalini ko‘proq bosib, avtomobilni rul chambaragini o‘zgartirmasdan sirpanishdan olib chiqasiz'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На повороте возник занос задней оси переднеприводного автомобиля. Ваши действия?', array['Уменьшите подачу топлива, рулевым колесом стабилизируете движение', 'Притормозите и повернёте рулевое колесо в сторону заноса', 'Слегка увеличите подачу топлива, корректируя направление движения рулевым колесом', 'Значительно увеличите подачу топлива, не меняя положения рулевого колеса']
from public.questions where ref = '#A064'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A065', t.id, 'Avtomobilning ABS tizimi burilishda sirpanish va yonga siljishni oldini oladimi?',
       array['Avtomobil faqat sirpanish ehtimolining oldini oladi', 'Avtomobil faqat yonga siljish ehtimolining oldini oladi', 'Avtomobil sirpanish va yonga sirpanishini oldini olmaydi'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Исключает ли антиблокировочная тормозная система (ABS возможность возникновения заноса или сноса при прохождении поворота?', array['Полностью исключает возможность возникновения только заноса', 'Полностью исключает возможность возникновения только сноса', 'Не исключает возможность возникновения сноса или заноса']
from public.questions where ref = '#A065'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A066', t.id, 'Motosikl haydovchisi qo‘lini yuqoriga ko‘tarib nima haqida axborot berayapti:',
       array['Harakatni davom ettirish haqida', 'O‘ngga burilmoqchi ekanligi haqida', 'To‘xtash haqida'], 2, 'q066.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Поднятая вверх рука водителя мотоцикла является сигналом, информирующим Вас о его намерении:', array['Продолжить движение прямо', 'Повернуть направо', 'Об остановке']
from public.questions where ref = '#A066'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A067', t.id, 'Yo‘l to‘sig‘iga chizilgan tik chiziq nimani bildiradi?',
       array['Temir yo‘l kesishmasiga yaqinlashayotganlik haqida', 'Xavfli chorrahaga yaqinlashayotganlik haqida', 'Yo‘lning kichik rauisli burilish, tik nishablik va boshqa xavfli joylarda yo‘l to‘siqlarining yon yuzalarini bildiradi'], 2, 'q067.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'О чем обозначает Вас вертикальная разметка, нанесенная на ограждение дороги?', array['Обозначает приближении к железнодорожному переезду', 'Обозначает приближении к опасному перекрестку', 'Обозначает боковые поверхности ограждений дорог на закруглениях малого радиуса, крутых спусках, других опасных участках']
from public.questions where ref = '#A067'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A068', t.id, 'Qaysi belgilar axborot-ko‘rsatkich belgilari?',
       array['1 va 2', '3 va 4', '2 va 3', '1 va 4'], 2, 'q068.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки являются информационно-указательным?', array['1 и 2', '3 и 4', '2 и 3', '1 и 4']
from public.questions where ref = '#A068'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A069', t.id, 'Qaysi yo‘l belgilari yo‘lning tor qismida haydovchiga ustunlik beradi?',
       array['Faqat "B"', '"A" va "B"', '"Б" va "B"', '"Б" va "Г"'], 3, 'q069.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При наличии каких знаков водитель пользуется преимуществом, если встречный разъезд затруднен препятствием?', array['Только В', 'А и В', 'Б и В', 'Б и Г']
from public.questions where ref = '#A069'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A070', t.id, 'Ushbu yo‘l belgilari qanday maqsadda qo‘llaniladi?',
       array['Majburiy tarzda tezlikni kamaytirish uchun', 'Keskin tormoz berish uchun', 'Ehtiyot choralarini ko‘rish uchun'], 0, 'q070.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'С какой целью применяется этот дорожный знак?', array['Для принудительного снижения скорости движения', 'Для резкого торможения', 'Для принятия меры предосторожности']
from public.questions where ref = '#A070'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A071', t.id, 'Qaysi belgi yo‘lning kichik radiusli xavfli burilish joyiga yaqinlashayotganlik haqida ogohlantiradi?',
       array['1', '2', '3', '4'], 3, 'q071.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак предупреждают что впереди имеется закругление дороги малого радиуса?', array['1', '2', '3', '4']
from public.questions where ref = '#A071'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A072', t.id, 'Rasmda ko‘rsatilgan chorhha-...',
       array['Tartibga solinmagan, teng ahamiyatga ega bo‘lmagan yo‘llar kesishadigan chorraha', 'Tartibga solinmagan, teng ahamiyatga ega bo‘lgan yo‘llar kesishadigan chorraha', 'Tartibga solingan chorraha'], 0, 'q072.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На рисунке изображена-...', array['Нерегулируемый, перекресток неравнозначных дорог', 'Нерегулируемый, равнозначный перекресток', 'Регулируемый перекресток']
from public.questions where ref = '#A072'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A073', t.id, 'Aylanma harakatlanish chorrahasida:',
       array['Harakatlanayotgan transport vositalari aylanaga kirib kelayotgan transport vositalariga nisbatan ustunlikka (imtiyozga) ega', 'Harakatlanayotgan transport vositalariga nisbatan aylanaga kirib kelayotgan transport vositalari ustunlikka (imtiyozga) ega'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На перекрёстке кругового движения:', array['Транспортные средства, движущиеся на перекрестке с круговым движением, имеют приоритет (преимущество) по отношению к транспортным средствам, въезжающим на перекресток', 'Транспортные средства въезжающий на перекресток имеют приоритет (преимущество) по отношению к транспортным средствам движущиеся на перекрестке']
from public.questions where ref = '#A073'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A074', t.id, 'Ushbu qo‘shimcha yo‘l belgisi bildiradi :',
       array['Belgi ta‘sir oralig‘ida to‘xtagan transport vositalari majburiy evakuatsiya qilinishini ko‘rsatadi', 'Belgi ta‘sir oralig‘ida to‘xtagan transport vositalarini evakuatsiya qilinish ruxsat etilganligini bildiradi', 'Belgi ta‘sir oralig‘ida to‘xtagan transport vositalarini evakuatsiya qilin taqiqlanganligini bildiradi'], 0, 'q074.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Эта табличка означает:', array['Указывает на принудительную эвакуацию автомобилей, остановившихся в зоне действие знака', 'Разрешает эвакуацию остановившихся транспортных средств в зоне действие знака', 'Запрещает эвакуацию остановившихся транспортных средств в зоне действие знака']
from public.questions where ref = '#A074'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A075', t.id, 'Qaysi belgi ikkinchi darajali yo‘l bilan tutashuvni bildiradi?',
       array['1', '2', '3', '4'], 1, 'q075.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак обозначает примыкание второстепенной дороги?', array['1', '2', '3', '4']
from public.questions where ref = '#A075'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A076', t.id, 'Agar avtomobilning o‘ng g‘ildiraklari nam qoplamali yo‘l yoqasiga chiqib qolsa, tavsiya etiladi:',
       array['Avtomobilni tormozlash va to‘liq to‘xtatish', 'Avtomobilni tormozlab, yo‘lning qatnov qismiga ohista ravon burish', 'Avtomobilni tormozlamasdan yo‘lning qatnov qismiga ohista ravon burish'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В случае, когда правые колёса автомобиля наезжают на неукреплённую влажную обочину, рекомендуется:', array['Затормозить и полностью остановиться', 'Затормозить и плавно направить автомобиль на проезжую часть', 'Не прибегая к торможению, плавно направить автомобиль на проезжую часть']
from public.questions where ref = '#A076'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A077', t.id, 'Qaysi rasmda ajratuvchi mintaqa ko‘rsatilgan?',
       array['hech qaysi', 'В', 'А va Б'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком рисунков показано разделительная полоса?', array['не в одном', 'В', 'А и Б']
from public.questions where ref = '#A077'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A078', t.id, 'Ushbu qo‘shimcha axborot yo‘l belgisi:',
       array['Ob‘yektgacha bo‘lgan masofani bildiradi', 'Belgining ta‘sir oralig‘ini bildiradi'], 0, 'q078.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Этот дополнительная табличка означает:', array['Расстояние до объекта', 'Зона действия знака']
from public.questions where ref = '#A078'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A079', t.id, 'Ko‘k avtomobil chorahhani kesib o‘tadi:',
       array['Birinchi bo‘lib', 'Ikkinchi bo‘lib', 'Oxirgi bo‘lib'], 2, 'q079.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Синий автомобиль проедет перекресток:', array['Первым', 'Вторым', 'Последнее']
from public.questions where ref = '#A079'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A080', t.id, 'Turar joy dahalarida qanday eng katta tezlikda harakatlanishga ruxsat etiladi:',
       array['5 km/s', '20 km/s', '30 km/s', '40 km/s'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'С какой максимальной скоростью разрешается движение в жилых зонах:', array['5 км/ч', '20 км/ч', '30 км/с', '40 км/ч']
from public.questions where ref = '#A080'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A081', t.id, 'Yo‘nalishli bo‘lmagan transport vositalari "A" xarfi bilan belgilangan o‘ng bo‘lakda qaysi holatlarda harakatlanishlari mumkin?',
       array['O‘nga burilishda', 'Yo‘lovchilarni chiqarish va tushirishda', 'Yuqoridagi barcha holatlarda aragda yo‘nalishli transport vositalariga xalaqit bermasa'], 2, 'q081.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких случаях немаршрутные транспортные средства могут двигаться по правой полосе, обозначенной буквой «А»?', array['При повороте направо', 'При посадке и высадке пассажиров', 'Во всех вышеперечисленных случаях, если не мешает движению маршрутных транспортных средств']
from public.questions where ref = '#A081'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A082', t.id, 'Qaysi rasmda ikkita qatnov qismiga ega bo‘lgan yo‘l ko‘rsatilgan?',
       array['"A" rasmda', '"Б" rasmda', 'Hech qaysi rasmda'], 2, 'q082.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком рисунке изображена дорога с двумя проезжими частями?', array['На рисунке «А»', 'На рисунке «Б»', 'Ни на одном рисунке']
from public.questions where ref = '#A082'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A083', t.id, 'Ushbu yo‘l nechta qatnov qismiga ega?',
       array['1', '2', '3'], 0, 'q083.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Сколько проезжих частей имеет эта дорога?', array['1', '2', '3']
from public.questions where ref = '#A083'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A084', t.id, 'Bu vaziyatda siz o‘ngga burilayotib, Siz:',
       array['Faqat transport vositalariga yo‘l berasiz', 'Barcha qatnov qismidagi piyodalarga yo‘l berasiz', 'Harakat yo;nalishi boyicha va burilayotgan ko‘chani kesib o‘tayotgan piyodalarga hamda boshqa transport vositalariga yo‘l barasiz'], 2, 'q084.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Когда вы поворачиваете направо в этой ситуации, вы:', array['Вы уступаете дорогу только транспортным средствам', 'Вы уступите дорогу пешеходам на всей проезжей части', 'Вы уступаете дорогу пешеходам и другим транспортным средствам, пересекающим улицу в направлении движения и при повороте']
from public.questions where ref = '#A084'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A085', t.id, 'Yuk avtomobili haydovchisiga qaysi yo‘nalishda harakatlanishga ruxsat beriladi?',
       array['To‘g‘riga va o‘ngga', 'O‘ngga chapga va orqaga', 'Faqat o‘ngga', 'Barcha yo‘nalishlarga'], 0, 'q085.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких направлениях разрешено движение водителю грузового автомобиля?', array['Направо и прямо', 'Направо, налево и назад', 'Только направо', 'На все направления']
from public.questions where ref = '#A085'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A086', t.id, 'Qaysi transport vositalariga harakatlanishga ruxsat berilgan?',
       array['Motosikl va yengil avtomobilga to‘g‘riga va o‘nga', 'Motosiklga o‘nga va yengil avtomobilga barcha yo‘nalishlarga', 'Yengil avtomobilga to‘g‘riga va o‘nga'], 2, 'q086.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каких транспортных средствах разрешено движение?', array['Мотоцикл и легковой автомобиль на прямой и вправо', 'На мотоцикле вправо, на легковом автомобиле во все стороны', 'К легковому автомобилю Прямо и вправо']
from public.questions where ref = '#A086'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A087', t.id, 'N1 toifadagi avtotransport vositalarining boshqaruv qurilmasidagi qanday eng katta lyuft yig‘indisiga yo‘l qo‘yiladi?',
       array['10 gradus', '20 gradus', '25 gradus'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Суммарный люфт в рулевом управлении в регламентированных условиях испытаний автотранспортного средства категория N1 не должен превышать следующих значений:', array['10°', '20°', '25°']
from public.questions where ref = '#A087'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A088', t.id, 'Ushbu svetafor qaysi yo‘nalishda harakatlanishga ruxsat beradi?',
       array['Faqat chapga', 'To‘g‘riga va chapga', 'To‘g‘riga va o‘ngga', 'Faqat o‘ngga'], 2, 'q088.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком направлении этот светофор позволяет вам двигаться?', array['Только влево', 'Прямо и влево', 'Прямо и вправо', 'Только вправо']
from public.questions where ref = '#A088'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A089', t.id, 'Qaysi brlgi yo‘lning ko‘rsatilgan yo‘nalishida oxiri berk ko‘chaligini bildiradi',
       array['1F4. 4', '2F5. 5', '3'], 0, 'q089.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак указывает на закрытую улицу в конце дороги в указанном направлении?', array['1F4. 4', '2F5. 5', '3']
from public.questions where ref = '#A089'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A090', t.id, 'Miltillovchi sariq ishorali svetofor:',
       array['Tartibga solinmagan chorraha yoki piyodalar o‘tish joyi borligidan xabardor qiladi', 'Tartibga solingan chorraha borligidan xabardor qiladi', 'Svetafor chirog‘i almashuvidan xabardor qiladi.'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'svetofor'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Мигающий желтый сигнал светофора:', array['Информирует о наличии нерегулируемого перекрестка или пешеходного перехода', 'Информирует о наличии регулируемого перекрестка', 'Сигнал светофора уведомляет вас об изменении цвета.']
from public.questions where ref = '#A090'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A091', t.id, 'Qaysi belgi ikkinchi darajali yo‘l bilan kesishuvni bildiradi?',
       array['1F4. 4', '2F5. 5', '3'], null, 'q091.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак обозначает пересечение с второстепенной дорогой', array['1F4. 4', '2F5. 5', '3']
from public.questions where ref = '#A091'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A092', t.id, 'To‘xtash qoidasini qaysi transport vositasining haydovchisi buzdi?',
       array['Har ikkala haydovchi ham', 'Faqat ko‘k avtomobil haydovchisi', 'Faqat qizil avtomobil haydovchisi'], 2, 'q092.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто из водителей нарушил правила остановки?', array['Оба нарушили', 'Только водитель синего автомобиля', 'Только водитель красного автомобиля']
from public.questions where ref = '#A092'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A093', t.id, 'Ushbu vaziyatda siz o‘ngga bo‘lakda harakatlanmoqdasiz, sizning bo‘lagingizda qayta tizilayotgan transport vositasiga yo‘l berishingiz kerakmi?',
       array['Kerak emas', 'Kerak'], 0, 'q093.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Обязаны ли вы двигаясь по правой полосе, уступить дорогу водителю автомобиля, который намерен перестроиться на Вашу полосу?', array['Не обязаны', 'Обязаны']
from public.questions where ref = '#A093'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A094', t.id, 'Ushbu yo‘l belgisi qaysi transport vositalarining harakatlanishini taqiqlanadi?',
       array['Ruxsat etilgan to‘la vazni 3,5 tonnadan ortiq bo‘lgan yuk avtomobillarini', 'Xavfli yuk tashiyotgan transport vositalarining harakatlanishini', 'Portlovchi va tez alangalanuvchi yukni tashiyotgan transport vositalarining harakatlanishi'], 1, 'q094.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Движение каких транспортных средств запрещает этот дорожный знак?', array['Грузовых автомобилей с разрешенной максимальной массой более 3.5 тонн', 'Движение транспортных средств с опасными грузами', 'Движение транспортных средств с взрывчатыми и легковоспламеняющимися грузами']
from public.questions where ref = '#A094'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A095', t.id, 'Sanab o‘tilgan qaysi hollarda egiluvchan ulagichda shatakka olish taqiqlanadi?',
       array['Faqat tog‘li yo‘llarda', 'Faqat sirpanchiq yo‘lda', 'Kunning qorong‘i vaqtida va yetarlicha ko‘rinmaslik sharoitida', 'Barcha sanab o‘tilgan hollarda'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких из перечисленных случаев запрещена буксировка на гибкой сцепке?', array['Только на горных дорогах', 'Только в гололедицу', 'Только в темное время суток и в условиях недостаточной видимости', 'Во всех перечисленных случаях']
from public.questions where ref = '#A095'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A096', t.id, 'Qizil avtomobil chorrahani nechanchi bo‘lib kesib o‘tadi?',
       array['Oxirgi bo‘lib', 'Ikkinchi bo‘lib', 'Birinchi bo‘lib'], 0, 'q096.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Красный автомобиль проедет перекресток:', array['Последним', 'Вторым', 'Первым']
from public.questions where ref = '#A096'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A097', t.id, 'Ushbu vaziyatda siz:',
       array['To‘xtamasdan harakatni davom ettirishingiz mumkin', 'Belgi oldida to‘xtashingiz va svetaforning ruxsat beruvchi ishorasini kutishingiz kerak'], 1, 'q097.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В этом случае Вы:', array['Можете продолжить движение без остановки', 'Должны остановиться перед знаком и ждать разрешающего сигнала светофора']
from public.questions where ref = '#A097'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A098', t.id, 'Bu joyda yo‘lovchilarni chiqarish yoki tushirish maqsadida to‘xtash mumkinmi?',
       array['Ha', 'Yo‘q'], 0, 'q098.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Можете ли Вы остановиться в этом месте для посадки или высадки пассажиров?', array['Да', 'Нет']
from public.questions where ref = '#A098'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A099', t.id, 'Qanday hollarda sizga 50 km/s dan yuqori tezlikda harakatlanish taqiqlangan?',
       array['Faqat qatnov qismi nam bo‘lsa', 'Har qanday holatda ham'], 0, 'q099.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком случае Вам необходимо двигаться со скоростью до 50 км/ч?', array['Только в том случав, когда покрытие на дороге влажное', 'Во всех случаях']
from public.questions where ref = '#A099'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A100', t.id, 'Qaysi belgi to‘siqni o‘ng yoki chap tomonidan chetlab o‘tishga ruxsat etilishini bildiradi?',
       array['1F4. 4', '2F5. 5', '3'], 1, 'q100.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак указывает на то, что разрешается обходить препятствие справа или слева?', array['1F4. 4', '2F5. 5', '3']
from public.questions where ref = '#A100'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A101', t.id, '"Imtiyoz" atamasiga tegishli ta‘rifni ko‘rsating',
       array['Yo‘l harakati qatnashchilariga nisbatan imtiyozi bo‘lgan boshqa yo‘l harakati qatnashchisining harakat yo‘nalishi yoki tezligini o‘zgartirishga majbur etishi mumkin bo‘lgan hollarda harakatni davom ettirmasligini yoki boshlamasligini, biror-bir manyovr bajarishi mumkin emasligini bildiruvchi talab', 'Mo‘ljallangan yo‘nalishda boshqa yo‘l harakati qatnashchilariga nisbatan oldin harakatlanish huquqi.'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В какой Формулировке указан правильный ответ термину "Преимущество".', array['Требование, означающее, что участии к дорожного движения не должен продолжать или начинать движение, осуществлять какой-либо маневр, если это может вынудить других участников движения, имеющих по отношению к нему приоритет, изменить направление движения или скорость', 'Право на первоочередное движение в намеченном направлении по отношению к другим участникам движения.']
from public.questions where ref = '#A101'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A102', t.id, 'Shokning belgilari qanday?',
       array['Teri va shilliq qavatining oqarishi', 'Kuchli ter ajralishi', 'Og‘iz qurishi, chanqoqlik, nafas olishning tezlashuvi', 'Es-hushning noaniqligi, behush holati', 'Yuqoridagi barcha holatlar'], 4, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Каковы признаки шока?', array['Побледнение кожи и слизистых оболочек', 'Сильное потоотделение', 'Сухость рта, жажда, учащённое дыхание', 'Спутанность сознания, обморочное состояние', 'Во всех случаях вышеуказанных']
from public.questions where ref = '#A102'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A103', t.id, 'Agar avtomobilning o‘ng g‘ildiraklari nam qoplamali yo‘l yoqasiga chiqib qolsa, tavsiya etiladi:',
       array['Avtomobilni tormozlash va to‘liq to‘xtatish', 'Avtomobilni tormozlab, yo‘lning qatnov qismiga ohista ravon burish', 'Avtomobilni tormozlamasdan yo‘lning qatnov qismiga ohista ravon burish'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В случае, когда правые колёса автомобиля наезжают на неукреплённую влажную обочину, рекомендуется:', array['Затормозить и полностью остановиться', 'Затормозить и плавно направить автомобиль на проезжую часть', 'Не прибегая к торможению, плавно направить автомобиль на проезжую часть']
from public.questions where ref = '#A103'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A104', t.id, 'Yo‘l harakati xavfsizligini ta‘minlash - ...',
       array['Yo‘l-transport hodisalarining kelib chiqish sabablarini oldini olishga, ularning og‘ir oqibatlarini kamaytirishga qaratilgan faoliyat', 'Transport vositalari va piyodalarning harakatlanishi uchun qurilgan yoki moslashtirilgan yer bo‘lagi yoxud suniy inshoot yuzasi. Yo‘l avtomobil va shahar elektr transporti yo‘llarini hamda trotuarlarni o‘z ichiga oladi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Обеспечение безопасности дорожного движения —', array['Состояние дорожного движения, отражающее степень защищенности его участников от дорожно-транспортных происшествий и их последствий.', 'Совокупность отношений, возникающих в процессе перемещения людей и грузов с помощью транспортных средств или без таковых в пределах дорог']
from public.questions where ref = '#A104'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A105', t.id, 'Ushbu ko‘rsatilgan holatda kim yo‘l berishi kerak?',
       array['Avtomobil haydovchisi', 'Motosikl haydovchisi'], 1, 'q105.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто обязан уступить дорогу в данной ситуации?', array['Водитель автомобиля', 'Мотоциклист']
from public.questions where ref = '#A105'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A106', t.id, 'Tik nishablikda dvigatel bilan tormozlashda qiyalikka nisbatan qanday uzatma tanlanadi?',
       array['Nishablik qancha qiya bo‘lsa uzatma pog‘onasi shuncha yuqori tanlanadi', 'Nishablik qancha qiya bo‘lsa uzatma pog‘onasi shuncha past tanlanadi', 'Pog‘onalarni nishablikka aloqasi yo‘q'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как следует выбирать передачу при торможении двигателем с учетом крутизны спуска?', array['Чем круче спуск, тем выше передача выбираться', 'Чем круче спуск, тем ниже передача', 'Выбор передачи не зависит от крутизны спуска']
from public.questions where ref = '#A106'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A107', t.id, 'Qaysi belgi haydovchiga kesib o‘tilayotgan yo‘lda harakatlanayotgan transport vositalariga yo‘l berishi lozimligini bildiradi?',
       array['А', 'Г', 'Б', 'Б va Г', 'В'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак указывает водителю уступить дорогу транспортным средствам, движущимся по пересекаемой дороге?', array['А', 'Г', 'Б', 'Б и Г', 'В']
from public.questions where ref = '#A107'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A108', t.id, 'Tumanga qarshi old chiroqlrni qorong‘i vaqtda, yo‘lning yoritilmagan qismlarida uzoqni yoki yaqinni yorituvchi chiroqlar bilan birga qo‘llash mumkinmi?',
       array['Mumkin', 'Mumkin emas'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Можно ли использоваться противотуманные Фары в темное время суток на неосвещенных участках дорог совместно с ближним или дальним светом Фар?', array['Можно', 'Нельзя']
from public.questions where ref = '#A108'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A109', t.id, 'Ushbu belgilardan qaysi biri oldinda yo‘l qoplamasi istida sun‘iy notekislik borligi haqida ogohlantiradi?',
       array['А', 'В', 'С', 'А va С'], 1, 'q109.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из указанных знаков предупреждает водителя об искусственных неровностях на проезжей части дорог?', array['А', 'В', 'С', 'А и С']
from public.questions where ref = '#A109'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A110', t.id, 'Ajratuvchi mintaqa - ...',
       array['Yo‘lning relssiz transport vositalari harakati uchun mo‘ljallangan qismi', 'Avtomobillarning bir qator bo‘lib harakatlanishi uchun yetarlicha keng bo‘lgan, yo‘l chiziqlari bilan belgilangan yoki belgilanmagan yo‘l qatnov qismining har qanday bo‘ylama bo‘lagi', 'Yo‘lning yonma-yon joylashgan qatnov qismlarini ajratuvchi, transport vositalari harakatlanishi yoki to‘xtashi uchun mo‘ljallanmagan, yo‘l sathidan baland va (yoki) 1.1 yotiq chizig‘i bilan belgilangan qismi'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разделительная полоса -...', array['Часть дороги, предназначенная для движения безрельсовых транспортных средств', 'Любая из продольных полос проезжей части, обозначенная или необозначенная дорожной разметкой и имеющая ширину, достаточную для движения автомобилей в один ряд', 'Элемент дороги, разделяющий смежные проезжие части и не предназначенный для движения и остановки транспортных средств, расположенный выше уровня дороги и (или) обозначенный дорожной разметкой']
from public.questions where ref = '#A110'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A111', t.id, 'Aholi punkti" atamasi nimani bildiradi?',
       array['Kirish va chiqish yo‘llari 5.22 - 5.25 belgilari bilan belgilangan hududni', 'Aholi yashaydigan hududni', 'Shahar, qishloq joylari hududini'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой значение обозначает термин "Населенный пункт"?', array['Территория, въезды и выезды с которой обозначены дорожными знаками 5.22 — 5.25', 'Территория, местожительства населения', 'Территория города и поселок']
from public.questions where ref = '#A111'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A112', t.id, 'Muskul va paylarning ezilishi hamda cho‘zilishi alomatlari qanday?',
       array['Jarohatlangan joyda og‘riq seziladi.', 'Jarohatlangan joyda shish paydo bo‘ladi, og‘riq seziladi, ba‘zan shu joyda mayda kapillyar qon tomirlari yorilib, qon quyilishi natijasida ko‘karish paydo bo‘ladi.'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Каковы признаки сдавливании и растяжении мышечной ткани и сухожилий?', array['На месте ранения чувствуется боль.', 'На месте ранения появляется шишка, чувствуется боль, иногда на этом месте лопаются мелкие капиллярные сосуды и в результате кровоизлияния образуется синяк']
from public.questions where ref = '#A112'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A113', t.id, 'Aylanma harakatlanish chorrahasida:',
       array['Harakatlanayotgan transport vositalari aylanaga kirib kelayotgan transport vositalariga nisbatan ustunlikka (imtiyozga) ega', 'Harakatlanayotgan transport vositalariga nisbatan aylanaga kirib kelayotgan transport vositalari ustunlikka (imtiyozga) ega'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На перекрёстке кругового движения:', array['Транспортные средства, движущиеся на перекрестке с круговым движением, имеют приоритет (преимущество) по отношению к транспортным средствам, въезжающим на перекресток', 'Транспортные средства въезжающий на перекресток имеют приоритет (преимущество) по отношению к транспортным средствам движущиеся на перекрестке']
from public.questions where ref = '#A113'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A114', t.id, 'Ushbu qo‘shimcha axborot yo‘l belgisi bildiradi:',
       array['Barcha turdagi transport vositalarining to‘xtab turish uchun yo‘lning qatnov qismida, trotuar yoniga qo‘yish usulini', 'Yengil avtomobillarning to‘xtab turish joyini', 'Mexanik transport vositalarining to‘xtab turish joyini'], 0, 'q114.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Эта табличка означает:', array['Указывает способ постановки транспортного средства на проезжую часть, вдоль тротуара', 'Указывает место стоянки легковых автомобилей', 'Указывает место стоянки механических транспортных средств']
from public.questions where ref = '#A114'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A115', t.id, 'Chapga burilayotgan haydovchi kesishayotgan yo‘lning qatnov qismidan o‘tayotgan piyodalarga yo‘l berishi kerakmi?',
       array['Ha, barcha hollarda o‘tkazishi kerak', 'Ha, agarda piyodalar o‘tish joyi bo‘lsa'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При повороте налево обязан ли водитель уступить дорогу пешеходам, переходящим проезжую часть пересекаемой ДОРОГИ?', array['Обязан во всех случаях', 'Обязан, если перекрестке есть пешеходного перехода']
from public.questions where ref = '#A115'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A116', t.id, 'Ushbu chorrahada avtobus haydovchisi kimga yo‘l berishi kerak?',
       array['Hech kimga', 'Qizil avtomobilga', 'Ko‘k avtomobilga'], 2, 'q116.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кому должен уступить дорогу водитель автобуса на этой перекрестке?', array['Никому', 'Красному автомобилю', 'Синему автомобилю']
from public.questions where ref = '#A116'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A117', t.id, 'M2 toifadagi avtotransport vositalarining boshqaruv qurilmasidagi qanday eng katta lyuft yig‘indisiga yo‘l qo‘yiladi:',
       array['10°', '20°', '25°'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Суммарный люфт в рулевом управлении в регламентированных условиях испытаний автотранспортного средства категория М2 не должен превышать следующих значений:', array['10°', '20°', '25°']
from public.questions where ref = '#A117'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A118', t.id, 'Agar avtomobilning o‘ng g‘ildiraklari nam qoplamali yo‘l yoqasiga chiqib qolsa, tavsiya etiladi:',
       array['Avtomobilni tormozlash va to‘liq to‘xtatish', 'Avtomobilni tormozlab, yo‘lning qatnov qismiga ohista ravon burish', 'Avtomobilni tormozlamasdan yo‘lning qatnov qismiga ohista ravon burish'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В случае, когда правые колёса автомобиля наезжают на неукреплённую влажную обочину, рекомендуется:', array['Затормозить и полностью остановиться', 'Затормозить и плавно направить автомобиль на проезжую часть', 'Не прибегая к торможению, плавно направить автомобиль на проезжую часть']
from public.questions where ref = '#A118'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A119', t.id, 'Qaysi rasmda ajratuvchi mintaqa bor bo‘lgan yo‘l ko‘rsatilgan?',
       array['Chapda', 'O‘ngda', 'Har ikkisida'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком рисунков дорога с разделительной полосой?', array['На левом', 'На правом', 'Обоих рисунках']
from public.questions where ref = '#A119'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A120', t.id, 'Kunning qorong‘i vaqtida harakatlanayotgan transport vositasining haydovchisi tezlikni tanlashda qanday eng asosiy hal qiluvchi omilni e‘tiborga olishi kerak?',
       array['Yo‘l harakati qoidalari o‘rnatilgan tezlik chegaralarini', 'Transport vositasining texnik tavsifnomasida ko‘rsatilgan tezlik chegarasini', 'Ko‘rinish sharoitini'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что должно иметь самое решающее значение при выборе водителем скорости движения в тёмное время суток?', array['Предельные ограничения скорости, установленные Правилами', 'Максимальная конструктивная скорость, установленная технической характеристикой используемого транспортного средства', 'Условия видимости']
from public.questions where ref = '#A120'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A121', t.id, 'Turar joy dahalarida qanday eng katta tezlikda harakatlanishga ruxsat etiladi:',
       array['5 km/s', '20 km/s', '30 km/s', '40 km/s'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'С какой максимальной скоростью разрешается движение в жилых зонах:', array['5 км/ч', '20 км/ч', '30 км/с', '40 км/ч']
from public.questions where ref = '#A121'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A122', t.id, 'Bosh miya jarohatlanganda, miya chayqalganda yoki bo‘yin qismi jarohatlanganda birinchi yordam ko‘rsatish:',
       array['Jarohatlangan odamni qattiq va tekis zambilga solib, bo‘yin qismi tagiga qattiq yostiqcha qo‘yib, qo‘zg‘atmasdan, mahkam bog‘lab shifoxonaga yuboriladi.', 'Jarohatlangan odamni yonboshlatib yotqizib, bo‘yin qismi tagiga qattiq yostiqcha qo‘yib, mahkam bog‘lab shifoxonaga yuboriladi.', 'Jarohatlangan odamni tinchlantirish, jarohatlangan joy sohasini sovuq suv, muz qo‘yish yo‘llari bilan sovitish, og‘riqni susaytirish va qon ketishini kamaytirish'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Оказание первой помощи при травме головного мозга сотрясении мозга или травме шейного отдела:', array['Пострадавшего надо положить на твёрдые носилки, под область шеи подложить твёрдую подушку, не двигать, крепко связать и отправить в больницу', 'Уложив пострадавшего набок под область шеи подложить твёрдую подушку, крепко связать и отправить в больницу', 'Успокоение пострадавшего, охлаждение области ранения путём наложения холодного компресса, льда, на ослабление боли и уменьшение кровотечения']
from public.questions where ref = '#A122'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A123', t.id, 'Yo‘lning xavfli burilishlarida oldingi uzatmali avtomobilning orqa o‘qi yon tomonga sirpanayotganda siz qanday harakat qilasiz?',
       array['Gaz berishni kamaytirib rul chambaragi bilan boshqaruvni barqarorlashtirasiz', 'Tormozlab turib rul chambaragini sirpangan tomonga burasiz', 'Gaz pedalini ohista bosib avtomobilni rul chambaragini to‘g‘rilab avtomobilni sirpanishdan olib chiqib ketasiz', 'Gaz pedalini ko‘proq bosib rul chambaragini o‘zgartirmasdan sirpanishdan olib chiqasiz'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На повороте возник занос задней оси переднеприводного автомобиля. Ваши действия?', array['Уменьшите подачу топлива, рулевым колесом стабилизируете движение', 'Притормозите и повернёте рулевое колесо в сторону заноса', 'Слегка увеличите подачу топлива, корректируя направление движения рулевым колесом', 'Значительно увеличите подачу топлива, не меняя положения рулевого колеса']
from public.questions where ref = '#A123'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A124', t.id, 'Ushbu yo‘l belgisi nimani bildiradi?',
       array['Xavfli yuktashiyotgan transport vositalari harakatini taqiqlaydi', 'Og‘ir yuk tashiyotgan transport vositalari harakatini taqiqlaydi', 'Portlovchi va tez alangalanadigan yuk tashiyotgan transport vositalari harakatini taqiqlaydi'], 0, 'q124.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что указывает этот дорожный знак?', array['Запрещает движение транспортных средств с опасным грузом', 'Запрещает движение транспортных средств с тяжёлыми грузами', 'Запрещает движение транспортных средств с взрывчатыми и легковоспламеняющимися грузами']
from public.questions where ref = '#A124'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A125', t.id, 'Haydovchining o‘rtacha reaksiya vaqti deb qabul qilingan:',
       array['Taxminan 0,2 sekund', 'Taxminan 1 sekund', 'Taxminan 5 sekund'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Принято считать, что среднее время реакции водителя составляет:', array['Примерно 0,2 секунды', 'Примерно 1 секунду', 'Примерно 5 секунды']
from public.questions where ref = '#A125'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A126', t.id, 'Ushbu chorrahada haydovchi orqaga harakatlanib ko‘rsatilgan manyovrni bajarishga ruxsat etiladimi?',
       array['Ruxsat etiladi', 'Taqiqlanadi'], 1, 'q126.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли водителю выполнить указанного маневра в перекрёстке, двигаясь назад?', array['Разрешается', 'Запрещается']
from public.questions where ref = '#A126'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A127', t.id, 'Ushbu tik chiziq nimani bildiradi?',
       array['Temir yo‘l kesishmasiga yaqinlashganlik haqida', 'Xavfli chorrahaga yaqinlashganlik haqida', 'Yo‘lning kichik radiusli burilish, tik nishablik va boshqa xavfli joylarda yo‘l to‘siqlarining yon yuzalarini bildiradi'], null, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A128', t.id, 'Ushbu tik chiziq nimani bildiradi?',
       array['Temir yo‘l kesishmasiga yaqinlashganlik haqida', 'Xavfli chorrahaga yaqinlashganlik haqida', 'Yo‘lning kichik radiusli burilish, tik nishablik va boshqa xavfli joylarda yo‘l to‘siqlarining yon yuzalarini bildiradi'], null, 'q128.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A129', t.id, 'Qaysi yo‘l belgilari yo‘lning tor qismida xaydovchiga ustunlik beradi?',
       array['Faqat В', 'А va В', 'Faqat Д', 'Faqat С'], 2, 'q129.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При наличии каких знаков водитель пользуется преимуществом, если встречный разъезд затруднен препятствием?', array['Только В', 'А и В', 'Только Д', 'Только С']
from public.questions where ref = '#A129'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A130', t.id, 'Ushbu yo‘l belgisi qanday maqsadda qo‘llaniladi?',
       array['Majburiy tarzda tezlikni kamaytirish uchun', 'To‘xtamasdan o‘tishni taqiqlaydi', 'Ehtiyot choralarini ko‘rish uchun'], 1, 'q130.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'С какой целью применяется этот дорожный знак?', array['Для принудительного снижения скорости движения', 'Движение без остановки запрещён', 'Для принятия меры предосторожности']
from public.questions where ref = '#A130'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A131', t.id, 'M3 toifadagi avtotransport vositalarining boshqaruv qurilmasidagi qanday eng katta lyuft yig‘indisiga yo‘l qo‘yiladi?',
       array['10°', '20°', '25°'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Суммарный люфт в рулевом управлении в регламентированных условиях испытаний автотранспортного средства категория М3 не должен превышать следующих значений:', array['10°', '20°', '25°']
from public.questions where ref = '#A131'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A132', t.id, 'Yondosh hudud bu - ...',
       array['Bevosita yo‘lga tutashgan va transport vositalari o‘tib ketishi uchun mo‘ljallanmagan hudud (hovlilar, turar joy dahalari, avtomobil to‘xtab turish joylari, yonilg‘i quyish shoxobchalari, korxona va shunga o‘xshashlar).', 'Yo‘llarning o‘zaro bir sathda kesishadigan, tutashadigan va ayriladigan joyi', 'Yo‘lning relssiz transport vositalari harakati uchun mo‘ljallangan qismi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Прилегающая территория -...?', array['Территория, непосредственно прилегающая к дороге и не предназначенная для сквозного движения транспортных средств (дворы, жилые массивы, автостоянки, автозаправочные станции, предприятия и т. п.).', 'Место пересечения, примыкания или разветвления дорог на одном уровне.', 'Часть дороги, предназначенная для движения безрельсовых транспортных средств.']
from public.questions where ref = '#A132'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A133', t.id, 'Qorin bo‘shlig‘i jarohatlangan odamga ovqat, suv, dori - darmon berish mumkinmi?',
       array['Ha', 'Yo‘q'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Можно ли давать пострадавшему пишу, воду и лекарства при повреждение брюшной полости?', array['Да', 'Нет']
from public.questions where ref = '#A133'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A134', t.id, 'Tezlik ortishi bilan haydovchining ko‘rish maydoni qanday o‘zgaradi?',
       array['Kengayadi', 'O‘zgarmaydi', 'Torayadi'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как изменяется поле зрения водителя с увеличением скорости движения?', array['Расширяется', 'Не изменяется', 'Сужается']
from public.questions where ref = '#A134'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A135', t.id, 'Mexanik transport vositasi - bu. . .',
       array['Odamlarni, yuklarni tashishga yoki maxsus ishlarni bajarishga mo‘ljallangan qurilma', 'Mexanik transport vositasi tarkibida harakatlanishga mo‘‘jallangan, dvigatel bilan jihozlanmagan transport vositasi. Bu atama yarim tirkama va uzaytiriladigan tirkamalarga ham taaluqlidir', 'Dvigatel bilan harakatga keltiriladigan transport vositasi (mopeddan tashqari). Bu atama barcha traktor va o‘zi yurar moslamalarga ham taalluqlidir'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Механическое транспортное средство - это...', array['Устройство, предназначенное для перевозки людей, грузов или для производства специальных работ.', 'Транспортное средство, не оборудованное двигателем и предназначенное для движения в составе с механическим транспортным средством. Термин распространяется также на полуприцепы и прицепы-роспуски.', 'Транспортное средство (кроме мопеда), приводимое в движение двигателем. Термин распространяется на любые тракторы и самоходные механизмы.']
from public.questions where ref = '#A135'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A136', t.id, 'Yengil avtomobilga qaysi yo‘nalishlarda harakatlanishga ruxsat etiladi?',
       array['Faqat to‘g‘riga', 'Faqat o‘ng va chapga', 'Istalgan yo‘nalishda'], null, 'q136.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких направлениях разрешено продолжить движение на легковой автомобиль?', array['Только прямо', 'Только налево или направо.', 'В любых направлениях']
from public.questions where ref = '#A136'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A137', t.id, 'Ushbu holatda ko‘k avtomobilКому следует уступить дорогу синий haydovchisi kimga yo‘l berishi lozim?',
       array['Faqat avtobusga', 'Hech kimga', 'Faqat yengil avtomobilga'], 0, 'q137.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'автомобиль?', array['Только автобусу', 'Никому', 'Только легковому автомобилю.']
from public.questions where ref = '#A137'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A138', t.id, 'Tormoz yo‘li deb nimaga aytiladi?',
       array['Haydovchi biron bir havfni aniqlab, avtomobilni to‘liq to‘xtatguncha bosib o‘tgan masofasi', 'Haydovchi tormoz tepkisini bosgandan to avtomobil to‘liq to‘xtaguncha bosib o‘tilgan masofa'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что подразумевается под тормозным путем?', array['Расстояние, пройденное транспортным средством с момента обнаружения водителем опасности до полной остановки', 'Расстояние, пройденное транспортным средством с момента нажатия на педаль тормоза до полной остановки']
from public.questions where ref = '#A138'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A139', t.id, 'Ushbu belgilardan qaysi biri «Notekis yo‘q» deb nomlanadi?',
       array['«А»', '«В»', '«C»'], 2, 'q139.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из знаков предупреждает водителя о неровности дороги?', array['«А»', '«В»', '«C»']
from public.questions where ref = '#A139'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A140', t.id, 'Aholi punktlaridan tashqarida tirkamali yuk avtomobillari qanday yuqori tezlik bilan harakatlanishi mumkin?',
       array['80 km/s', '70 km/s', '90 km/s', '60 km/s'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'С какой максимальной скоростью может двигаться грузовые автомобили с прицепом вне населенных пунктах?', array['80 км/ч', '70 км/ч', '90 км/ч', '60 км/ч']
from public.questions where ref = '#A140'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A141', t.id, 'Ushbu belgi nimani bildiradi?',
       array['Oldinda tik balandlik borligini', 'Oldinda ko‘tarma ko‘prik borligini', 'Sun‘iy yo‘l notekisligini'], 2, 'q141.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'О чем предупреждает этот знак?', array['Впереди есть крутой подъем', 'Впереди есть разводной мост', 'Искусственная неровность дороги']
from public.questions where ref = '#A141'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A142', t.id, 'Yo‘l harakati qoidalariga ko‘ra yo‘l belgilari nechta guruhga bo‘linadi?',
       array['5 ta', '6 ta', '7 ta'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Сколько групп имеется дорожных знаков по правилам дорожного движения', array['5 та', '6 та', '7 та']
from public.questions where ref = '#A142'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A143', t.id, 'Venoz qon ketish alomatlarini ko‘rsating:',
       array['Qon tomirlaridan pushti rangli qon kuchli pulsatsiya bilan otilib chiqadi', 'Qon tomirlaridan to‘q qizil rangdagi qon sizib oqib chiqadi', 'Mayda qon tomirlaridan ichki a‘zolarga qonning oqib chiqishi kuzatiladi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Признаки венозное кровотечение:', array['Кровь розового цвета сильной пульсацией бьётся из сосудов', 'Тёмно-красная кровь струится из сосудов', 'Кровотечение во внутренние органы из мелких кровеносных сосудов']
from public.questions where ref = '#A143'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A144', t.id, 'G‘ildiraklarni yo‘l bilan ilashishi yo‘qolgana (kuchli yomg‘ir, sel yoki suv toshgan yo‘l qismlari) haydovchi:',
       array['Tezlikni oshirishi lozim', 'Tormoz tepkisini keskin bosish bilan tezlikni kamaytirish lozim', 'Dvigatel bilan tormozlash orqali tezlikni kamaytirishi lozim'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В случае потери сцепления колес с дорогой из-за образования «водяного клина» водителю следует:', array['Увеличить скорость', 'Снизить скорость резким нажатием на педаль тормоза', 'Снизить скорость, применяя торможение двигателем']
from public.questions where ref = '#A144'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A145', t.id, 'Turar joy dahalaridan chiqishda haydovchilar:',
       array['Boshqa harakat qatnashchilariga yo‘l berishi kerak', 'Boshqa harakat qatnashchilariga nisbatan imtiyozga ega'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При выезде из жилых зон водители должны:', array['Уступить дорогу другим участникам дорожного движения', 'Имеет приоритет, чем другим участникам дорожного движения']
from public.questions where ref = '#A145'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A146', t.id, 'Ushbu belgilardan qaysi biri, bir yoki bir nechta bo‘laklarda harakatlanish yo‘nalishi qarama-qarshi tomonga o‘zgarishi mumkin bo‘lgan yo‘l qismining boshlanishini biliradi?',
       array['«А»', '«Б»', '«В»'], 2, 'q146.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из этих знаков указывает начало участка дороги, на котором на одной или нескольких полосах направление движения может изменяться на противоположное?', array['«А»', '«Б»', '«В»']
from public.questions where ref = '#A146'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A147', t.id, 'Chorrahada qaysi avtomobil yo‘l berishi kerak?',
       array['Ko‘k avtomobil', 'Qizil avtomobil'], 1, 'q147.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой автомобиль должен уступить дорогу на перекрестке?', array['Синий автомобиль', 'Красный автомобиль']
from public.questions where ref = '#A147'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A148', t.id, 'Tumanga qarshi chiroqlarni qorong‘i vaqtda yo‘lning yoritilmagan qisimlarida uzoqni yorituvchi chiroqlar bilan birga qo‘llash mumkinmi?',
       array['Ha', 'Yo‘q'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Можно ли использовать противотуманные фары совместно с ближним или дальним светом Фар в темное время суток на неосвещенных участках', array['Да', 'Нет']
from public.questions where ref = '#A148'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A149', t.id, 'Yengil avtomobil tirkamasi burilishda qanday trayektoriya bo‘yicha harakatlanadi?',
       array['Burilish markaziga nisbatan avtomobil trayektoriyasidan tashqarida', 'Avtomobil burilish trayektoriyasi bo‘yicha', 'Burilish markaziga nisbatan avtomobil trayektoriyasidan ichkarida'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'По какой траектории двигается прицеп легкового автомобиля при прохождении поворота?', array['Дальше от центра поворота, чем траектория движения автомобиля', 'По траектории движения автомобиля', 'Ближе к центру поворота, чем траектория движения автомобиля']
from public.questions where ref = '#A149'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A150', t.id, 'Qaysi belgi temir yo‘l kesishmasini to‘suvchi qurilma bilan jihozlanganligi haqida ogohlantiradi?',
       array['«А»', '«В»', '«C»', '«Д»'], 2, 'q150.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак предупреждает водителя об оборудования заградительным устройством железнодорожного переезда?', array['«А»', '«В»', '«C»', '«Д»']
from public.questions where ref = '#A150'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A151', t.id, 'Agar biror bir to‘siq sababli qarama-qarshi yo‘nalishlarda harakatlanish qiyin bo‘lsa kim yo‘l berishi kerak?',
       array['To‘siq bo‘lmagan tomondagi haydovchi', 'To‘siq o‘z tomonida bo‘lgan haydovchi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто должен уступить дорогу если встречный разъезд затруднен?', array['Водитель, на стороне которого не имеется препятствие', 'Водитель, на стороне которого имеется препятствие']
from public.questions where ref = '#A151'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A152', t.id, '«Imtiyoz» atamasiga tegishli tarifni ko‘rsating:',
       array['Yo‘l harakati qatnashchilariga nisbatan imtiyozi bo‘lgan boshqa yo‘l harakati qatnashchisining harakat yo‘nalishi yoki tezligini o‘zgartirishga majbur etishi mumkin bo‘lgan hollarda harakatni davom ettirmasligi yoki boshlamasligi, biror-bir manyovr bajarishi mumkin emasligini bildiruvchi talab.', 'Mo‘ljallangan yo‘nalishda boshqa yo‘l harakati qatnashchilariga nisbatan oldin harakatlanish huquqi.'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В какой формулировке указан правильный ответ термину "Преимущество"', array['Требование, означающее, что участник дорожного движения не должен продолжать или начинать движение, осуществлять какой-либо маневр, если это может вынудить других участников движения, имеющих по отношению к нему приоритет, изменить направление движения или скорость', 'Право на первоочередное движение в намеченном направлении по отношению к другим участникам движения.']
from public.questions where ref = '#A152'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A153', t.id, 'Arterial qon ketish alomatlarini ko‘rsating:',
       array['Qon tomirlaridan pushti rangli qon kuchli pulsatsiya bilan otilib chiqadi', 'Qon tomirlaridan to‘q qizil rangdagi qon sizib oqib chiqadi', 'Mayda qon tomirlaridan ichki a‘zolarga qonning oqib chiqishi kuzatiladi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Признаки артериальное кровотечение:', array['Кровь розового цвета сильной пульсацией бьётся из сосудов', 'Тёмно-красная кровь струится из сосудов', 'Кровотечение во внутренние органы из мелких кровеносных сосудов']
from public.questions where ref = '#A153'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A154', t.id, 'Avtomobilni qanday boshqarish usuli yonilg‘i sarfini tejaydi?',
       array['Shiddat bilan tezlanish oxista va sekinlashish bilan', 'Ohista (ravon) tezlanish va shiddat bilan sekinlashish bilan', 'Ohista (ravon) tezlanish va ohista sekinlashish bilan'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При каком способе вождения будет обеспечен наименьший расход топлива?', array['При резком ускорении и плавном замедлении', 'При плавном ускорении и резком замедлении', 'При плавном ускорении и плавном замедлении']
from public.questions where ref = '#A154'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A155', t.id, 'Ko‘rsatilgan qaysi belgi yo‘lning o‘ta sirpanchiq bo‘lgan qismini bildiradi?',
       array['Faqat «А»', '«А» va «В»', 'Faqat «В»'], 2, 'q155.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки предупреждает об участке дороги с повышенной скользкостью проезжей части?', array['Только «А»', '«А» и «В»', 'Только «В»']
from public.questions where ref = '#A155'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A156', t.id, 'Chap qo‘lni yonga cho‘zish yoki o‘ng qo‘lni tirsakdan to‘g‘ri burchak ostida bukib, Yuqoriga ko‘tarish ishorasi nimani bildiradi?',
       array['Chapga burilishni yoki qayrilib olishni', 'O‘ngga burilish yoki qayrilib olishni', 'To‘xtashi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'О чем предупреждает сигнал вытянутая в сторону левая рука, либо правая вытянутая в сторону и согнутая в локте под прямым углом вверх?', array['Левого поворота или разворота', 'Правого поворота или разворота', 'Остановки']
from public.questions where ref = '#A156'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A157', t.id, 'Ushbu holatda qaysi transport vositasi yo‘l berishi kerak?',
       array['Yengil avtomobil', 'Yuk avtomobili'], 1, 'q157.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой транспортное средство должен уступить дорогу?', array['Легковой автомобиль', 'Грузовой автомобиль']
from public.questions where ref = '#A157'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A158', t.id, 'Qaysi belgi svetaforning (tartibga soluvchining) taqiqlovchi ishorasida transport vositalari to‘xtaydigan joyni bildiradi?',
       array['«А»', '«Б»', '«В»', '«Г»'], 2, 'q158.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'svetofor'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак указывает место остановки транспортных средств при запрещающем сигнале светофора (регулировщика)?', array['«А»', '«Б»', '«В»', '«Г»']
from public.questions where ref = '#A158'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A159', t.id, 'Sekinlashish bo‘lagi bo‘lgan yo‘llarda burilmoqchi bo‘lgan haydovchi qachon tezlikni kamaytirishi lozim?',
       array['Sekinlashish bo‘lagiga o‘tguncha', 'Sekinlashish bo‘lagiga o‘tgach'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Когда водитель должен снижать скорость при наличии полосы торможения, намеревающийся повернут?', array['До перестроения на полосу торможения', 'После перестроения на полосе торможения']
from public.questions where ref = '#A159'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A160', t.id, 'Qaysi belgi falokatli holatlar uchun kirish yo‘lini bildiradi?',
       array['«А» va «Д»', '«В»', '«C»'], 1, 'q160.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак указывает дорогу для выезда в аварийных случаях?', array['«А» и «Д»', '«В»', '«C»']
from public.questions where ref = '#A160'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A161', t.id, 'Qattiq ulagichda shatakka olingan avtobusda yoki trolleybusda odam tashishga ruxsat etiladimi?',
       array['Taqiqlanadi', 'Ruxsat etiladi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли перевозка людей при буксировке на жёсткой сцепке в буксируемом автобусе или троллейбусе?', array['Запрещается', 'Разрешается']
from public.questions where ref = '#A161'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A162', t.id, 'Quyudagi izoh qaysi atamaga tegishli? Texnik nuqson, tashilayotgan yuk, haydovchi va yo‘lovchining holati, yo‘ldagi biror to‘siq tufayli xavf yuzaga kelganda yoxud ob-havo sharoitiga bog‘liq holda transport vositasi harakatini to‘xtatish.',
       array['Yo‘l-transport hodisasi', 'Yo‘l xarakati xavfsizligini ta‘minlash', 'Majburiy to‘xtash'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На какому термину соответствует этот примечание? Прекращение движения транспортного средства по причине технической неисправности или опасности, создаваемой перевозимым грузом, состоянием водителя, пассажира, препятствием на дороге или метеорологическими условиями.', array['Дорожно-транспортное происшествие', 'Обеспечение безопасности дорожного движения', 'Вынужденная остановка']
from public.questions where ref = '#A162'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A163', t.id, 'Bosh miya jarohatlanishining quidagi alomatlar bilan xarakterlanadi:',
       array['Hushdan ketish bir necha soniyadan bir necha soatgacha bo‘lishi mumkin', 'Qayt qilish bir ikki marta, og‘ir holatlarda ko‘proq bo‘lishi mumkin', 'Amneziya - xotiraning yo‘qolishi/ sodir bo‘lgan jarohatlanish bilan bog‘liq va hayotidagi ba‘zi voqealar xotirasidan o‘chadi', 'Yuqoridagi barcha holatlar'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Травма головного мозга характеризуется следующими основными признаками:', array['Потеря сознания может длиться от нескольких секунд до нескольких часов', 'Рвота - два-три раза, в тяжёлых случаях больше', 'Амнезия - потеря памяти, связана с полученной травмой и некоторые события жизни стираются из памяти', 'Во всех случаях вышеуказанных']
from public.questions where ref = '#A163'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A164', t.id, 'Tik nishabliklarda dvigatel bilan tormozlashda qiyalikka nisbatan qanday uzatma tanlanadi?',
       array['Nishablik qancha qiya bo‘lsa uzatma pog‘onasi shuncha yuqori tanlanadi', 'Nishablik qancha qiya bo‘lsa uzatma pog‘onasi shuncha past tanlanadi', 'Pog‘onalarni tanlashning nishablikka aloqasi yo‘q'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как следует выбирать передачу при торможении двигателем с учетом крутизны спуска?', array['Чем круче спуск, тем выше передача', 'Чем круче спуск тем ниже передача', 'Выбор передачи не зависит от крутизны спуска']
from public.questions where ref = '#A164'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A165', t.id, 'Chorrahadan tashqaridagi tartibga solinmagan velosiped yo‘lkasi bilan yo‘l kesishmasida kim yo‘l berishi kerak?',
       array['Transport vositalari haydovchilari', 'Velosiped yo‘lkasidan harakatlanayotgan velosiped va moped haydovchilari'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто должен уступить дорогу вне перекрёстков, на нерегулируемом пересечении велосипедной дорожки с дорогой?', array['Водители транспортных средств', 'Велосипедисты и водители мопеда']
from public.questions where ref = '#A165'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A166', t.id, 'Hayvonlarni yo‘lda haydab borishga qoidaga ko‘ra ruxsat etiladi:',
       array['Kunning yorug‘ vaqtida', 'Kunning qorong‘i vaqtida', 'Istalgan vaqtda'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Животных по дороге следует перегонять, как правило:', array['В светлое время суток', 'В темное время суток', 'В любое время']
from public.questions where ref = '#A166'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A167', t.id, 'Ushbu holatda qaysi transport vositasi yo‘l berishi kerak?',
       array['Yengil avtomobil', 'Avtobus'], 1, 'q167.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой транспортное средство должен уступить дорогу?', array['легковой автомобиле', 'Автобус']
from public.questions where ref = '#A167'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A168', t.id, 'Qaysi belgilar yuk avtomobillarida quvib o‘tish taqiqlangan hududning oxirini bildiradi?',
       array['Faqat «А»', 'Faqat «Б»', 'Faqat «А» , «Б»', '«А», «Б», «В»'], 3, 'q168.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки обозначают конец зоны запрещения обгона грузовыми автомобилями?', array['«А»', '«Б»', '«А» , «Б»', '«А», «Б», «В»']
from public.questions where ref = '#A168'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A169', t.id, 'Svetaforning miltillovchi sariq ishorasi nima haqida ogohlantiradi?',
       array['Harakatlanishga ruxsat beradi', 'Chorraha tartibga solinmaganligi to‘g‘risida', 'Barcha javoblar to‘g‘ri'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'О чем предупреждает мигающий жёлтый сигнал светофора', array['Разрешает движению', 'О нерегулируемом перекрестке', 'Все ответы правильные']
from public.questions where ref = '#A169'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A170', t.id, 'Transport vositalarini qatnov qimining kengaytirilmagan joylarida qanday tartibda to‘xtash va to‘xtab turishga ruxsat etiladi?',
       array['Burchak ostida', 'Parallel ravishda', 'Istalgan usulda'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком порядке разрешается ставить транспортные средства не имеющих местное уширение проезжей части?', array['Под углом', 'Параллельно', 'Любым способом']
from public.questions where ref = '#A170'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A171', t.id, 'Qaysi belgi to‘xtash chizig‘i oldida, u bo‘maganda, kesib o‘tiladigan qatnov qismining chetida to‘xtamasdan harakatlanishni taqiqlaydi?',
       array['«А»', '«Б»', '«Б» ва «В»', '«А» ва «Г»', '«Г»'], 1, 'q171.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак из указанных запрещает движение перед стоп- линией, а при его отсутствии - перед краем пересекаемой проезжей части?', array['«А»', '«Б»', '«Б» и «В»', '«А» и «Г»', '«Г»']
from public.questions where ref = '#A171'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A172', t.id, 'Yo‘l harakati xavfsizligini ta‘minlash -',
       array['Yo‘l-transport hodisalarining kelib chiqish sabablarini oldini olishga, ularning og‘ir oqibatlarini kamaytirishga qaratilgan faoliyat', 'Yo‘llarda harakatni boshqarish bo‘yicha huquqiy, tashkiliy- texnikaviy tadbirlar va boshqaruv harakatlari majmui'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'texnik-holat'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Обеспечение безопасности дорожного движения —', array['Деятельность, направленная на предупреждение причин возникновения дорожно-транспортных происшествий, снижение тяжести их последствий', 'Совокупность отношений, возникающих в процессе перемещения людей и грузов с помощью транспортных средств или без таковых в пределах дорог.']
from public.questions where ref = '#A172'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A173', t.id, 'Shokning belgilari:',
       array['Teri va shilliq qavatlarning oqarishi', 'Kuchli ter ajralishi', 'Og‘iz qurishi, chanqoqlik, nafas olishning tezlashuvi', 'Es - hushning noaniqligi, behush holat', 'Yuqoridagi barcha holatlar'], 4, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Признаки шока:', array['Побледнение кожи и слизистых оболочек', 'Сильное потоотделение', 'Сухость рта, жажда, учащённое дыхание', 'Спутанность сознания, обморочное состояние', 'Во всех случаях вышеуказанных']
from public.questions where ref = '#A173'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A174', t.id, 'Quvib o‘tishga taalluqli belgilarni ko‘rsating?',
       array['«А» va «В»', '«В» va «C»', '«А» va «C»'], 2, 'q174.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки из указанных относятся к обгону?', array['«А» и «В»', '«В» и «C»', '«А» и «C»']
from public.questions where ref = '#A174'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A175', t.id, 'Avtomobillarning bir qator bo‘lib harakatlanishi uchun yetarlicha keng bo‘lgan, yo‘l chiziqlari bilan belgilangan yoki belgilanmagan yo‘l qatnov qismining har qanday bo‘ylama bo‘lagi nima deb ataladi?',
       array['Qatnov qismi', 'Harakatlanish bo‘lagi', 'Yo‘l yoqasi', 'Yondosh hudud'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как называется любая из продольных полос проезжей части, обозначенная или необозначенная дорожной разметкой и имеющая ширину, достаточную для движения автомобилей в один ряд?', array['Проезжая часть', 'Полоса дивижения', 'Обочина', 'Прилегающая территория']
from public.questions where ref = '#A175'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A176', t.id, 'Qaysi belgi velosiped yo‘lkasini ko‘rsatadi?',
       array['«А»', '«В»', '«C»'], 2, 'q176.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак указывает велосипедную дорожку?', array['«А»', '«В»', '«C»']
from public.questions where ref = '#A176'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A177', t.id, 'Ushbu chorrahada kim yo‘l beradi?',
       array['Ko‘k avtomobil', 'Mototsikl va sariq avtomobil'], null, 'q177.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто уступить дорогу на этом перекрестке?', array['Синий автомобиль', 'Мотоцикл и желтый автомобиль']
from public.questions where ref = '#A177'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A178', t.id, 'Xavfsiz oraliq masofani ko‘rsating:',
       array['«А» ва «В»', '«В»', '«Б»'], 2, 'q178.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Покажите безопасную дистанцию.', array['«А» и «В»', '«В»', '«Б»']
from public.questions where ref = '#A178'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A179', t.id, 'Ushbu belgi qaysi turdagi transport vositalarini to‘xtamasdan o‘tishlarini taqiqlaydi?',
       array['Yuk avtomobillarini', 'Yengil avtomobillarini', 'Barcha turdagi transport vositalarini'], 2, 'q179.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Каких видов транспортных средств запрещает движения без остановки этот знак?', array['Грузовых автомобилей', 'Легковых автомобилей', 'Всех видов транспортных средств.']
from public.questions where ref = '#A179'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A180', t.id, 'Agar haydovchi keskin tormoz bermasdan harakatini to‘xtata olmasa, svetaforning yashil ishorasidan keyin yongan sariq ishorasida harakatni davom ettirishga ruxsat beriladimi?',
       array['Ruxsat etiladi', 'Taqiqlanadi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли водителю продолжить движение после переключения зеленого сигнала светофора на желтый, если возможно остановиться перед перекрестком, только применив экстренное торможение?', array['Разрешается', 'Запрещается']
from public.questions where ref = '#A180'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A181', t.id, 'Qaysi belgi «Xavfli yuk tashiyotgan transport vositalarining harakatlanishi taqiqlangan» deb nomlanadi?',
       array['«А»', '«В»', '«C»'], null, 'q181.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак запрещает движения транспортных средстве опасным грузом?', array['«А»', '«В»', '«C»']
from public.questions where ref = '#A181'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A182', t.id, 'Chorraha - bu ...',
       array['Bevosita yo‘lga tutashgan va transport vositalari o‘tib ketishi uchun mo‘ljallanmagan hudud (hovlilar, turar joy dahalari, avtomobil to‘xtab turish joylari, yonilg‘i quyish shaxobchalari, korxona va shunga o‘xshashlar)', 'Yo‘lning o‘zaro bir sathda kesishadigan, tutashadigan va ayriladigan joyi', 'Yo‘llarning relissiz transport vositalari harakati uchun mo‘ljallangan qismi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Перекресток — это...', array['Территория, непосредственно прилегающая к дороге и не предназначенная для сквозного движения транспортных средств (дворы, жилые массивы, автостоянки, автозаправочные станции, предприятия и т. п.).', 'Место пересечения, примыкания или разветвления дорог на одном уровне.', 'Часть дороги, предназначенная для движения безрельсовых транспортных средств.']
from public.questions where ref = '#A182'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A183', t.id, 'Bosh miya jarohatlanishining asosiy alomatlari:',
       array['Hushdan ketish bir necha soniyadan bir necha soatgacha bo‘lishi mumkin', 'Qayt qilish bir - ikki marta, og‘ir holatlarda ko‘proq bo‘lishi mumkin', 'Amneziya - xotiraning yo‘qolishi, sodir bo‘lgan jarohatlanish bilan bog‘liq va hayotidan ba‘zi voqealar xotirasidan o‘chadi', 'Yuqoridagi barcha holatlar'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Травма головного мозга характеризуется следующими основными признаками:', array['Потеря сознания может длиться от нескольких секунд до нескольких часов', 'Рвота - два-три раза, в тяжёлых случаях больше', 'Амнезия - потеря памяти, связана с полученной травмой и некоторые события жизни стираются из памяти', 'Во всех перечисленных случаях']
from public.questions where ref = '#A183'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A184', t.id, 'G‘ildiraklarni yo‘l bilan ilashishi yo‘qolganda (kuchli yomg‘ir, sel yoki suv toshgan yo‘l qisimlari) haydovchi:',
       array['Tezlikni oshirishi lozim', 'Tormoz tepkisini keskin bosish bilan tezlikni kamaytirishi lozim', 'Dvigatel bilan tormozlash orqali tezlikni kamaytirishi lozim'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В случае потери сцепления колес с дорогой из-за образования «водяного клина» водителю следует:', array['Увеличить скорость', 'Снизить скорость резким нажатием на педаль тормоза', 'Снизить скорость, применяя торможение двигателем']
from public.questions where ref = '#A184'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A185', t.id, 'Piyodalar yo‘lkasi - bu . . .',
       array['Yo‘l qatnov qismining piyodalar kesib o‘tishi uchun mo‘ljallangan, 5.16.1, 5.16.2 yo‘l belgilari va 1.14.1-1.14.3 yo‘l chiziqlari bilan ajratilgan bo‘lagi', 'Yo‘lning piyodalar harakatlanishi uchun mo‘ljallangan va transport vositalari harakati taqiqlangan qismi', 'Qatnov qismiga tutashgan yoki undan maysazor, ariq, maxsus to‘siqlar bilan ajratilgan va piyodalarning harakatlanishi uchun mo‘ljallangan yo‘l qismi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Пешеходная дорожка - это...', array['Участок проезжей части дороги, предназначенный для пересечения пешеходами, обозначенный дорожными знаками 5.16.1, 5.16.2 и дорожной разметкой 1.14.1-1.14.3.3.', 'Часть дороги, предназначенная для движения пешеходов, по которой запрещено движение транспортных средств.', 'Часть дороги, примыкающая к проезжей части или отделенная от нее газоном, арыком или специальным сооружением, предназначенная для движения пешеходов.']
from public.questions where ref = '#A185'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A186', t.id, 'Qaysi belgi yo‘lning tor qisimlarida ro‘paradan kelayotgan transport vositasiga yo‘l berish lozimligini bildiradi?',
       array['«А»', '«Б»', '«Б» va «В»', '«А» va «Г»', '«Г»'], 0, 'q186.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак обязывает уступить дорогу встречным транспортным средствам движущимся через узкий коридор?', array['«А»', '«Б»', '«Б» и «В»', '«А» и «Г»', '«Г»']
from public.questions where ref = '#A186'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A187', t.id, 'Yo‘lning qiyaliklarida qisqa muddatga to‘xtagan mexanik uzatmali avtomobilni joyidan to‘satdan harakatlanib ketishini oldini olish uchun:',
       array['To‘xtab turish tormozidan foydalanish lozim', 'Birinchi uzatmani yoki orqa uzatmani ulash lozim', 'Uzatmalar qutisi richagini neytral holatga o‘tkazish lozim'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Для предупреждения скатывания автомобиля с механической трансмиссией при кратковременной остановке на подъеме следует:', array['Привести в действие стояночный тормоз', 'Включить первую передачу или передачу заднего хода', 'Перевести рычаг переключения передач в нейтральное положение']
from public.questions where ref = '#A187'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A188', t.id, 'To‘xtab turish tormoz tizimi N toifadagi avtotransport vositalarini aslahalangan holatda qanday qiyalikda harakatsiz holatda ushlab tura olmasa foydalanish taqiqlanadi?',
       array['25 foizdan kam bo‘lgan', '16 foizdan kam bo‘lgan', '31 foizdan kam bo‘lgan', '20 foizdan kam bo‘lgan'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком уклоне запрещается эксплуатация автотранспортных средств категории N с полной нагрузкой пои необеспечении неподвижное состояние стояночной тормозной системы?', array['Не менее 25 %', 'Не менее 16 %', 'Не менее 31 %', 'Не менее 20%']
from public.questions where ref = '#A188'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A189', t.id, 'Ushbu belgilardan qaysi biri haydovchining shu joydagi yashash yoki ishlash joyiga yetib borishiga monelik qilmaydi?',
       array['«A»', '«B»', '«C»', '«B» va «C»'], 2, 'q189.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из указанных знаков не запрещает водителю проехать к месту проживания и работы?', array['«A»', '«B»', '«C»', '«B» и «C»']
from public.questions where ref = '#A189'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A190', t.id, 'Ko‘rsatilgan yo‘l belgilaridan qaysi biri taqiqlovchi belgilar ilgari kiritgan barcha cheklovlarni bekor qiladi?',
       array['Faqat «В»', '«А» va «Б»', '«В» va «Г»', 'Barchasi'], 0, 'q190.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из указанных знаков отменяют все ограничения, введенные ранее запрещающими знаками?', array['Только «В»', '«А» и «Б»', '«В» и «Г»', 'Все']
from public.questions where ref = '#A190'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A191', t.id, 'Qaysi rasmdagi yo‘l ajratuvchi mintaqa ega?',
       array['Har ikkisida', 'O‘ng tarafdagisida', 'Chap tarafdagisida'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'На каком рисунке изображена дорога с разделительной полосой?', array['На обоих', 'Только на правом', 'Только на налевом']
from public.questions where ref = '#A191'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A192', t.id, 'Ushbu ko‘rsatilgan yo‘llar nechtadan qatnov qismiga ega?',
       array['Bittadan', 'Ikkitadan', 'To‘rttadan'], null, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Сколько проезжих частей имеет данные дороги?', array['По одному', 'По две', 'По четыре']
from public.questions where ref = '#A192'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A193', t.id, 'Yo‘l-transport hodisasi-',
       array['Transport vositasining yo‘lda harakatlanishi jarayonida ro‘y bergan, fuqarolarning halok bo‘lishiga yoki sog‘lig‘iga zarar yetishiga, transport vositalari, inshootlar, yuklarning shikastlanishi yoxud boshqa moddiy zarar yetishiga sabab bo‘lgan hodisa', 'Yo‘l harakati qatnashchilarining yo‘l-transport hodisalari va ularning oqibatlaridan himoyalanganlik darajasini aks ettiruvchi yo‘l harakati holati'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Дорожно-транспортное пооисшествие-', array['Событие, возникшее в процессе движения по дороге транспортного средства, при котором наступила смерть или причинен вред здоровью граждан, повреждены транспортные средства, сооружения, грузы либо причинен иной материальный ущерб', 'Комплекс правовых, организационно-технических мероприятий и распорядительных действий по управлению движением на дорогах']
from public.questions where ref = '#A193'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A194', t.id, 'Quyidagi belgilardan qaysi biri haydovchini boshqa xavf-xatarlar to‘g‘risida ogohlantiradi?',
       array['Faqat «A»', 'Faqat «Б»', 'Faqat «В»'], 2, 'q194.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из следующих знаков предупреждает водителя о прочих опасности?', array['Только «A»', 'Только «Б»', 'Только «В»']
from public.questions where ref = '#A194'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A195', t.id, 'Moped haydovchilariga ruxsat beriladi:',
       array['Faqat yo‘lning chetki o‘ng bo‘lagida o‘ng tomonidan bir qator bo‘lib harakatlanishga', 'Faqat yo‘l yoqasidan harakatlanishga, agar piyodalarga xalaqit bermasa', 'Barcha sanab o‘tilgan hollarga'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Водителям мопедов разрешено двигаться:', array['Только по правому краю проезжей части в один ряд', 'Только по обочине, если не создают помехи пешеходам', 'Во всех перечисленных случаях']
from public.questions where ref = '#A195'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A196', t.id, 'Harakatlanishga ruxsat berilgan:',
       array['Qizil, ko‘k, yashil va sariq avtomobilga', 'Qizil va sariq avtomobilga', 'Qizil, sariq va yashil avtomobilga'], 1, 'q196.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешено двигаться:', array['Красный ,синий, зеленый и желтую машину', 'Красный и желтую машину', 'Красный, желтый и зеленый автомобиль']
from public.questions where ref = '#A196'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A197', t.id, 'Siz chorrahadan chapga burilishda qaysi transport vositasiga yo‘l berishingiz lozim?',
       array['Avtobusga', 'Yengil avtomobilga', 'Hech kimga'], 2, 'q197.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Вы намерены повернуть налево, какому транспортному средству следует уступить дорогу?', array['Автобусу', 'Легковому автомобилю', 'Никому']
from public.questions where ref = '#A197'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A198', t.id, 'Svetaforning qizil yoki sariq ishoralari bilan bir vaqtda yongan qo‘shimcha tarmoqning yo‘naltirgichli yashil ishorasi yo‘nalishida harakatlanayotgan transport vositasining haydovchisi kimga yo‘l berishi kerak?',
       array['Boshqa yo‘nalishlarda harakatlanayotgan transport vositalariga yo‘l berishi kerak', 'O‘ngdan kelayotgan transport voistalariga', 'Qarama-qarshi yo‘nalishda to‘g‘riga yoki o‘ngga harakatlanayotgan transport vositalariga'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кому обязан уступить дорогу водитель транспортного средства при движении в направлении зеленой стрелки, включенной в дополнительной секции одновременно с желтым и красным сигналом светофора?', array['Транспортным средствам, движущимся с других направлений.', 'Транспортным средствам, приближающимся справа', 'Транспортным средствам, движущимся со встречного направления прямо и направо']
from public.questions where ref = '#A198'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A199', t.id, 'Avtomobilni qanday boshqarish usuli yonilg‘i sarfini tejaydi?',
       array['Shiddat bilan tezlanish va ohista (ravon) sekinlashish bilan', 'Ohista (ravon) tezlanish va shiddat bilan sekinlashish bilan', 'Ohista (ravon) tezlanish va ohista sekinlashish bilan'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При каком способе вождения будет обеспечен наименьший расход топлива?', array['При резком ускорении и плавном замедлении', 'При плавном ускорении и резком замедлении', 'При плавном ускорении и плавном замедлении']
from public.questions where ref = '#A199'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A200', t.id, 'Ushbu yotiq chiziq nimani bildiradi?',
       array['Velosiped yo‘lkasini', 'Sun‘iy yo‘l notekisligini', 'Yo‘nalishli taksilar to‘xtaydigan joyni'], 1, 'q200.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что обозначает эта горизонтальная разметка?', array['Велосипедную дорожку', 'Искусственную неровности дороги.', 'Места стоянки маршрутных такси.']
from public.questions where ref = '#A200'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A201', t.id, 'Ushbu belgi . . .',
       array['Oldinda harakatlanish serqatnovligi haqida ogohlantiradi', 'Oldinda transport vositalarining tirbandligi haqida ogohlantiradi', 'Oldinda transport vositalari orasida xafiz oraliqni ta‘minlash lozimligi haqida ogohlantiradi'], null, 'q201.png', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Этот дорожный знак...', array['Предупреждает о высоком интенсивности движения в переди.', 'Предупреждает о заторе транспортных средств в переди.', 'О создании безопасной дистанции между транспортными средствами.']
from public.questions where ref = '#A201'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A202', t.id, 'Piyodalar o‘tish joyi - bu ...',
       array['Yo‘l qatnov qismining piyodalar kesib o‘tishi uchun mo‘ljallangan, 5.16.1, 5.16.2 yo‘l belgilari va 1.14.1-1.14.3 yo‘l chiziqlari bilan ajratilgan bo‘lagi', 'Yo‘lning piyodalar harkatlanishi uchun mo‘ljallangan va transport vositalari harakati taqiqlangan qismi', 'Qatnov qismiga tutashgan yoki undan maysazor, ariq, maxsus to‘siqlar bilan ajratilgan va piyodalarning harakatlanishi uchun mo‘ljallangan yo‘l qismi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Пешеходный переход - это ...', array['Участок проезжей части дороги, предназначенный для пересечения пешеходами, обозначенный дорожными знаками 5.16.1, 5.16.2 и дорожной разметкой 1.14.1-1.14.3.', 'Часть дороги, примыкающая к проезжей части или отделенная от нее газоном, арыком или специальным сооружением, предназначенная для движения пешеходов.', 'Часть дороги, предназначенная для движения пешеходов, по которой запрещено движение транспортных средств.']
from public.questions where ref = '#A202'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A203', t.id, 'To‘xtab turish qoidasini kim buzdi?',
       array['Faqat «А»', 'Faqat «Б»', '«А» va «Б»'], 1, 'q203.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто нарушил правило стоянки?', array['Только «А»', 'Только «Б»', '«А» и «Б»']
from public.questions where ref = '#A203'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A204', t.id, 'Aholi punktlariga tegishli yo‘l harakati qoidalari qayerdan boshlanadi?',
       array['Aholi punkti nomini ko‘rsatuvchi oq rangli 5.22 belgisidan boshlab', 'Aholi punkiti nomoni ko‘rsatuvchi oq 5.22 yoki 5.24 havorang rangli belgidan boshlab', 'Yo‘l yuzidagi qurilma va inshootlardan boshlab'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Где начинают действовать правила, относящиеся к населённым пунктам?', array['Только с места установки дорожного знака с названием населённого пункта на белом фоне 5.22', 'С места установки дорожного знака с названием населённого пункта на белом 5.22 или синем фоне 5.24', 'В начале застроенной территории, непосредственно прилегающей к дороге']
from public.questions where ref = '#A204'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A205', t.id, 'Burilish ko‘rsatkichi bilan berilayotgan ogohlantiruvchi ishora qachon to‘xtatilishi kerak?',
       array['Manyovr bajarishdan oldin', 'Manyovr bajargandan so‘ng darhol', 'Manyovr bajarayotganda'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Когда должна быть прекращена подача сигнала указателями поворота?', array['Непосредственно перед началом маневра', 'Сразу же после завершения маневра', 'В процессе выполнения маневра']
from public.questions where ref = '#A205'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A206', t.id, 'Qaysi yo‘l belgilari qayrilib olishga ruxsat beradi?',
       array['Faqat «Б»', 'Faqat «Б» va «Г»', 'Faqat «А», «Б» va «В»', 'Barchasi'], 3, 'q206.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки разрешают выполнить разворот?', array['Только «Б»', 'Только «Б» va «Г»', 'Только «А», «Б» va «В»', 'Все']
from public.questions where ref = '#A206'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A207', t.id, 'Ushbu yo‘l belgisi ta‘sir oralig‘ida sizga odam tushirish (chiqarish)ga yoki yuk ortish (tushurish)ga ruxsat etiladimi?средства в зоне действия этого знака?',
       array['Ha', 'Yo‘q'], null, 'q207.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли Вам осуществить посадку (высадку) пассажиров либо загрузку (разгрузку) транспортного', array['Да', 'Нет']
from public.questions where ref = '#A207'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A208', t.id, 'Yengil avtomobilda qaysi yo‘nalishlarda harakatlanishga ruxsat etiladi?',
       array['Faqat to‘g‘riga', 'Faqat o‘ngga va chapga', 'Istalgan yo‘nalishda'], 2, 'q208.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких направлениях Вам разрешено продолжить движение на легковом автомобиле?', array['Только прямо', 'Только налево или направо', 'В любых']
from public.questions where ref = '#A208'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A209', t.id, 'Quruq ob-obhavo sharoitida asfalt-beton qoplamali yo‘lda harakatlanayotgan haydovchi yomg‘ir tomchilab qolganda nima qilishi kerak?',
       array['Tezlikni kamaytirish va extiyot bo‘lishi kerak', 'Tezlikni o‘zgartirmasdan harakatni davom ettirish', 'Yomg‘ir tezlashib ketmasdan tezroq harakat qilishi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как следует поступить водителю, если во время движения по сухой дороге с асфальтобетонным покрытием начал капать дождь?', array['Уменьшить скорость и быть особенно осторожным', 'Не изменяя скорости, продолжить движение', 'Увеличить скорость и попытаться проехать как можно большее расстояние, пока не начался сильный дождь']
from public.questions where ref = '#A209'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A210', t.id, 'Yoqilg‘i bilan ta‘minlash tepkisini keskin tezlikni oshirish uchun bosayotganda, avtomobil sirpanishni boshlasa haydovchi qanday harakat qilishi kerak?',
       array['Tepkini yanada kuchliroq bosish', 'Tepkiga ta‘sir etuvchi kuchni o‘zgartirmaslik', 'Tepkiga ta‘sir etuvchi kuchni kamaytirish'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как водитель должен воздействовать на педаль управления подачи топлива при возникновении заноса, вызванного резким ускорением движения?', array['Усилить нажатие на педаль', 'Не менять силу нажатия на педаль', 'Уменьшить нажатие на педаль']
from public.questions where ref = '#A210'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A211', t.id, 'Tormoz tizimi ishlamaydigan avtomobilning vazni sizning avtomobilingiz vaznini yarmidan ortiq bo‘lsa, uni shatakka olishingizga ruxsat etiladimi?',
       array['Ruxsat etiladi', 'Taqiqlanadi', 'Faqat 30km/soat tezlikda ruxsat etiladi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли Вам буксировать автомобиль с недействующей тормозной системой, если Фактическая масса этого автомобиля превышает половину фактической массы Вашего автомобиля?', array['Разрешается', 'Запрещается', 'Разрешается только при скорости буксировки не более 30 км/ч']
from public.questions where ref = '#A211'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A212', t.id, 'Yo‘nalishli transport vositasi bekatidan tashqarida yo‘l chetidan qo‘zg‘alayotgan yo‘nalishli transport vositasiga yo‘l berishingiz kerakmi?',
       array['Ha', 'Yo‘q'], 1, 'q212.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Обязаны ли Вы уступить дорогу маршрутному транспортному средству, отъезжающему от тротуара, где нет обозначенного места остановки?', array['Да', 'Нет']
from public.questions where ref = '#A212'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A213', t.id, 'Piyodalar to‘xtab turgan avtobus va trolleybusning qaysi tomonidan yo‘lni kesib o‘tishlari kerak?',
       array['Oldi tomonidan', 'Orqa tomonidan', 'Istalgan tomonidan'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'С какой стороны автобуса и троллейбуса пешеходы должны переходить дорогу?', array['Спереди автобуса и троллейбуса', 'Сзади автобуса и троллейбуса', 'Без разницы']
from public.questions where ref = '#A213'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A214', t.id, 'Sizga ko‘rsatilgan joyda yengil avtomobilda to‘xtashga ruxsat etiladimi?',
       array['Ha', 'Yo‘q'], 1, 'q214.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешено ли остановиться легковому автомобилю в указанном месте?', array['Да', 'Нет']
from public.questions where ref = '#A214'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A215', t.id, 'Yonlama oraliq masofani tanlashda tezlikning dahli bormi?',
       array['Yonlama oraliq masofani tanlashni tezlikka aloqasi yo‘q', 'Tezlik oshganda yonlama oraliq masofani oshirish kerak'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Зависит ли выбор бокового интервала от скорости движения?', array['Выбор бокового интервала от скорости движения не зависит', 'При увеличении скорости движения боковой интервал необходимо увеличить']
from public.questions where ref = '#A215'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A216', t.id, 'Ushbu vaziyatda quvib o‘tishdan so‘ng siz o‘rta bo‘lakda qolishingiz mumkinmi?',
       array['Ha', 'Yo‘q'], 1, 'q216.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'quvib-otish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Можете ли Вы продолжить движение по средней полосе после обгона?', array['Да', 'Нет']
from public.questions where ref = '#A216'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A217', t.id, 'Cheklangan ko‘rinish sharoitida orqaga harakatlanishda harakat xavfsizligini ta‘minlash uchun:',
       array['Tovushli signal berishi', 'Falokat yorug‘lik ishoralarini yoqish', 'Boshqa shaxslar yordamidan foydalanish'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Для обеспечения безопасности при движении задним ходом в местах, где видимость ограничена, необходимо:', array['Подать звуковой сигнал', 'Включить аварийную сигнализацию', 'Прибегнуть к помощи других лиц']
from public.questions where ref = '#A217'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A218', t.id, 'Ushbu holatda siz bajarishingiz lozim:',
       array['Belgi oldida to‘xtash', 'To‘xtash chizig‘i oldida to‘xtash', 'Boshqa transport vositalari bo‘lmasa, horrahadan to‘xtamasdan o‘tib ketish'], 1, 'q218.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В данной ситуации Вы должны:', array['Остановиться у знака', 'Остановиться у стоп-линии', 'При отсутствии других транспортных средств проехать перекресток без остановки']
from public.questions where ref = '#A218'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A219', t.id, 'Kunning yorug‘ vaqtida aholi punktlaridan tashqarida quvib o‘tilayotgan transport vositasi haydovchisining e‘tiborini qanday jalb qilasiz?',
       array['Faqat tovushli ishoralarni qo‘llab', 'Faqat chiroqlarni yoqib-o‘chirish bilan', 'Sanab o‘tilgan barcha usul bilan va ularni birgalikda qo‘llash bilan'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как Вы можете в светлое время суток привлечь внимание водителя обгоняемого автомобиля при движении вне населенного пункта?', array['Только звуковым сигналом', 'Только кратковременным переключением фар с ближнего света на дальний', 'Любым из перечисленных способов, включая совместную подачу этих сигналов']
from public.questions where ref = '#A219'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A220', t.id, 'Yo‘lning qanday qismida harakatlanganda kuchli yonlama shamol xavfi ortadi?',
       array['Ochiq joyda harakatlanganda', 'Yo‘lning yopiq qismida harakatlanganda', 'Yo‘lning yopiq qismidan ochiq qismiga chiqishda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При движении по какому участку дороги действие сильного бокового ветра наиболее опасно?', array['По открытому', 'По закрытому деревьями', 'При выезде с закрытого участка на открытый']
from public.questions where ref = '#A220'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A221', t.id, 'Uzoq davom etadigan keng ravon yo‘lda avtomobilni yuqori tezlikda boshqarganda haydovchiga tezlik qanday qabul qilinadi?',
       array['Aslidagidan sekin harakatlanayotganga o‘xshaydi', 'Aslidagidan tez harakatlanayotganga o‘xshaydi', 'Tezlikni qabul qilish o‘zgarmaydi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как воспринимается водителем скорость своего автомобиля пои длительном движении по ровной и широкой дороге на большой скорости?', array['Кажется меньше чем в действительности', 'Кажется больше, чем в действительности', 'Восприятие скорости не меняется']
from public.questions where ref = '#A221'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A222', t.id, 'Nosoz transport vositasini shatakka olgan yengil avtomobil salonida odam tashishga ruxsat etiladimi?',
       array['Ruxsat etiladi', 'Taqiqlanadi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешена ли перевозка людей в салоне легкового автомобиля, буксирующего неисправное транспортное средство?', array['Разрешена', 'Запрещена']
from public.questions where ref = '#A222'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A223', t.id, 'Ushbu holatda sizga temir yo‘l kesishmasiga chiqishga ruxsat etiladimi?',
       array['Ha', 'Ha, yaqinlashib kelayotgan poyezd yo‘q bo‘lsa', 'Taqiqlanadi'], 2, 'q223.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешено ли Вам въехать на железнодорожный переезд?', array['Да', 'Да, если отсутствует приближающийся поезд', 'Нет']
from public.questions where ref = '#A223'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A224', t.id, 'Ko‘k avtomobil chapga burilmoqchi. Kimga yo‘l berishi kerak?',
       array['Faqat avtobusga', 'Faqat yuk avtomobiliga', 'Har ikki transport vositasiga'], 2, 'q224.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Синяя машина собирается повернуть налево, кому она должна уступить дорогу?', array['Только автобусу', 'Только грузовому автомобилю', 'Обоим транспортным средствам']
from public.questions where ref = '#A224'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A225', t.id, 'Yengil avtomobilning orqa oynasiga parda yoki chiypardalar o‘rnatish mumkinmi?',
       array['Taqiqlanadi', 'Ruxsat etiladi, agarda ikki tomonda orqani ko‘rsatuvchi ko‘zgusi bo‘lsa'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли устанавливать шторки или жалюзи на заднем стекле легкового автомобиля?', array['Запрещается', 'Разрешается, но только при наличии с обеих сторон зеркал заднего вида']
from public.questions where ref = '#A225'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A226', t.id, 'Chorrahaning ko‘rsatilgan joyida sizga to‘xtashga ruxsat etiladimi?',
       array['Ruxsat etiladi', 'Taqiqlanadi', 'Ruxsat etiladi, agarda sizning transport vositangiz bilan sidirg‘a chiziq orasidagi masofa 3 metrdan ortiq bo‘lsa'], 1, 'q226.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешена ли Вам остановка в указанном месте на перекрестке?', array['Разрешена', 'Запрещена', 'Разрешена, если расстояние от Вашего транспортного средства до линии разметки не менее 3 м']
from public.questions where ref = '#A226'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A227', t.id, 'Siz ro‘paradan yaqinlashayotgan yuk avtomobiliga yo‘l berishingiz kerakmi?',
       array['Ha', 'Yo‘q'], 1, 'q227.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Должны ли Вы уступить дорогу встречному грузовому автомобилю?', array['Да', 'Нет']
from public.questions where ref = '#A227'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A228', t.id, 'Transport vositasi qiyalikda joyidan qo‘zg‘alishda to‘xtab turish tormoz dastagini qay vaqtda tushirishni boshlash kerak?',
       array['Harakatni boshlashdan avval', 'Harakatni boshlagandan so‘ng', 'harakatni boshlash bilan bir vaqtda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В какой момент следует начинать отпускать стояночный тормоз при заезде на подъем?', array['До начала движения', 'После начала движения', 'Одновременно с началом движения']
from public.questions where ref = '#A228'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A229', t.id, '90 km/soat tezlikda harakatlanayotgan transport vositasi 1sekundda qancha masofani bosib o‘tadi?',
       array['15 m', '25 m', '35 m'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какое расстояние проедет транспортное средство за одну секунду при скорости движения 90 км/ч?', array['15 м', '25 м', '35 м']
from public.questions where ref = '#A229'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A230', t.id, 'Avtomobilning ABS tizimi burilishda sirpanish va yonga siljishni oldini oladimi?',
       array['Avtomobilni faqat sirpanish ehtimolining oldini oladi', 'Avtomobilni faqat yonga siljish ehtimolining oldini oladi', 'Avtomobilni sirpanish va yonga siljish ehtimolining oldini olmaydi'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Предотвращает ли система АВS автомобиля боковое скольжение и скольжение при повороте?', array['Предотвращает только скольжение автомобиля', 'Предотвращает скольжение автомобиля только в сторону', 'Не препятствует боковому скольжению и скольжению автомобиля в сторону']
from public.questions where ref = '#A230'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A231', t.id, 'Ko‘rsatilgan qaysi joyda siz avtomobilni qoidaga binoan to‘xtatishingiz mumkin?',
       array['Фақат «А»', 'Фақат «Б»', 'Фақат «Б» ва «В»', 'Ҳеч қайсисида'], 1, 'q231.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком из указанных мест Вы можете произвести остановку?', array['Только «А»', 'Только «Б»', 'Только «Б» и «В»', 'Ни в каком']
from public.questions where ref = '#A231'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A232', t.id, 'Shatakka olingan avtomobilni falokat yorug‘lik ishoralari nosoz bo‘lganda transport vositasi qanday belgilanishi kerak?',
       array['Gabarit chiroqlarini yoqish', 'Orqa tumanga qarshi chiroqlarini yoqish', 'Shatakka olingan transport vositasi orqa tomoniga falokat sababli to‘xtash belgisini o‘rnatish'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как следует обозначить буксируемый автомобиль при отсутствии или неисправности аварийной сигнализации?', array['Включить габаритные огни', 'Включить задние противотуманные фары', 'Установить на задней части буксируемого автомобиля знак аварийной остановки']
from public.questions where ref = '#A232'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A233', t.id, 'Ko‘rsatilgan yo‘l belgilaridan qaysi biri ruxsat etilgan to‘la vazni 3,5 tonnadan kam bo‘lgan yuk avtomobiliga o‘ngga harakatlanishni buyuradi?',
       array['Faqat «А»', 'Faqat «Б»', '«А» va «Б»', '«Б» va «В»'], 1, 'q233.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки обязывают водителя грузового автомобиля, с разрешенной максимальной массой до 3.5 т., повернуть направо?', array['Только «А»', 'Только «Б»', '«А» и «Б»', '«Б» и «В»']
from public.questions where ref = '#A233'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A234', t.id, 'Sanab o‘tilgan qaysi hollarda haydovchi orqadagi vaziyatni e‘tiborga olishi kerak?',
       array['Faqat keskin tormoz berishda', 'Faqat nam qoplama yoki yaxmalakli yo‘llarda tormoz berganda', 'Har qanday tormozlashda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком из перечисленных случаев водителю следует оценивать обстановку сзади:', array['Только при резком торможении', 'Только при торможении на дороге с мокрым или скользким покрытием.', 'При любом торможении']
from public.questions where ref = '#A234'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A235', t.id, 'Tuman sharoitida, agar ko‘rinish masofasi 300 metrdan kam bo‘lsa kunduzgi chiroqlarni yoqish yetarlimi?',
       array['Yetarli', 'Yetarli emas'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Достаточно ли включения дневных ходовых огней для обозначения транспортного средства при движении в тумане, когда видимость дороги менее 300 м?', array['Достаточно', 'Недостаточно']
from public.questions where ref = '#A235'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A236', t.id, '«Quvib o‘tish» atamasi nimani bildiradi?',
       array['Bir va bir nechta transport vositalaridan o‘zib ketish', 'Egallab turgan bo‘lakdan qarama-qarshi harakat bo‘lagiga chiqib bir yoki bir nechta transport vositalaridan o‘zib ketish va dastlab egallab turgan bo‘lagiga qaytish', 'Egallagan harakatlanish bo‘lagidan chiqib, oldinda harakatlanayotgan transport vositasidan o‘zib ketish'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'quvib-otish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что означает термин "обгон"?', array['Опережение одного или нескольких транспортных средств.', 'Опережение одного или нескольких транспортных средств, связанное с выездом на полосу (сторону проезжей части), предназначенную для встречного движения, и последующим возвращением на ранее занимаемую полосу (сторону проезжей части)', 'Опережение движущегося впереди транспортного средства, связанное с выездом из занимаемой полосы']
from public.questions where ref = '#A236'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A237', t.id, 'Kunning qorong‘i vaqtida va bulutli ob-havoda ro‘paradan kelayotgan avtomobil tezligi qanday tuyuladi?',
       array['Aslidagidan kam tezlikda tuyuladi', 'Aslidagidan katta tezlikda tuyuladi', 'Tezlikni qabul qilish o‘zgarmaydi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В тёмное время суток и в пасмурную погоду скорость встречного автомобиля воспринимается:', array['Ниже, чем в действительности', 'Выше, чем в действительности', 'Восприятие скорости не меняется']
from public.questions where ref = '#A237'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A238', t.id, 'Tormoz tizimiga ega bo‘lmagan tirkama bilan harakatlanayotganda yengil avtomobilni tormoz yo‘li qanday o‘zgaradi?',
       array['Tirkama qo‘shimcha qarshilikka ega bo‘lgani uchun tormoz yo‘li kamayadi', 'Tormoz yo‘li uzayadi', 'Tormoz yo‘li o‘zgarmaydi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как изменяется длина тормозного пути легкового автомобиля при движении с прицепом, не имеющим тормозной системы?', array['Тормозной путь уменьшается, так как прицеп оказывает дополнительное сопротивление движению', 'Тормозной путь увеличивается', 'Тормозной путь не изменяется']
from public.questions where ref = '#A238'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A239', t.id, 'Yo‘lning keskin burilishida yuzaga keladigan sirpanishning oldini olish uchun haydovchi nima qilishi kerak?',
       array['Burilishdan oldin tezlikni kamaytirib, avtomobilni erkin harakatlanishi uchun ilashma tepkisini bosishi', 'Burilishdan oldin tezlikni kamaytirish, kerak bo‘lsa uzatmalar pog‘onasini pasaytirish, burilishdan o‘tayotganda tezlikni oshirmaslik va avtomobilni keskin tormozlamaslik', 'Sanab o‘tilgan har ikki usulni qo‘llashga ruxsat etiladi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что следует сделать водителю, чтобы предотвратить возникновение заноса при проезде крутого поворота?', array['Перед поворотом снизить скорость и выжать педаль сцепления, чтобы дать возможность автомобилю двигаться накатом на повороте', 'Перед поворотом снизить скорость, при необходимости включить пониженную передачу, а при проезде поворота не увеличивать резко скорость и не тормозить', 'Допускается любое из перечисленных действий']
from public.questions where ref = '#A239'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A240', t.id, 'Qattiq yoki egiluvchan ulagichda shatakka olingan yuk avtomobilining kabinasida odam tashishga ruxsat etiladimi?',
       array['Ruxsat etiladi', 'Taqiqlanadi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При буксировке на жесткой или гибкой сцепки, разрешается ли перевозить людей в кузове буксирующего грузового автомобиля?', array['Разрешено', 'Запрещено']
from public.questions where ref = '#A240'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A241', t.id, 'Chorrahaga kirishda siz:',
       array['Mototsiklga yo‘l berishingiz kerak', 'Har ikkisiga ham yo‘l berishingiz kerak', 'Birinchi o‘tish huquqiga egasiz'], 1, 'q241.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'При въезде на перекресток Вы :', array['Должны уступить дорогу только мотоциклу', 'Должны уступить дорогу обоим транспортным средствам', 'Имеете преимущественное право на движение']
from public.questions where ref = '#A241'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A242', t.id, 'Qaysi yo‘l belgisi barcha transport vositalarining harakatini istisnosiz taqiqlaydi?',
       array['«А»', '«Б»', '«В»'], 1, 'q242.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак запрещает дальнейшее движение всех без исключения транспортных средств?', array['«А»', '«Б»', '«В»']
from public.questions where ref = '#A242'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A243', t.id, 'Sanab o‘tilgan qaysi transport vositalarini o‘t o‘chirgichsiz tasarruf etishga ruxsat etiladi?',
       array['Avtomobillarni', 'Avtobuslarni', 'Barcha mototsikllarni', 'Faqat yon kajavasiz mototsikllarni'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'texnik-holat'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из перечисленных транспортных средств разрешается эксплуатировать без огнетушителя?', array['Автомобили', 'Автобусы', 'Все мотоциклы', 'Только мотоциклы без бокового прицепа.']
from public.questions where ref = '#A243'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A244', t.id, 'Kunning yorug‘ vaqtida aholi punktlaridan tashqarida siz quvib o‘tayotgan transport vositasi haydovchisining e‘tiborini qanday jalb qilasiz?',
       array['Faqat tovush ishorasi bilan', 'Faqat yorug‘lik faralar qisqa-qisqa yoqib o‘chirish bilan', 'Sanab o‘tilgan barcha usullar bilan va ularni birga qo‘llash bilan'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как Вы можете в светлое время суток привлечь внимание водителя обгоняемого автомобиля при движении вне населенного пункта?', array['Только звуковым сигналом', 'Только кратковременным переключением фар с ближнего света на дальний', 'Любым из перечисленных способов, включая совместную подачу этих сигналов']
from public.questions where ref = '#A244'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A245', t.id, 'Qaysi qo‘shimcha axborot belgilari birga qo‘llanilganda belgilarning ta‘sir oralig‘ini ko‘rsatadi?',
       array['Faqat «А»', 'Faqat «Б»', '«Б» va «В»'], 2, 'q245.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки дополнительной информации указывают протяженность зоны действия знаков, с которыми они применяются?', array['Только «А»', 'Только «Б»', '«Б» и «В»']
from public.questions where ref = '#A245'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A246', t.id, 'Birinchi uzatmada uzoq tezlanishda yurish yoqilg‘i sarfiga qanday ta‘sir etadi?',
       array['Yoqilg‘i sarfi ortadi', 'Yoqilg‘i sarfi kamayadi', 'Yoqilg‘i sarfi o‘zgarmaydi'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как влияет длительный разгон транспортного средства с включенной первой передачей на расход топлива?', array['Расход топлива увеличивается', 'Расход топлива уменьшается', 'Расход топлива не изменяется']
from public.questions where ref = '#A246'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A247', t.id, 'Qaysi yo‘l belgisi piyodalar yo‘lkasini bildiradi?',
       array['Faqat «Б»', 'Faqat «Б» va «В»', 'Barcha belgilar'], 0, 'q247.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из знаков обозначает пешеходную дорожку?', array['Только «Б»', 'Только «Б» и «В»', 'Все знаки']
from public.questions where ref = '#A247'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A248', t.id, 'Qaysi holatda siz majburiy to‘xtashni amalga oshirasiz?',
       array['Piyodalar o‘tish joyi oldida piyodalarga yo‘l berish uchun to‘xtab', 'Texnik nozozlik tufayli yo‘lning harakat qismida', 'Har ikki sanab o‘tilgan holda'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком случае Вы совершите вынужденную остановку?', array['Остановившись непосредственно перед пешеходным переходом, чтобы уступить дорогу пешеходу.', 'Остановившись на проезжей части из-за технической неисправности автомобиля', 'В обоих перечисленных случаях.']
from public.questions where ref = '#A248'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A249', t.id, 'Qaysi belgilarda qarama-qarshi harakatlanishda o‘tib ketsh qiyin bo‘lsa, siz yo‘l berishingiz kerak?',
       array['Faqat «В»', '«А» va «В»', '«Б» va «В»', '«Б» va «Г»'], 1, 'q249.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки требует, что Вы должны уступить дорогу, если встречный разъезд затруднен?', array['Только «В»', '«А» и «В»', '«Б» и «В»', '«Б» и «Г»']
from public.questions where ref = '#A249'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A250', t.id, 'Qaysi hollarda sizga harakatni davom ettirish taqiqlanadi, hatto ta‘mirlash ustaxonasiga ham, agarda faralar va orqa gabarit chiroqlar nosoz bo‘lsa ?',
       array['Faqat yetarlicha ko‘rinmaslik sharoitida', 'Kunning qorong‘i vaqtida', 'Har ikkala sanab o‘tilgan holatda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'texnik-holat'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких случаях Вам запрещается дальнейшее движение даже до места ремонта или стоянки с не горящими (из-за неисправности) фарами и задними габаритными огнями?', array['Только в условиях недостаточной видимости.', 'Только в темное время суток', 'В обоих перечисленных случаях']
from public.questions where ref = '#A250'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A251', t.id, 'Qanday hollarda yo‘lning burilish qismlarida yengil avtomobil ag‘darilishga qarshi turg‘unroq?',
       array['Yuksiz va yo‘lovchilarsiz', 'Yo‘lovchilar bilan yuksiz', 'Yo‘lovchilarsiz, yuqori yukxonasida yuki bilan'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком случае легковой автомобиль более устойчив против опрокидывания на повороте?', array['Без груза и пассажиров', 'С пассажирами, но без груза', 'Без пассажиров, но с грузом на верхнем багажнике']
from public.questions where ref = '#A251'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A252', t.id, 'Kunning qorong‘u vaqtida aholi punktlarida yo‘ning yoritilgan qismida siz qanday tashqi yoritish chiroqlaridan foydalanishingiz kerak?',
       array['Gabarit chiroqlardan', 'Yaqinni yorituvchi chiroqlardan', 'Yaqinni yoki uzoqni yorituvchi chiroqlardan'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие внешние световые приборы Вы должны использовать при движении в темное время суток на освещенных участках дорог населенного пункта?', array['Габаритные огни', 'Фары ближнего света', 'Фары ближнего или дальнего света']
from public.questions where ref = '#A252'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A253', t.id, 'Qaysi transport vositasining haydovchisi qoidani buzib burilmoqda?',
       array['Faqat yengil avtomobil haydovchisi', 'Faqat mototsikl haydovchisi', 'Ikkisi ham buzmoqda'], 2, 'q253.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто из водителей, совершающих поворот, нарушает правила?', array['Только водитель легкового автомобиля', 'Только мотоциклист', 'Оба нарушают']
from public.questions where ref = '#A253'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A254', t.id, 'Ushbu yo‘lda sizga yo‘l belgisidan keyin qaysi bo‘laklarda harakatlanishga ruxsat beriladi?',
       array['Istalgan bo‘lakdan', 'O‘ng bo‘lakdan', 'Faqat chap bo‘lakdan'], 1, 'q254.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'По какой полосе вам разрешено ездить после дорожного знака?', array['По любой полосе', 'По правой полосе', 'Только по левой полосе']
from public.questions where ref = '#A254'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A255', t.id, 'Qaysi yo‘l belgilari chapga burilishni taqiqlaydi?',
       array['Faqat «А»', 'Faqat «А» va «Б»', 'Faqat «А» va «Г»', 'Barchasi'], 2, 'q255.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки запрещают поворот налево?', array['Только «А»', 'Только «А» ва «Б»', 'Только «А» ва «Г»', 'Все']
from public.questions where ref = '#A255'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A256', t.id, 'Yo‘l transport hodisasiga dahldor haydovchilar birinchi navbatda nima qilishlari kerak?',
       array['Yo‘lning harakat qismini bo‘shatishlari kerak', 'Transport vositasini darhol to‘xtatishi, avariya ishoralarini yoqishi va avariya sababli to‘xtash belgisini o‘rnatishi', 'Sodir etilgan hodisa xaqida YHXXga xabar berishi kerak'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что обязаны сделать в первую очередь водители, причастные к дорожно-транспортному происшествию?', array['Освободить проезжую часть', 'Немедленно остановиться, включить аварийную сигнализацию и выставить знак аварийной остановки', 'Сообщить о случившемся в СБДД']
from public.questions where ref = '#A256'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A257', t.id, 'Piyodalar turar joy dahasida qayerda harakatlanishlari mumkin?',
       array['Faqat tratuarda', 'Faqat qatnov qismidan', 'Tratuarda, hamda qatnov qismida'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Где могут двигаться пешеходы в жилой зоне?', array['Только по тротуарам', 'По тротуарам и в один ряд по краю проезжей части', 'По тротуарам и по проезжей части']
from public.questions where ref = '#A257'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A258', t.id, 'Quvib o‘tishni bajarayotganda chapga burilishni ko‘rsatuvchi chiroqni qachon o‘chirishingiz kerak?',
       array['Manyovrni tugallagach, darhol', 'Quvib o‘tilayotgan transport vositasidan o‘zib ketgandan so‘ng istalgan vaqtda', 'O‘z ixtiyoringizga havola'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'quvib-otish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Когда Вы обязаны выключить левые указатели поворота, выполняя обгон?', array['Сразу после завершения маневра', 'После опережения обгоняемого транспортного средства', 'По своему усмотрению']
from public.questions where ref = '#A258'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A259', t.id, 'Chorrahadagi uzuq-uzuq chiziqlar nimani bildiradi?',
       array['Majburiy harakatni', 'Chorrahada harakatlanish bo‘lagini chegarasini'], 1, 'q259.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что обозначают прерывистые линии разметки на перекрестке?', array['Обязательное направление движения на перекрестке', 'Границы полос движения в пределах перекрестка']
from public.questions where ref = '#A259'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A260', t.id, 'Qanday alomatlar charchash belgilari hisoblanadi?',
       array['Uyquchanlik, bo‘shashish, diqqatning susayishi', 'Zo‘riqish, asabiylashish', 'Bosh aylanishi, ko‘zlarga qum kirgan kabi achishish, terlash alomati'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Каковы типичные признаки наступившего утомления водителя?', array['Сонливость, вялость, притупление внимания', 'Возбуждённость, раздражительность', 'Головокружение, резь в глазах, повышенная потливость']
from public.questions where ref = '#A260'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A261', t.id, 'Siz yengil avtomobildan qaysi jihozlar mavjud bo‘lmaganda foydalanishingiz mumkin?',
       array['Tibbiy quticha', 'O‘t o‘chirgich', 'Falokat to‘xtash belgisi', 'G‘ildirab ketishga qarshi moslama'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Вы имеете право эксплуатировать легковой автомобиль при отсутствии:', array['Аптечки', 'Огнетушителя', 'Знака аварийной остановки', 'Противооткатных упоров']
from public.questions where ref = '#A261'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A262', t.id, 'Kunning yorug‘ vaqtida quyidagi hollarda yaqinni yorituvchi chiroqlar yoqilishi kerak:',
       array['Yo‘lovchilarni tashiyotgan avtobus va yo‘nalishli transport vositalarida', 'Xavfli, katta o‘lchamli va og‘ir vaznli yuklarni tashishda', 'Mototsikl va mopedlarda', 'Barcha sanab o‘tilgan hollarda'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В светлое время суток ближний свет фар должен быть включен в следующих случаях:', array['При движении в составе организованной транспортной колонны', 'При перевозке опасных, крупногабаритных и тяжеловесных грузов', 'На мотоциклах и мопедах', 'Во всех перечисленных случаях']
from public.questions where ref = '#A262'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A263', t.id, 'Qaysi yo‘nalishda harakatlanishni davom ettirishingiz mumkin?',
       array['Faqat chapga', 'Chapga va orqaga qayrilib olishga', 'O‘ngga, chapga va orqaga qayrilib olishga'], 2, 'q263.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких направлениях Вам можно продолжить движение?', array['Только направо', 'Налево и в обратном направлении', 'Направо, налево и в обратном направлении']
from public.questions where ref = '#A263'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A264', t.id, '72 km/soat tezlikda harakatlanayotgan transport vositasi 1 sekundda qancha masofani bosib o‘tadi?',
       array['15 m', '20 m', '25 m'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какое расстояние проедет транспортное средство за одну секунду при скорости движения 72 км/ч?', array['15 м', '20 м', '25 м']
from public.questions where ref = '#A264'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A265', t.id, 'Qaysi hollarda transport vositasidan foydalanish taqiqlanadi?',
       array['Yonilg‘i darajasini ko‘rsatish qurilmasi ishlamaydi', 'O‘t oldirish tizimi nosoz', 'Dvigatel qiyinchilik bilan ishga tushadi', 'Tovush signallari ishlamaydi'], 3, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'texnik-holat'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком случае запрещается эксплуатация транспортного средства?', array['Не работает указатель уровня топлива', 'Нарушена система зажигания', 'Затруднен пуск двигателя', 'Не работает звуковой сигнал']
from public.questions where ref = '#A265'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A266', t.id, 'Kunning yorug‘ vaqtida aholi punktlarida quvib o‘tilayotgan transport vositasi haydovchisining e‘tiborini jalb qilish uchun mumkin:',
       array['Tovush signalidan foydalanish', 'Faqat yaqinni yorituvchi chiroqni uzoqni yorituvchi chiroqqa qisqa muddat orasida o‘tkazish bilan ishora berish', 'Faqat birgalikda yorug‘lik ishoralari bilan birga tovush signallarini qo‘llash', 'Sanab o‘tilganlarning barchasidan foydalanish'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Привлечь внимание водителя обгоняемого автомобиля при движении в населенном пункте в светлое время суток можно:', array['Только звуковым сигналом', 'Только кратковременным переключением фар ближнего света на дальний', 'Только совместной подачей звукового и светового сигнала', 'Любые из перечисленных способов']
from public.questions where ref = '#A266'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A267', t.id, 'Svetafor ishoralari qaysi guruh yo‘l belgilarini bekor qiladi (miltillovchi sariq ishoradan tashqari)?',
       array['Imtiyoz belgilari', 'Taqiqlovchi belgilar', 'Buyuruvchi belgilar', 'Barcha sanab o‘tilganlari'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Значения каких дорожных знаков отменяются сигналами светофора?', array['Знаков приоритета', 'Запрещающих знаков', 'Предписывающих знаков', 'Всех перечисленных']
from public.questions where ref = '#A267'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A268', t.id, 'Ushbu yo‘l chizig‘i sizga qanday manyovr bajarishni taqiqlaydi?',
       array['Quvib o‘tishni', 'Aylanib o‘tishni', 'Qayralib olishni', 'Sanab o‘tilgan barcha manevrlarga ruxsat beriladi'], 3, 'q268.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'quvib-otish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой маневр Вам запрещается выполнить при наличии данной линии разметки?', array['Обгон', 'Объезд', 'Разворот', 'Разрешает все перечисленные маневры']
from public.questions where ref = '#A268'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A269', t.id, 'Ushbu belgi axborot beradi:',
       array['Siz o‘ngga yoki chapga burilishingiz kerakligini ko‘rsatadi', 'Reversiv harakatlanish yo‘liga chiqish haqida', 'Chorrahadan o‘ngga va chapga bir tomonlama harakat tashkil qilingan'], 1, 'q269.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Этот знак указывает, что:', array['Вы должны повернуть направо или налево', 'На пересекаемой дороге организовано реверсивное движение', 'Вправо и влево от перекрестка организовано одностороннее движение']
from public.questions where ref = '#A269'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A270', t.id, 'M3 toifadagi avtotransport vositalarining boshqaruv qurilmasidagi qanday eng katta lyuft yig‘indisiga yo‘l qo‘yiladi :',
       array['10°', '20°', '25°'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Суммарный люфт в рулевом управлении в регламентированных условиях испытаний автотранспортного средства категории М3 не должен превышать следующих значений:', array['10°', '20°', '25°']
from public.questions where ref = '#A270'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A271', t.id, 'Sizga ruxsat etilgan to‘la vazni 3,5 tonnadan ortiq yuk avtomobilida harakatlanish:',
       array['Faqat to‘g‘riga', 'To‘g‘riga va o‘ngga', 'Barcha yo‘nalishlarda'], 0, 'q271.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Вам разрешено продолжить движение на грузовом автомобиле с разрешенной максимальной массой более 3,5 т:', array['Только прямо', 'Прямо и направо', 'Во всех направлениях']
from public.questions where ref = '#A271'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A272', t.id, '108 km/s tezlikda harakatlanayotgan transport vositasi 1 sekundda qancha masofani bosib o‘tadi?',
       array['15 m', '25 m', '30 m'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какое расстояние проедет транспортное средство за одну секунду при скорости движения 108 км/ч?', array['15 м', '25 м', '30 м']
from public.questions where ref = '#A272'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A273', t.id, 'Ko‘rsatilgan qaysi belgi reversiv harakat boshlanishi haqida axborot beradi?',
       array['«А»', '«Б»', '«В»'], 1, 'q273.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой из указанных знаков информирует о начале дороги с реверсивным движением?', array['«А»', '«Б»', '«В»']
from public.questions where ref = '#A273'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A274', t.id, 'Shatakka olib harakatlanishingiz mumkin:',
       array['Faqat «A» yo‘nalishi bo‘yicha', 'Faqat «B» yo‘nalish bo‘yicha', 'Ko‘rsatilgan barcha yo‘nalish bo‘yicha'], 0, 'q274.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Продолжить буксировку можно:', array['Только в направлении А', 'Только в направлении Б', 'В любом из указанных направлений']
from public.questions where ref = '#A274'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A275', t.id, 'Ushbu yo‘l belgisi chorrahaga yaqinlashayotganlik to‘g‘risida ogohlantiradi, bunda Siz:',
       array['Birinchi bo‘lib o‘tish huquqiga egasiz', 'Kesib o‘tayotgan yo‘ldagi transport vositalariga yo‘l berishingiz kerak', 'Faqatgina o‘ng tomondan yaqinlashib kelayotgan transport vositalariga yo‘l berishingiz kerak'], 2, 'q275.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Этот знак предупреждает о приближении к перекрестку, на котором Вы:', array['Имеете право преимущественного проезда', 'Должны уступить дорогу всем транспортным средствам, движущимся по пересекаемой дороге', 'Должны уступить дорогу только транспортным средствам, приближающимся справа']
from public.questions where ref = '#A275'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A276', t.id, 'Haydovchiga transport vositasini boshqarish vaqtida telefondan foydalanishga ruxsat etiladimi?',
       array['Ruxsat etiladi', 'Qo‘lni ishlatmasdan texnik vosilalardan foydalanish gaplashishga ruxsat etiladi', '20 km/s tezlikda harakatlanayotganda ruxsat etiladi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли водителю пользоваться телефоном во время движения?', array['Разрешается', 'Разрешается только при использовании технического устройства, позволяющего вести переговоры без использования рук', 'Разрешается только при движении со скоростью менее 20 км/ч']
from public.questions where ref = '#A276'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A277', t.id, 'Agar avtomobil antiblokirovkali (ABS) tormoz tizimi bilan jihozlangan bo‘lsa keskin tormoz berishni qanday amalga oshirish kerak?',
       array['Tormoz tepkisini uzub-uzub bosish yo‘li bilan', 'Tormoz tepkisini oxirigacha bosish va avtomobilni to‘liq to‘xtaguncha tepkini qo‘yib yubormaslik', 'To‘xtab turish tormozi tizimini qo‘llash yo‘li bilan'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Как правильно произвести экстренное торможение, если автомобиль оборудован ABS антиблокировочной тормозной системой?', array['Путем прерывистого нажатия на педаль тормоза', 'Путем нажатия на педаль тормоза до упора и удерживания ее до полной остановки', 'Путем использования стояночной тормозной системы']
from public.questions where ref = '#A277'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A278', t.id, 'Tumanga qarshi chiroqlar va orqa tumanga qarshi chiroqlar birga yoqilishi mumkin?',
       array['Cheklangan ko‘rinish sharoitida', 'Yetarlicha ko‘rinmaslik sharoitida'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Противотуманные фары и задние противотуманные фонари могут быть включены одновременно:', array['В условиях ограниченной видимости', 'В условиях недостаточной видимости']
from public.questions where ref = '#A278'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A279', t.id, 'Yo‘l harakati qoidalari bo‘yicha «yonlama oraliq masofa»ni ko‘rsating:',
       array['Faqat «А»', 'Faqat «Б»', 'Faqat «В»', '«А» va «В»'], 3, 'q279.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Укажите расстояние, под которым в Правилах понимается «боковой интервал»:', array['Только «А»', 'Только «Б»', 'Только «В»', '«А» и «В»']
from public.questions where ref = '#A279'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A280', t.id, 'Ushbu ko‘rsatilgan vaziyatda sizga hovliga orqa bilan kirib qayrilib olishga ruxsat beriladimi?',
       array['Har qanday hollarda ruxsat beriladi', 'Ruxsat beriladi agarda bunda harakatning boshqa ishtirokchilariga halaqit berilmasa', 'Taqiqlanadi'], 1, 'q280.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешается ли Вам выполнить разворот с заездом во двор задним ходом?', array['Разрешается', 'Разрешается, если при этом не будут созданы помехи другим участникам движения', 'Запрещается']
from public.questions where ref = '#A280'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A281', t.id, 'Haydovchi chapga burilishda qaysi yo‘nalish bo‘yicha qoidani buzmoqda?',
       array['Faqat «A» yo‘nalishi bo‘yicha', 'Faqat «B» yo‘nalishi bo‘yicha', 'Ko‘rsatilgan barcha yo‘nalish bo‘yicha'], 2, 'q281.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'manyovr'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'По какой траектории водитель автомобиля нарушил правила при повороте налево:', array['Только по траектории А', 'Только по траектории Б', 'По любой траектории из указанных']
from public.questions where ref = '#A281'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A282', t.id, 'Ko‘rsatilgan belgilardan qaysi biri yo‘lning ko‘rinish masofasi cheklangan joylarda majburan to‘xtagan transport vositalarini belgilash uchun qo‘llaniladi?',
       array['«А»', '«Б»', '«В»'], 0, 'q282.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какой знак используется для обозначения транспортного средства при вынужденной остановке на местах, где с учетом условий видимости, оно не может быть своевременно замечено другими водителями?', array['«А»', '«Б»', '«В»']
from public.questions where ref = '#A282'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A283', t.id, 'Chorrahaga kirganingizda tartibga soluvchi qo‘lini yuqoriga ko‘tardi, sizga harakatlanishga ruxsat etiladimi?',
       array['Ruxsat etilmaydi', 'Ruxsat etiladi, agarda siz o‘ngga buriladigan bo‘lsangiz', 'Ruxsat etiladi'], null, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'svetofor'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Раз р е ш а етс я ли В а м п р од олж итьдвижение,если регулировщик поднял руку вверх после того, как Вы въехали на перекресток?', array['Не разрешается', 'Разрешается, только если Вы поворачиваете направо', 'Разрешается']
from public.questions where ref = '#A283'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A284', t.id, 'Ko‘rsatilgan qaysi belgilar sizga yashash manzilingizga avtomobilda o‘tishga ruxsat beradi?',
       array['Faqat «A»', 'Faqat «B»', 'Faqat «A» va «B»', 'Barchasi'], null, 'q284.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки разрешают Вам проезд на автомобиле к месту проживания?', array['Только «А»', 'Только «Б»', 'Только «А» и «B»', 'Все']
from public.questions where ref = '#A284'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A285', t.id, 'Qanday hollarda aholi punktlarida tovush moslamalaridan foydalanishga ruxsat etiladi?',
       array['Quvib o‘tishda ogohlantirish uchun', 'Yo‘l-transport hodisasining oldini olish uchun', 'Har ikkala sanab o‘tilgan hollarda'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'quvib-otish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких случаях разрешено применять звуковые сигналы в населённых пунктах?', array['Только для предупреждения о намерении произвести обгон', 'Только для предотвращения дорожно-транспортного происшествия', 'В обоих перечисленных случаях']
from public.questions where ref = '#A285'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A286', t.id, 'Yuk avtomobili haydovchisi to‘xtab turish qoidasini buzdimi?',
       array['Buzdi', 'Buzmadi, agar uning ruxsat etilgan to‘liq vazni 3,5 tonnadan oshmasa', 'Xato qilmadi'], null, 'q286.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A287', t.id, 'Ko‘rsatilganyo‘l belgilaridan qaysi biri faqat yo‘lqoplamasinam bo‘lganda ta‘sir etadi?',
       array['Faqat «A»', 'Faqat «A» va «Б»', 'Barchasi'], null, 'q287.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие знаки распространяют свое действиетольконапериод времени, когда покрытие проезжей части влажное?', array['Только «А»', 'Только «А» и «Б»', 'Все']
from public.questions where ref = '#A287'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A288', t.id, 'Yo‘lning sirpanchiq qismida rul chambaragini keskin burganda hosil bo‘ladigan sirpanishning oldini olish uchun haydovchi qanday ehtiyot choralarini ko‘rishi kerak?',
       array['Rul chambaragini zudlik bilan sirpanayotgan tomonga burish va tezda avtomobilni harakat yo‘nalishini to‘g‘irlab olish', 'Ilashmani uzish', 'Tormoz tepkisini bosish'], null, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что следует предпринять водителю для предотвращения опасных последствий заноса автомобиля при резком повороте рулевого колеса на скользкой дороге?', array['Быстро, но плавно повернуть рулевое колесо в сторону заноса, затем опережающим воздействием на рулевое колесо выровнять траекторию движения автомобиля.', 'Выключить сцепление', 'Нажать на педаль тормоза']
from public.questions where ref = '#A288'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A289', t.id, 'Sanabo‘tilganqaysiholatdatransportvositasidan foydalanishga ruxsat etiladi?',
       array['Tashqi yoritgich asboblari ifloslangan bo‘lsa', 'Yorituvchi chiroq nurining yo‘nalishi buzilgan bo‘lsa', 'Old qismida - oq yoki sariq rangli tumanga qarshi faralar o‘rnatilgan bo‘lsa'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каком случае разрешается эксплуатация транспортного средства?', array['Загрязнены внешние световые приборы', 'Нарушена регулировка фар', 'Спереди - установлены б е л ы е и л и желтые противотуманные фары']
from public.questions where ref = '#A289'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A290', t.id, 'Transport vositalari qattiq ulagichda shatakka olinganda shatakka olgan va shatakka olingan transport vositalari orasidagi masofa qancha bo‘lishi kerak?',
       array['4 metrdan oshmasligi', '4 metrdan 6 metrgacha', 'Qoidalarda belgilanmagan'], 0, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какое расстояние должно быть обеспечено между буксирующим и буксируемым транспортными средствами при буксировке на жесткой сцепке?', array['Не более 4 м', 'От 4 до 6 м', 'Правилами не регламентируется']
from public.questions where ref = '#A290'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A291', t.id, 'Turar joy dahalarida qanday harakatlar taqiqlangan?',
       array['Faqat o‘quv mashg‘ulotlarini bajarish', 'Faqat dvigatel ishlab turganda to‘xtab turish', 'Barcha sanab o‘tilgan hollarda'], 2, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие действия запрещены в жилой зоне?', array['Только учебная езда', 'Только стоянка с работающим двигателем', 'Все вышеперечисленные действия']
from public.questions where ref = '#A291'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A292', t.id, 'Qaysi haydovchi to‘xtab turish qoidasini buzdi?',
       array['Mototsikl haydovchisi', 'Trotuarda to‘ xtab turgan avtomobil haydovchisi', 'Hech kim buzmadi'], null, 'q292.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Кто из водителей нарушил правила стоянки?', array['Только водитель мотоцикла', 'Только водитель автомобиля стоящий на тротуаре', 'Никто не нарушил']
from public.questions where ref = '#A292'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A293', t.id, 'Yo‘lda «TO‘XTASh», yozuvi ko‘rinishidagi yo‘l chizig‘i nimani bildiradi?',
       array['Tartibga solingan chorrahada to‘xtash chizig‘iga yaqinlashayotganligi xaqida ogohlantiradi', 'To‘xtash chizig‘i va «To‘xtamasdan harakatlanish taqiqlanadi» yo‘l belgisi o‘rnatilgan yo‘l qismiga yaqinlashayotganligini bildiradi', '«Yo‘l bering» yo‘l belgisiga yaqinlashayotganligini bildiradi'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Что означает разметка в виде надписи «СТОП» на проезжей части?', array['Предупреждает о приближении к стоп-линии перед регулируемым перекрестком', 'Предупреждает о приближении к стоп-линии и знаку «Движение без остановки запрещено»', 'Предупреждает о приближении к знаку «Уступите дорогу»']
from public.questions where ref = '#A293'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A294', t.id, 'Ushbu yo‘l nechta harakatlanish bo‘lagiga ega?',
       array['Bitta harakatlanish bo‘lagiga', 'Ikkita harakatlanish bo‘lagiga', 'Uchta harakatlanish bo‘lagiga'], 1, 'q294.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Сколько полос движений имеет данная дорога?', array['Одну полосу для движения', 'Две полосы для движения', 'Три полосы для движения']
from public.questions where ref = '#A294'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A295', t.id, 'Ushbu belgilardan qaysi biri bir tomonlama xarakat tashkil qilingan yo‘lning boshida o‘pnatiladi?',
       array['Faqat «A»', 'Faqat «Б»', '«Б» va «Г»', '«Б» yoki «В»'], 1, 'q295.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Какие из этих знаков устанавливают в начале дороги с односторонним движением?', array['Только «А»', 'Только «Б»', '«Б» и «Г»', '«Б» или «В»']
from public.questions where ref = '#A295'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A296', t.id, 'Sanab o‘tilgan qaysi hollarda egiluvchan ulagichda shatakka olish taqiqlanadi?',
       array['Faqat tog‘li yo‘llarda', 'Yo‘l yaxmalak, sirpanchiq bo‘lgan hollarda', 'Kunning qorong‘i vaqtida va yetarli ko‘rinmaslik sharoitida', 'Barcha sanab o‘tilgan hollarda'], 1, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'shatak-yuk'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких из перечисленных случаев запрещена буксировка на гибкой сцепке?', array['Только на горных дорогах', 'Только в гололедицу', 'Только в темное время суток и в условиях недостаточной видимости', 'Во всех перечисленных случаях']
from public.questions where ref = '#A296'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A297', t.id, 'Ushbuko‘rsatilganholatda mototsikl haydovchisi sizga yo‘l berishi kerakmi?',
       array['Yo‘q', 'Ha'], 1, 'q297.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Обязан ли мотоциклист уступить Вам дорогу в данной ситуации?', array['Нет', 'Да']
from public.questions where ref = '#A297'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A298', t.id, 'Qaysi hollarda yo‘lning harakatlanish bo‘lagini ajratuvchi uzuq-uzuq chiziqni bosib o‘tish mumkin?',
       array['Faqat qayta tizilishda', 'Yo‘lda boshqa transport vositalari bo‘lmasa', 'Barcha sanab o‘tilgan hollarda'], null, null, 'draft', 'docx-geometry'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'В каких случаях Вы можете наезжать на прерывистые линии разметки, разделяющие проезжую часть на полосы движения?', array['Только при перестроении', 'Только если на дороге нет других транспортных средств', 'Во всех перечисленных случаях']
from public.questions where ref = '#A298'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A299', t.id, 'Siz chorrahadan chapga burilmoqchisiz. Ushbu vaziyatda kimga yo‘l berasiz?',
       array['Faqat avtobusga', 'Faqat qizil avtomobilga', 'Hech kimga'], null, 'q299.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Вы намерены повернуть налево. Кому следует уступить дорогу?', array['Только автобусу', 'Только легковому автомобилю', 'Никому']
from public.questions where ref = '#A299'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A300', t.id, 'Siz chorrahadan to‘g‘riga o‘tmoqchisiz. Ushbu vaziyatda Sizning harakatingiz?',
       array['Chorrahaga birinchi kirgan qizil avtomobilga yo‘l berish', 'Qizil avtomobil yo‘l berayotganiga ishonch xosil qilib chorrahadan birinchi o‘tish'], 1, 'q300.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Вы намерены проехать перекресток в прямом направлении. Ваши действия?', array['Уступите дорогу легковому автомобилю, поскольку он первым въехал на перекресток', 'Убедитесь, что легковой автомобиль уступает дорогу, и проедете перекресток первым']
from public.questions where ref = '#A300'
on conflict (question_id, lang) do nothing;

insert into public.questions (ref, topic_id, text, options, correct, image, state, key_source)
select '#A301', t.id, 'Ushbu joyda avtomobilni to‘xtab turish uchun qo‘yishga ruxsat etiladimi?',
       array['Ha', 'Yo‘q'], 1, 'q301.jpeg', 'draft', 'docx-geometry'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options)
select id, 'ru', 'Разрешено ли водителю ставить автомо-биль на стоянку в указанном месте?', array['Да', 'Нет']
from public.questions where ref = '#A301'
on conflict (question_id, lang) do nothing;

commit;
