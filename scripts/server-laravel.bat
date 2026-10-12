@echo off
rem Menjalankan API Laravel (Master-Admin) di http://127.0.0.1:8000 untuk aplikasi (mode server).
rem  - php -S (satu utas) di port 8001 memakai PostgreSQL dari .env
rem  - proxy berutas banyak di port 8000 di depannya (php -S saja sering mereset koneksi paralel browser)
rem Jalankan scripts\postgres-mulai.bat lebih dulu. Tutup jendela ini untuk berhenti.
set "APP=%~dp0..\Master-Admin"
rem Tambahkan folder PHP XAMPP hanya untuk proses ini (tidak mengubah PATH sistem).
set "PATH=C:\xampp\php;%PATH%"
start "Laravel (port 8001)" /min php -d extension=pdo_pgsql -d extension=pgsql -S 127.0.0.1:8001 -t "%APP%\public" "%APP%\public\index.php"
echo Proxy berjalan di http://127.0.0.1:8000 (Ctrl+C untuk berhenti).
python "%~dp0proxy_berutas.py" 8000 8001
