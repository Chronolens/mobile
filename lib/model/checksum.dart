import 'package:isar/isar.dart';

part 'checksum.g.dart';

@collection
class Checksum {
  Id id = Isar.autoIncrement;

  late String localId;
  late String checksum;
}
