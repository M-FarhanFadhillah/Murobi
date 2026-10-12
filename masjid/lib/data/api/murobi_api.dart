import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:masjid/data/api/api_client.dart';
import 'package:masjid/data/api/api_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginResult {
  const LoginResult(this.user, this.token);

  final ApiUser user;
  final String token;
}

// Seluruh pemanggilan endpoint API Murobi (docs/API.md). Daftar data publik
// disimpan di perangkat tiap kali berhasil dimuat, lalu dipakai kembali saat
// server tidak terjangkau.
class MurobiApi {
  MurobiApi({
    http.Client? httpClient,
    String? baseUrl,
    Duration timeout = const Duration(seconds: 15),
    Duration retryDelay = const Duration(milliseconds: 300),
  }) {
    _client = ApiClient(
      client: httpClient,
      baseUrl: baseUrl,
      timeout: timeout,
      retryDelay: retryDelay,
      tokenProvider: () => token,
    );
  }

  static final MurobiApi instance = MurobiApi();

  // Token Bearer akun yang sedang masuk (null = belum masuk).
  String? token;

  late final ApiClient _client;

  // ---- Data publik ----

  Future<List<ApiBanner>> banners() async {
    final list = await _cachedList('banner');
    return list.map(ApiBanner.fromJson).toList();
  }

  Future<List<ApiMasjid>> masjids() async {
    final list = await _cachedList('masjid');
    return list.map(ApiMasjid.fromJson).toList();
  }

  Future<List<ApiActivity>> activities({int? masjidId}) async {
    final list = await _cachedList(
      'activity',
      query: masjidId == null ? null : {'masjid_id': '$masjidId'},
    );
    return list.map(ApiActivity.fromJson).toList();
  }

  Future<List<ApiEdukasi>> books() async {
    final list = await _cachedList('edu/book');
    return list.map((e) => ApiEdukasi.fromJson(e, isVideo: false)).toList();
  }

  Future<List<ApiEdukasi>> videos() async {
    final list = await _cachedList('edu/video');
    return list.map((e) => ApiEdukasi.fromJson(e, isVideo: true)).toList();
  }

  // ---- Akun ----

  Future<LoginResult> login(String login, String password) async {
    final json = _asMap(await _client.post('login', body: {
      'login': login,
      'password': password,
      'device_name': 'murobi-app',
    }));
    final token = json['token'];
    if (token is! String || token.isEmpty) throw _unexpected();
    return LoginResult(_userFrom(json), token);
  }

  // Masuk dengan akun Google: salah satu dari [idToken] (Android) atau
  // [accessToken] (web). Server memeriksanya langsung ke Google.
  Future<LoginResult> loginWithGoogle({
    String? idToken,
    String? accessToken,
  }) async {
    final json = _asMap(await _client.post('auth/google', body: {
      if (idToken != null) 'id_token': idToken,
      if (idToken == null && accessToken != null) 'access_token': accessToken,
      'device_name': 'murobi-app',
    }));
    final token = json['token'];
    if (token is! String || token.isEmpty) throw _unexpected();
    return LoginResult(_userFrom(json), token);
  }

  // Mengembalikan pesan sukses dari server.
  Future<String> register({
    required String name,
    required String email,
    required String noHp,
    required String password,
  }) async {
    final json = _asMap(await _client.post('register', body: {
      'name': name,
      'email': email,
      'no_hp': noHp,
      'password': password,
    }));
    return (json['message'] as String?) ??
        'Pendaftaran berhasil. Akun Anda menunggu persetujuan admin.';
  }

  Future<ApiUser> me() async => _userFrom(_asMap(await _client.get('me')));

  Future<void> logout() async {
    await _client.post('logout');
  }

  Future<ApiUser> updateMe({
    required String name,
    required String email,
    required String noHp,
  }) async {
    final json = _asMap(await _client.patch('me', body: {
      'name': name,
      'email': email,
      'no_hp': noHp,
    }));
    return _userFrom(json);
  }

