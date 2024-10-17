import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/media_info.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/utils/constants.dart';
import 'package:mobile/utils/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncManager {
  //Native Module
  static const platform = MethodChannel('com.example.mobile/images');

  Future<List<MediaAsset>> getAssetStructure() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    int? lastSync = await asyncPrefs.getInt(LAST_SYNC);

    List<MediaAsset> assets = [];

    List<MediaInfo> local = await getAllImagePathsNative();
    for (var localAsset in local) {
      assets.add(LocalMedia(
          null, localAsset.path, localAsset.id, null, localAsset.timestamp));
    }

    if (lastSync == null) {
      // DO FULL SYNC

      // Map of remote id to RemoteMedia
      Map<String, RemoteMedia> remote =
          await APIServiceClient().syncFullRemote();

      await asyncPrefs.setInt(LAST_SYNC, DateTime.now().millisecondsSinceEpoch);

      await asyncPrefs.setString(REMOTE_ASSETS, jsonEncode(remote));

      for (var remoteMedia in remote.values) {
        assets.add(remoteMedia);
      }
      print("finish");
    } else {
      // DO PARTIAL SYNC

      // Sync partial remote
      List remote = await APIServiceClient().syncPartialRemote(lastSync);
      await asyncPrefs.setInt(LAST_SYNC, DateTime.now().millisecondsSinceEpoch);

      // Map the uploaded items from the remote sync
      final Map<String, RemoteMedia> uploadedMap =
          (remote[0] as Map).map<String, RemoteMedia>((key, value) {
        return MapEntry(key, RemoteMedia.fromJson(value, key));
      });

      // Cast the list of deleted items to List<String>
      List<String> deletedList = (remote[1] as List).cast<String>();

      // Get the remote media from local storage
      String? savedRemoteMediaJson = await asyncPrefs.getString(REMOTE_ASSETS);
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
      await asyncPrefs.setString(REMOTE_ASSETS, jsonEncode(savedRemoteMedia));

      // Update remoteAssets with the checksums
      for (var remoteMedia in savedRemoteMedia.values) {
        assets.add(remoteMedia);
      }
      //}
    }
    print("before sort");
    assets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    print("after sort");
    print("finished getAssetstructure()");
    // Call syncResolver with localAssets and remoteAssets
    return assets;
  }

  List<List<int>> splitIntoChunks(List<MediaAsset> assets, int chunkSize) {
    List<List<int>> chunks = [];
    int start = 0;

    // Loop over the list and create chunks
    while (start < assets.length) {
      int end = start;
      // Try to extend the chunk to at least chunkSize
      while (end < assets.length && end - start + 1 < chunkSize) {
        end++;
      }

      // Now, extend until the timestamp changes to avoid splitting identical timestamps
      while (end < assets.length - 1 &&
          assets[end].timestamp == assets[end + 1].timestamp) {
        end++;
      }

      // Add the chunk to the list, with start and end (inclusive)
      chunks.add([start, end]);

      // Move to the next chunk (starting after this chunk)
      start = end + 1;
    }

    return chunks;
  }

  Future<List<MediaInfo>> getAllImagePathsNative() async {
    try {
      // Call the method on the platform (Android in this case)
      print("before native");
      final List<dynamic> paths =
          await platform.invokeMethod('getAllImagePathsNative');

      List<MediaInfo> localMediaInfo = [];
      for (var pair in paths) {
        List<String> s =
            (pair as List<dynamic>).map((e) => e.toString()).toList();
        //File file = File(s[0]);
        localMediaInfo.add(MediaInfo(
            s[0], int.parse(s[2]) /* await getFileStamp(file) */, s[1]));
      }
      print("before native");
      return localMediaInfo;
    } on PlatformException catch (_) {
      return [];
    }
  }

  Future<String> computeChecksum(String path) async {
    File file = File(path);
    final fileStream = file.openRead();
    return base64.encode((await sha256.bind(fileStream).first).bytes);
  }

  Future<String?> getOrComputeChecksum(
      String id, String path, DatabaseService database) async {
    String? checksum = await database.checkChecksumInDatabase(id);

    if (checksum == null) {
      checksum = await computeChecksum(path);
      await database.storeChecksumInDatabase(id, checksum);
    }
    return checksum;
  }

  Future<List<MediaAsset>> resolver(List<MediaAsset> chunk) async {
    DatabaseService database = await DatabaseService.create();
    List<MediaAsset> resolvedAssets = [];

    // Iterate through the sorted list and look for pairs of matching assets
    for (int i = 0; i < chunk.length; i++) {
      MediaAsset currentAsset = chunk[i];

      // If it's a local media and the checksum is null, calculate it
      if (currentAsset is LocalMedia) {
        currentAsset.checksum = await getOrComputeChecksum(
            currentAsset.id, currentAsset.path, database);
      }

      // Check if the next asset exists and whether it needs checksum computation
      if (i + 1 < chunk.length) {
        MediaAsset nextAsset = chunk[i + 1];

        if (nextAsset is LocalMedia) {
          nextAsset.checksum = await getOrComputeChecksum(
              nextAsset.id, nextAsset.path, database);
        }

        // Only merge if one is LocalMedia and the other is RemoteMedia, and their checksums match
        if (currentAsset.timestamp == nextAsset.timestamp &&
            currentAsset.checksum != null &&
            currentAsset.checksum == nextAsset.checksum) {
          // If both are local or both are remote, don't merge
          if (currentAsset is LocalMedia && nextAsset is RemoteMedia) {
            // Merge remote into local
            currentAsset.remoteId = nextAsset.id;
            resolvedAssets.add(currentAsset); // Add the merged LocalMedia
            i++; // Skip the next asset, since it's merged
          } else if (currentAsset is RemoteMedia && nextAsset is LocalMedia) {
            // Merge local into remote
            nextAsset.remoteId = currentAsset.id;
            resolvedAssets.add(nextAsset); // Add the merged LocalMedia
            i++; // Skip the next asset, since it's merged
          } else {
            // If both are LocalMedia or both are RemoteMedia, just add them separately
            resolvedAssets.add(currentAsset);
          }
        } else {
          // If no merging, add the current asset to the resolved list
          resolvedAssets.add(currentAsset);
        }
      } else {
        // If it's the last item in the list, add it to the resolved list
        resolvedAssets.add(currentAsset);
      }
    }
    database.close();
    return resolvedAssets;
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

  void insertAssets(List<MediaAsset> current, List<LocalMedia> local) {}
}
