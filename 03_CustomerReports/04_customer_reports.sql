-- =====================================================================
--  Данные, которые требует заказчик (по его документам)
--  БД booking_41_varnakov, PostgreSQL 18.1, localhost:5432
--  Варнаков Степан Максимович, группа 4-1 ИС
--
--  Дата, на которую строятся отчёты, задаётся в CTE params.
--  В документах заказчика это 01.03.2025; в работающей ИС — CURRENT_DATE.
-- =====================================================================

-- 1. Номерной фонд
--    Этаж, номер и категория каждого номера гостиницы.
SELECT f.number || ' этаж' AS "Этаж",
       r.number            AS "Номер",
       c.name              AS "Категория"
FROM room r
JOIN floor f         ON f.id = r.floor_id
JOIN room_category c ON c.id = r.category_id
ORDER BY f.number, r.number;

-- 2. Отчет по состоянию номерного фонда на дату
--    Для каждого номера: статус на дату и дата выезда текущего постояльца.
WITH params AS (SELECT DATE '2025-03-01' AS d)
SELECT f.number || ' этаж' AS "Этаж",
       r.number            AS "Номер",
       c.name              AS "Категория",
       s.name              AS "Статус",
       to_char((SELECT min(st.check_out)
                FROM stay st
                WHERE st.room_id = r.id
                  AND st.check_in <= p.d
                  AND (st.check_out IS NULL OR st.check_out >= p.d)),
               'DD.MM.YYYY') AS "Дата выезда"
FROM params p
CROSS JOIN room r
JOIN floor f         ON f.id = r.floor_id
JOIN room_category c ON c.id = r.category_id
LEFT JOIN LATERAL (SELECT l.status_id
                   FROM room_status_log l
                   WHERE l.room_id = r.id AND l.status_date <= p.d
                   ORDER BY l.status_date DESC
                   LIMIT 1) ls ON true
LEFT JOIN room_status s ON s.id = ls.status_id
ORDER BY f.number, r.number;

-- 3. Постояльцы, живущие сейчас в гостинице
--    Гости, у которых на дату въезд уже был, а выезд ещё не наступил.
WITH params AS (SELECT DATE '2025-03-01' AS d)
SELECT f.number || ' этаж' AS "Этаж",
       r.number            AS "Номер",
       c.name              AS "Категория",
       concat_ws(' ', g.last_name, g.first_name, g.patronymic) AS "Клиент",
       to_char(st.check_in,  'DD.MM.YYYY') AS "Въезд",
       to_char(st.check_out, 'DD.MM.YYYY') AS "Выезд"
FROM params p
JOIN stay st ON st.check_in <= p.d
            AND (st.check_out IS NULL OR st.check_out >= p.d)
JOIN guest g         ON g.id = st.guest_id
JOIN room r          ON r.id = st.room_id
JOIN floor f         ON f.id = r.floor_id
JOIN room_category c ON c.id = r.category_id
ORDER BY f.number, r.number, g.last_name;

-- 4. Проверка: статус номера не совпадает с заселениями на дату
--    «Занят» без постояльца или постоялец в номере без статуса «Занят».
WITH params AS (SELECT DATE '2025-03-01' AS d),
state AS (
    SELECT r.id, r.number, s.name AS status,
           EXISTS (SELECT 1 FROM stay st
                   WHERE st.room_id = r.id
                     AND st.check_in <= p.d
                     AND (st.check_out IS NULL OR st.check_out >= p.d)) AS has_guest
    FROM params p
    CROSS JOIN room r
    LEFT JOIN LATERAL (SELECT l.status_id
                       FROM room_status_log l
                       WHERE l.room_id = r.id AND l.status_date <= p.d
                       ORDER BY l.status_date DESC
                       LIMIT 1) ls ON true
    LEFT JOIN room_status s ON s.id = ls.status_id
)
SELECT number AS "Номер", status AS "Статус",
       CASE WHEN has_guest THEN 'есть' ELSE 'нет' END AS "Постоялец на дату"
FROM state
WHERE (status = 'Занят') <> has_guest
ORDER BY number;

-- 5. Проверка: заселения без известной даты выезда
SELECT r.number AS "Номер",
       concat_ws(' ', g.last_name, g.first_name, g.patronymic) AS "Клиент",
       to_char(st.check_in, 'DD.MM.YYYY') AS "Въезд"
FROM stay st
JOIN guest g ON g.id = st.guest_id
JOIN room r  ON r.id = st.room_id
WHERE st.check_out IS NULL
ORDER BY r.number;
