// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:masjid/screens/dashboard.dart';
import 'package:masjid/screens/splashscreen.dart';
import 'package:masjid/screens/ziswaf/zakat_pages.dart';
import 'package:masjid/screens/profile/profile_pages.dart';
import 'package:masjid/login/login.dart';
import 'package:masjid/login/sign_up.dart';

void main() {
  runApp(MaterialApp(
    home: const SplashScreen(),
    routes: {
      '/dashboard': (context) => const Dashboard(),
      '/zakatPage': (context) => const DetailZiswafPages(),
      '/profilepages': (context) => ProfilePages(),
      '/login': (context) => LoginWidget(),
      '/signup': (context) => SignUpWidget()
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: SplashScreen());
  }

  static of(BuildContext context) {}
}