# Murobi terhadap PostgreSQL asli

**Status: sudah dijalankan dan terbukti pada 12 Oktober 2026** di komputer pengembangan
ini (PostgreSQL 16, PHP 8.2 XAMPP, Laravel 9). Dokumen ini merangkum hasilnya, temuan
yang harus diketahui, dan cara menjalankannya lagi.

## 1. Apa yang dibuktikan

Terhadap basis data PostgreSQL asli milik proyek ini (3 akun, 2 masjid, 6 kegiatan,
2 materi, 4 banner):

| Pemeriksaan | Hasil |
| --- | --- |
| Koneksi Laravel → PostgreSQL, skema 15 migrasi lama sudah ada | Berhasil |
| Migrasi baru `reports` (hanya tabel itu ditambahkan) | Berhasil |
| Data publik: `/api/masjid`, `/banner`, `/activity`, `/edu/book`, `/edu/video` | 200, jumlah sesuai isi basis data |
| Masuk dengan email + kata sandi (akun hash bcrypt), kata sandi salah → 401 | Sesuai |
| `GET /api/me`, keluar (token dicabut) | Sesuai |
| Laporan masalah: jamaah kirim, admin lihat/tandai selesai, jamaah dilarang melihat semua (403) | Sesuai |
| Admin menambah kegiatan dengan gambar, muncul di daftar publik, gambar dilayani **byte-per-byte sama**, lalu dihapus (berkas ikut terhapus) | Sesuai |
| Login Google dengan akun Google sungguhan lewat aplikasi → server memeriksa token ke Google → akun jamaah dibuat → Beranda tampil dengan data masjid dari PostgreSQL | Berhasil |
| Token Google palsu → 401 (bukan 503), artinya server benar-benar menghubungi Google | Sesuai |
| Semua data uji dihapus; jumlah baris kembali persis seperti semula | Terverifikasi |

**Belum terbukti:** login dengan akun *asli* yang sudah ada (kata sandi teks polos) karena
kata sandinya tidak diketahui; perilakunya sudah diuji otomatis (SQLite) dan tidak
dijalankan terhadap data asli. Berkas video (mp4), HTTPS/rilis, dan perangkat fisik juga belum.

## 2. Temuan penting

| ID | Temuan | Penanganan |
| --- | --- | --- |
| P-1 | **Sequence id tertinggal.** Data hasil restore cadangan memakai id eksplisit tanpa menaikkan sequence, sehingga *menambah* data gagal: `duplicate key value violates unique constraint "activities_pkey"`. 10 dari 16 tabel terdampak (juga panel web). Tidak terlihat di SQLite. | Perintah baru `php artisan db:fix-sequences` (`--dry-run` hanya melaporkan). Sudah dijalankan; sekarang semua tabel `ok`. **Jalankan lagi setiap habis restore cadangan.** |
| P-2 | **`libpq.dll` hilang dari `C:\Program Files\PostgreSQL\16\bin`.** `pg_dump`, `psql`, `pg_ctl` memuat `libpq.dll` milik XAMPP dari PATH sistem (versi tidak cocok) dan gagal dengan kode `0xC0000138`. | `libpq.dll` asli PostgreSQL 16 (sudah ada di folder `lib`) disalin ke `bin`. Sekarang semua alat berjalan tanpa trik PATH. |
| P-3 | **Layanan Windows `postgresql-x64-16` tidak mau start** (error 1053), baik sebelum maupun sesudah P-2 diperbaiki, dan tanpa catatan di log PostgreSQL maupun Event Log. | Tidak mengubah akun layanan sistem. Disediakan `scripts\postgres-mulai.bat` yang menyalakan PostgreSQL yang sama (data yang sama) sebagai proses pengguna. Setelah komputer dimulai ulang, jalankan skrip itu lagi. |
| P-4 | `APP_DEBUG=true` di `.env`: respons error API memuat jejak tumpukan lengkap (jalur berkas). | Belum diubah (berkas `.env` milik Anda). Untuk server sungguhan isi `APP_DEBUG=false`. |
| P-5 | `php -S` (server bawaan PHP) satu utas mereset koneksi paralel browser dan respons besar di komputer ini. | `scripts\server-laravel.bat` memasang proxy berutas banyak di depannya. Untuk demo yang sungguh-sungguh pakai Apache XAMPP. |
| P-6 | Cadangan penuh dibuat sebelum perubahan apa pun. | `D:\Tugas Kuliah\Enlight\cadangan-postgres-sebelum-uji-2026-10-12.sql` (di luar repo karena memuat data akun). |

## 3. Menjalankan sehari-hari

```bat
rem 1) Nyalakan PostgreSQL (sekali setelah komputer menyala)
scripts\postgres-mulai.bat

rem 2) Nyalakan API Laravel di http://127.0.0.1:8000 (biarkan jendelanya terbuka)
scripts\server-laravel.bat

rem 3) Aplikasi: VS Code konfigurasi "3. Dengan server Laravel - Emulator MuMu" atau
rem    "4. Dengan server Laravel - Chrome" (sudah diatur di masjid\.vscode\launch.json)

rem Berhenti
scripts\postgres-berhenti.bat
```

`scripts\server-laravel.bat` memakai PHP XAMPP dengan argumen
`-d extension=pdo_pgsql -d extension=pgsql` hanya untuk proses itu; `php.ini` tidak diubah.
Bila `Master-Admin\.env` belum memakai `DB_CONNECTION=pgsql`, atur dulu (`DB_HOST`, `DB_PORT`,
`DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `FILESYSTEM_DISK=public`).

## 4. Setelah restore cadangan atau pindah komputer

```bash
# dari folder Master-Admin, dengan ekstensi pgsql aktif
php -d extension=pdo_pgsql -d extension=pgsql artisan migrate --path=database/migrations/2026_10_12_000001_create_reports_table.php
php -d extension=pdo_pgsql -d extension=pgsql artisan db:fix-sequences
```

Jangan menjalankan `php artisan migrate` polos pada basis data hasil restore (Laravel
dapat mencoba membuat ulang tabel lama). Pastikan juga ada akun admin:

```sql
select id, email, is_admin, status from users order by id;
update users set is_admin = true, status = 1 where email = '<email admin Anda>';
```

Kata sandi lama berupa teks polos tetap diterima dan **tidak diubah** oleh API (agar login
panel web tidak rusak). Kata sandi akun baru dari aplikasi disimpan sebagai hash bcrypt.

## 5. Uji cepat dengan curl

```bash
curl http://127.0.0.1:8000/api/masjid
curl -X POST http://127.0.0.1:8000/api/login -H "Accept: application/json" \
  -H "Content-Type: application/json" -d '{"login":"<email>","password":"<kata sandi>"}'
curl http://127.0.0.1:8000/api/me -H "Accept: application/json" -H "Authorization: Bearer <token>"
```

## 6. Peringatan tentang tes otomatis

Tes backend memakai `RefreshDatabase`, yang menghapus semua tabel. Karena itu `phpunit.xml`
**memaksa SQLite memori** dan tes menolak berjalan bila koneksinya bukan SQLite. Jangan
menghapus pengaman itu dan jangan menjalankan tes dengan `DB_CONNECTION=pgsql`.

## 7. Memulihkan dari cadangan

```bat
"C:\Program Files\PostgreSQL\16\bin\psql.exe" -h 127.0.0.1 -U <pengguna> -d <nama_database> -f "D:\Tugas Kuliah\Enlight\cadangan-postgres-sebelum-uji-2026-10-12.sql"
```

(Cadangan dibuat dengan `--clean --if-exists`, jadi menimpa tabel yang ada.)
