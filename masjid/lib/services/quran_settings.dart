import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mode tampilan ayat. "Arab saja" membantu jamaah yang ingin fokus membaca.
enum QuranViewMode { semua, arabTerjemahan, arabSaja }

extension QuranViewModeLabel on QuranViewMode {
  String get label {
    switch (this) {
      case QuranViewMode.semua:
        return 'Arab, Latin & Terjemahan';
      case QuranViewMode.arabTerjemahan:
        return 'Arab & Terjemahan';
      case QuranViewMode.arabSaja:
        return 'Arab saja';
    }
  }

  bool get showLatin => this == QuranViewMode.semua;

  bool get showTranslation => this != QuranViewMode.arabSaja;
}

// Pengaturan tampilan Al-Qur'an: ukuran huruf (zoom in/out) dan mode layar.
// Disimpan di perangkat agar tetap sama saat aplikasi dibuka lagi.
class QuranSettings extends ChangeNotifier {
  QuranSettings();

  static final QuranSettings instance = QuranSettings();

  static const double minScale = 0.8;
  static const double maxScale = 2.0;
  static const double step = 0.1;

  static const String _scaleKey = 'quran_font_scale';
  static const String _modeKey = 'quran_view_mode';

  double _fontScale = 1.0;
  QuranViewMode _mode = QuranViewMode.semua;
  Future<void>? _loading;
  bool _touched = false;

  double get fontScale => _fontScale;

  QuranViewMode get mode => _mode;

  bool get canZoomIn => _fontScale < maxScale - 0.001;

  bool get canZoomOut => _fontScale > minScale + 0.001;

  // Memuat pengaturan tersimpan. Aman dipanggil berkali-kali.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Jika pengguna sudah mengubah pengaturan selama memuat, jangan menimpanya.
      if (!_touched) {
        final scale = prefs.getDouble(_scaleKey);
        if (scale != null) _fontScale = _normalize(scale);

        final modeName = prefs.getString(_modeKey);
        for (final mode in QuranViewMode.values) {
          if (mode.name == modeName) _mode = mode;
        }
      }
    } catch (_) {
      // Penyimpanan tidak tersedia: pakai pengaturan bawaan.
    }
    notifyListeners();
  }

  // Membatasi ke rentang yang diizinkan dan satu angka desimal (0.8, 0.9, ...).
  double _normalize(double value) =>
      (value.clamp(minScale, maxScale) * 10).round() / 10;

  Future<void> zoomIn() => setFontScale(_fontScale + step);

  Future<void> zoomOut() => setFontScale(_fontScale - step);

  Future<void> setFontScale(double value) async {
    final next = _normalize(value);
    if (next == _fontScale) return;
    _touched = true;
    _fontScale = next;
    notifyListeners();
    await _save();
  }

  Future<void> setMode(QuranViewMode mode) async {
    if (mode == _mode) return;
    _touched = true;
    _mode = mode;
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_scaleKey, _fontScale);
      await prefs.setString(_modeKey, _mode.name);
    } catch (_) {}
  }
}
