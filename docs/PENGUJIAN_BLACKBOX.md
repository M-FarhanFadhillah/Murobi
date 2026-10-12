# Pengujian Black Box — Aplikasi Murobi

Dokumen ini merangkum pengujian fungsional (black box) aplikasi Murobi dan
API-nya, disusun dari hasil uji yang benar-benar dijalankan pada **12 Oktober
2026**. Setiap baris menyebut buktinya; kasus yang belum terbukti dicatat di
bagian "Keterbatasan", bukan ditandai berhasil.

## 1. Lingkungan uji

| Komponen | Keterangan |
| --- | --- |
| Aplikasi | Flutter 3.13.7 (Dart 3.1.3), tema Material, `flutter_bloc`, `just_audio`, `http` |
| Server | Laravel 9.52 + Sanctum 3, PHP 8.2 (XAMPP). Tes otomatis memakai **SQLite memori**; uji langsung (kolom bukti **P**) memakai **PostgreSQL 16 asli** |
| Perangkat Android | MuMu Player, Android 15 (API 35), x86_64, layar 1080×1920, build debug |
| Peramban | Chrome (panel peramban), Flutter web, lebar 390 px |
| Alamat server dari emulator | `http://10.0.2.2:8000` |
| Data uji | Data contoh buatan (4 masjid, 3 banner, 3 kegiatan, 5 materi, 4 akun) — tidak memakai data asli |

## 2. Ringkasan hasil

| Jenis bukti | Kode | Jumlah | Hasil |
| --- | --- | --- | --- |
| Tes otomatis Flutter (`flutter test`) | **F** | 266 tes | 266 lulus |
| Tes otomatis Laravel (`php artisan test`) | **L** | 42 tes (40 API + 2 bawaan) | 42 lulus |
| Uji langsung `curl` ke Laravel lokal (SQLite sementara): endpoint laporan | **C** | 9 permintaan | sesuai |
| Uji langsung ke **PostgreSQL asli** (data publik, login, laporan, kelola kegiatan + gambar, login Google) | **P** | lihat `docs/PANDUAN_POSTGRESQL.md` | sesuai; 3 temuan (T-13 s.d. T-15) |
| Pengamatan langsung di emulator MuMu | **A** | lihat tabel | sesuai |
| Pengamatan langsung di peramban | **W** | lihat tabel | sesuai |
| Skrip uji terpadu: kode aplikasi memanggil server Laravel lokal | **S** | 4 skenario | sesuai (skrip sementara, sudah dihapus) |

Rincian tes Flutter per berkas: `account_test` 18, `api_test` 75, `api_ui_test`
25, `auth_test` 11, `edukasi_test` 32, `google_test` 18, `kegiatan_test` 11,
`prayer_test` 13, `quran_library_test` 22, `quran_test` 18, `report_test` 22,
`widget_test` 1.

## 3. Kasus uji

Kolom **Hasil**: *Sesuai* berarti hasil aktual sama dengan yang diharapkan.

