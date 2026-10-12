import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ayat yang ditandai (bookmark). Teks Arab dan terjemahan ikut disimpan agar
// daftar tanda tetap bisa ditampilkan tanpa internet.
class QuranBookmark {
  const QuranBookmark({
    required this.suratNomor,
    required this.suratNama,
    required this.ayatNomor,
    required this.teksArab,
    required this.terjemahan,
  });

  final int suratNomor;

  // Nama latin surah, mis. "Al-Fatihah".
  final String suratNama;
  final int ayatNomor;
  final String teksArab;
  final String terjemahan;

  // Pengenal unik, mis. "2:255".
  String get key => '$suratNomor:$ayatNomor';

  bool matches(int surat, int ayat) =>
      suratNomor == surat && ayatNomor == ayat;

  Map<String, dynamic> toJson() => {
        'surat': suratNomor,
        'suratNama': suratNama,
        'ayat': ayatNomor,
        'arab': teksArab,
        'idn': terjemahan,
      };

  factory QuranBookmark.fromJson(Map<String, dynamic> json) => QuranBookmark(
        suratNomor: json['surat'] as int,
        suratNama: json['suratNama'] as String,
        ayatNomor: json['ayat'] as int,
        teksArab: (json['arab'] as String?) ?? '',
        terjemahan: (json['idn'] as String?) ?? '',
      );
}

// Posisi terakhir yang dibaca jamaah.
class QuranLastRead {
  const QuranLastRead({
    required this.suratNomor,
    required this.suratNama,
    required this.ayatNomor,
  });

  final int suratNomor;
  final String suratNama;
  final int ayatNomor;

  Map<String, dynamic> toJson() => {
        'surat': suratNomor,
        'suratNama': suratNama,
        'ayat': ayatNomor,
      };

  factory QuranLastRead.fromJson(Map<String, dynamic> json) => QuranLastRead(
        suratNomor: json['surat'] as int,
        suratNama: json['suratNama'] as String,
        ayatNomor: json['ayat'] as int,
      );
}

enum BookmarkResult { added, removed, limitReached }

// Tanda ayat dan posisi terakhir dibaca. Disimpan di perangkat.
class QuranReadingStore extends ChangeNotifier {
  QuranReadingStore();

  static final QuranReadingStore instance = QuranReadingStore();

  static const int maxBookmarks = 200;

  static const String _bookmarksKey = 'quran_bookmarks_v1';
  static const String _lastReadKey = 'quran_last_read_v1';

  List<QuranBookmark> _bookmarks = [];
  QuranLastRead? _lastRead;
  Future<void>? _loading;
  bool _touched = false;

  // Tanda terbaru berada di urutan teratas.
  List<QuranBookmark> get bookmarks => List.unmodifiable(_bookmarks);

  QuranLastRead? get lastRead => _lastRead;

  bool isBookmarked(int suratNomor, int ayatNomor) =>
      _bookmarks.any((b) => b.matches(suratNomor, ayatNomor));

  // Memuat data tersimpan. Aman dipanggil berkali-kali.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Jika sudah ada perubahan selama memuat, jangan menimpanya.
      if (!_touched) {
        final rawBookmarks = prefs.getString(_bookmarksKey);
        if (rawBookmarks != null) {
          _bookmarks = (jsonDecode(rawBookmarks) as List<dynamic>)
              .map((e) => QuranBookmark.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        final rawLastRead = prefs.getString(_lastReadKey);
        if (rawLastRead != null) {
          _lastRead = QuranLastRead.fromJson(
            jsonDecode(rawLastRead) as Map<String, dynamic>,
          );
        }
      }
    } catch (_) {
      // Data rusak atau penyimpanan tidak tersedia: mulai dari kosong.
    }
    notifyListeners();
  }

  // Menandai ayat, atau menghapus tandanya jika sudah ditandai.
  Future<BookmarkResult> toggleBookmark(QuranBookmark bookmark) async {
    await load();
    final exists = isBookmarked(bookmark.suratNomor, bookmark.ayatNomor);
    if (!exists && _bookmarks.length >= maxBookmarks) {
      return BookmarkResult.limitReached;
    }

    _touched = true;
    if (exists) {
      _bookmarks = _bookmarks
          .where((b) => !b.matches(bookmark.suratNomor, bookmark.ayatNomor))
          .toList();
    } else {
      _bookmarks = [bookmark, ..._bookmarks];
    }
    notifyListeners();
    await _saveBookmarks();
    return exists ? BookmarkResult.removed : BookmarkResult.added;
  }

  // Menghapus tanda. Daftar berubah seketika (tanpa menunggu penyimpanan).
  Future<void> removeBookmark(int suratNomor, int ayatNomor) {
    _touched = true;
    _bookmarks =
        _bookmarks.where((b) => !b.matches(suratNomor, ayatNomor)).toList();
    notifyListeners();
    return _saveBookmarks();
  }

  Future<void> setLastRead(QuranLastRead value) async {
    final current = _lastRead;
    if (current != null &&
        current.suratNomor == value.suratNomor &&
        current.ayatNomor == value.ayatNomor) {
      return;
    }
    _touched = true;
    _lastRead = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastReadKey, jsonEncode(value.toJson()));
    } catch (_) {}
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _bookmarksKey,
        jsonEncode(_bookmarks.map((b) => b.toJson()).toList()),
      );
    } catch (_) {}
  }
}
