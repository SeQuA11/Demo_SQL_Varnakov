# Demo_SQL_Varnakov

Модуль 3 — база данных гостиницы `booking_41_varnakov` на PostgreSQL 18. Схема совпадает с ER-диаграммой из Demo_DB_Varnakov.

| Папка | Содержимое |
|---|---|
| `01_Database` | Создание БД (`01_schema.sql`), импорт данных заказчика (`02_import.sql` + `import/*.csv`), подготовленные данные в Excel, резервная копия (`booking_41_varnakov_backup.sql`, `backup.cmd`), отчёт |
| `02_Queries` | Запросы: свободные номера, «Стандарт», количество номеров, «Бизнес» с 1 кроватью, клиенты за февраль 2025 (`03_queries.sql`); процент загрузки номерного фонда (`05_occupancy.sql`); отчёт со скриншотами |
| `03_CustomerReports` | Данные, требуемые заказчику, и контрольные запросы (`04_customer_reports.sql`), формулировки |

## Развёртывание

```
psql -h localhost -U postgres -c "CREATE DATABASE booking_41_varnakov ENCODING 'UTF8'"
cd 01_Database
psql -h localhost -U postgres -d booking_41_varnakov -f 01_schema.sql
psql -h localhost -U postgres -d booking_41_varnakov -f 02_import.sql
```

Или восстановить из резервной копии:

```
psql -h localhost -U postgres -d booking_41_varnakov -f 01_Database/booking_41_varnakov_backup.sql
```
