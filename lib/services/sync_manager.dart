import 'dart:collection';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:mobile/model/checksum.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/media_info.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/utils/checksum.dart';
import 'package:mobile/utils/constants.dart';
import 'package:photo_manager/photo_manager.dart';
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

      //final List<dynamic> paths =
      //    await platform.invokeMethod('getAllImagePathsNative');

      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      List<MediaInfo> localMediaInfo = [];

      for (final album in albums) {
        List<AssetEntity> media =
            await album.getAssetListRange(start: 0, end: 100);

        //for (final asset in media) {
        //  final file = await asset.file;
        //  if (file != null) {
        //    final id = asset.id;
        //    final createDateTime = asset.createDateTime.millisecondsSinceEpoch;
        //    final modifiedDateTime =
        //        asset.modifiedDateTime.millisecondsSinceEpoch;
        //
        //    // TODO: This could be better, maybe append and then reverse?
        //
        //    localMediaInfo.insert(
        //        0,
        //        MediaInfo(
        //            file.path,
        //            createDateTime == 0 ? modifiedDateTime : createDateTime,
        //            id));
        //  }
        }
      }

      //for (var pair in paths) {
      //  List<String> s =
      //      (pair as List<dynamic>).map((e) => e.toString()).toList();
      //  localMediaInfo.insert(0, MediaInfo(s[0], int.parse(s[2]), s[1]));
      //}
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
