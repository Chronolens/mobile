import 'dart:io';
import 'package:exif/exif.dart';

Future<int> getFileStamp(File file) async {

  final data = await readExifFromFile(file);
  final imageDateTime = data["Image DateTime"]?.printable.replaceFirst(':', '-').replaceFirst(':', '-');
  final eXIFDateTimeOriginal = data["EXIF DateTimeOriginal"]?.printable.replaceFirst(':', '-').replaceFirst(':', '-');
  final eXIFDateTimeDigitized = data["EXIF DateTimeDigitized"]?.printable.replaceFirst(':', '-').replaceFirst(':', '-');

  final int timeStamp;

  if (imageDateTime != null) {
    DateTime dateTime = DateTime.parse(imageDateTime);
    timeStamp = dateTime.millisecondsSinceEpoch;
  } else if (eXIFDateTimeOriginal != null) {
    DateTime dateTime = DateTime.parse(eXIFDateTimeOriginal);
    timeStamp = dateTime.millisecondsSinceEpoch;
  } else if (eXIFDateTimeDigitized != null) {
    DateTime dateTime = DateTime.parse(eXIFDateTimeDigitized);
    timeStamp = dateTime.millisecondsSinceEpoch;
  } else {
    final stat = FileStat.statSync(file.path);
    timeStamp = stat.modified.millisecond;
  }

  return timeStamp;
}
