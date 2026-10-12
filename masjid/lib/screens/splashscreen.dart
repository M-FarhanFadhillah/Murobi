import 'package:flutter/material.dart';
import 'dart:async';
import 'package:masjid/login/login.dart';
import 'package:masjid/services/account_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.accountService});

  // Dapat diganti saat pengujian; bawaannya AccountService.instance.
  final AccountService? accountService;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  // Splash tampil minimal 2 detik. Dengan server, sesi yang tersimpan dipulihkan
  // lebih dulu: berhasil -> beranda, selain itu -> halaman masuk.
  Future<void> _continue() async {
    final service = widget.accountService ?? AccountService.instance;
    final restoring = service.restore();
    await Future<void>.delayed(const Duration(seconds: 2));
    final restored = await restoring;
    if (!mounted) return;

    if (restored) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginWidget()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: const Color(0xFF99D399),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: const Color(0x4d9e9e9e), width: 1),
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              ///***If you have exported images you must have to copy those images in assets/images directory.
              Image(
                image: AssetImage("assets/images/SplashScreen.png"),
                height: 250,
                width: 250,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
