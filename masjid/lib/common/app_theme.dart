import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Palet warna Murobi. Dipakai di semua halaman supaya tampilannya seirama.
class AppPalette {
  AppPalette._();

  static const Color primary = Color(0xFF0F8A3C);
  static const Color primaryDark = Color(0xFF0B3A0E);
  static const Color teal = Color(0xFF1FA89A);
  static const Color gold = Color(0xFFFFC266);
  static const Color lime = Color(0xFFD7F55A);

  // Latar halaman: gradien mint ke biru muda (sesuai Figma).
  static const Color mint = Color(0xFFBFF5C6);
  static const Color sky = Color(0xFFBBD6FF);

  // Latar halaman login/daftar dan splash.
  static const Color authBackground = Color(0xFF99D399);

  static const Color textDark = Color(0xFF12281A);
  static const Color textMuted = Color(0xFF5F6F65);
  static const Color link = Color(0xFF1E5BD8);
  static const Color danger = Color(0xFFD64545);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [mint, sky],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, teal],
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: primaryDark.withOpacity(0.14),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];
}

// Font untuk huruf Latin bertanda pada transliterasi Al-Qur'an (ā ī ū ḍ ḥ ṣ ṭ ẓ).
// Poppins tidak memuat ḍ ḥ ṣ ṭ ẓ ṡ; tanpa font cadangan, huruf itu tampil
// sebagai kotak di perangkat yang tidak punya font sistem pengganti (mis.
// emulator MuMu). Font ini disertakan di aplikasi (assets/fonts/) supaya
// tampil benar juga tanpa internet.
class AppFonts {
  AppFonts._();

  static const String latinExtended = 'RobotoStatic';
  static const List<String> latinFallback = [latinExtended];
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.primary,
        primary: AppPalette.primary,
      ),
      useMaterial3: false,
    );
    return base.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      primaryColor: AppPalette.primary,
      scaffoldBackgroundColor: Colors.white,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppPalette.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
    );
  }
}
