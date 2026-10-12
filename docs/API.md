# API Murobi (Laravel `Master-Admin`)

Dokumen ini menjelaskan API yang dipakai aplikasi Flutter `masjid`. Endpoint
yang sudah ada sebelumnya ditandai **(ada)**; yang ditambahkan untuk aplikasi
mobile ditandai **(baru)**. Semua perubahan pada endpoint lama hanya
**menambah field**, tidak mengubah atau menghapus field yang sudah ada.

## Umum

| Hal | Nilai |
| --- | --- |
| Alamat dasar | `{BASE_URL}/api` (lokal: `http://127.0.0.1:8000/api`) |
| Format | JSON. Kirim header `Accept: application/json` |
| Autentikasi | Laravel Sanctum, header `Authorization: Bearer {token}` |
| Zona waktu | Sesuai `APP_TIMEZONE` Laravel (bawaan UTC) |
| Pembatasan | 60 permintaan/menit per alamat IP; login dan daftar 10/menit |

Format error:

```json
{ "message": "Penjelasan singkat.", "errors": { "field": ["pesan"] } }
```

`errors` hanya ada untuk kode 422. Kode lain yang dipakai: 401 (belum masuk atau
kata sandi salah), 403 (tidak diizinkan), 404, 429 (terlalu banyak permintaan).

### Alamat gambar dan berkas

Panel admin menyimpan unggahan di disk Laravel (`FILESYSTEM_DISK`) dengan nama
berkas acak, mis. `cover-banner/xyz.jpg`. Setiap respons yang memuat berkas
sekarang punya field pendamping `*_url` (alamat lengkap yang bisa dibuka
langsung). Nilainya `null` jika berkasnya tidak ada di disk.

## Data publik

### `GET /api/banner` (ada)

Banner berstatus aktif (maksimal 3, diatur di panel admin).

```json
[{
  "id": 9, "judul": "Buka Bersama", "deskripsi": "…",
  "cover": "cover-banner/owfHI2N6X….jpg",
  "cover_url": "http://127.0.0.1:8000/api/files/cover-banner/owfHI2N6X….jpg",
  "kategori": 2, "status": true,
  "created_at": "…", "updated_at": "…"
}]
```

`kategori`: 0 = Informatif, 1 = Promo, 2 = Kegiatan. Field baru: `cover_url`.

### `GET /api/masjid` dan `GET /api/masjid/{id}` (ada)

Daftar masjid. `GET /api/masjid/{id}` mengembalikan **larik** berisi 0 atau 1
masjid (bentuk lama dipertahankan).

```json
[{
  "id": 8, "masjid_name": "Al-Fajri",
  "masjid_pict": "masjid-profile/aV3….jpg", "masjid_pict_url": "…",
  "alamat": "Palembang, Sumatera Selatan", "ketua_masjid": "Zaki Fauzan",
  "kapasitas": 1200, "saldo_awal": 20000000, "kas": 20000000,
  "created_at": "…", "updated_at": "…"
}]
```

Field baru: `masjid_pict_url`.

### `GET /api/edu/book` dan `GET /api/edu/video` (ada)

Materi edukasi jenis Buku (`jenis_education_id` = 1) dan Video (= 2).

```json
[{
  "id": 1, "jenis_education_id": 2, "judul": "Batu", "kategori": 0,
  "content": "konten-edukasi/MwJ0ff….mp4", "content_url": "…",
  "deskripsi": "…", "created_at": "…", "updated_at": "…"
}]
```

`kategori`: 0 = Anak-anak, 1 = Dewasa (remaja), 2 = Orang tua. `content` adalah
berkas yang diunggah admin: gambar atau PDF untuk Buku, berkas video (mp4)
untuk Video. Field baru: `content_url`.

### `GET /api/activity` (baru)

Kegiatan masjid, terbaru di atas. Parameter opsional: `masjid_id`.

```json
[{
  "id": 1, "masjid_id": 8, "masjid_name": "Al-Fajri",
  "activity_name": "Pengajian Bersama",
  "decription": "…", "deskripsi": "…",
  "categories": 0,
  "pict": "gambar-kegiatan/abc.jpg", "pict_url": "…",
  "created_at": "…", "updated_at": "…"
}]
```

`categories`: 0 = kegiatan besar, 1 = sedang, 2 = kecil. `decription` (ejaan asli
kolom di database) dan `deskripsi` berisi teks yang sama.

