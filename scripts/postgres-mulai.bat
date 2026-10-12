@echo off
rem Menyalakan PostgreSQL 16 (data bawaan) sebagai proses pengguna, tanpa layanan Windows.
rem Layanan Windows "postgresql-x64-16" tidak mau start di komputer ini; cara ini memakai data yang sama.
set "PGDATA=C:\Program Files\PostgreSQL\16\data"
set "PGBIN=C:\Program Files\PostgreSQL\16\bin"
"%PGBIN%\pg_isready.exe" -h 127.0.0.1 -p 5432 >nul 2>&1 && (echo PostgreSQL sudah berjalan. & exit /b 0)
echo Menyalakan PostgreSQL...
"%PGBIN%\pg_ctl.exe" start -D "%PGDATA%" -l "%TEMP%\murobi-postgres-start.log" -w -t 60
if errorlevel 1 (echo GAGAL. Lihat %TEMP%\murobi-postgres-start.log & exit /b 1)
echo PostgreSQL berjalan di port 5432.
