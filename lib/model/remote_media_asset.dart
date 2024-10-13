import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/api_service.dart';
import 'package:photo_manager/photo_manager.dart';

class RemoteMedia extends MediaAsset {
  String id;

  RemoteMedia(this.id, super.checksum, super.timestamp);

  factory RemoteMedia.fromJson(Map<String, dynamic> json, String checksum) {
    final id = json['id'] as String;
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
