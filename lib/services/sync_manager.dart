import 'dart:collection';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/media_info.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/utils/checksum.dart';
import 'package:mobile/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncManager {
  //Native Module
  static const platform = MethodChannel('com.example.mobile/images');

  Future<List<RemoteMedia>> getAssetStructure(DatabaseService database) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    int? lastSync = await asyncPrefs.getInt(LAST_SYNC);

    List<RemoteMedia> assets = [];

    if (lastSync == null) {
      // DO FULL SYNC

      List<RemoteMedia> remote = await APIServiceClient().syncFullRemote();
      await database.upsertRemoteAssets(remote);
      assets.addAll(remote);
    } else {
      // DO PARTIAL SYNC

      print("Request media modified since $lastSync");
      List remote = await APIServiceClient().syncPartialRemote(lastSync);

      final List<RemoteMedia> uploadedList =
          (remote[0] as List).map((r) => RemoteMedia.fromJson(r)).toList();

      List<String> deletedList = (remote[1] as List).cast<String>();

      await database.upsertRemoteAssets(uploadedList);
      await database.deleteRemoteAssets(deletedList);

      assets.addAll(await database.getRemoteAssets());
    }
    assets.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return assets;
  }

  Future<List<MediaInfo>> getAllLocalMedia() async {
    try {
      // Call the method on the platform (Android in this case)
      print("before native");
      final List<dynamic> paths =
          await platform.invokeMethod('getAllImagePathsNative');

      List<MediaInfo> localMediaInfo = [];
      for (var pair in paths) {
        List<String> s =
            (pair as List<dynamic>).map((e) => e.toString()).toList();
        localMediaInfo.insert(0, MediaInfo(s[0], int.parse(s[2]), s[1]));
      }
      print("before native");
      return localMediaInfo;
    } on PlatformException catch (_) {
      return [];
    }
  }

  List<MediaAsset> mergeAssets(
      List<LocalMedia> local, List<RemoteMedia> remote) {
    List<MediaAsset> mediaAssets = [];
    Map<String, RemoteMedia> remoteMediaMap = {
      for (var r in remote) r.checksum!: r
    };

    // A set to track checksums that have both local and remote counterparts
    HashSet<String> localAndRemoteHashes = HashSet();

    // Process local media and check if there's a remote counterpart
    for (var localMedia in local) {
      var remoteMedia = remoteMediaMap[localMedia.checksum];

      if (remoteMedia != null) {
        // Local media has a corresponding remote media
        mediaAssets.add(LocalMedia(remoteMedia.id, localMedia.path,
            localMedia.id, localMedia.checksum, localMedia.timestamp));
        localAndRemoteHashes.add(localMedia.checksum!);
      } else {
        // Local media exists only locally
        mediaAssets.add(LocalMedia(null, localMedia.path, localMedia.id,
            localMedia.checksum, localMedia.timestamp));
      }
    }

    // Add remote media that doesn't have a local counterpart
    for (var remoteMedia in remote) {
      if (!localAndRemoteHashes.contains(remoteMedia.checksum)) {
        mediaAssets.add(remoteMedia);
      }
    }

    // Sort the mediaAssets by timestamp, descending
    mediaAssets.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return mediaAssets;
  }
}

// The background isolate function
void backgroundMediaLoader(List args) async {
  SendPort sendPort = args[0];
  RootIsolateToken rootToken = args[1];
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);

  List<MediaInfo> localMedia = await SyncManager().getAllLocalMedia();

  List<LocalMedia> calculatedLocalMedia = [];
  for (var (ind, asset) in localMedia.indexed) {
    String checksum =
        // FIXME: GetOrComputeChecksum (don't forget to maybe make the db global)
        await computeChecksum(asset.path);

    // Create a new LocalMedia item
    LocalMedia newMedia =
        LocalMedia(null, asset.path, asset.id, checksum, asset.timestamp);

    // Add the new media item to the list
    calculatedLocalMedia.add(newMedia);

    // Send the updated media list back to the main thread
    if (ind % 100 == 0) {
      print("Sent 100 more pictures to the frontend");
      sendPort.send(calculatedLocalMedia);
      calculatedLocalMedia.clear();
    }
  }
  sendPort.send(calculatedLocalMedia);

  // Once done, send a completion message (if needed)
  sendPort.send("done");
}
