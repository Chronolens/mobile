import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/model/login_request.dart';
import 'package:mobile/model/login_response.dart';
import 'package:mobile/model/media.dart';

class APIServiceClient {

  Future<LoginResponse?> login(String username, String password) async {
    var uri = Uri.parse('http://10.0.0.10:8080/login');
    var payload = LoginRequest(username, password).toJson();
    var body = json.encode(payload);
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var response = await http.post(uri, body: body, headers: headers);
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<List<MediaFile>?> getMediaFile() async {
    var client = http.Client();
    var uri = Uri.parse('https://10.0.0.10:8080/image_upload');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      return mediaFileFromJson(const Utf8Decoder().convert(response.bodyBytes));
    }
    return null;
  }

// late ClientChannel channel;
// late ChronoLensClient stub;

// APIServiceClient() {
//   // Initialize gRPC channel
//   channel = ClientChannel(
//     '10.0.0.10', // The IP or hostname of the gRPC server
//     port: 8080, // The port on which the gRPC server is running
//     options: const ChannelOptions(
//       credentials: ChannelCredentials
//           .insecure(), // Use secure credentials in production
//     ),
//   );

//   // Create stub from generated gRPC code
//   stub = ChronoLensClient(channel);
// }

// // Function to get photo by ID
// Future<Maybe<GrpcError?>> login(String username, String password) async {
//   try {
//     final request = LoginRequest()
//       ..username = username
//       ..password = password;

//     final response = await stub.login(request);

//     final storage = new FlutterSecureStorage();
//     await storage.write(key: "jwtToken", value: response.token);

//     // String? value = await storage.read(key: "jwtToken");
//     // print(value);

//     return const Nothing();
//   } on GrpcError catch (e) {
//     print('GrpcError: $e');
//     return Just(e);
//   } catch (e) {
//     print('Random Error: $e');
//     return const Just(null);
//   }
// }

// // Function to upload an image
// Future<UploadImageResponse?> uploadImage(String filetype, ByteBuffer data) async {
//   try {
//     // Create an ImageInfo object with the filetype
//     final imageInfo = ImageInfo()..filetype = filetype;

//     // Create an UploadImageRequest with image info
//     final infoRequest = UploadImageRequest()..info = imageInfo;

//     // Create an UploadImageRequest with image data
//     final imageRequest = UploadImageRequest()..image = data.asUint8List();

//     // Create a streaming request (since it's defined as stream in proto)
//     final response = await stub.uploadImage(Stream.fromIterable([infoRequest, imageRequest]));

//     // Return the response
//     return response;
//   } catch (e) {
//     print('Error uploading image: $e');
//     return null;
//   }
// }
/*Future<UploadImageResponse?> uploadImage(String filetype, ByteBuffer data) async {
    try {
      // Create a GetPhotoRequest with the provided id
      final request = UploadImageRequest()
        ..data = data;

      // Call the gRPC method and get the response
      final response = await stub.uploadImage(request);

      // Return the photo URL from the response
      return response;
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }*/
}
