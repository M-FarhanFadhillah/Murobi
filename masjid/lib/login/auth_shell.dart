import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:masjid/common/app_theme.dart';

// Kerangka halaman Masuk dan Daftar (sesuai Figma): latar hijau berornamen,
// judul, tab Masuk/Daftar, dan kartu putih berisi formulir. Bila dibuka dari
// Profil, ada tombol kembali agar tamu bisa batal tanpa masuk.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.isLogin,
    required this.child,
  });

  final bool isLogin;
  final Widget child;

  void _openTab(BuildContext context, bool login) {
    if (login == isLogin) return;
    Navigator.of(context).pushReplacementNamed(login ? '/login' : '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.authBackground,
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            child: _Ornament(asset: 'assets/images/left.png', width: 190),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Transform.rotate(
              angle: math.pi,
              child: const _Ornament(
                asset: 'assets/images/left.png',
                width: 190,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Navigator.of(context).canPop())
                        Transform.translate(
                          offset: const Offset(-12, 0),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            tooltip: 'Kembali',
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppPalette.textDark,
                            ),
                          ),
                        ),
                      Text(
                        isLogin ? 'Masuk Akun' : 'Daftar Akun',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.textDark,
                        ),
                      ),
                      Text(
                        isLogin ? 'Selamat datang\nkembali' : 'Selamat datang',
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.3,
                          color: AppPalette.textDark,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Tab di belakang, kartu di depan. Tab yang tidak aktif
                      // (putih pudar) memanjang ke bawah kartu sehingga warnanya
                      // mengisi celah di balik sudut kartu yang membulat.
                      Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _AuthTab(
                                  label: 'Masuk',
                                  selected: isLogin,
                                  onTap: () => _openTab(context, true),
                                ),
                              ),
                              Expanded(
                                child: _AuthTab(
                                  label: 'Daftar',
                                  selected: !isLogin,
                                  onTap: () => _openTab(context, false),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: _AuthTab.height),
                            child: Container(
                              key: const ValueKey('auth-card'),
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(24, 24, 24, 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(
                                    isLogin ? 0 : _AuthTab.cardRadius,
                                  ),
                                  topRight: Radius.circular(
                                    isLogin ? _AuthTab.cardRadius : 0,
                                  ),
                                  bottomLeft: const Radius.circular(20),
                                  bottomRight: const Radius.circular(20),
                                ),
                                boxShadow: AppPalette.softShadow,
                              ),
                              child: child,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ornament extends StatelessWidget {
  const _Ornament({required this.asset, required this.width});

  final String asset;
  final double width;

  @override
  Widget build(BuildContext context) {
    // Ornamen emas dibuat transparan agar menyatu dengan latar.
    return Opacity(
      opacity: 0.4,
      child: Image.asset(asset, width: width),
    );
  }
}

class _AuthTab extends StatelessWidget {
  const _AuthTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  // Tinggi bagian tab yang terlihat di atas kartu.
  static const double height = 48;

  // Radius sudut atas kartu di sisi tab yang tidak aktif. Tab tidak aktif
  // memanjang sejauh ini ke belakang kartu untuk mengisi celah sudutnya.
  static const double cardRadius = 20;

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: selected ? height : height + cardRadius,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.35),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SizedBox(
          height: height,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppPalette.textDark : AppPalette.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Kolom isian bergaris bawah (gaya Figma).
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppPalette.textMuted, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppPalette.primary),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppPalette.primary, width: 2),
        ),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppPalette.textDark,
                ),
              ),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 4,
        shadowColor: AppPalette.primary.withOpacity(0.5),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
    );
  }
}

// Pemisah "atau" dan tombol Google (Facebook sudah dihapus).
class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({
    super.key,
    required this.onGoogle,
    this.loading = false,
  });

  final VoidCallback onGoogle;

  // True selama menunggu akun Google dipilih/diperiksa.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
        const Text('atau', style: TextStyle(color: AppPalette.textMuted)),
        const SizedBox(height: 10),
        InkWell(
          onTap: loading ? null : onGoogle,
          customBorder: const CircleBorder(),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
              boxShadow: AppPalette.softShadow,
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const FaIcon(
                      FontAwesomeIcons.google,
                      size: 22,
                      color: Color(0xFFDB4437),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
