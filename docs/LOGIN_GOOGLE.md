# Login dengan Google

Tombol **G** di halaman Masuk dan Daftar sudah tersambung. Agar bisa dipakai,
Anda perlu **ID klien OAuth** dari Google Cloud Console (gratis, memakai akun
Google Anda sendiri). ID itu tidak dapat dibuatkan dari luar, jadi tanpa ID
tersebut tombol hanya menampilkan pesan *"Login Google belum dikonfigurasi
(GOOGLE_CLIENT_ID belum diisi)"*.

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

## 2. Menyiapkan Google Cloud Console (sekali saja)

1. Buka <https://console.cloud.google.com/> → buat **Project** baru (mis. `murobi`).
2. **APIs & Services → OAuth consent screen**: pilih *External*, isi nama aplikasi
   dan email Anda. Biarkan status **Testing**, lalu tambahkan email yang akan
   dipakai mencoba/demo di **Test users** (selama Testing hanya akun itu yang
   boleh masuk).
3. **APIs & Services → Credentials → Create credentials → OAuth client ID**:
   1. Jenis **Web application**. Ini ID yang dipakai aplikasi dan server
      (`GOOGLE_CLIENT_ID`). Untuk mencoba di Chrome, isi
      **Authorized JavaScript origins** dengan `http://localhost:5555`
      (jalankan web dengan `--web-hostname localhost --web-port 5555`).
   2. Jenis **Android** (untuk emulator/HP): *Package name* `com.example.masjid`
      dan *SHA-1* sertifikat debug komputer ini:

      ```
      C2:4C:E1:25:4B:F8:44:23:DF:40:55:AB:38:D4:CB:24:77:54:1F:C2
      ```

      Dibaca dengan:
      ```bash
      "C:\Program Files\Java\jdk-17.0.4\bin\keytool.exe" -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android
      ```
      Untuk APK rilis, daftarkan juga SHA-1 kunci rilisnya.

   Aplikasi memakai ID **Web** sebagai `serverClientId` supaya Google
   mengeluarkan *id token*; ID **Android** hanya perlu terdaftar (tidak perlu
   disalin ke mana pun).

## 3. Menjalankan

Ganti `XXXX` dengan ID klien **Web** (berakhiran `.apps.googleusercontent.com`).

```bash
# Mode lokal, Chrome
flutter run -d chrome --web-hostname localhost --web-port 5555 --dart-define=GOOGLE_CLIENT_ID=XXXX

# Mode lokal, emulator/HP Android (JDK 17)
flutter run -d 127.0.0.1:16384 --dart-define=GOOGLE_CLIENT_ID=XXXX

# Mode server: tambahkan alamat server
flutter run -d 127.0.0.1:16384 --dart-define=GOOGLE_CLIENT_ID=XXXX --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

Di VS Code, tambahkan `"--dart-define=GOOGLE_CLIENT_ID=XXXX"` pada `args`
konfigurasi di `.vscode/launch.json`.

Server (mode server saja), di `Master-Admin/.env` milik Anda:

```
GOOGLE_CLIENT_ID=XXXX
# Beberapa ID dipisah koma: GOOGLE_CLIENT_ID=ID_WEB,ID_LAIN
# GOOGLE_AUTO_APPROVE=false     # opsional: akun baru Google tetap menunggu admin
```

lalu `php artisan config:clear`. Tanpa `GOOGLE_CLIENT_ID` di server, endpoint
menjawab 503 *"Login Google belum dikonfigurasi di server."*.

## 4. Catatan penting

- **Emulator MuMu** harus punya *Google Play Services* dan akun Google yang
  sudah masuk; sebagian citra emulator tidak memilikinya. Jika tombol G gagal di
  emulator, uji di Chrome atau HP asli. (Belum bisa saya pastikan untuk MuMu
  Anda tanpa ID klien.)
- Di web, Google hanya memberi *access token* (bukan id token). Server
  mendukung keduanya (`id_token` atau `access_token`).
- Setelah memilih "Keluar", sesi Google di aplikasi ikut ditutup sehingga
  pemilih akun muncul lagi pada percobaan berikutnya.

## 5. Yang sudah dan belum terbukti

| Bagian | Status |
| --- | --- |
| Aplikasi: alur lokal dan server, dibatalkan, belum dikonfigurasi, gagal, ketukan ganda | Teruji otomatis dengan Google tiruan (`test/google_test.dart`, 18 tes) |
| Server: akun baru, akun lama, status menunggu/ditolak, aud salah, email belum terverifikasi, token ditolak, tanpa client id, access token | Teruji otomatis dengan panggilan ke Google yang ditiru (`GoogleAuthApiTest`, 8 tes) |
| Dialog pemilih akun Google sungguhan dan token sungguhan dari Google | **Belum teruji** — butuh ID klien Anda dan akun Google |
