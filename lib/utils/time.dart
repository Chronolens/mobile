import 'dart:io';
import 'package:exif/exif.dart';

Future<int> getFileStamp(File file) async {
  final data = await readExifFromFile(file);
  
  final imageDateTime = data["Image DateTime"]
      ?.printable
      .replaceFirst(':', '-')
      .replaceFirst(':', '-');
  final eXIFDateTimeOriginal = data["EXIF DateTimeOriginal"]
      ?.printable
      .replaceFirst(':', '-')
      .replaceFirst(':', '-');
  final eXIFDateTimeDigitized = data["EXIF DateTimeDigitized"]
      ?.printable
      .replaceFirst(':', '-')
      .replaceFirst(':', '-');


  final int timestamp;

  if (imageDateTime != null) {
    DateTime dateTime = DateTime.parse(imageDateTime);
    timestamp = dateTime.millisecondsSinceEpoch;
  } else if (eXIFDateTimeOriginal != null) {
    DateTime dateTime = DateTime.parse(eXIFDateTimeOriginal);
    timestamp = dateTime.millisecondsSinceEpoch;
  } else if (eXIFDateTimeDigitized != null) {
    DateTime dateTime = DateTime.parse(eXIFDateTimeDigitized);
    timestamp = dateTime.millisecondsSinceEpoch;
  } else {
    final stat = FileStat.statSync(file.path);
    timestamp = stat.modified.millisecondsSinceEpoch;
  }

  return timestamp;
}
