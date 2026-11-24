import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/screens/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Uji asap: aplikasi dimulai dari splash lalu langsung ke beranda (tanpa harus
// masuk; masuk/daftar ada di Profil).
void main() {
  testWidgets('splash screen langsung berpindah ke beranda', (tester) async {
    // Perangkat baru: belum ada sesi tersimpan.
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      home: const SplashScreen(),
      routes: {'/dashboard': (_) => const Scaffold(body: Text('DASHBOARD'))},
    ));
    expect(find.text('DASHBOARD'), findsNothing);

    // Splash menunggu 2 detik sebelum membuka beranda.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('DASHBOARD'), findsOneWidget);
    expect(find.text('Masuk Akun'), findsNothing);
  });
}
