import 'package:isar/isar.dart';
import 'package:mobile/model/remote_media_asset.dart';

part 'remote_asset_db.g.dart';

@collection
class RemoteAssetDb {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true, replace: true)
  late String remoteId;
  late String checksum;
  late int timestamp;

}
