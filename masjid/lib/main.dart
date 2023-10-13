import 'package:flutter/material.dart';
import 'package:masjid/screens/dashboard.dart';
import 'package:masjid/screens/splashscreen.dart';

void main() {
  runApp(MaterialApp(
    home: SplashScreen(),
    routes: {
      '/dashboard': (context) => Dashboard(),
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
}