### 3.1 Autentikasi

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| AUT-01 | Masuk dengan email dan kata sandi benar | Beranda terbuka, profil terisi dari server | Sesuai | F `api_ui` (masuk berhasil); L `AuthApiTest`; A; W |
| AUT-02 | Masuk dengan nomor HP | Berhasil seperti email | Sesuai | L login dengan email atau nomor hp; F `auth_test`; S |
| AUT-03 | Kata sandi salah / ID tidak ada | Pesan "ID atau kata sandi salah.", tetap di halaman masuk | Sesuai | F `auth_test`, `api_ui`; L login gagal 401; W (kata sandi lama setelah diganti) |
| AUT-04 | Kolom kosong | Pesan validasi per kolom | Sesuai | F `auth_test` |
| AUT-05 | Akun belum disetujui admin mencoba masuk | Ditolak: "Akun Anda menunggu persetujuan admin." | Sesuai | F `api_test`, `api_ui`; L akun menunggu atau ditolak; S |
| AUT-06 | Daftar dengan data valid | Akun dibuat berstatus menunggu; pindah ke masuk dengan pesan persetujuan | Sesuai | F `api_ui` (SignUp berhasil); L register; S |
| AUT-07 | Daftar dengan email/HP ganda, kata sandi lemah, konfirmasi beda | Ditolak dengan pesan di kolom terkait | Sesuai | F `account_test`, `api_ui`; L register menolak data tidak valid; S |
| AUT-08 | Buka ulang aplikasi setelah masuk | Sesi dipulihkan dari token tersimpan; langsung beranda | Sesuai | F `api_ui` (Splash); A (matikan paksa lalu buka lagi); W |
| AUT-09 | Token dicabut / tidak sah | Kembali ke halaman masuk, token dihapus dari perangkat | Sesuai | F `api_test`, `api_ui`; W (setelah data direset) |
| AUT-10 | Keluar dari akun | Kembali ke halaman masuk; token dicabut di server | Sesuai | F `api_ui`, `api_test`; L me dan logout; A; W; S |
| AUT-11 | Ganti kata sandi: lama salah, lalu benar | Salah: pesan di bawah kolom; benar: berhasil, kata sandi lama tidak berlaku lagi | Sesuai | F `account_test`, `api_ui`; L ubah kata sandi; W; S |
| AUT-12 | Admin mencoba ganti kata sandi dari aplikasi | Ditolak (403), pesan mengarah ke panel web | Sesuai | F `api_test`; L admin tidak bisa mengubah kata sandi; S |
| AUT-13 | Masuk dengan kata sandi lama (teks polos) | Diterima dan data tidak diubah | Sesuai | L kata sandi polos data lama diterima; A (admin) |
| AUT-14 | Percobaan masuk beruntun melebihi batas | Pesan "Terlalu banyak percobaan…" berbahasa Indonesia | Sesuai | F `api_test` (kode 429); S (server memang membalas 429) |

| AUT-15 | Masuk dengan Google (mode lokal) | Profil Google menjadi akun jamaah; menuju beranda; email yang sama dengan akun demo tidak menjadikannya admin | Sesuai (Google tiruan) | F `google_test` |
| AUT-16 | Masuk dengan Google (server) | Token dikirim ke server; sesi dan token tersimpan; web hanya mengirim access token | Sesuai (Google tiruan) | F `google_test`; L `GoogleAuthApiTest` (akun baru, akun lama dicocokkan lewat email) |
| AUT-17 | Google dibatalkan / ID klien belum diisi / error / ketukan ganda | Pesan jelas, tidak ada sesi, Google tidak dibuka dua kali | Sesuai | F `google_test` |
| AUT-18 | Token Google tidak sah: `aud` aplikasi lain, email belum terverifikasi, ditolak Google, kosong | 401 "Akun Google tidak dapat diverifikasi."; tidak ada akun dibuat | Sesuai | L `GoogleAuthApiTest`; C (503 saat ID klien kosong) |
| AUT-19 | Akun Google berstatus menunggu / ditolak, atau persetujuan otomatis dimatikan | 403 dengan pesan status | Sesuai | L `GoogleAuthApiTest` |
| AUT-20 | Login Google dengan akun Google sungguhan di Chrome (mode lokal, lalu mode server terhadap PostgreSQL asli) | Masuk ke Beranda; di mode server akun jamaah dibuat dan data masjid dari PostgreSQL tampil | Sesuai | **P** (lihat `docs/LOGIN_GOOGLE.md` bagian 5) |

### 3.2 Profil

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| PRF-01 | Buka tab Profil | Nama, email, HP, dan peran (Jamaah / Admin Masjid) dari server | Sesuai | F `api_ui`; A; W |
| PRF-02 | Ubah nama dan simpan | "Profil berhasil diperbarui", tersimpan di server | Sesuai | F `api_ui`; L ubah data diri; W; S |
| PRF-03 | Ubah email menjadi milik akun lain | Ditolak, pesan server tampil, mode edit tetap | Sesuai | F `api_ui`; L; S |
| PRF-04 | Ubah foto dari galeri | Avatar berganti; berkas tersimpan di server; tetap tampil setelah aplikasi dibuka ulang | Sesuai | F `api_test` (unggah multipart); L unggah foto profil; **A**; S |
| PRF-05 | Sesi berakhir saat menyimpan | Kembali ke halaman masuk | Sesuai | F `api_ui` |
| PRF-06 | Baris "Ubah Kata Sandi" / EDIT di layar sempit | Tidak meluap | Sesuai | F `api_ui` (temuan T-3) |
| PRF-07 | Buka Profil | Tidak ada lagi kartu pengaturan "Bahasa" | Sesuai | F `report_test` (halaman profil) |

