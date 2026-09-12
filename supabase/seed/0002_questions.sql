-- ═══════════════════════════════════════════════════════════════════════
--  NAZARIY — 0002: boshlang'ich savollar (10 ta) va mavzular
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
  ('umumiy-qoidalar', 'Umumiy qoidalar', 1),
  ('yol-belgilari', 'Yoʻl belgilari', 2),
  ('tezlik-rejimi', 'Tezlik rejimi', 3),
  ('chorrahalar', 'Chorrahalar', 4),
  ('svetofor', 'Svetofor', 5),
  ('quvib-otish', 'Quvib oʻtish', 6),
  ('toxtab-turish', 'Toʻxtab turish', 7),
  ('birinchi-yordam', 'Birinchi yordam', 8)
on conflict (slug) do update set name = excluded.name, sort_order = excluded.sort_order;

-- ── Savollar ───────────────────────────────────────────────────────────

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#001', t.id, '«Yoʻl harakati xavfsizligi» nuqtai nazaridan haydovchi harakatni boshlashdan oldin nima qilishi shart?',
       array['Faqat ovoz signalini berish', 'Manyovr niyatini yoʻnalish koʻrsatkichi bilan bildirish va boshqa harakat qatnashchilariga xalaqit bermaslik', 'Faqat orqa koʻrinish koʻzgusiga qarash', 'Hech qanday cheklov yoʻq'], 1, 'YHQ 8-bandi: manyovr boshlashdan oldin yoʻnalish koʻrsatkichi bilan signal berilishi va manyovr xavfsiz boʻlishi shart.',
       null, 'published'
from public.topics t where t.slug = 'umumiy-qoidalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'Что обязан сделать водитель перед началом движения с точки зрения безопасности дорожного движения?', array['Только подать звуковой сигнал', 'Подать сигнал указателем поворота о намерении совершить манёвр и не создавать помех другим участникам движения', 'Только посмотреть в зеркало заднего вида', 'Никаких ограничений нет'], 'Пункт 8 ПДД: перед началом манёвра необходимо подать сигнал указателем поворота, и манёвр должен быть безопасным.'
from public.questions where ref = '#001'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#002', t.id, 'Rasmda koʻrsatilgan belgi nimani anglatadi?',
       array['Yoʻl berish', 'Bosh yoʻl', 'Toʻxtamasdan harakatlanish taqiqlanadi', 'Tor yoʻldan oʻtish'], 1, '«Bosh yoʻl» (2.1) — belgi qoʻyilgan yoʻl tartibga solinmagan chorrahalarda imtiyozli yoʻl hisoblanadi.',
       'priority', 'published'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'Что обозначает знак, показанный на рисунке?', array['Уступите дорогу', 'Главная дорога', 'Движение без остановки запрещено', 'Проезд по узкой дороге'], '«Главная дорога» (2.1) — дорога со этим знаком считается приоритетной на нерегулируемых перекрёстках.'
from public.questions where ref = '#002'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#003', t.id, 'Aholi punktlarida yengil avtomobil uchun ruxsat etilgan eng katta tezlik qancha?',
       array['60 km/soat', '70 km/soat', '80 km/soat', '90 km/soat'], 0, 'Aholi punktlarida umumiy chegara — 70 km/soat emas, 60 km/soat (agar belgi bilan boshqacha koʻrsatilmagan boʻlsa).',
       null, 'published'
from public.topics t where t.slug = 'tezlik-rejimi'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'Какая максимальная разрешённая скорость для легкового автомобиля в населённых пунктах?', array['60 км/ч', '70 км/ч', '80 км/ч', '90 км/ч'], 'Общее ограничение в населённых пунктах — не 70 км/ч, а 60 км/ч (если знаком не установлено иное).'
from public.questions where ref = '#003'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#004', t.id, 'Bu belgi qoʻyilgan yoʻl uchastkasiga qaysi transport kirishi mumkin?',
       array['Yoʻnalishli transport vositalari', 'Barcha transport vositalari', 'Faqat yengil avtomobillar', 'Hech qaysi transport vositasi'], 0, '«Kirish taqiqlangan» (3.1) belgisi yoʻnalishli transport vositalariga taalluqli emas.',
       'noentry', 'published'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'Какому транспорту разрешён въезд на участок дороги с этим знаком?', array['Маршрутным транспортным средствам', 'Всем транспортным средствам', 'Только легковым автомобилям', 'Никакому транспортному средству'], 'Знак «Въезд запрещён» (3.1) не распространяется на маршрутные транспортные средства.'
from public.questions where ref = '#004'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#005', t.id, 'Tartibga solinmagan teng ahamiyatli chorrahada haydovchi kimga yoʻl berishi shart?',
       array['Chapdan yaqinlashayotgan transportga', 'Oʻngdan yaqinlashayotgan transportga', 'Tezligi kattaroq transportga', 'Yuk avtomobiliga'], 1, 'Teng ahamiyatli chorrahada «oʻngdan halaqit» qoidasi ishlaydi — oʻngdan kelayotganga yoʻl beriladi.',
       null, 'published'
