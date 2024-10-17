import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mobile/services/database_service.dart';

Future<String> computeChecksum(String path) async {
    File file = File(path);
    final fileStream = file.openRead();
    return base64.encode((await sha1.bind(fileStream).first).bytes);
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
