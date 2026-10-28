-- =====================================================================
--  Импорт данных заказчика в booking_41_varnakov
--  CSV-файлы (UTF-8) лежат в папке import\ рядом со скриптом.
--  Запуск из папки со скриптом:
--      psql -h localhost -U postgres -d booking_41_varnakov -f 02_import.sql
-- =====================================================================

\set ON_ERROR_STOP on
BEGIN;

TRUNCATE cleaning_task, payment, stay, guest, room_status_log, room_status, room, room_category,
         bed_type, comfort_class, floor RESTART IDENTITY CASCADE;

-- Порядок: сначала справочники, затем зависимые таблицы
\copy floor           FROM 'import/floor.csv'           WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy comfort_class   FROM 'import/comfort_class.csv'   WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy bed_type        FROM 'import/bed_type.csv'        WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy room_category   FROM 'import/room_category.csv'   WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy room            FROM 'import/room.csv'            WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy room_status     FROM 'import/room_status.csv'     WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy room_status_log FROM 'import/room_status_log.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy guest           FROM 'import/guest.csv'           WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy stay (id, room_id, guest_id, check_in, check_out) FROM 'import/stay.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')

-- id загружены явно — сдвигаем счётчики, чтобы новые записи получали следующий номер
SELECT setval(pg_get_serial_sequence('floor',           'id'), (SELECT max(id) FROM floor));
SELECT setval(pg_get_serial_sequence('comfort_class',   'id'), (SELECT max(id) FROM comfort_class));
SELECT setval(pg_get_serial_sequence('bed_type',        'id'), (SELECT max(id) FROM bed_type));
SELECT setval(pg_get_serial_sequence('room_category',   'id'), (SELECT max(id) FROM room_category));
SELECT setval(pg_get_serial_sequence('room',            'id'), (SELECT max(id) FROM room));
SELECT setval(pg_get_serial_sequence('room_status',     'id'), (SELECT max(id) FROM room_status));
SELECT setval(pg_get_serial_sequence('room_status_log', 'id'), (SELECT max(id) FROM room_status_log));
SELECT setval(pg_get_serial_sequence('guest',           'id'), (SELECT max(id) FROM guest));
SELECT setval(pg_get_serial_sequence('stay',            'id'), (SELECT max(id) FROM stay));

COMMIT;