### `GET /api/lapkeu/{masjid_id}` (ada)

Laporan keuangan satu masjid. Parameter opsional `filter_awal` dan
`filter_akhir` (tanggal) untuk membatasi rentang. Tidak berubah.

### `GET /api/files/{path}` (baru)

Menyajikan berkas unggahan (mendukung `Range` untuk pemutaran video). Hanya
folder `cover-banner`, `konten-edukasi`, `gambar-kegiatan`, `masjid-profile`,
dan `profil-pict` yang dapat dibuka; selain itu 404.

## Akun jamaah

Alur: jamaah **mendaftar** lewat aplikasi, akunnya berstatus **0 (menunggu)**.
Admin menyetujuinya di panel web (`/validateRegist`, status menjadi 1) atau
menolaknya (status 2). Hanya akun berstatus 1 yang dapat **masuk**.

Objek `user` pada semua respons di bawah:

```json
{
  "id": 3, "name": "Ahmad Al Farizi", "email": "ahmad@gmail.com",
  "no_hp": "081994851234",
  "profil_pict": "profil-pict/geK5L….jpg", "profil_pict_url": "…",
  "is_admin": false, "status": 1
}
```

### `POST /api/register` (baru)

Body JSON: `name` (min 3), `email` (unik), `no_hp` (unik, `08…` atau `+62…`, 9-14
digit), `password` (min 8 karakter). Respons **201**:

```json
{ "message": "Pendaftaran berhasil. Akun Anda menunggu persetujuan admin.",
  "user": { "…": "status 0" } }
```

Kata sandi disimpan sebagai hash bcrypt. Error 422 jika data tidak valid atau
email/no_hp sudah terdaftar.

### `POST /api/login` (baru)

Body JSON: `login` (email **atau** no_hp), `password`, `device_name` (opsional).

- 200 → `{ "token": "…", "token_type": "Bearer", "user": { … } }`
- 401 → `ID atau kata sandi salah.`
- 403 → `Akun Anda menunggu persetujuan admin.` (status 0) atau
  `Pendaftaran Anda ditolak oleh admin.` (status 2)

**Catatan kata sandi lama.** Data bawaan panel admin menyimpan kata sandi
**polos** (tanpa hash), dan login web membandingkannya apa adanya. Endpoint ini
menerima kedua bentuk (hash bcrypt atau polos) dan **tidak mengubah** data yang
tersimpan, supaya login admin di panel web tetap berfungsi.

### `POST /api/logout` (baru, perlu token)

Mencabut token yang dipakai. 200 → `{ "message": "Berhasil keluar." }`.

### `GET /api/me` (baru, perlu token)

200 → `{ "user": { … } }`.

### `PATCH /api/me` (baru, perlu token)

Body JSON, semua opsional: `name`, `email`, `no_hp` (aturan sama dengan
pendaftaran; email/no_hp tidak boleh dipakai akun lain). 200 → `{ "user": { … } }`.

### `POST /api/me/photo` (baru, perlu token)

`multipart/form-data` dengan berkas gambar `profil_pict` (maksimal 2 MB).
200 → `{ "user": { … } }`.

### `POST /api/me/password` (baru, perlu token)

Body JSON: `old_password`, `new_password` (min 8, harus berbeda).
200 → `{ "message": "Kata sandi berhasil diubah." }`; 422 jika kata sandi lama
salah. Akun admin (`is_admin` = true) ditolak dengan 403: kata sandi admin
diubah lewat panel web karena disimpan dalam format lama.

## Kelola konten (khusus admin)

Dipakai aplikasi agar admin dapat menambah, mengubah, dan menghapus Kegiatan dan
Edukasi. Semua perlu `Authorization: Bearer {token}` akun dengan `is_admin` =
true; tanpa token 401, akun jamaah biasa 403 (`Hanya admin yang boleh melakukan
ini.`). Admin dapat mengelola semua masjid (tabel `users` tidak punya kolom
masjid). **Pembaruan memakai `POST`** (multipart) karena PHP tidak membaca berkas
pada PATCH/PUT. Semua respons sukses mengembalikan objek yang sama dengan
`GET` daftarnya (termasuk `pict_url`/`content_url`).

### Kegiatan

