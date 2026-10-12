# Login dengan Google

**Status: berfungsi dan terbukti dengan akun Google sungguhan (12 Oktober 2026)**, baik mode
lokal maupun mode server (aplikasi → Laravel → PostgreSQL). Tombol **G** ada di halaman Masuk
dan Daftar.

## 1. Cara kerja

| Mode | Yang terjadi setelah memilih akun Google |
| --- | --- |
| **Lokal** (tanpa `API_BASE_URL`) | Nama, email, dan foto dari akun Google dipakai langsung sebagai akun **jamaah** di perangkat. Tidak ada server. Akunnya hanya hidup selama aplikasi terbuka. |
| **Server** (dengan `API_BASE_URL`) | Aplikasi mengirim token Google ke `POST /api/auth/google`. **Server memeriksa token itu langsung ke Google** (bukan percaya begitu saja pada aplikasi), lalu mencocokkan akun lewat email. Bila belum ada, akun jamaah dibuat dan langsung aktif. Token sesi Murobi dikembalikan seperti login biasa. |

Aturan di server (`Master-Admin/app/Http/Controllers/Api/AuthController.php`,
`app/Support/GoogleIdentity.php`):

- Token harus berasal dari ID klien milik Anda (`aud` cocok) dan email harus
  sudah terverifikasi oleh Google. Token dari aplikasi lain ditolak (401).
- Email sudah terdaftar → masuk ke akun itu (termasuk bila itu akun admin).
  Status akun tetap dihormati: *menunggu* atau *ditolak* tidak bisa masuk (403).
- Akun baru dari Google berstatus aktif. Agar tetap harus disetujui admin,
  isi `GOOGLE_AUTO_APPROVE=false` di `.env`.
- Akun Google belum punya nomor HP. Kolom `users.no_hp` wajib dan unik, jadi
  disimpan nilai pengganti `google:<id>` yang **tidak ditampilkan** (aplikasi
  melihat nomor kosong). Jamaah mengisi nomor aslinya lewat Profil → EDIT.
- Kata sandi akun baru acak dan tidak diketahui siapa pun: akun itu hanya bisa
  dimasuki lewat Google.

## 2. Konfigurasi yang sudah dibuat (Google Cloud project `murobi`)

Dibuat lewat Google Cloud Console dengan akun `fadhillah28.mff@gmail.com`:

| Bagian | Nilai |
| --- | --- |
| Project | `murobi` |
| Layar persetujuan | Nama aplikasi *Murobi*, audience **External**, status **Testing** |
| Test users | `fadhillah28.mff@gmail.com` (selama Testing **hanya** akun yang terdaftar di sini yang boleh masuk; tambah akun lain di *Google Auth Platform → Audience → Test users*) |
| Klien OAuth **Web** `Murobi Web` | ID: `11242990333-blv88asbo5hru9fhrmjqhn5meoga07k2.apps.googleusercontent.com`. Authorized JavaScript origin: `http://localhost:5555` |
| Klien OAuth **Android** `Murobi Android (debug)` | Package `com.example.masjid`, SHA-1 sertifikat debug komputer ini: `C2:4C:E1:25:4B:F8:44:23:DF:40:55:AB:38:D4:CB:24:77:54:1F:C2` |
| API yang diaktifkan | **Google People API** (wajib untuk login di web: plugin `google_sign_in_web` memanggilnya untuk mengambil nama/email) |

ID klien bukan rahasia (ia terlihat di aplikasi); rahasia klien tidak dipakai dan tidak disimpan.
Aplikasi memakai ID **Web** sebagai `serverClientId` di Android supaya Google mengeluarkan *id token*;
klien **Android** hanya perlu terdaftar.

Tempat ID dipasang:

- `masjid/.vscode/launch.json`: keempat konfigurasi sudah berisi `--dart-define=GOOGLE_CLIENT_ID=…`;
  konfigurasi Chrome memakai `--web-hostname=localhost --web-port=5555` (harus **persis** sama
  dengan *origin* yang didaftarkan).
- `Master-Admin/.env`: baris `GOOGLE_CLIENT_ID=…` (ditambahkan; berkas itu tidak ikut git).