### 3.3 Beranda

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| BRD-01 | Buka beranda | Jam berjalan, tanggal, lima waktu sholat tampil | Sesuai | A; W (manual; tanpa tes otomatis) |
| BRD-02 | Pilih masjid lain | Header dan kegiatan berganti ke masjid itu | Sesuai | F `api_test` (berganti masjid); W |
| BRD-03 | Banner dari server | Hanya banner aktif yang punya gambar; tanpa banner, carousel disembunyikan | Sesuai | F `api_test`; A; W |
| BRD-04 | Kegiatan masjid terpilih | Poster terbaru tampil; gagal memuat: pesan + "Coba lagi" | Sesuai | F `api_ui`; W |
| BRD-05 | Gambar gagal dimuat | Placeholder berisi ikon dan judul, bukan layar rusak | Sesuai | W |
| BRD-06 | Jadwal sholat tanpa internet, ada jadwal tersimpan (maks. 7 hari) | Lima waktu tetap tampil; bila dari hari lain ada catatan "Jadwal tersimpan (dd/MM)" | Sesuai | F `prayer_test` |
| BRD-07 | Jadwal sholat tanpa internet dan tanpa jadwal tersimpan / tersimpan > 7 hari / jam perangkat mundur / data rusak | Pesan "Jadwal sholat belum tersedia" + tombol muat ulang yang berfungsi | Sesuai | F `prayer_test` |
| BRD-08 | Respons Aladhan bukan 200, bukan JSON, atau koneksi menggantung (10 detik) | Memakai jadwal tersimpan, tidak menggantung | Sesuai | F `prayer_test` |

### 3.4 Kegiatan masjid

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| KGT-01 | Jamaah membuka daftar kegiatan | Poster, judul, deskripsi; tanpa tombol Unggah / geser-hapus | Sesuai | F `api_ui`, `kegiatan_test` |
| KGT-02 | Admin menambah kegiatan (poster dari galeri + judul) | Tampil paling atas; tersimpan di server bersama berkasnya | Sesuai | F `api_test`; L admin menambah mengubah dan menghapus kegiatan; **A** |
| KGT-03 | Admin menghapus kegiatan (geser + konfirmasi) | Hilang dari daftar; berkas poster ikut terhapus di server | Sesuai | F `api_ui`, `api_test`; L; **A** |
| KGT-04 | Hapus gagal di server | Poster kembali ke daftar, pesan server tampil | Sesuai | F `api_ui` (temuan T-1) |
| KGT-05 | Tambah dengan data tidak valid | 422 dengan pesan Indonesia (masjid, judul, poster) | Sesuai | L kegiatan validasi |
| KGT-06 | Akun biasa / tanpa token menambah | 403 / 401, tidak ada data tersimpan | Sesuai | L tanpa token ditolak dan jamaah biasa dilarang |

