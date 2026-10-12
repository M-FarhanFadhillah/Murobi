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

1. **Masuk sebagai jamaah** → Beranda: jam, jadwal sholat, banner, pilih masjid, kegiatan masjid.
2. **Edukasi**: kategori, buka artikel, buka video lalu "Tonton Video" (membuka YouTube).
3. **Al-Qur'an**: daftar surah, Juz, Bookmark; buka surah, zoom, mode "Arab saja", putar bacaan.
4. **Profil**: ubah data, ganti foto dari galeri, ubah kata sandi, keluar.
5. **Laporan masalah**: sebagai jamaah buka Profil → **Laporkan Permasalahan**, tulis
   laporan, kirim. Keluar, masuk sebagai admin → Profil → **Laporan Masalah Jamaah**: laporan tadi muncul; coba **Tandai selesai** dan hapus.
6. **Masuk sebagai admin** → Profil → **Kelola Kegiatan Masjid** (unggah dan geser-hapus poster).
7. **Edukasi** sebagai admin: **Tambah materi** (artikel dengan sampul, atau video dengan tautan YouTube), ubah, hapus.

## 4. Yang perlu disiapkan sebelum seminar

- **Internet.** Jadwal sholat diambil dari internet setiap Beranda dibuka dan
  belum punya cadangan offline (tanpa internet muncul "Jadwal sholat belum
  tersedia"). Al-Qur'an tersimpan di perangkat setelah sebuah surah dibuka
  sekali; bacaan audio, gambar mini dan pemutaran YouTube butuh internet.
  Siapkan hotspot HP sebagai cadangan.
- **Buka sekali** surah yang akan didemokan saat ada internet.
- **Gambar untuk diunggah.** Taruh beberapa gambar poster di galeri MuMu
  (seret berkasnya ke jendela MuMu).
- **Data bersih.** Perubahan admin (kegiatan, materi) dan foto profil tersimpan
  di emulator. Untuk mengembalikan ke awal, jalankan di terminal:
  ```bash
  "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" -s 127.0.0.1:16384 shell pm clear com.example.masjid
  ```
- **Tombol Google** hanya berfungsi bila ID klien Google sudah dipasang
  (`docs/LOGIN_GOOGLE.md`) dan butuh internet; bila belum, ia menampilkan pesan
  "belum dikonfigurasi". **OTP** belum tersedia (butuh backend). Jangan didemokan
  bila belum disiapkan.
- Akun yang dibuat lewat **Daftar** di mode lokal hanya hidup selama aplikasi terbuka.

## 5. Bila ada masalah

| Gejala | Tindakan |
| --- | --- |
| Emulator tidak muncul / "Device not found" | Pastikan MuMu menyala; **Terminal → Run Task → "MuMu: sambungkan adb"**; bila masih gagal pakai konfigurasi 2 (Chrome) |
| Layar emulator miring (landscape) | Putar lewat pengaturan MuMu; ukuran layar emulator bisa berubah antar-sesi, itu normal |
| Build gagal soal Java / Gradle | Pastikan JDK 17 ada di `C:\Program Files\Java\jdk-17.0.4` (dipakai oleh `.vscode/settings.json` dan `launch.json`) |
| Pesan `errno = 1224` / berkas `.dart_tool` terkunci | Hentikan sesi debug lain (Shift+F5), tutup terminal yang menjalankan `flutter`, lalu ulangi |
| Aplikasi putih / tidak merespons setelah lama | Hot restart (Ctrl+Shift+F5) atau jalankan ulang (F5) |
| Jadwal sholat kosong | Periksa internet, lalu ketuk ikon muat ulang di kartu jadwal |

Tes otomatis dapat dijalankan dari **Terminal → Run Task → "Flutter: jalankan
semua tes"** (253 tes).
