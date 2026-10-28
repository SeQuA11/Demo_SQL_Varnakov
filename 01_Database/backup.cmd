@echo off
rem Резервная копия БД booking_41_varnakov в файл booking_41_varnakov_backup.sql рядом со скриптом.
rem Восстановление: psql -h localhost -U postgres -d booking_41_varnakov -f booking_41_varnakov_backup.sql
cd /d "%~dp0"
"C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -h localhost -U postgres -d booking_41_varnakov --no-owner -F p -f booking_41_varnakov_backup.sql
