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
import 'package:mobile/utils/constants.dart';
import 'package:mobile/utils/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncManager {
  //Native Module
  static const platform = MethodChannel('com.example.mobile/images');

  Future<List<MediaAsset>> sync() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    int? lastSync = await asyncPrefs.getInt(LAST_SYNC);

    Map<String, RemoteMedia> remoteAssets = HashMap();
    Map<String, MediaInfo> localAssets = HashMap();

    if (lastSync == null) {
      // DO FULL SYNC
      List<MediaInfo> local = await getAllImagePathsNative();

      Map<String, String> checksumCache = HashMap();

      // Generate hashes
      for (var localMedia in local) {
        File file = File(localMedia.path);
        final fileStream = file.openRead();
        String checksum =
            base64.encode((await sha256.bind(fileStream).first).bytes);
        // Add to checksum cache
        checksumCache[localMedia.id] = checksum;
        // Add to local_assets
        localAssets[checksum] = localMedia;
      }

      await asyncPrefs.setString(CHECKSUM_CACHE, jsonEncode(checksumCache));

      // Map of remote id to RemoteMedia
      Map<String, RemoteMedia> remote =
          await APIServiceClient().syncFullRemote();

      await asyncPrefs.setInt(LAST_SYNC, DateTime.now().millisecondsSinceEpoch);

      await asyncPrefs.setString(REMOTE_ASSETS, jsonEncode(remote));

      for (var remoteMedia in remote.entries) {
        remoteAssets[remoteMedia.value.checksum] = remoteMedia.value;
      }
    } else {
      // DO PARTIAL SYNC

      List<MediaInfo> local = await getAllImagePathsNative();

      String? checksumCacheJson = await asyncPrefs.getString(CHECKSUM_CACHE);
      if (checksumCacheJson != null) {
        // Decode the JSON and cast it properly
        Map<String, dynamic> decodedChecksumCache =
            jsonDecode(checksumCacheJson);
        Map<String, String> checksumCache =
            decodedChecksumCache.cast<String, String>();

        for (var localMedia in local) {
          String? hashLookup = checksumCache[localMedia.id];
          String checksum;
          if (hashLookup != null) {
            checksum = hashLookup;
          } else {
            File file = File(localMedia.path);
            final fileStream = file.openRead();
            checksum =
                base64.encode((await sha256.bind(fileStream).first).bytes);
            // Add to hash cache
            checksumCache[localMedia.id] = checksum;
          }
          // Add to local_assets
          localAssets[checksum] = localMedia;
        }

        // Store the checksum cache again
        await asyncPrefs.setString(CHECKSUM_CACHE, jsonEncode(checksumCache));

        // Sync partial remote
        List remote = await APIServiceClient().syncPartialRemote(lastSync);
        await asyncPrefs.setInt(
            LAST_SYNC, DateTime.now().millisecondsSinceEpoch);

        // Map the uploaded items from the remote sync
        final Map<String, RemoteMedia> uploadedMap =
            (remote[0] as Map).map<String, RemoteMedia>((key, value) {
          return MapEntry(key, RemoteMedia.fromJson(value, key));
        });

        // Cast the list of deleted items to List<String>
        List<String> deletedList = (remote[1] as List).cast<String>();

        // Get the remote media from local storage
        String? savedRemoteMediaJson =
            await asyncPrefs.getString(REMOTE_ASSETS);
        Map<String, RemoteMedia> savedRemoteMedia =
            (jsonDecode(savedRemoteMediaJson!) as Map<String, dynamic>)
                .map<String, RemoteMedia>((key, value) =>
                    MapEntry(key, RemoteMedia.fromJson(value, key)));

        // Add the uploaded items to saved remote media
        for (var uploadedMedia in uploadedMap.entries) {
          savedRemoteMedia[uploadedMedia.key] = uploadedMedia.value;
        }

        // Remove the deleted items from saved remote media
        for (var deleted in deletedList) {
          savedRemoteMedia.remove(deleted);
        }

        // Save the updated remote media to local storage
        await asyncPrefs.setString(
            REMOTE_ASSETS,jsonEncode(savedRemoteMedia));

        // Update remoteAssets with the checksums
        for (var remoteMedia in savedRemoteMedia.entries) {
          remoteAssets[remoteMedia.value.checksum] = remoteMedia.value;
        }
      }
    }

    // Call syncResolver with localAssets and remoteAssets
    return await syncResolver(localAssets, remoteAssets);
  }

  Future<List<MediaInfo>> getAllImagePathsNative() async {
    try {
      // Call the method on the platform (Android in this case)
      final List<dynamic> paths =
          await platform.invokeMethod('getAllImagePathsNative');

      List<MediaInfo> localMediaInfo = [];
      for (var pair in paths.take(256)) {
        List<String> s =
            (pair as List<dynamic>).map((e) => e.toString()).toList();
        File file = File(s[0]);
        localMediaInfo.add(MediaInfo(s[0], await getFileStamp(file), s[1]));
      }

      return localMediaInfo;
    } on PlatformException catch (_) {
      return [];
    }
  }

  Future<List<MediaAsset>> syncResolver(Map<String, MediaInfo> localMediaInfo,
      Map<String, RemoteMedia> remoteMediaInfo) async {
    List<MediaAsset> mediaAssets = [];
    HashSet<String> localAndRemoteHashes = HashSet();

    for (var entry in localMediaInfo.entries) {
      var remoteMedia = remoteMediaInfo[entry.key];

      if (remoteMedia != null) {
        mediaAssets.add(LocalMedia(remoteMedia.id, entry.value.path,
            entry.value.id, entry.key, entry.value.timestamp));
        localAndRemoteHashes.add(entry.key);
      } else {
        mediaAssets.add(LocalMedia(null, entry.value.path, entry.value.id,
            entry.key, entry.value.timestamp));
      }
    }
    mediaAssets.addAll(remoteMediaInfo.values.toList()
      ..removeWhere((item) => localAndRemoteHashes.contains(item.checksum)));

    mediaAssets.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    for (var a in mediaAssets) {
      print(
          "Media:${a.checksum} | ${a.timestamp} | ${a is LocalMedia ? "true" : "false"}");
    }
    print("DONE");
    return mediaAssets;
  }
}
