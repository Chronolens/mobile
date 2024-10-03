import 'dart:convert';
import 'package:http/http.dart' as http;




// List<MediaFile> mediaFileFromJson(String str) =>
//     List<MediaFile>.from(json.decode(str).map((x) => MediaFile.fromJson(x)));

// String mediaFileToJson(List<MediaFile> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class MediaFile {
//   String? fileName;
//   String? fileType;
//   int? fileSize;
//   List<int>? fileChunks; // File data as chunks
//   //MetaData? metaData; // Optional metadata

//   MediaFile({
//     this.fileName,
//     this.fileType,
//     this.fileSize,
//     this.fileChunks,
//     //this.metaData,
//   });

//   factory MediaFile.fromJson(Map<String, dynamic> json) {
//     return MediaFile(
//       fileName: json["fileName"],
//       fileType: json["fileType"],
//       fileSize: json["fileSize"],
//       fileChunks: json["fileChunks"] == null ? [] : List<int>.from(json["fileChunks"]),
//       //metaData: json["metaData"] == null ? null : MetaData.fromJson(json["metaData"]),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     "fileName": fileName,
//     "fileType": fileType,
//     "fileSize": fileSize,
//     "fileChunks": fileChunks == null ? [] : List<dynamic>.from(fileChunks!),
//     //"metaData": metaData?.toJson(),
//   };
// }

/*
class MetaData {
  String? createdBy;
  DateTime? creationDate;

  MetaData({
    this.createdBy,
    this.creationDate,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) => MetaData(
        createdBy: json["createdBy"],
        creationDate: json["creationDate"] == null ? null : DateTime.parse(json["creationDate"]),
      );

  Map<String, dynamic> toJson() => {
        "createdBy": createdBy,
        "creationDate": creationDate?.toIso8601String(),
      };
}
*/