import 'package:isar/isar.dart';

part 'checksum.g.dart';

@collection
class Checksum {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String localId;
  late String checksum;
}
