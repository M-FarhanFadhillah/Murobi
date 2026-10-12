// Aturan validasi isian formulir yang dipakai di beberapa halaman (daftar,
// profil, ubah kata sandi), supaya pesannya seragam.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // Nomor telepon Indonesia: diawali 0 atau +62, lalu 8-13 digit.
  static final RegExp _phoneRegex = RegExp(r'^(\+62|0)[0-9]{8,13}$');

  static String? nama(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Nama wajib diisi';
    if (text.length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Email wajib diisi';
    if (!_emailRegex.hasMatch(text)) return 'Format email tidak valid';
    return null;
  }

  static String? phone(String? value, {String label = 'Nomor telepon'}) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '$label wajib diisi';
    if (!_phoneRegex.hasMatch(text)) {
      return 'Gunakan format 08xxxxxxxxxx atau +62xxxxxxxxxx';
    }
    return null;
  }

  // Kata sandi baru: minimal 8 karakter, huruf besar dan kecil, angka, simbol.
  static String? password(String? value) {
    final text = value ?? '';
    if (text.length < 8) return 'Kata sandi minimal 8 karakter';
    if (!text.contains(RegExp(r'[A-Z]')) || !text.contains(RegExp(r'[a-z]'))) {
      return 'Gunakan huruf besar dan kecil';
    }
    if (!text.contains(RegExp(r'[0-9]'))) return 'Gunakan minimal 1 angka';
    if (!text.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return 'Gunakan minimal 1 simbol';
    }
    return null;
  }

  // Isian umum yang tidak boleh kosong.
  static String? required(String? value, String label) {
    if ((value ?? '').trim().isEmpty) return '$label wajib diisi';
    return null;
  }
}
