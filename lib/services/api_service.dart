import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/utils/constants.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/model/login_request.dart';
import 'package:mobile/model/login_response.dart';

class APIServiceClient {
  Future<int?> login(String username, String password, String baseUrl) async {
    var uri = Uri.parse('$baseUrl/login');
    var payload = LoginRequest(username, password).toJson();
    var body = json.encode(payload);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      var response = await http.post(uri, body: body, headers: headers);
      if (response.statusCode == 200) {
        LoginResponse loginResponse =
            LoginResponse.fromJson(json.decode(response.body));
        final storage = FlutterSecureStorage();
        await storage.write(key: 'jwtToken', value: loginResponse.token);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(BASE_URL, baseUrl);
      }
      return response.statusCode;
    } catch (e) {
      return null;
    }
  }

  void upload(String path /*File file , Map<String, String> fields */) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString(BASE_URL) ?? "";

    var uri = Uri.parse('$baseUrl/image/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', path));

    var response = await request.send();
    if (response.statusCode == 200)
      print('Uploaded!');
    else
      print("bruh");
  }

}
