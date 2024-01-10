import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:masjid/api/api.dart';
import 'package:masjid/models/model_api.dart';

class ApiService {
  static Future<List<ApiModel>> getApi() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.endPoint);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<ApiModel> _apiModel = List.from(json.decode(response.body)).map((item) => ApiModel.fromJson(item)).toList();
        return _apiModel;
      } 
      else
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
    } catch (e) {
      log(e.toString());
      throw Exception('Failed to fetch data. Error: ${e.toString()}');
    }
  }
}
