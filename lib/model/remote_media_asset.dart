import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/api_service.dart';

class RemoteMedia extends MediaAsset {
  String id;

  RemoteMedia(this.id, super.checksum, super.timestamp);

  factory RemoteMedia.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final checksum = json['hash'] as String;
    final timestamp = json['created_at'] as int;
    return RemoteMedia(id, checksum, timestamp);
  }

  @override
  bool eq(MediaAsset other) {
    if (other is! RemoteMedia) {
      return false;
    }

    return true;
  }

  @override
  Future<Widget> getPreview() async {
    String imgUrl = await APIServiceClient().getPreview(id);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.network(imgUrl).image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8.0,
          right: 8.0,
          child: Icon(
            Icons.cloud,
            size: 16.0,
            color: Colors.lightBlueAccent,
          ),
        ),
      ],
    );
  }
}
