import 'dart:io';
import 'dart:async';
import 'package:crypto/crypto.dart';
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
        await storage.write(key: JWT_TOKEN, value: loginResponse.token);

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(BASE_URL, baseUrl);
      }
      return response.statusCode;
    } catch (e) {
      return null;
    }
  }

  void upload(String path) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString(BASE_URL) ?? "";
    var uri = Uri.parse('$baseUrl/image/upload');
    print('$baseUrl/image/upload');

    final fileStream = File(path).openRead();
    final checksum = (await sha256.bind(fileStream).first).toString();

    final storage = FlutterSecureStorage();
    final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";

    var request = http.MultipartRequest('POST', uri)
      ..headers[HttpHeaders.authorizationHeader] = "Bearer $jwtToken"
      ..files.add(
          await http.MultipartFile.fromPath('image', path, filename: checksum));

    var response = await request.send();
    if (response.statusCode == 200)
      print('Uploaded!');
    else
      print(response);
  }

  Future<void> uploadFileStream(String filePath) async {
    final file = new File(filePath);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString(BASE_URL) ?? "";
    var uri = Uri.parse('$baseUrl/image/upload');
    final fileStream = File(filePath).openRead();
    final checksum = (await sha256.bind(fileStream).first).bytes;


    final storage = FlutterSecureStorage();
    final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";

    final streamedRequest = new http.StreamedRequest('POST', uri)
      ..headers.addAll({
        'Cache-Control': 'no-cache',
        HttpHeaders.authorizationHeader : "Bearer $jwtToken",
        //'Content-Type': file.
      });
    streamedRequest.sink.add(checksum);
    streamedRequest.contentLength = await file.length() + checksum.length;
    print(checksum);
    print(streamedRequest.contentLength);
    file.openRead().listen((chunk) {
      print(chunk.length);
      streamedRequest.sink.add(chunk);
    }, onDone: () {
      streamedRequest.sink.close();
    });

    var response = await streamedRequest.send();
    
    print('Response: ${response}');
  }
}
