import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:masjid/api/api.dart';
import 'package:masjid/models/model_api.dart';

class ApiService {
  static Future<List<ApiModel>> getApi() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.endPoint);
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<ApiModel> _apiModel = [apiModelFromJson(response.body)];
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
