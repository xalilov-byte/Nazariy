#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────
#  Migratsiya va seed'ni bazaga qo'llash.
#
#  Ishlatilishi:
#      SUPABASE_DB_URL='postgresql://…' bash supabase/apply.sh
#
#  Bir xil skript ikki joyda ishlaydi:
#    · CI (.github/workflows/db-apply.yml) — haqiqiy Supabase bazasiga
#    · lokal PostgreSQL — tekshirish uchun
#  Shuning uchun CI'da birinchi marta sinalmaydi: xulqi allaqachon
#  ma'lum bo'ladi.
#
#  XAVFSIZLIK: skript FAQAT qo'shadi. Jadval o'chirish yoki ma'lumotni
#  tozalash yo'q. Migratsiya allaqachon qo'llangan bo'lsa — o'tkazib
#  yuboriladi, qaytadan urinilmaydi.
# ─────────────────────────────────────────────────────────────────────────
set -euo pipefail

if [ -z "${SUPABASE_DB_URL:-}" ]; then
  echo "XATO: SUPABASE_DB_URL o'rnatilmagan" >&2
  exit 1
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PSQL=(psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -X -q)

echo "── Ulanish tekshirilmoqda ──"
"${PSQL[@]}" -tAc "select 'server: '||current_setting('server_version');"

# ── Sxema allaqachon bormi? ──
# to_regclass jadval yo'q bo'lsa null qaytaradi — xato bermaydi.
HAS_SCHEMA=$("${PSQL[@]}" -tAc "select case when to_regclass('public.topics') is null then 'no' else 'yes' end;")

if [ "$HAS_SCHEMA" = "no" ]; then
  echo "── Migratsiya qo'llanmoqda: 0001_init.sql ──"
  "${PSQL[@]}" -f "$HERE/migrations/0001_init.sql"
  echo "   sxema yaratildi"
else
  echo "── Migratsiya allaqachon qo'llangan — o'tkazib yuborildi ──"
  echo "   (topics jadvali mavjud; sxemani o'zgartirish uchun yangi"
  echo "    migratsiya fayli yoziladi, eskisi qayta ishga tushirilmaydi)"
fi

# Seed idempotent: "on conflict" bilan yozilgan, shuning uchun har doim
# xavfsiz ishga tushadi va mavjud savollarni takrorlamaydi.
echo "── Seed qo'llanmoqda: 0002_questions.sql ──"
"${PSQL[@]}" -f "$HERE/seed/0002_questions.sql"

echo "── Natija ──"
"${PSQL[@]}" -tAc "
  select '  mavzular:        '||count(*) from public.topics
  union all select '  savollar:        '||count(*) from public.questions
  union all select '  tarjimalar:      '||count(*) from public.question_translations
  union all select '  nashr etilgan:   '||count(*) from public.published_questions
  union all select '  audit yozuvlari: '||count(*) from public.audit_log;"

# ── RLS yoqilganini tasdiqlash ──
# Eng muhim tekshiruv: RLS o'chib qolgan jadval bo'lsa, publishable
# kalit bilan hamma narsa ochiq bo'lib qoladi.
echo "── RLS holati ──"
UNPROTECTED=$("${PSQL[@]}" -tAc "
  select coalesce(string_agg(tablename, ', '), '')
  from pg_tables
  where schemaname = 'public' and not rowsecurity;")

if [ -n "$UNPROTECTED" ]; then
  echo "XATO: RLS yoqilmagan jadval(lar): $UNPROTECTED" >&2
  exit 1
fi
echo "  public sxemasidagi barcha jadvalda RLS yoqilgan"

echo
echo "✅ Qo'llash tugadi"