| Endpoint | Isi |
| --- | --- |
| `POST /api/activity` | multipart: `masjid_id` (wajib, ada), `activity_name` (wajib), `deskripsi`, `categories` (0-2, bawaan 0), `pict` (wajib, gambar maks. 4 MB). 201. |
| `POST /api/activity/{id}` | semua field opsional; `pict` baru mengganti poster lama (berkas lama dihapus). |
| `DELETE /api/activity/{id}` | menghapus kegiatan dan posternya. 404 jika tidak ada. |

### Edukasi

| Endpoint | Isi |
| --- | --- |
| `POST /api/edu` | multipart: `jenis` (`book` / `video`), `judul`, `kategori` (0 anak, 1 remaja, 2 orang tua), `deskripsi` (isi artikel; wajib), lalu: **buku** `content` opsional (gambar atau PDF, maks. 30 MB); **video** `content` (mp4/webm/mov) **atau** `video_url` (mis. tautan YouTube, disimpan apa adanya di kolom `content`). 201. |
| `POST /api/edu/{id}` | field opsional; jenis tidak dapat diubah; `content`/`video_url` baru mengganti yang lama (berkas lama dihapus, tautan tidak). |
| `DELETE /api/edu/{id}` | menghapus materi dan berkasnya. |

`content_url` pada `GET /api/edu/video` berisi tautan itu sendiri bila `content`
berupa `http(s)://`. Catatan: pratinjau video di panel web (`<video src=...>`)
tidak dapat memutar tautan YouTube; materi tersebut tetap tampil benar di
aplikasi. Validasi gagal -> 422 dengan pesan Indonesia di `errors`.

## Catatan keamanan untuk pengembangan lanjutan

Ditemukan saat membaca kode yang sudah ada; **belum diubah** karena di luar
cakupan penambahan API ini:

1. **Kata sandi polos.** `userController::store`/`update` dan
   `AdminsController::authenticate` menyimpan serta membandingkan kata sandi
   tanpa hash (komentar kode: "Jangan Lupa bcrypt passwordnya!"). Disarankan
   mengganti ke `Hash::make` dan `Auth::attempt`, lalu mengubah kata sandi
   lama menjadi hash. Setelah itu pengecualian admin di `POST /api/me/password`
   dapat dihapus.
2. **`GET /api/user/{id}` terbuka untuk umum** dan menampilkan nama, email, dan
   nomor HP siapa pun hanya dengan menebak `id`. Aplikasi mobile tidak
   memakainya; gunakan `GET /api/me`. Sebaiknya endpoint lama diberi
   `auth:sanctum` atau dihapus.
3. Isi `.env` (termasuk kata sandi database) ada di folder `Master-Admin`;
   pastikan tidak ikut di-commit (sudah ada di `.gitignore`).

## Menjalankan aplikasi Flutter terhadap server

Tanpa pengaturan apa pun aplikasi berjalan dalam **mode lokal** (akun dummy
`jamaah`/`jamaah123` dan `admin`/`admin123`, data di perangkat). Untuk memakai
server, beri alamat dasarnya saat menjalankan:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000      # emulator Android
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000  # HP asli, satu Wi-Fi
```

Pada mode server: masuk/daftar/profil/foto/kata sandi lewat API (token disimpan
di perangkat dan dipulihkan saat aplikasi dibuka), daftar masjid, banner,
kegiatan, dan materi edukasi dimuat dari server (disimpan sebagai cache untuk
dipakai saat server tidak terjangkau). Admin (peran Admin Masjid) melihat tombol
tambah dan geser-hapus; kegiatan baru milik masjid yang dipilih di Beranda. Tambah/ubah/
hapus konten dari aplikasi hanya untuk akun admin (lihat "Kelola konten").

**HTTP di Android.** Sejak Android 9, `http://` biasa diblokir. Build **debug**
(`flutter run`) sudah diizinkan lewat `android/app/src/debug/AndroidManifest.xml`.
Build **rilis** tetap hanya HTTPS; untuk demo APK rilis ke server di Wi-Fi lokal
(HTTP), tambahkan `android:usesCleartextTraffic="true"` pada `<application>` di
`android/app/src/main/AndroidManifest.xml` (jangan dipakai untuk produksi), atau
pasang HTTPS di server.

Catatan pengembangan: `php artisan serve` hanya melayani satu permintaan sekali
waktu. Di mesin pengembangan ini server bawaan PHP juga memotong respons di atas
~64 KB, sehingga gambar besar sering gagal dimuat. Perkecil gambar unggahan atau
pakai Apache (XAMPP).
