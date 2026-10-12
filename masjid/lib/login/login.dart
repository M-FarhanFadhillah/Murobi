import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/login/auth_shell.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/api_auth_service.dart';

// Halaman Masuk (sesuai Figma "Masuk Akun"). Tanpa alamat server memakai akun
// dummy; dengan server, masuk lewat API.
class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key, this.accountService});

  // Dapat diganti saat pengujian; bawaannya AccountService.instance.
  final AccountService? accountService;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiAuthService _authService = ApiAuthService();
  late final AccountService _account =
      widget.accountService ?? AccountService.instance;

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ID/email/nomor HP dan kata sandi dicocokkan dengan akun dummy atau server.
  Future<void> _onSignIn() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    final result =
        await _account.signIn(_idController.text, _passwordController.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (result.ok) {
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_) => false);
    } else {
      _snack(result.error!);
    }
  }

  Future<void> _onGoogleSignIn() async {
    try {
      final ok = await _authService.signInWithGoogle();
      if (!mounted) return;
      if (ok) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/dashboard', (_) => false);
      } else {
        _snack('Login Google dibatalkan atau gagal.');
      }
    } catch (_) {
      if (!mounted) return;
      _snack('Login Google belum dikonfigurasi.');
    }
  }

  // Alur lupa kata sandi (sesuai Figma). Sementara belum mengirim email sungguhan.
  Future<void> _showForgotPassword() async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => const _ForgotPasswordDialog(),
    );
    if (sent != true) return;
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppPalette.primary, size: 56),
            SizedBox(height: 12),
            Text(
              'Link verifikasi berhasil dikirim.\nSilahkan periksa email Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      isLogin: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthField(
              label: 'ID / Email / No. Telepon',
              controller: _idController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'ID wajib diisi'
                  : null,
            ),
            const SizedBox(height: 8),
            AuthField(
              label: 'Kata sandi',
              controller: _passwordController,
              obscure: _obscure,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSignIn(),
              validator: (value) => (value ?? '').isEmpty
                  ? 'Kata sandi wajib diisi'
                  : null,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _showForgotPassword,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: const Text(
                  'Lupa kata sandi',
                  style: TextStyle(color: AppPalette.link, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AuthPrimaryButton(
              label: 'Masuk',
              loading: _loading,
              onPressed: _onSignIn,
            ),
            AuthSocialRow(onGoogle: _onGoogleSignIn),
            const SizedBox(height: 18),
            Center(
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed('/signup'),
                child: const Text.rich(
                  TextSpan(
                    text: 'Belum punya akun? ',
                    style: TextStyle(fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Daftar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Petunjuk akun dummy; tidak relevan saat memakai server.
            if (!_account.remote)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppPalette.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Akun demo\nJamaah: jamaah / jamaah123\nAdmin: admin / admin123',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppPalette.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Dialog "Masukkan Email/nomor yang terdaftar". Controller dimiliki dialog ini
// supaya dibuang bersamaan dengan dialognya (setelah animasi tutup selesai).
class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog();

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final TextEditingController _controller = TextEditingController();

  bool get _filled => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Masukkan Email/nomor yang terdaftar',
        style: TextStyle(fontSize: 16),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppPalette.primary, width: 2),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actions: [
        SizedBox(
          width: 180,
          child: ElevatedButton(
            onPressed: _filled ? () => Navigator.pop(context, true) : null,
            child: const Text('Kirim'),
          ),
        ),
      ],
    );
  }
}
