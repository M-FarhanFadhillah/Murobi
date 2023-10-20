import 'package:flutter/material.dart';
import 'package:masjid/screens/dashboard.dart';
import 'package:masjid/screens/splashscreen.dart';
import 'package:masjid/screens/ziswaf/zakat_pages.dart';
import 'package:masjid/screens/profile/profile_pages.dart';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
    routes: {
      '/dashboard': (context) => Dashboard(),
      '/zakatPage': (context) => DetailZiswafPages(),
      '/profile': (context) => ProfilePages(),
    },
  ));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(), // Gunakan SplashScreenPage sebagai halaman awal
    );
  }

  static of(BuildContext context) {}
}
