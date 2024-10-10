import 'package:mime/mime.dart';
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
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
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

  // void upload(String path) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String baseUrl = prefs.getString(BASE_URL) ?? "";
  //   var uri = Uri.parse('$baseUrl/image/upload');
  //   print('$baseUrl/image/upload');

  //   final fileStream = File(path).openRead();
  //   final checksum = (await sha256.bind(fileStream).first).toString();

  //   final storage = FlutterSecureStorage();
  //   final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";
  //     final mimeType = lookupMimeType(path) ?? "application/octet-stream";

  //   var request = http.MultipartRequest('POST', uri)
  //     ..headers.addAll({
  //       HttpHeaders.cacheControlHeader: 'no-cache',
  //       HttpHeaders.authorizationHeader: "Bearer $jwtToken",
  //       HttpHeaders.contentTypeHeader: mimeType,
  //       'Content-Digest': "sha-256=:$checksum:",
  //       'Expect': '100-continue'
  //     })
  //     ..files.add(
  //         await http.MultipartFile.fromPath('image', path, filename: checksum));

  //   var response = await request.send();
  //   if (response.statusCode == 200)
  //     print('Uploaded!');
  //   else
  //     print(response);
  // }

  Future<void> uploadFileStream(String filePath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String baseUrl = prefs.getString(BASE_URL) ?? "";
    var uri = Uri.parse('$baseUrl/image/upload');
    final storage = FlutterSecureStorage();
    final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";

    final file = File(filePath);
    final fileStream = file.openRead();
    final checksum = base64.encode((await sha256.bind(fileStream).first).bytes);
    final mimeType = lookupMimeType(filePath) ?? "application/octet-stream";

    print("MimeType: $mimeType");
    print("CheckSum: $checksum");
    print("FilePath: $filePath");

    final streamedRequest = http.StreamedRequest('POST', uri)
      ..headers.addAll({
        HttpHeaders.cacheControlHeader: 'no-cache',
        HttpHeaders.authorizationHeader: "Bearer $jwtToken",
        HttpHeaders.contentTypeHeader: mimeType,
        'Content-Digest': "sha-256=:$checksum:",
        'Expect': '100-continue'
      });

    streamedRequest.contentLength = await file.length();
    file.openRead().listen((chunk) {
      print("chunk: ${chunk.length}");
      streamedRequest.sink.add(chunk);
    }, onDone: () {
      streamedRequest.sink.close();
    });
    try {
      var response = await streamedRequest.send();

      print(
          'Response: ${response.statusCode} ${response.reasonPhrase} ${await response.stream.bytesToString()}');
    } on http.ClientException catch (e) {
      print("Client Exception: ${e.message}");
    } catch (e) {
      print("Other exception");
    }
  }
}