### 3.5 Edukasi

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| EDU-01 | Buka tab Edukasi | Tab Rekomendasi (terbaru semua kategori, maks. 5), Anak-anak, Remaja, Orang Tua; terbaru di atas | Sesuai | F `api_test`, `api_ui`; A; W |
| EDU-02 | Buka detail artikel dan video | Video: tombol "Tonton Video"; artikel: tidak ada | Sesuai | F `edukasi_test`, `api_ui`; A |
| EDU-03 | Ketuk "Tonton Video" (tautan YouTube) | Tautan terbuka di peramban dan video diputar | Sesuai | F `edukasi_test`; **A** (Chrome membuka m.youtube.com) |
| EDU-04 | Materi berisi PDF | Tombol "Buka Berkas" membuka tautan berkas | Sesuai | F `api_ui` |
| EDU-05 | Admin menambah artikel tanpa gambar | Tersimpan, tampil teratas | Sesuai | F `api_test`, `api_ui`; L; **A** |
| EDU-06 | Admin menambah artikel dengan sampul dari galeri | Sampul tersimpan di server dan tampil di daftar dan detail | Sesuai | F `api_test`; L; **A** |
| EDU-07 | Admin menambah video dengan tautan YouTube | Tersimpan; deskripsi kosong memakai judul; gambar mini tampil | Sesuai | F `api_test`; L video dengan tautan atau berkas; **A** |
| EDU-08 | Validasi form | Judul, isi, tautan wajib dan valid; server 422 dengan pesan Indonesia | Sesuai | F `edukasi_test`; L edukasi validasi |
| EDU-09 | Admin mengubah materi | Kategori dan judul berubah; jenis tidak dapat diganti; hanya bagian berubah yang dikirim | Sesuai | F `api_test`, `api_ui`; L ubah dan hapus edukasi; **A** |
| EDU-10 | Admin menghapus materi | Hilang di server; jika gagal, daftar dikembalikan | Sesuai | F `api_test`; L; **A** |
| EDU-11 | Gagal memuat daftar | Pesan dan tombol "Coba lagi"; tarik untuk menyegarkan | Sesuai | F `api_ui`; A (tarik untuk menyegarkan) |

### 3.6 Al-Qur'an

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| QRN-01 | Buka tab Al-Qur'an | Tab Surah, Juz, Bookmark; daftar surah tampil | Sesuai | F `quran_library_test`; A |
| QRN-02 | Cari surah / juz | Daftar tersaring | Sesuai | F `quran_library_test` |
| QRN-03 | Baca surah | Arab, Latin, terjemahan; mode "Arab saja"; zoom 80–200% | Sesuai | F `quran_test` |
| QRN-04 | Putar bacaan surah | Tombol putar memulai, jeda menghentikan | Sesuai (pemutar tiruan) | F `quran_test` |
| QRN-05 | Tanda (bookmark) dan terakhir dibaca | Tersimpan di perangkat, membuka ayat tersimpan | Sesuai | F `quran_library_test` |
| QRN-06 | Tanpa internet | Memakai salinan tersimpan, atau pesan ramah + "Coba lagi" | Sesuai | F `quran_test` (ApiService) |
| QRN-07 | Surat terakhir (An-Nas) | Tampil tanpa error | Sesuai | F `quran_test` (temuan sebelumnya, sudah diperbaiki) |

### 3.7 Ketahanan jaringan dan mode lokal

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| NET-01 | Server tidak terjangkau | Pesan jaringan, aplikasi tidak crash | Sesuai | F `api_test`, `api_ui`; W |
| NET-02 | GET putus di tengah jalan | Diulang sekali; POST tidak pernah diulang otomatis | Sesuai | F `api_test` |
| NET-03 | Waktu habis (15 detik) | Kesalahan jaringan, tidak diulang | Sesuai | F `api_test` |
| NET-04 | Server mati / 5xx | Daftar terakhir yang berhasil dipakai (cache); 404 tidak memakai cache | Sesuai | F `api_test` |
| NET-05 | Respons bukan JSON / bukan larik | Pesan jelas, tidak crash | Sesuai | F `api_test` |
| NET-06 | Aplikasi tanpa alamat server | Mode lokal: akun dummy, data di perangkat, tidak memanggil server | Sesuai | F `api_test`, `auth_test`, `kegiatan_test`, `edukasi_test` |

### 3.8 Hak akses dan keamanan dasar

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| HAK-01 | Endpoint admin: tanpa token / jamaah / admin | 401 JSON / 403 / diizinkan | Sesuai | L `AdminContentApiTest`, `AuthApiTest` (401 JSON tanpa header Accept) |
| HAK-02 | Menu kelola dan tombol tambah | Hanya terlihat oleh admin | Sesuai | F `api_ui`, `edukasi_test`, `kegiatan_test`; A |
| HAK-03 | Berkas di luar folder yang diizinkan, `..` | 404 | Sesuai | L berkas disajikan hanya dari folder yang diizinkan |
| HAK-04 | Permintaan `Range` untuk video | 206 dengan `Content-Range` | Sesuai | L berkas mendukung range |
| HAK-05 | Kata sandi baru disimpan | Berupa hash bcrypt, bukan teks polos | Sesuai | L register membuat akun … dengan hash |

