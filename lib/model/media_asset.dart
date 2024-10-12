import 'dart:typed_data';

abstract class MediaAsset {
  String checksum;
  int timestamp;

  MediaAsset(this.checksum, this.timestamp);

  Future<Uint8List?> getPreview();
}
