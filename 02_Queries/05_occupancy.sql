-- =====================================================================
--  Процент загрузки номерного фонда — отношение количества проданных
--  ночей к общему количеству номеров в отеле.
--  БД booking_41_varnakov, PostgreSQL 18
--
--  Ночь с d на d+1 продана, если гость заехал не позже d и выезжает
--  позже d (или дата выезда не известна). Брони без заезда не считаются.
-- =====================================================================

-- 1. Загрузка на дату
WITH params AS (SELECT DATE '2025-03-01' AS d)
SELECT p.d                                      AS "На дату",
       count(DISTINCT st.room_id)               AS "Продано ночей",
       (SELECT count(*) FROM room)              AS "Всего номеров",
       round(100.0 * count(DISTINCT st.room_id) / (SELECT count(*) FROM room), 1) AS "Загрузка, %"
FROM params p
LEFT JOIN stay st ON st.is_checked_in
                 AND st.check_in <= p.d
                 AND (st.check_out IS NULL OR st.check_out > p.d)
GROUP BY p.d;

-- 2. Загрузка за период: проданные ночи / (номеров × дней в периоде)
WITH params AS (SELECT DATE '2025-02-01' AS d_from, DATE '2025-02-28' AS d_to),
sold AS (
    SELECT coalesce(sum(greatest(0,
               least(coalesce(st.check_out, p.d_to + 1), p.d_to + 1)
               - greatest(st.check_in, p.d_from))), 0) AS nights
    FROM params p
    JOIN stay st ON st.is_checked_in
)
SELECT p.d_from                                    AS "С",
       p.d_to                                      AS "По",
       s.nights                                    AS "Продано ночей",
       (SELECT count(*) FROM room) * (p.d_to - p.d_from + 1) AS "Номеро-ночей всего",
       round(100.0 * s.nights / ((SELECT count(*) FROM room) * (p.d_to - p.d_from + 1)), 1) AS "Загрузка, %"
FROM params p, sold s;
