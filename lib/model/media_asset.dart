import 'package:flutter/material.dart';

abstract class MediaAsset {
  String checksum;
  int timestamp;

  MediaAsset(this.checksum, this.timestamp);

  Future<Widget?> getPreview();
}
