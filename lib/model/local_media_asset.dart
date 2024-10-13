import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalMedia extends MediaAsset {
  String? remoteId;
  String path;
  String id;

  LocalMedia(
      this.remoteId, this.path, this.id, super.checksum, super.timestamp);

  @override
  Future<Widget?> getPreview() async {
    final preview = await AssetEntity.fromId(id);
    final thumbnail = await preview?.thumbnailData;
    return Image.memory(thumbnail!);
  }
}
