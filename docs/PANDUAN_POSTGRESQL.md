# Panduan: menjalankan Murobi terhadap PostgreSQL asli

Semua pengujian sejauh ini memakai SQLite sementara. Panduan ini untuk
membuktikan bahwa API dan aplikasi juga bekerja di database PostgreSQL yang
dipakai panel web Anda. Langkah ini **Anda** yang menjalankan, karena database
dan `.env` Anda tidak pernah saya buka atau sentuh.

## 1. Yang sudah dicek (hanya dengan membaca)

Dari cadangan `db-backups/api.sql` (9 Januari 2024) dan kode:

| Pemeriksaan | Hasil |
| --- | --- |
| Tabel `personal_access_tokens` (dibutuhkan Sanctum) | Ada |
| `users.is_admin` / `users.status` | `bool` / `int4 default 0` — sesuai yang dipakai API |
| `activities.decription`, `activities.pict` | `text` / `varchar(255)` — sesuai |
| `education.content` (varchar 255), `education.deskripsi` (text) | Sesuai (tautan YouTube muat di `content`) |
| Migrasi atau kolom baru dari pekerjaan API | **Tidak ada** (`git status Master-Admin/database` bersih) |
| Login panel web | Memakai tabel **`users`** dengan `is_admin = true` (`AdminsController::authenticate`), bukan tabel `admins` |
| Isi `users` pada cadangan | Hanya 1 baris: `ahmad@gmail.com`, bukan admin, `status = 1`, kata sandi teks polos |

Artinya: tidak ada perubahan skema yang perlu dijalankan. Yang perlu dipastikan
adalah **ada akun admin** di `users` (lihat langkah 4).

Kondisi di komputer ini (saat diperiksa): layanan `postgresql-x64-16` berhenti;
ekstensi PHP `pdo_pgsql` belum aktif di XAMPP maupun Herd; `APP_KEY` di `.env`
kosong.

## 2. Persiapan

1. **Cadangkan dulu.** API baru menulis ke `users` (daftar), `personal_access_tokens`
   (masuk), `activities`, `education`, dan berkas di `storage/app/public`.
   ```bash
   pg_dump -U postgres -d <nama_database> --clean --if-exists -f cadangan-sebelum-uji.sql
   ```
2. **Nyalakan PostgreSQL**: Services → `postgresql-x64-16` → Start (atau
   `net start postgresql-x64-16` di PowerShell administrator).
3. **Aktifkan ekstensi PHP tanpa mengubah `php.ini`** — cukup tambahkan dua
   argumen setiap kali menjalankan PHP (sudah diperiksa: driver `pgsql` muncul):
   ```bash
   C:\xampp\php\php.exe -d extension=pdo_pgsql -d extension=pgsql artisan serve --host=0.0.0.0 --port=8000
   ```
   Cara permanen: hapus tanda `;` pada `;extension=pdo_pgsql` dan
   `;extension=pgsql` di `C:\xampp\php\php.ini`, lalu mulai ulang Apache/terminal.
4. **Tabel laporan masalah.** Fitur "Laporan Masalah" memakai satu tabel baru
   `reports`. Tambahkan **hanya migrasi itu** (jangan menjalankan `php artisan
   migrate` polos: bila basis data dibuat dari cadangan SQL, Laravel dapat
   mencoba membuat ulang tabel lama):
   ```bash
   C:\xampp\php\php.exe -d extension=pdo_pgsql -d extension=pgsql artisan migrate --path=database/migrations/2026_10_12_000001_create_reports_table.php
   ```
   Tabel lain tidak diubah. (Login Google, bila dipakai, tidak butuh tabel
   baru; lihat `docs/LOGIN_GOOGLE.md`.)
5. **`.env`** (milik Anda; jangan dibagikan): `DB_CONNECTION=pgsql`, `DB_HOST`,
   `DB_PORT=5432`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, dan
   `FILESYSTEM_DISK=public`. Berkas gambar disajikan lewat `/api/files/...`,
   jadi `php artisan storage:link` tidak diperlukan oleh API.
