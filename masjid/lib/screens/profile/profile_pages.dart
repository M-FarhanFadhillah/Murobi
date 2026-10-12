import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masjid/common/app_theme.dart';
import 'package:masjid/common/app_widgets.dart';
import 'package:masjid/common/image_source_sheet.dart';
import 'package:masjid/common/validators.dart';
import 'package:masjid/screens/kegiatan/kegiatan_masjid_page.dart';
import 'package:masjid/screens/profile/change_password_dialog.dart';
import 'package:masjid/services/account_service.dart';
import 'package:masjid/services/auth_session.dart';
import 'package:masjid/services/profile_store.dart';

// Halaman Profil (sesuai Figma "Profil" dan "edit foto profil"): data diri,
// ubah data, ubah foto, bahasa, laporan masalah, dan keluar.
class ProfilePages extends StatefulWidget {
  const ProfilePages({super.key, this.accountService});

  // Dapat diganti saat pengujian; bawaannya AccountService.instance.
  final AccountService? accountService;

  @override
  State<ProfilePages> createState() => _ProfilePagesState();
}

class _ProfilePagesState extends State<ProfilePages> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final ProfileStore _store = ProfileStore.instance;
  late final AccountService _account =
      widget.accountService ?? AccountService.instance;
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _startEditing() {
    _namaController.text = _store.nama;
    _emailController.text = _store.email;
    _phoneController.text = _store.phone;
    setState(() => _editing = true);
  }

  void _cancelEditing() {
    FocusScope.of(context).unfocus();
    setState(() => _editing = false);
  }

  // Sesi berakhir (token ditolak server): kembali ke halaman masuk.
  bool _leaveIfSignedOut() {
    if (AuthSession.current != null) return false;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    return true;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() => _saving = true);
    final result = await _account.updateProfile(
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (!result.ok) {
      _snack(result.error!);
      _leaveIfSignedOut();
      return;
    }
    setState(() => _editing = false);
    _snack('Profil berhasil diperbarui.');
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 80,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final result = await _account.updatePhoto(bytes);
      if (!mounted) return;
      if (!result.ok) {
        _snack(result.error!);
        _leaveIfSignedOut();
        return;
      }
      _snack('Foto profil diperbarui.');
    } catch (_) {
      if (!mounted) return;
      _snack('Foto tidak dapat diambil. Periksa izin kamera atau galeri.');
    }
  }

  Future<void> _changePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => ChangePasswordDialog(accountService: _account),
    );
    if (!mounted) return;
    if (changed != true) {
      // Sesi bisa berakhir selagi dialog terbuka.
      _leaveIfSignedOut();
      return;
    }
    _snack('Kata sandi berhasil diubah.');
  }

  // Pilihan sumber foto (sesuai Figma "Ubah foto profil").
  Future<void> _changePhoto() async {
    final source = await showImageSourceSheet(
      context,
      title: 'Ubah foto profil',
    );
    if (source == null) return;
    await _pickPhoto(source);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari akun?'),
        content: const Text('Anda perlu masuk lagi untuk memakai aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppPalette.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!mounted) return;

    await _account.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: _store,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Profil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.primaryDark,
                    ),
                  ),
                ),
                _buildPhotoCard(),
                const SizedBox(height: 14),
                _buildDataCard(),
                const SizedBox(height: 14),
                _buildLanguageCard(),
                const SizedBox(height: 14),
                _buildMenuCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoCard() {
    final photo = _store.photoImage;

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  gradient: AppPalette.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: const Color(0xFFE3EEE6),
                  backgroundImage: photo,
                  onBackgroundImageError: photo == null ? null : (_, __) {},
                  child: photo == null
                      ? const Icon(
                          Icons.person,
                          size: 76,
                          color: AppPalette.textMuted,
                        )
                      : null,
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Material(
                  color: AppPalette.primary,
                  shape: const CircleBorder(
                    side: BorderSide(color: Colors.white, width: 3),
                  ),
                  child: InkWell(
                    onTap: _changePhoto,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _store.nama,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppPalette.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: AppPalette.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AuthSession.current?.roleLabel ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard() {
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileField(
              label: 'Nama',
              value: _store.nama,
              controller: _namaController,
              editing: _editing,
              keyboardType: TextInputType.name,
              validator: Validators.nama,
            ),
            _ProfileField(
              label: 'Email',
              value: _store.email,
              controller: _emailController,
              editing: _editing,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            _ProfileField(
              label: 'Nomor handphone',
              value: _store.phone,
              controller: _phoneController,
              editing: _editing,
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  Validators.phone(value, label: 'Nomor handphone'),
            ),
            const SizedBox(height: 4),
            if (_editing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _cancelEditing,
                    child: const Text('BATAL'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('SIMPAN'),
                  ),
                ],
              )
            else
              Row(
                children: [
                  // Mengisi sisa lebar dan boleh menyempit (teks turun baris),
                  // supaya tidak meluap pada layar sempit atau huruf besar.
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _changePassword,
                        child: const Text(
                          'Ubah Kata Sandi',
                          style: TextStyle(
                            color: AppPalette.link,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _startEditing,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('EDIT'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bahasa', style: TextStyle(color: AppPalette.textMuted)),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.translate_rounded, color: AppPalette.primaryDark),
              SizedBox(width: 10),
              Text(
                'Bahasa Indonesia',
                style: TextStyle(
                  color: AppPalette.link,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          if (AuthSession.canManageContent) ...[
            ListTile(
              leading: const Icon(
                Icons.event_note_outlined,
                color: AppPalette.primaryDark,
              ),
              title: const Text('Kelola Kegiatan Masjid'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KegiatanMasjidPage()),
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
          ],
          ListTile(
            leading: const Icon(
              Icons.flag_outlined,
              color: AppPalette.primaryDark,
            ),
            title: const Text('Laporkan Permasalahan'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.pushNamed(context, '/reportproblem'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppPalette.danger),
            title: const Text(
              'Keluar',
              style: TextStyle(color: AppPalette.danger),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }
}

// Baris data profil: teks biasa saat dilihat, kolom isian saat mengedit.
class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    required this.controller,
    required this.editing,
    required this.keyboardType,
    required this.validator,
  });

  final String label;
  final String value;
  final TextEditingController controller;
  final bool editing;
  final TextInputType keyboardType;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppPalette.textMuted),
          ),
          const SizedBox(height: 2),
          if (editing)
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppPalette.primary, width: 2),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black26)),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppPalette.textDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
