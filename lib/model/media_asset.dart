import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

abstract class MediaAsset {
  String checksum;
  int timestamp;

  MediaAsset(this.checksum, this.timestamp);

  Future<Widget?> getPreview();
}