6. Bila panel web menampilkan *No application encryption key*, jalankan
   `php artisan key:generate` (API sendiri tidak membutuhkannya).

## 3. Server

`php artisan serve` hanya melayani satu permintaan sekali waktu. Untuk uji yang
lebih mulus pakai Apache dari XAMPP. Di komputer yang saya pakai, server bawaan
PHP juga tidak andal untuk respons lebih dari sekitar 64 KB (gambar besar bisa
gagal dimuat), jadi gunakan gambar kecil saat mencoba atau pakai Apache.

## 4. Pastikan ada akun admin

Jalankan di psql/pgAdmin (membaca saja):

```sql
select id, email, is_admin, status from users order by id;
```

Akun yang dipakai aplikasi sebagai admin harus `is_admin = true` dan
`status = 1`. Bila belum ada, tentukan sendiri akunnya lalu:

```sql
update users set is_admin = true, status = 1 where email = '<email admin Anda>';
```

Kata sandi lama berupa teks polos tetap diterima dan **tidak diubah** oleh API
(supaya login panel web tidak rusak). Kata sandi akun baru dari aplikasi
disimpan sebagai hash bcrypt.

## 5. Uji cepat dengan curl

Ganti `<...>` dengan data Anda. Port sesuai langkah 3.

```bash
# 1) Data publik
curl http://127.0.0.1:8000/api/masjid
curl "http://127.0.0.1:8000/api/activity?masjid_id=<id masjid>"
curl http://127.0.0.1:8000/api/edu/book

# 2) Masuk sebagai admin -> catat "token"
curl -X POST http://127.0.0.1:8000/api/login -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"login":"<email admin>","password":"<kata sandi>"}'

# 3) Data akun
curl http://127.0.0.1:8000/api/me -H "Accept: application/json" -H "Authorization: Bearer <token>"

# 4) Tambah lalu hapus materi uji (bukti tulis ke PostgreSQL)
curl -X POST http://127.0.0.1:8000/api/edu -H "Accept: application/json" \
  -H "Authorization: Bearer <token>" -F jenis=book -F "judul=Materi uji" \
  -F kategori=0 -F "deskripsi=Hanya untuk uji."
curl -X DELETE http://127.0.0.1:8000/api/edu/<id dari langkah di atas> \
  -H "Accept: application/json" -H "Authorization: Bearer <token>"

# 5) Keluar (mencabut token)
curl -X POST http://127.0.0.1:8000/api/logout -H "Accept: application/json" -H "Authorization: Bearer <token>"
```

Hasil yang diharapkan: langkah 1 berupa larik JSON; langkah 2 mengembalikan
`token`; langkah 3 menampilkan `is_admin: true`; langkah 4 membalas 201 lalu
200; langkah 5 membalas 200.

## 6. Aplikasi

```bash
# Emulator MuMu (JDK 17)
flutter run -d 127.0.0.1:16384 --dart-define=API_BASE_URL=http://10.0.2.2:8000

# HP asli di Wi-Fi yang sama (izinkan port 8000 di Windows Firewall)
flutter run --dart-define=API_BASE_URL=http://<IP-LAN-komputer>:8000
```

Lalu ulangi alur utama dari `docs/PENGUJIAN_BLACKBOX.md`: masuk, Beranda, ganti
masjid, Edukasi, Profil, serta (sebagai admin) tambah dan hapus satu kegiatan
dan satu materi.

## 7. Peringatan tentang tes otomatis

Tes backend memakai `RefreshDatabase`, yang menghapus semua tabel. Karena itu
`phpunit.xml` sekarang **memaksa SQLite memori** dan tes menolak berjalan bila
koneksinya bukan SQLite. Jangan menghapus pengaman itu, dan jangan menjalankan
tes dengan `DB_CONNECTION=pgsql`.

## 8. Setelah selesai

Hapus data uji (lewat API atau panel web), matikan server, dan bila ada
masalah pulihkan dari cadangan langkah 2:

```bash
psql -U postgres -d <nama_database> -f cadangan-sebelum-uji.sql
```
