import 'dart:io';
import 'dart:typed_data';
import 'package:mobile/model/media_asset.dart';

class LocalMedia extends MediaAsset {
  String? remoteId;
  String path;

  LocalMedia(this.remoteId, this.path, super.checksum, super.timestamp);

  @override
  Future<Uint8List?> getPreview() async {
    File file = File(path);
    print("Getting preview for file: $path");
    return file.readAsBytesSync();
  }
}
