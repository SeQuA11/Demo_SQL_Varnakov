-- =====================================================================
--  Запросы к БД booking_41_varnakov (PostgreSQL 18, localhost:5432)
--  Варнаков Степан Максимович, группа 4-1 ИС
--
--  Свободный номер — номер, у которого последний статус в журнале
--  room_status_log не «Занят».
-- =====================================================================

-- 1. Вывод списка свободных номеров
SELECT r.number AS "Номер", f.number AS "Этаж",
       c.name AS "Категория", s.name AS "Статус"
FROM room r
JOIN floor f ON f.id = r.floor_id
JOIN room_category c ON c.id = r.category_id
JOIN room_status_log l ON l.room_id = r.id
 AND l.status_date = (SELECT max(status_date)
                      FROM room_status_log WHERE room_id = r.id)
JOIN room_status s ON s.id = l.status_id
WHERE s.name <> 'Занят'
ORDER BY r.number;

-- 2. Вывод списка свободных номеров категории «Стандарт»
SELECT r.number AS "Номер", f.number AS "Этаж",
       c.name AS "Категория", s.name AS "Статус"
FROM room r
JOIN floor f ON f.id = r.floor_id
JOIN room_category c ON c.id = r.category_id
JOIN comfort_class cc ON cc.id = c.comfort_class_id
JOIN room_status_log l ON l.room_id = r.id
 AND l.status_date = (SELECT max(status_date)
                      FROM room_status_log WHERE room_id = r.id)
JOIN room_status s ON s.id = l.status_id
WHERE s.name <> 'Занят'
  AND cc.name = 'Стандарт'
ORDER BY r.number;

-- 3. Вывод количества всех номеров
SELECT count(*) AS "Всего номеров"
FROM room;

-- 4. Вывод количества свободных номеров категории «Бизнес» с 1 кроватью
SELECT count(*) AS "Свободных «Бизнес» с 1 кроватью"
FROM room r
JOIN room_category c ON c.id = r.category_id
JOIN comfort_class cc ON cc.id = c.comfort_class_id
JOIN bed_type b ON b.id = c.bed_type_id
JOIN room_status_log l ON l.room_id = r.id
 AND l.status_date = (SELECT max(status_date)
                      FROM room_status_log WHERE room_id = r.id)
JOIN room_status s ON s.id = l.status_id
WHERE s.name <> 'Занят'
  AND cc.name = 'Бизнес'
  AND 1 BETWEEN b.beds_min AND b.beds_max;

-- 5. Вывод списка клиентов, проживающих в период февраля 2025 года
--    (заселение пересекается с 01.02.2025–28.02.2025)
SELECT g.last_name AS "Фамилия", g.first_name AS "Имя",
       g.patronymic AS "Отчество", r.number AS "Номер",
       st.check_in AS "Въезд", st.check_out AS "Выезд"
FROM stay st
JOIN guest g ON g.id = st.guest_id
JOIN room r ON r.id = st.room_id
WHERE st.check_in < DATE '2025-03-01'
  AND (st.check_out IS NULL OR st.check_out >= DATE '2025-02-01')
ORDER BY g.last_name, g.first_name;
