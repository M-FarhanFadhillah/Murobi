import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:masjid/data/api/murobi_api.dart';

http.Response jsonResponse(Object? body, [int status = 200]) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}

Map<String, dynamic> userJson({
  int id = 3,
  String name = 'Ahmad Al Farizi',
  String email = 'ahmad@gmail.com',
  String noHp = '081994851234',
  bool admin = false,
  int status = 1,
  String? photoUrl,
}) {
  return {
    'id': id,
    'name': name,
    'email': email,
    'no_hp': noHp,
    'profil_pict': photoUrl == null ? '' : 'profil-pict/foto.jpg',
    'profil_pict_url': photoUrl,
    'is_admin': admin,
    'status': status,
  };
}

// Isi permintaan multipart: field teks (nama -> nilai) dan nama field berkas.
class Multipart {
  Multipart(this.fields, this.files);

  final Map<String, String> fields;
  final List<String> files;
}

Multipart parseMultipart(http.Request request) {
  final crlf = String.fromCharCodes([13, 10]);
  final boundary =
      RegExp('boundary=(.+)').firstMatch(request.headers['content-type'] ?? '')![1]!;
  final body = latin1.decode(request.bodyBytes);
  final fields = <String, String>{};
  final files = <String>[];
  for (final part in body.split('--$boundary')) {
    final headerEnd = part.indexOf(crlf + crlf);
    if (headerEnd < 0) continue;
    final header = part.substring(0, headerEnd);
    final name = RegExp('name="([^"]+)"').firstMatch(header)?[1];
    if (name == null) continue;
    if (header.contains('filename=')) {
      files.add(name);
    } else {
      var value = part.substring(headerEnd + 4);
      if (value.endsWith(crlf)) value = value.substring(0, value.length - 2);
      fields[name] = utf8.decode(latin1.encode(value));
    }
  }
  return Multipart(fields, files);
}

typedef ServerHandler = FutureOr<http.Response> Function(http.Request request);

// Server palsu: mencatat setiap permintaan dan menjawab lewat [handler] yang
// bisa diganti di tengah pengujian (mis. untuk meniru server mati).
class FakeServer {
  FakeServer(this.handler, {Duration timeout = const Duration(seconds: 5)}) {
    api = MurobiApi(
      httpClient: MockClient((request) async {
        requests.add(request);
        return handler(request);
      }),
      baseUrl: 'http://test/api',
      timeout: timeout,
      retryDelay: Duration.zero,
    );
  }

  ServerHandler handler;
  final List<http.Request> requests = [];
  late final MurobiApi api;

  http.Request get last => requests.last;

  Map<String, dynamic> get lastBody =>
      jsonDecode(last.body) as Map<String, dynamic>;

  // Server tidak terjangkau.
  static http.Response offline(http.Request request) =>
      throw http.ClientException('offline');
}
