import 'package:isar/isar.dart';
import 'package:mobile/model/checksum.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  late Isar database;

  static Future<DatabaseService> create() async {
    DatabaseService databaseService = DatabaseService();
    final dir = await getApplicationDocumentsDirectory();
    databaseService.database = await Isar.open(
      [ChecksumSchema],
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

  Future<void> close() async {
    await database.close();
  }
}
