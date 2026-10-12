import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:masjid/screens/splashscreen.dart';

// Uji asap: aplikasi dimulai dari splash lalu berpindah ke halaman login.
void main() {
  testWidgets('splash screen berpindah ke halaman login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('Masuk Akun'), findsNothing);

    // Splash menunggu 2 detik sebelum membuka halaman login.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Masuk Akun'), findsOneWidget);
  });
}