from public.topics t where t.slug = 'chorrahalar'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'Кому обязан уступить дорогу водитель на нерегулируемом равнозначном перекрёстке?', array['Транспорту, приближающемуся слева', 'Транспорту, приближающемуся справа', 'Транспорту с большей скоростью', 'Грузовому автомобилю'], 'На равнозначном перекрёстке действует правило «помеха справа» — уступают тому, кто приближается справа.'
from public.questions where ref = '#005'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#006', t.id, 'Svetoforning sariq miltillovchi signali nimani bildiradi?',
       array['Harakat taqiqlangan', 'Chorraha tartibga solinmagan, ehtiyot boʻlib oʻtish mumkin', 'Toʻxtash majburiy', 'Faqat oʻngga burilish mumkin'], 1, 'Sariq miltillovchi signal chorrahaning tartibga solinmaganini bildiradi; oʻtishda belgilar va yoʻl berish qoidalariga amal qilinadi.',
       null, 'published'
from public.topics t where t.slug = 'svetofor'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'Что означает жёлтый мигающий сигнал светофора?', array['Движение запрещено', 'Перекрёсток нерегулируемый, проезд разрешён с осторожностью', 'Остановка обязательна', 'Разрешён только поворот направо'], 'Жёлтый мигающий сигнал означает, что перекрёсток нерегулируемый; при проезде руководствуются знаками и правилами приоритета.'
from public.questions where ref = '#006'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#007', t.id, 'Uchburchak shaklidagi qizil hoshiyali belgilar qaysi guruhga kiradi?',
       array['Taqiqlovchi', 'Buyuruvchi', 'Ogohlantiruvchi', 'Axborot-ishorat'], 2, 'Qizil hoshiyali teng yonli uchburchak — ogohlantiruvchi belgilar guruhi (1-guruh).',
       'warning', 'published'
from public.topics t where t.slug = 'yol-belgilari'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'К какой группе относятся знаки треугольной формы с красной каймой?', array['Запрещающие', 'Предписывающие', 'Предупреждающие', 'Информационно-указательные'], 'Равнобедренный треугольник с красной каймой — группа предупреждающих знаков (1-я группа).'
from public.questions where ref = '#007'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#008', t.id, 'Quvib oʻtish qaysi holatda taqiqlanadi?',
       array['Yoʻl kengligi 7 metrdan ortiq boʻlsa', 'Tartibga solinmagan piyodalar oʻtish joyida', 'Aholi punkti tashqarisida', 'Ikki qatorli yoʻlda'], 1, 'Piyodalar oʻtish joylarida quvib oʻtish taqiqlanadi — piyoda koʻrinmay qolishi xavfi bor.',
       null, 'published'
from public.topics t where t.slug = 'quvib-otish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'В каком случае обгон запрещён?', array['Если ширина дороги более 7 метров', 'На нерегулируемом пешеходном переходе', 'Вне населённого пункта', 'На дороге с двумя полосами'], 'На пешеходных переходах обгон запрещён — есть риск не увидеть пешехода.'
from public.questions where ref = '#008'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#009', t.id, 'Temir yoʻl kesishmasidan qancha masofada toʻxtash taqiqlanadi?',
       array['10 m', '30 m', '50 m', '100 m'], 2, 'Temir yoʻl kesishmalarida va ularga 50 metrdan yaqin masofada toʻxtash taqiqlanadi.',
       null, 'published'
from public.topics t where t.slug = 'toxtab-turish'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'На каком расстоянии от железнодорожного переезда запрещена остановка?', array['10 м', '30 м', '50 м', '100 м'], 'Остановка запрещена на железнодорожных переездах и ближе 50 метров от них.'
from public.questions where ref = '#009'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

insert into public.questions (ref, topic_id, text, options, correct, explain, sign, state)
select '#010', t.id, 'Arterial qon ketishida birinchi navbatda nima qilinadi?',
       array['Jarohatga sovuq qoʻyiladi', 'Jarohat ustidan bogʻlov qoʻyiladi', 'Jarohatdan yuqoriga qon toʻxtatuvchi jgut qoʻyiladi', 'Jabrlanuvchiga suv beriladi'], 2, 'Arterial qon ketishida jgut jarohatdan yuqoriga qoʻyiladi va qoʻyilgan vaqti yozib qoldiriladi.',
       null, 'published'
from public.topics t where t.slug = 'birinchi-yordam'
on conflict (ref) do nothing;
insert into public.question_translations (question_id, lang, text, options, explain)
select id, 'ru', 'Что делают в первую очередь при артериальном кровотечении?', array['К ране прикладывают холод', 'На рану накладывают повязку', 'Выше раны накладывают кровоостанавливающий жгут', 'Пострадавшему дают воду'], 'При артериальном кровотечении жгут накладывают выше раны и записывают время наложения.'
from public.questions where ref = '#010'
on conflict (question_id, lang) do update
  set text = excluded.text, options = excluded.options,
      explain = excluded.explain, updated_at = now();

commit;

-- ── Nazorat ────────────────────────────────────────────────────────────
-- Ishga tushirgandan keyin shuni bajarib tekshiring:
--   select count(*) from public.topics;                        -- 8
--   select count(*) from public.questions;                     -- 10
--   select count(*) from public.question_translations;          -- rus tarjimasi soni
--   select count(*) from public.published_questions;            -- 10
