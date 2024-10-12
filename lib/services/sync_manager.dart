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

      for (String s in paths.cast<String>().take(20)) {
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

  Future<List<MediaAsset>> syncResolver(
      /* Map<String, MediaInfo> localMediaInfo,
      Map<String, RemoteMedia> remoteMediaInfo */
      ) async {
    final start = DateTime.now().millisecondsSinceEpoch;
    Map<String, MediaInfo> localMediaInfo = await getAllImagePathsNative();
    Map<String, RemoteMedia> remoteMediaInfo =
        await APIServiceClient().syncFull();

    List<MediaAsset> mediaAssets = [];
    HashSet<String> localAndRemoteHashes = HashSet();

    for (var entry in localMediaInfo.entries) {
      var remoteMedia = remoteMediaInfo[entry.key];

      if (remoteMedia != null) {
        mediaAssets.add(LocalMedia(remoteMedia.id, entry.value.path, entry.key,
            entry.value.timestamp));
        localAndRemoteHashes.add(entry.key);
      } else {
        mediaAssets.add(LocalMedia(
            null, entry.value.path, entry.key, entry.value.timestamp));
      }
    }
    mediaAssets.addAll(remoteMediaInfo.values.toList()
      ..removeWhere((item) => localAndRemoteHashes.contains(item.checksum))
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)));

    int i = 0;
    for (var a in mediaAssets) {
      print(
          "Media:${a.checksum} | ${a.timestamp} | ${a is LocalMedia ? "true" : "false"}");
      if (i == 10) {
        break;
      }
    }
    final end = DateTime.now().millisecondsSinceEpoch;
    print("It ALL took ${(end - start)}");
    print("DONE");
    return mediaAssets;
  }
}
