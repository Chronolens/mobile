import 'package:isar/isar.dart';
import 'package:mobile/model/checksum.dart';
import 'package:mobile/model/remote_asset_db.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  late Isar database;

  static Future<DatabaseService> create() async {
    DatabaseService databaseService = DatabaseService();
    final dir = await getApplicationDocumentsDirectory();
    databaseService.database = await Isar.open(
      [ChecksumSchema, RemoteAssetDbSchema],
      directory: dir.path,
    );
    return databaseService;
  }

  Future<void> storeChecksumInDatabase(String localId, String checksum) async {
    final newChecksum = Checksum()
      ..localId = localId
      ..checksum = checksum;

    await database.writeTxn(() async {
      await database.checksums.put(newChecksum);
    });
  }

  Future<String?> checkChecksumInDatabase(String localId) async {
    final existingChecksum =
        await database.checksums.filter().localIdEqualTo(localId).findFirst();

    if (existingChecksum != null) {
      return existingChecksum.checksum;
    }
    return null;
  }

  Future<List<Checksum>> getChecksumsFromList(List<String> ids) async {
    return ids.isEmpty
        ? []
        : await database.checksums
            .filter()
            .anyOf(ids, (q, String id) => q.localIdEqualTo(id))
            .findAll();
  }

  Future<void> upsertRemoteAssets(List<RemoteMedia> remoteMedia) async {
    final remoteAssetsDB = remoteMedia
        .map((r) => RemoteAssetDb()
          ..remoteId = r.id
          ..checksum = r.checksum!
          ..timestamp = r.timestamp)
        .toList();

    
    await database.writeTxn(() async {
      print(await database.remoteAssetDbs.putAll(remoteAssetsDB));
    });
  }

  Future<void> deleteRemoteAssets(List<String> remoteIds) async {
    if (remoteIds.isEmpty) {
      
      return; // Do nothing if the list is empty
    }

    
    await database.writeTxn(() async {
      print(await database.remoteAssetDbs
          .filter()
          .anyOf(remoteIds, (q, String remoteId) => q.remoteIdEqualTo(remoteId))
          .deleteAll());
    });
  }

  Future<List<RemoteMedia>> getRemoteAssets() async {
    List<RemoteAssetDb> remoteMediaList = [];
    await database.txn(() async {
      remoteMediaList = await database.remoteAssetDbs.where().findAll();
    });

    
    return remoteMediaList
        .map((r) => RemoteMedia(r.remoteId, r.checksum, r.timestamp))
        .toList();
  }

  Future<void> close() async {
    await database.close();
  }
}
