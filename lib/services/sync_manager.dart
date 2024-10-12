import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/media_info.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/utils/time.dart';

class SyncManager {
  //Native Module
  static const platform = MethodChannel('com.example.mobile/images');

  Future<Map<String, MediaInfo>> getAllImagePathsNative() async {
    final start = DateTime.now().millisecondsSinceEpoch;
    print("Starting");
    try {
      // Call the method on the platform (Android in this case)
      final List<dynamic> paths =
          await platform.invokeMethod('getAllImagePathsNative');

      Map<String, MediaInfo> mediaInfo = HashMap();

      for (String s in paths.cast<String>().take(10)) {
        File file = File(s);
        final fileStream = file.openRead();
        final checksum =
            base64.encode((await sha256.bind(fileStream).first).bytes);
        mediaInfo[checksum] = MediaInfo(s, await getFileStamp(file));
      }

      final end = DateTime.now().millisecondsSinceEpoch;
      print("It took ${(end - start)}");
      print("Finished getAllImagePathsNative()");
      return mediaInfo;
    } on PlatformException catch (e) {
      print("Failed to get image paths: '${e.message}'.");
      return HashMap();
    }
  }

}
