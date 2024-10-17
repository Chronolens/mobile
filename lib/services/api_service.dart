import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:mobile/model/login_request.dart';
import 'package:mobile/model/login_response.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:mobile/utils/checksum.dart';
import 'package:mobile/utils/constants.dart';
import 'package:mobile/utils/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

        final SharedPreferencesAsync prefs = SharedPreferencesAsync();
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

  // TODO: change funtion inputs
  Future<void> uploadFileStream(String filePath) async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    String baseUrl = await prefs.getString(BASE_URL) ?? "";
    var uri = Uri.parse('$baseUrl/image/upload');
    final storage = FlutterSecureStorage();
    final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";

    final file = File(filePath);
    final checksum = await computeChecksum(filePath);
    final mimeType = lookupMimeType(filePath) ?? "application/octet-stream";

    print("MimeType: $mimeType");
    print("CheckSum: $checksum");
    print("FilePath: $filePath");

    final int fileTimeStamp = await getFileStamp(file);

    final streamedRequest = http.StreamedRequest('POST', uri)
      ..headers.addAll({
        HttpHeaders.cacheControlHeader: 'no-cache',
        HttpHeaders.authorizationHeader: "Bearer $jwtToken",
        HttpHeaders.contentTypeHeader: mimeType,
        "Timestamp": fileTimeStamp.toString(),
        'Content-Digest': "sha-1=:$checksum:",
        'Expect': '100-continue'
      });

    streamedRequest.contentLength = await file.length();
    file.openRead().listen((chunk) {
      //print("chunk: ${chunk.length}");
      streamedRequest.sink.add(chunk);
    }, onDone: () {
      streamedRequest.sink.close();
    });
    try {
      var response = await streamedRequest.send();

      print(
          'Response: ${response.statusCode} ${response.reasonPhrase} ${await response.stream.bytesToString()}');
    } on http.ClientException catch (e) {
      // Probably already exists on server
      print("Client Exception: ${e.message}");
    } catch (e) {
      print("Other exception");
    }
  }

  Future<List<RemoteMedia>> syncFullRemote() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    String baseUrl = await prefs.getString(BASE_URL) ?? "";
    var uri = Uri.parse('$baseUrl/sync/full');
    final storage = FlutterSecureStorage();
    final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer $jwtToken"
    };

    try {
      var response = await http.get(uri, headers: headers);
      print("Body: ${response.body}");
      final List<dynamic> sync = jsonDecode(response.body);
      final List<RemoteMedia> mediaMap =
          sync.map((v) => RemoteMedia.fromJson(v)).toList();

      print("Finished syncFull()");

      return mediaMap;
    } catch (e) {
      print("Exception $e");
      return [];
    }
  }

  Future<List> syncPartialRemote(int lastSync) async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    String baseUrl = await prefs.getString(BASE_URL) ?? "";
    var uri = Uri.parse('$baseUrl/sync/partial');
    final storage = FlutterSecureStorage();
    final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer $jwtToken",
      "Since": lastSync.toString()
    };

    try {
      var response = await http.get(uri, headers: headers);
      print("Body: ${response.body}");
      final Map<String, dynamic> sync = jsonDecode(response.body);

      return [sync["uploaded"], sync["deleted"]];
    } catch (e) {
      print("Exception $e");
      return [];
    }
  }

  Future<String> getPreview(String uuid) async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    String baseUrl = await prefs.getString(BASE_URL) ?? "";
    var uri = Uri.parse('$baseUrl/preview/$uuid');
    final storage = FlutterSecureStorage();
    final jwtToken = await storage.read(key: JWT_TOKEN) ?? "";

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: "Bearer $jwtToken"
    };

    try {
      var response = await http.get(uri, headers: headers);
      print(response.body);
      return response.body;
    } catch (e) {
      print("Error getting preview for: $uuid");
      return "";
    }
  }
}