### 3.9 Laporan masalah

| ID | Skenario | Hasil yang diharapkan | Hasil | Bukti |
| --- | --- | --- | --- | --- |
| LAP-01 | Jamaah menulis laporan | Muncul sebagai gelembung "Terkirim"; kolom dikosongkan; tidak ada balasan otomatis lagi | Sesuai | F `report_test`; L `ReportApiTest`; C |
| LAP-02 | Laporan terlalu pendek (< 5) / terlalu panjang (> 1000) | Pesan "Isi laporan minimal 5 karakter." / maksimal 1000; tidak tersimpan | Sesuai | F `report_test`; L |
| LAP-03 | Jamaah melihat laporannya | Hanya miliknya; yang sudah ditangani bertanda "Sudah ditangani admin" | Sesuai | F `report_test`; L; C |
| LAP-04 | Admin membuka menu "Laporan Masalah Jamaah" | Daftar laporan semua jamaah (pengirim, email, waktu, isi, status), terbaru di atas, ringkasan "N laporan baru" | Sesuai | F `report_test`; L; C |
| LAP-05 | Admin menandai selesai / membuka lagi | Status berubah; jamaah melihat statusnya | Sesuai | F `report_test`; L; C |
| LAP-06 | Admin menghapus laporan | Konfirmasi dulu; Batal = tetap ada; hapus = hilang; 404 dianggap sudah terhapus | Sesuai | F `report_test`; L; C |
| LAP-07 | Jamaah mencoba melihat semua / mengubah / menghapus laporan; tanpa token | 403 / 401, data tidak berubah | Sesuai | L `ReportApiTest`; C (403) |
| LAP-08 | Gagal memuat / mengubah | Pesan + "Coba lagi"; perubahan yang gagal tidak mengubah daftar | Sesuai | F `report_test` |
| LAP-09 | Mode lokal | Laporan jamaah tersimpan di perangkat dan terbaca admin pada perangkat yang sama; jamaah lain tidak melihat laporan orang lain | Sesuai | F `report_test` |
| LAP-10 | Keluar akun | Laporan akun sebelumnya dibersihkan dari memori | Sesuai | F `report_test` (reset) |

## 4. Temuan selama pengujian dan perbaikannya

