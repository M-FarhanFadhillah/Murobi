import 'package:masjid/models/lapkeu_model.dart';
import 'package:masjid/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';

class ApiLapkeu {
  static Future<List<LapkeuModel>> getApi(String id_masjid) async {
    try {
      var url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.endPoint_lapkeu}/$id_masjid');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<LapkeuModel> _apiLapkeuModel = List.from(json.decode(response.body)).map((item) => LapkeuModel.fromJson(item)).toList();
        return _apiLapkeuModel;
      } 
      else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to fetch data. Error: ${e.toString()}');
    }
  }
}