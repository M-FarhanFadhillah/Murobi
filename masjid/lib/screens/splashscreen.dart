import 'package:flutter/material.dart';
import 'dart:async';
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

  // Splash tampil minimal 2 detik lalu selalu membuka Beranda: aplikasi bisa
  // dipakai tanpa akun (mis. jamaah lansia). Sesi yang tersimpan dipulihkan
  // lebih dulu, jadi pengguna yang pernah masuk tetap masuk. Masuk/daftar ada
  // di halaman Profil.
  Future<void> _continue() async {
    final service = widget.accountService ?? AccountService.instance;
    final restoring = service.restore();
    await Future<void>.delayed(const Duration(seconds: 2));
    await restoring;
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/dashboard');
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
