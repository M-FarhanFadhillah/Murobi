// Model data dari API Murobi (lihat docs/API.md). Penguraian dibuat longgar:
// field yang hilang atau bertipe lain diberi nilai bawaan, bukan melempar error,
// supaya satu data yang janggal tidak membuat seluruh daftar gagal tampil.

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

String _asString(dynamic value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

// Alamat berkas: null jika kosong (server mengirim null bila berkas tidak ada).
String? _asUrl(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime _asDate(dynamic value) =>
    DateTime.tryParse(_asString(value))?.toLocal() ??
    DateTime.fromMillisecondsSinceEpoch(0);

class ApiUser {
  const ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.noHp,
    required this.isAdmin,
    required this.status,
    this.photoUrl,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        email: _asString(json['email']),
        noHp: _asString(json['no_hp']),
        isAdmin: json['is_admin'] == true || json['is_admin'] == 1,
        status: _asInt(json['status']),
        photoUrl: _asUrl(json['profil_pict_url']),
      );

  final int id;
  final String name;
  final String email;
  final String noHp;
  final bool isAdmin;

  // 0 = menunggu persetujuan, 1 = aktif, 2 = ditolak.
  final int status;
  final String? photoUrl;
}

class ApiMasjid {
  const ApiMasjid({
    required this.id,
    required this.nama,
    required this.alamat,
    this.fotoUrl,
  });

  factory ApiMasjid.fromJson(Map<String, dynamic> json) => ApiMasjid(
        id: _asInt(json['id']),
        nama: _asString(json['masjid_name']),
        alamat: _asString(json['alamat']),
        fotoUrl: _asUrl(json['masjid_pict_url']),
      );

  final int id;
  final String nama;
  final String alamat;
  final String? fotoUrl;
}

class ApiBanner {
  const ApiBanner({
    required this.id,
    required this.judul,
    this.coverUrl,
  });

  factory ApiBanner.fromJson(Map<String, dynamic> json) => ApiBanner(
        id: _asInt(json['id']),
        judul: _asString(json['judul']),
        coverUrl: _asUrl(json['cover_url']),
      );

  final int id;
  final String judul;
  final String? coverUrl;
}

class ApiActivity {
  const ApiActivity({
    required this.id,
    required this.masjidId,
    required this.nama,
    required this.deskripsi,
    required this.createdAt,
    this.pictUrl,
  });

  factory ApiActivity.fromJson(Map<String, dynamic> json) => ApiActivity(
        id: _asInt(json['id']),
        masjidId: _asInt(json['masjid_id']),
        nama: _asString(json['activity_name']),
        deskripsi: _asString(json['deskripsi'], _asString(json['decription'])),
        createdAt: _asDate(json['created_at']),
        pictUrl: _asUrl(json['pict_url']),
      );

  final int id;
  final int masjidId;
  final String nama;
  final String deskripsi;
  final DateTime createdAt;
  final String? pictUrl;
}

class ApiEdukasi {
  const ApiEdukasi({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.deskripsi,
    required this.createdAt,
    required this.isVideo,
    this.contentUrl,
  });

  factory ApiEdukasi.fromJson(
    Map<String, dynamic> json, {
    required bool isVideo,
  }) =>
      ApiEdukasi(
        id: _asInt(json['id']),
        judul: _asString(json['judul']),
        kategori: _asInt(json['kategori']),
        deskripsi: _asString(json['deskripsi']),
        createdAt: _asDate(json['created_at']),
        isVideo: isVideo,
        contentUrl: _asUrl(json['content_url']),
      );

  final int id;
  final String judul;

  // 0 = Anak-anak, 1 = Remaja, 2 = Orang Tua.
  final int kategori;
  final String deskripsi;
  final DateTime createdAt;
  final bool isVideo;
  final String? contentUrl;
}
