import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/api_service.dart';
import 'package:photo_manager/photo_manager.dart';

class RemoteMedia extends MediaAsset {
  String id;

  RemoteMedia(this.id, super.checksum, super.timestamp);

  factory RemoteMedia.fromJson(Map<String, dynamic> json, String checksum) {
    final id = json['id'] as String;
    final timestamp = json['created_at'] as int;
    return RemoteMedia(id, checksum, timestamp);
  }

  @override
  Future<Uint8List?> getPreview() async {
    String imgUrl = await APIServiceClient().getPreview(this.id);
    Uri uri = Uri.parse(imgUrl);
    try {
      var response = await http.get(uri);
      Uint8List data = response.bodyBytes;
      final AssetEntity? assetEntity = await PhotoManager.editor.saveImage(data, filename: this.id);
      return await assetEntity?.thumbnailData;
    } catch (e) {
      return null;
    }
  }

}
