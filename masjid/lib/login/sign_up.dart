import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/validators.dart';
import 'package:masjid/login/auth_shell.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';

// Halaman Daftar (sesuai Figma "Daftar Akun"), cukup nama, nomor telepon, dan
// kata sandi; tanpa email. Tanpa alamat server akun disimpan di perangkat dan
// dipakai masuk dengan nomor telepon; dengan server, akun didaftarkan lewat API
// dan menunggu persetujuan admin.
class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key, this.accountService});

  // Dapat diganti saat pengujian; bawaannya AccountService.instance.
  final AccountService? accountService;

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  late final AccountService _account =
      widget.accountService ?? AccountService.instance;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSignUp() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final result = await _account.signUp(
      nama: _namaController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.ok) {
      _snack(result.error!);
      return;
    }

    // Messenger diambil sebelum berpindah halaman agar pesan tampil di halaman
    // masuk.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pushReplacementNamed('/login');
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(result.message ?? 'Akun dibuat.')));
  }

  // Halaman ini dibuka dari Profil: setelah berhasil, tutup dan kembali ke
  // Profil (yang langsung menampilkan akun). Bila menjadi halaman pertama,
  // buka Beranda.
  void _finish() {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nama = AuthSession.current?.nama;
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushNamedAndRemoveUntil('/dashboard', (_) => false);
    }
    if (nama != null && nama.isNotEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Selamat datang, $nama.')));
    }
  }

  // Daftar dengan Google sama dengan masuk: akun dibuat bila belum ada.
  Future<void> _onGoogleSignUp() async {
    if (_googleLoading || _loading) return;
    setState(() => _googleLoading = true);

    final result = await _account.signInWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoading = false);

    if (result.ok) {
      _finish();
    } else {
      _snack(result.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      isLogin: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              label: 'Nama',
              controller: _namaController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              validator: Validators.nama,
            ),
            AuthField(
              label: 'No. Telepon',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: Validators.phone,
            ),
            AuthField(
              label: 'Kata sandi',
              controller: _passwordController,
              obscure: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              textInputAction: TextInputAction.next,
              validator: Validators.password,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6, bottom: 2),
              child: Text(
                '*Kata sandi min 8 karakter\n'
                '*Menggunakan huruf besar dan kecil\n'
                '*Menggunakan minimal 1 angka dan 1 simbol',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: AppPalette.danger,
                ),
              ),
            ),
            AuthField(
              label: 'Konfirmasi kata sandi',
              controller: _confirmController,
              obscure: _obscureConfirm,
              onToggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSignUp(),
              validator: (value) => value != _passwordController.text
                  ? 'Konfirmasi kata sandi tidak sama'
                  : null,
            ),
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: 'Daftar',
              loading: _loading,
              onPressed: _onSignUp,
            ),
            AuthSocialRow(onGoogle: _onGoogleSignUp, loading: _googleLoading),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text.rich(
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: TextStyle(fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Masuk',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