  Future<ApiUser> uploadPhoto(Uint8List bytes, {String filename = 'foto.jpg'}) async {
    final json = _asMap(await _client.postFile(
      'me/photo',
      field: 'profil_pict',
      bytes: bytes,
      filename: filename,
    ));
    return _userFrom(json);
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.post('me/password', body: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  // ---- Laporan masalah ----

  Future<ApiReport> sendReport(String message) async {
    final json = _asMap(await _client.post('reports', body: {'message': message}));
    return ApiReport.fromJson(json);
  }

  // Laporan milik akun yang sedang masuk.
  Future<List<ApiReport>> myReports() async {
    final list = _asList(await _client.get('reports/mine'));
    return list.map(ApiReport.fromJson).toList();
  }

  // Admin: laporan dari semua jamaah.
  Future<List<ApiReport>> allReports() async {
    final list = _asList(await _client.get('reports'));
    return list.map(ApiReport.fromJson).toList();
  }

  // Admin: [done] true = sudah ditangani.
  Future<ApiReport> setReportDone(int id, {required bool done}) async {
    final json = _asMap(await _client.patch('reports/$id', body: {
      'status': done ? 1 : 0,
    }));
    return ApiReport.fromJson(json);
  }

  Future<void> deleteReport(int id) async {
    await _client.delete('reports/$id');
  }

  // ---- Kelola konten (admin) ----

  Future<ApiActivity> createActivity({
    required int masjidId,
    required String nama,
    required String deskripsi,
    required Uint8List poster,
  }) async {
    final json = _asMap(await _client.postMultipart(
      'activity',
      fields: {
        'masjid_id': '$masjidId',
        'activity_name': nama,
        'deskripsi': deskripsi,
      },
      file: MultipartPart(field: 'pict', bytes: poster, filename: 'poster.jpg'),
    ));
    return ApiActivity.fromJson(json);
  }

  Future<void> deleteActivity(int id) async {
    await _client.delete('activity/$id');
  }

  // [jenis] = 'book' atau 'video'. Buku: [cover] opsional. Video: [videoUrl].
  Future<ApiEdukasi> createEdukasi({
    required bool isVideo,
    required String judul,
    required int kategori,
    required String deskripsi,
    Uint8List? cover,
    String? videoUrl,
  }) async {
    final json = _asMap(await _client.postMultipart(
      'edu',
      fields: {
        'jenis': isVideo ? 'video' : 'book',
        'judul': judul,
        'kategori': '$kategori',
        'deskripsi': deskripsi,
        if (videoUrl != null) 'video_url': videoUrl,
      },
      file: cover == null
          ? null
          : MultipartPart(field: 'content', bytes: cover, filename: 'cover.jpg'),
    ));
    return ApiEdukasi.fromJson(json, isVideo: isVideo);
  }

  // Hanya field yang diisi yang dikirim; jenis materi tidak dapat diubah.
  Future<ApiEdukasi> updateEdukasi(
    int id, {
    required bool isVideo,
    String? judul,
    int? kategori,
    String? deskripsi,
    Uint8List? cover,
    String? videoUrl,
  }) async {
    final json = _asMap(await _client.postMultipart(
      'edu/$id',
      fields: {
        if (judul != null) 'judul': judul,
        if (kategori != null) 'kategori': '$kategori',
        if (deskripsi != null) 'deskripsi': deskripsi,
        if (videoUrl != null) 'video_url': videoUrl,
      },
      file: cover == null
          ? null
          : MultipartPart(field: 'content', bytes: cover, filename: 'cover.jpg'),
    ));
    return ApiEdukasi.fromJson(json, isVideo: isVideo);
  }

  Future<void> deleteEdukasi(int id) async {
    await _client.delete('edu/$id');
  }

  // ---- Pendukung ----

  static ApiException _unexpected() =>
      const ApiException('Respons server tidak dikenali.');

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw _unexpected();
  }

  static ApiUser _userFrom(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is! Map) throw _unexpected();
    return ApiUser.fromJson(Map<String, dynamic>.from(user));
  }

  static List<Map<String, dynamic>> _asList(dynamic data) {
    if (data is! List) throw _unexpected();
    return [
      for (final item in data)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }

  Future<List<Map<String, dynamic>>> _cachedList(
    String path, {
    Map<String, String>? query,
  }) async {
    final key = 'api_cache_v1_$path'
        '${query == null ? '' : '?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}'}';
    try {
      final list = _asList(await _client.get(path, query: query));
      await _writeCache(key, list);
      return list;
    } on ApiException catch (error) {
      final serverDown = error.isNetworkError || (error.statusCode ?? 0) >= 500;
      if (!serverDown) rethrow;
      final cached = await _readCache(key);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<void> _writeCache(String key, List<Map<String, dynamic>> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(list));
    } catch (_) {
      // Penyimpanan tidak tersedia atau penuh: lewati, cache hanya pelengkap.
    }
  }

  Future<List<Map<String, dynamic>>?> _readCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      return _asList(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }
}