Untuk APK **rilis** daftarkan juga SHA-1 kunci rilis pada klien Android baru, dan untuk domain
server sungguhan tambahkan sebagai *Authorized JavaScript origin*. Untuk dipakai orang banyak,
status aplikasi harus dipublikasikan (*Publish app*) dan melalui verifikasi Google bila
meminta cakupan sensitif; cakupan `email`/`profile` yang dipakai di sini tidak sensitif.

## 3. Menjalankan

```bash
# Mode lokal, Chrome
flutter run -d chrome --web-hostname localhost --web-port 5555 --dart-define=GOOGLE_CLIENT_ID=<ID web>

# Mode lokal, emulator/HP Android (JDK 17)
flutter run -d 127.0.0.1:16384 --dart-define=GOOGLE_CLIENT_ID=<ID web>

# Mode server: tambahkan alamat server
flutter run -d 127.0.0.1:16384 --dart-define=GOOGLE_CLIENT_ID=<ID web> --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Lebih mudah: pakai konfigurasi VS Code (F5), semuanya sudah terisi.

Server: `GOOGLE_CLIENT_ID` di `Master-Admin/.env` (boleh beberapa ID dipisah koma) lalu
`php artisan config:clear`. Tanpa itu endpoint menjawab 503
*"Login Google belum dikonfigurasi di server."*.

## 4. Catatan penting

- **Popup.** Di web, Google membuka jendela popup; pilih akun lalu *Continue*.
  Selama popup terbuka tombol G menampilkan indikator memuat.
- **Emulator MuMu** harus punya *Google Play Services* dan akun Google yang sudah masuk; sebagian
  citra emulator tidak memilikinya. **Login Google di Android/MuMu belum dicoba** (yang terbukti
  adalah di web/Chrome). Bila gagal di emulator, uji di Chrome atau HP asli.
- Di web, Google hanya memberi *access token* (bukan id token); server mendukung keduanya
  (`id_token` atau `access_token`).
- Pada uji di web, foto profil Google tidak tampil (kemungkinan pembatasan CORS gambar Google
  pada CanvasKit; penyebab pastinya belum diselidiki). Nama dan email tampil normal.
- Setelah "Keluar", sesi Google di aplikasi ikut ditutup sehingga pemilih akun muncul lagi.
- Pada mode debug, penyebab asli kegagalan login Google dicatat di konsol (`Login Google gagal: …`);
  pengguna hanya melihat pesan umum.

## 5. Bukti pengujian

| Bagian | Status |
| --- | --- |
| Aplikasi: alur lokal dan server, dibatalkan, belum dikonfigurasi, gagal, ketukan ganda | Teruji otomatis dengan Google tiruan (`test/google_test.dart`, 18 tes) |
| Server: akun baru, akun lama, status menunggu/ditolak, aud salah, email belum terverifikasi, token ditolak, tanpa client id, access token | Teruji otomatis dengan panggilan ke Google yang ditiru (`GoogleAuthApiTest`, 8 tes) |
| **Chrome, mode lokal, akun Google sungguhan** | Berhasil: masuk ke Beranda; Profil terisi nama dan email dari Google, nomor kosong |
| **Chrome, mode server (Laravel + PostgreSQL asli), akun Google sungguhan** | Berhasil: server memeriksa access token ke Google, membuat akun jamaah (`status=1`, bukan admin, `no_hp` pengganti `google:…`, kata sandi acak ter-hash), Beranda memuat data masjid dari PostgreSQL. Akun uji itu dihapus lagi setelah pengecekan |
| Token palsu ke server | 401 "Akun Google tidak dapat diverifikasi." (server menghubungi Google; bukan 503) |
| Android / emulator MuMu / HP fisik | **Belum diuji** |

Temuan selama uji: kegagalan pertama disebabkan **People API belum aktif** di project (plugin web
memanggilnya setelah token diterbitkan); pesan umum aplikasi menyembunyikannya, sehingga log
debug ditambahkan. Kegagalan kedua adalah server uji PHP satu utas (lihat
`docs/PANDUAN_POSTGRESQL.md`, P-5), bukan Google.
