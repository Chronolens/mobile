import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile/services/database_service.dart';
import 'package:photo_manager/photo_manager.dart';

Future<String> computeChecksumIOS(String id) async {
  File? file = await (await AssetEntity.fromId(id))?.originFile;

  final fileStream = file!.openRead();
  return base64.encode((await sha1.bind(fileStream).first).bytes);
}

Future<String> computeChecksumAndroid(String path) async {
  File file = File(path);
  final fileStream = file.openRead();
  return base64.encode((await sha1.bind(fileStream).first).bytes);
}

Future<String?> getOrComputeChecksum(
    String id, String path, DatabaseService database) async {

  String? checksum = await database.checkChecksumInDatabase(id);

  if (checksum == null) {
    if (Platform.isIOS) {
      checksum = await computeChecksumIOS(id);
    } else {
      checksum = await computeChecksumAndroid(path);
    }
    await database.storeChecksumInDatabase(id, checksum);
  }
  return checksum;
}
