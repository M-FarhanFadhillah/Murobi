@echo off
rem Menghentikan PostgreSQL 16 yang dinyalakan oleh postgres-mulai.bat (aman: mode fast).
set "PGDATA=C:\Program Files\PostgreSQL\16\data"
"C:\Program Files\PostgreSQL\16\bin\pg_ctl.exe" stop -D "%PGDATA%" -m fast -t 60
