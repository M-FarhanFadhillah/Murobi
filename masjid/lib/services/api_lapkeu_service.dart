import 'package:masjid/models/lapkeu_model.dart';
import 'package:masjid/utils/api.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';

class ApiLapkeu {
  static Future<List<LapkeuModel>> getApi() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.endPoint_lapkeu);
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
      throw Exception('Failed to fetch data. Error di API: ${e.toString()}');
    }
  }
}