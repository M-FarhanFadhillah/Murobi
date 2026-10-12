import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Akun Google yang dipilih pengguna. Salah satu dari [idToken] (Android/iOS)
// atau [accessToken] (web) dikirim ke server untuk diperiksa ke Google.
class GoogleProfile {
  const GoogleProfile({
    required this.email,
    required this.name,
    this.photoUrl,
    this.idToken,
    this.accessToken,
  });

  final String email;
  final String name;
  final String? photoUrl;
  final String? idToken;
  final String? accessToken;
}

// ID klien Google belum diisi (lihat docs/LOGIN_GOOGLE.md).
class GoogleNotConfigured implements Exception {
  const GoogleNotConfigured();
}

// Pembungkus google_sign_in supaya mudah diganti saat pengujian.
abstract class GoogleAuthClient {
  // null jika pengguna membatalkan. Melempar [GoogleNotConfigured] bila ID
  // klien belum diisi, dan error lain bila Google/jaringan bermasalah.
  Future<GoogleProfile?> signIn();

  Future<void> signOut();
}

// Konfigurasi lewat --dart-define=GOOGLE_CLIENT_ID=<ID klien OAuth "Web">.
// ID yang sama dipakai server (GOOGLE_CLIENT_ID di .env Laravel) untuk
// memeriksa token. Di Android ID ini menjadi serverClientId agar Google
// mengeluarkan id token; di web ia menjadi clientId.
class GoogleConfig {
  GoogleConfig._();

  static const String clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  static bool get configured => clientId.trim().isNotEmpty;
}

class DeviceGoogleAuth implements GoogleAuthClient {
  GoogleSignIn? _signIn;

  GoogleSignIn _client() {
    if (!GoogleConfig.configured) throw const GoogleNotConfigured();
    final id = GoogleConfig.clientId.trim();
    return _signIn ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      clientId: kIsWeb ? id : null,
      serverClientId: kIsWeb ? null : id,
    );
  }

  @override
  Future<GoogleProfile?> signIn() async {
    final client = _client();
    // Memaksa pemilih akun muncul lagi (bukan langsung memakai akun terakhir).
    await client.signOut().catchError((_) => null);
    final account = await client.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    if ((auth.idToken ?? auth.accessToken) == null) {
      throw StateError('Google tidak mengembalikan token.');
    }
    return GoogleProfile(
      email: account.email,
      name: (account.displayName ?? '').trim(),
      photoUrl: account.photoUrl,
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
  }

  @override
  Future<void> signOut() async {
    if (!GoogleConfig.configured) return;
    try {
      await _client().signOut();
    } catch (_) {
      // Tidak ada sesi Google yang perlu ditutup.
    }
  }
}
