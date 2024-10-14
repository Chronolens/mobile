import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/api_service.dart';

class RemoteMedia extends MediaAsset {
  String id;

  RemoteMedia(this.id, super.checksum, super.timestamp);

  // Add this method to convert the object to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'hash': super.checksum,
      'created_at': super.timestamp,
    };
  }

  factory RemoteMedia.fromJson(Map<String, dynamic> json, String id) {
    final checksum = json['hash'] as String;
    final timestamp = json['created_at'] as int;
    return RemoteMedia(id, checksum, timestamp);
  }

  @override
  Future<Widget?> getPreview() async {
    String imgUrl = await APIServiceClient().getPreview(id);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.network(imgUrl).image,
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        Positioned(
          top: 8.0,
          right: 8.0,
          child: Icon(
            Icons.cloud,
            color: Colors.black,
            size: 24.0,
          ),
        ),
      ],
    );
  }
}
