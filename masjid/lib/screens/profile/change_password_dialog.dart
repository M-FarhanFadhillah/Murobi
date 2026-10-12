import 'package:flutter/material.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/validators.dart';
import 'package:masjid/services/account_service.dart';

// Dialog "Ubah Kata Sandi". Mengembalikan true jika kata sandi berhasil diubah.
// Controller dimiliki dialog ini supaya dibuang bersamaan dengan dialognya.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key, this.accountService});

  // Dapat diganti saat pengujian; bawaannya AccountService.instance.
  final AccountService? accountService;

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _serverError;
  bool _saving = false;

  late final AccountService _account =
      widget.accountService ?? AccountService.instance;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _serverError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final result = await _account.changePassword(
      oldPassword: _oldController.text,
      newPassword: _newController.text,
    );
    if (!mounted) return;

    if (!result.ok) {
      setState(() {
        _saving = false;
        _serverError = result.error;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  InputDecoration _decoration({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppPalette.primary, width: 2),
      ),
      suffixIcon: IconButton(
        onPressed: onToggle,
        tooltip: obscure ? 'Tampilkan' : 'Sembunyikan',
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Ubah Kata Sandi'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _oldController,
                obscureText: _obscureOld,
                autofocus: true,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    Validators.required(value, 'Kata sandi lama'),
                decoration: _decoration(
                  label: 'Kata sandi lama',
                  obscure: _obscureOld,
                  onToggle: () => setState(() => _obscureOld = !_obscureOld),
                  errorText: _serverError,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
                decoration: _decoration(
                  label: 'Kata sandi baru',
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6, bottom: 2),
                child: Text(
                  '*Minimal 8 karakter\n'
                  '*Huruf besar dan kecil\n'
                  '*Minimal 1 angka dan 1 simbol',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppPalette.danger,
                  ),
                ),
              ),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) => value != _newController.text
                    ? 'Konfirmasi kata sandi tidak sama'
                    : null,
                decoration: _decoration(
                  label: 'Ulangi kata sandi baru',
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          style: FilledButton.styleFrom(backgroundColor: AppPalette.primary),
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