| ID | Temuan | Perbaikan |
| --- | --- | --- |
| T-1 | Jika hapus gagal sangat cepat, `Dismissible` yang sama dipasang ulang pada frame yang sama dan melempar assertion (mode debug) | Daftar dikembalikan setelah jeda 50 ms |
| T-2 | Pesan pembatasan Laravel berbahasa Inggris ("Too Many Attempts.") tampil apa adanya | Pesan Indonesia selalu dipakai untuk kode 429 |
| T-3 | Baris "Ubah Kata Sandi" + EDIT meluap pada layar sempit / huruf besar | Tata letak dibuat fleksibel (`Expanded`) |
| T-4 | Kartu kegiatan sempat menulis "Belum ada kegiatan" sebelum data dimuat | Status memuat ditampilkan sampai masjid dipilih dan data tiba |
| T-5 | Respons tambah/ubah materi mengembalikan `kategori` sebagai string ("1"), berbeda dari daftar | Dikembalikan sebagai angka; ada pernyataan uji |
| T-6 | Email unik tidak peka huruf: `A@x.com` dan `a@x.com` lolos validasi lalu gagal di database | Validasi memakai `lower(email)` |
| T-7 | Android 9+ memblokir HTTP biasa sehingga aplikasi gagal terhubung | Build debug mengizinkan HTTP (`src/debug/AndroidManifest.xml`); rilis tetap HTTPS |
| T-8 | Tes backend memakai `RefreshDatabase`; tanpa pengaturan, tes dapat memakai koneksi `.env` (PostgreSQL asli) dan menghapus tabelnya | `phpunit.xml` memaksa SQLite memori dan tes menolak berjalan bila koneksi bukan SQLite |
| T-9 | Kata sandi lama di data asli berupa teks polos | Diterima apa adanya (agar panel web tetap berfungsi) dan tidak diubah; risiko dicatat di `docs/API.md` |
| T-10 | Kolom `users.no_hp` wajib dan unik, sedangkan akun Google tidak punya nomor HP | Disimpan nilai pengganti `google:<id>` yang disembunyikan dari aplikasi (tampil kosong); jamaah mengisi nomor asli lewat Profil. Tanpa mengubah skema tabel `users` |
| T-11 | Tombol "Muat ulang" pada kartu jadwal sholat memicu assertion di mode debug (`setState` mengembalikan Future) | `setState` memakai blok; ada tes yang mengetuk tombol itu |
| T-12 | Pesan "Jadwal sholat belum tersedia" + tombol dapat meluap pada layar sempit / huruf besar | Teks dibungkus `Flexible` |
| T-13 | Pada PostgreSQL asli hasil restore cadangan, sequence id sepuluh tabel tertinggal dari id tertinggi sehingga menambah data gagal (`duplicate key ... _pkey`); tidak muncul di SQLite | Perintah `php artisan db:fix-sequences` (+ tes), dijalankan pada basis data asli |
| T-14 | `libpq.dll` hilang dari folder `bin` PostgreSQL 16 sehingga `pg_dump`/`psql`/`pg_ctl` memuat `libpq.dll` XAMPP yang tidak cocok; layanan Windows PostgreSQL juga tidak mau start | `libpq.dll` asli disalin ke `bin`; disediakan `scripts/postgres-mulai.bat` (lihat `docs/PANDUAN_POSTGRESQL.md`, P-2 dan P-3) |
| T-15 | Login Google di web gagal dengan pesan umum karena **Google People API** belum diaktifkan di project (dipanggil plugin web setelah token terbit) | API diaktifkan; log debug penyebab asli ditambahkan di `AccountService.signInWithGoogle` |

## 5. Keterbatasan (belum terbukti)

1. **PostgreSQL asli** sudah dipakai untuk uji langsung (kolom bukti **P**), kecuali login dengan
   akun lama berkata sandi teks polos (kata sandinya tidak diketahui; diuji otomatis saja).
   Lihat `docs/PANDUAN_POSTGRESQL.md`.
2. **Berkas video (mp4) dari server** belum diputar di perangkat. Yang terbukti:
   tautan YouTube, dan penyajian berkas dengan `Range` di sisi server.
3. **Bacaan audio sungguhan** di perangkat belum diuji; tes memakai pemutar tiruan.
4. **Build rilis (APK) dan HTTPS** belum dicoba.
5. **Login Google** terbukti dengan akun sungguhan di **Chrome** (mode lokal dan server), tetapi
   **belum dicoba di Android/emulator MuMu/HP fisik** (lihat `docs/LOGIN_GOOGLE.md`). **OTP nomor
   HP** belum berfungsi (backend belum ada). "Lupa kata sandi" belum mengirim email.
6. **Perangkat fisik**, iOS, uji beban, dan aksesibilitas belum diuji.
7. **Gambar besar**: di komputer uji ini server bawaan PHP tidak andal untuk
   respons lebih dari sekitar 64 KB, jadi pengujian memakai gambar kecil
   (< 60 KB). Pada server sungguhan (Apache/Nginx) hal ini tidak berlaku, tetapi
   belum diuji.
8. Sesekali koneksi lokal mereset permintaan; aplikasi menampilkan pesan jaringan
   dan perintah diulang manual berhasil.

## 6. Cara mengulang

```bash
# Flutter (dari folder masjid/)
flutter test

# Laravel (dari folder Master-Admin/) — memakai SQLite memori otomatis
php artisan test

# Aplikasi di emulator terhadap server lokal (JDK 17)
flutter run -d 127.0.0.1:16384 --dart-define=API_BASE_URL=http://10.0.2.2:8000
```
