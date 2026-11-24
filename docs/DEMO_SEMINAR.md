# Panduan Demo Seminar (VS Code + emulator MuMu)

Rekomendasi: demo memakai **mode lokal** (tanpa server). Aplikasi berjalan
sendiri dengan akun dummy dan data tersimpan di perangkat, jadi tidak ada
server atau database yang bisa gagal di tengah presentasi. Mode server tetap
tersedia (konfigurasi 3 dan 4), tetapi butuh Laravel dan PostgreSQL yang
berjalan (lihat `docs/PANDUAN_POSTGRESQL.md`).

## 1. Sekali saja: buka proyek di VS Code

1. Jalankan VS Code, lalu **File → Open Folder** dan pilih
   `D:\Tugas Kuliah\Enlight\super-app-masjid\masjid`
   (folder `masjid`, bukan folder induknya).
2. Ekstensi **Dart** dan **Flutter** sudah terpasang.
3. Konfigurasi sudah ada di folder `.vscode/`: `launch.json` (tombol jalan),
   `tasks.json` (sambung emulator, tes), `settings.json` (JDK 17 untuk build Android).

## 2. Menjalankan demo

1. **Nyalakan MuMu Player** dan tunggu layar utamanya muncul.
2. Di VS Code tekan **Ctrl+Shift+D** (Run and Debug), pilih
   **"1. Demo lokal - Emulator MuMu (disarankan)"**, lalu tekan **F5**.
   Tugas "MuMu: sambungkan adb" berjalan otomatis.
3. Build pertama sekitar 3–4 menit; berikutnya jauh lebih cepat. **Jalankan
   sekali jauh sebelum seminar** agar hasil build sudah siap.
4. Selama berjalan: **Ctrl+S** atau ikon petir = hot reload; **Ctrl+Shift+F5** =
   hot restart; **Shift+F5** = berhenti.

Konfigurasi lain:

| Nama | Dipakai untuk |
| --- | --- |
| 1. Demo lokal - Emulator MuMu | Demo utama |
| 2. Demo lokal - Chrome | Cadangan bila emulator bermasalah (aplikasi sama, tampil di Chrome) |
| 3. Dengan server Laravel - Emulator MuMu | Demo terhubung server (`http://10.0.2.2:8000`) |
| 4. Dengan server Laravel - Chrome | Server di komputer yang sama (`http://127.0.0.1:8000`) |

## 3. Akun dan alur demo (± 8 menit)

Akun dummy: **jamaah / jamaah123** dan **admin / admin123**.

Aplikasi **bisa dipakai tanpa akun** (memudahkan jamaah lansia): splash langsung
membuka Beranda. Masuk dan daftar ada di **Profil** (ikon profil di pojok kanan
atas Beranda). Yang sudah pernah masuk tetap masuk saat aplikasi dibuka lagi.

1. **Buka aplikasi tanpa masuk** → Beranda: jam, jadwal sholat, banner, pilih masjid, kegiatan masjid.
2. **Edukasi**: kategori, buka artikel, buka video lalu "Tonton Video" (membuka YouTube).
3. **Al-Qur'an**: daftar surah, Juz, Bookmark; buka surah, zoom, mode "Arab saja", putar bacaan.
   Teks 114 surah ada di dalam aplikasi, jadi tetap bisa dibaca tanpa internet (murotal butuh internet).
4. **Profil sebagai tamu**: kartu "Anda belum masuk" → **Masuk** (jamaah) atau **Daftar Akun**.
   Setelah masuk kembali ke Profil: ubah data, ganti foto dari galeri, ubah kata sandi, keluar
   (setelah keluar tetap di aplikasi).
5. **Laporan masalah**: sebagai jamaah buka Profil → **Laporkan Permasalahan**, tulis
   laporan, kirim. Keluar, masuk sebagai admin → Profil → **Laporan Masalah Jamaah**: laporan tadi muncul; coba **Tandai selesai** dan hapus.
6. **Masuk sebagai admin** → Profil → **Kelola Kegiatan Masjid** (unggah dan geser-hapus poster).
7. **Edukasi** sebagai admin: **Tambah materi** (artikel dengan sampul, atau video dengan tautan YouTube), ubah, hapus.

## 4. Yang perlu disiapkan sebelum seminar

- **Internet.** Jadwal sholat diambil dari internet dan **disimpan di perangkat**:
  asal Beranda pernah dibuka sekali dengan internet (maksimal 7 hari
  sebelumnya), jadwal tetap tampil tanpa internet, dengan catatan tanggalnya bila
  bukan hari ini. **Buka Beranda sekali dengan internet sebelum seminar.** Tanpa
  jadwal tersimpan sama sekali muncul "Jadwal sholat belum tersedia".
  Teks Al-Qur'an (114 surah: Arab, Latin, terjemahan) sudah ada di dalam
  aplikasi dan selalu bisa dibaca tanpa internet. Murotal (audio), gambar mini
  dan pemutaran YouTube butuh internet; murotal tanpa internet menampilkan
  "Audio tidak dapat diputar. Periksa koneksi internet.".
  Siapkan hotspot HP sebagai cadangan.
- **Demo Al-Qur'an tanpa internet** (opsional): matikan Wi-Fi dari panel cepat
  MuMu (tarik bilah status ke bawah). Selama Wi-Fi MuMu mati, **adb dan VS Code
  ikut terputus** dari emulator (aplikasi tetap berjalan). Setelah demo, nyalakan
  Wi-Fi lagi lalu **Terminal → Run Task → "MuMu: sambungkan adb"**.
- **Gambar untuk diunggah.** Taruh beberapa gambar poster di galeri MuMu
  (seret berkasnya ke jendela MuMu).
- **Data bersih.** Perubahan admin (kegiatan, materi) dan foto profil tersimpan
  di emulator. Untuk mengembalikan ke awal, jalankan di terminal:
  ```bash
  "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" -s 127.0.0.1:16384 shell pm clear com.example.masjid
  ```
- **Tombol Google** sudah terpasang (ID klien ada di `launch.json`) dan terbukti di Chrome.
  Selama aplikasi Google berstatus *Testing*, **hanya akun test user** (sekarang
  `fadhillah28.mff@gmail.com`) yang boleh masuk, dan butuh internet. Di emulator MuMu
  belum dicoba (butuh Google Play Services); untuk seminar demokan di **Chrome** (konfigurasi 2)
  atau lewati. **OTP** belum tersedia (butuh backend).
- **Demo mode server** (opsional): nyalakan PostgreSQL dan API dengan `scripts\postgres-mulai.bat`
  lalu `scripts\server-laravel.bat`, kemudian konfigurasi 3 atau 4 (`docs/PANDUAN_POSTGRESQL.md`).
  Layanan Windows PostgreSQL tidak mau start di komputer ini, jadi skrip itu perlu dijalankan
  setiap komputer dinyalakan.
- **Daftar** cukup nama, nomor telepon, dan kata sandi (tanpa email). Di mode lokal
  akun tersimpan di perangkat (kata sandi dalam bentuk hash), masuk dengan **nomor
  telepon**, dan tetap bisa dipakai setelah aplikasi ditutup. Email boleh diisi
  belakangan di Profil (opsional).
- **Daftar di mode server belum bisa**: server Laravel masih mewajibkan email, jadi
  pendaftaran dari aplikasi ditolak ("email wajib diisi."). Untuk demo mode server,
  pakai akun yang sudah ada atau login Google.

## 5. Bila ada masalah

| Gejala | Tindakan |
| --- | --- |
| Emulator tidak muncul / "Device not found" | Pastikan MuMu menyala; **Terminal → Run Task → "MuMu: sambungkan adb"**; bila masih gagal pakai konfigurasi 2 (Chrome) |
| Layar emulator miring (landscape) | Aplikasi dikunci tegak (potret): saat Murobi dibuka, layar MuMu ikut tegak dan banner tampil dengan proporsi benar |
| Build gagal soal Java / Gradle | Pastikan JDK 17 ada di `C:\Program Files\Java\jdk-17.0.4` (dipakai oleh `.vscode/settings.json` dan `launch.json`) |
| Pesan `errno = 1224` / berkas `.dart_tool` terkunci | Hentikan sesi debug lain (Shift+F5), tutup terminal yang menjalankan `flutter`, lalu ulangi |
| Saat build muncul `Parameter format not correct -` | Aman diabaikan: berasal dari skrip bawaan Flutter SDK 3.13 (perintah Windows `attrib`), tidak memengaruhi aplikasi |
| Saat build muncul `WARNING: [Processor] ... media2-session` atau `Note: Some input files use or override a deprecated API` | Aman diabaikan: peringatan dari pustaka pihak ketiga (audio), build tetap berhasil |
| Aplikasi putih / tidak merespons setelah lama | Hot restart (Ctrl+Shift+F5) atau jalankan ulang (F5) |
| Jadwal sholat kosong | Periksa internet, lalu ketuk ikon muat ulang di kartu jadwal (jadwal tersimpan dipakai otomatis bila ada) |

Tes otomatis dapat dijalankan dari **Terminal → Run Task → "Flutter: jalankan
semua tes"** (320 tes).
