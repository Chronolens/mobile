import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalMedia extends MediaAsset {
  String? remoteId;
  String path;
  String id;

  LocalMedia(
      this.remoteId, this.path, this.id, super.checksum, super.timestamp);

  @override
  Future<Widget> getPreview() async {
    final preview = await AssetEntity.fromId(id);
    final thumbnail = await preview?.thumbnailData;

    return thumbnail != null
        ? Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.memory(thumbnail!).image,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              if (remoteId != null) // Only add the icon if remoteId is not null
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
          )
        : Container(
            color: Colors.grey,
          );
  }
}
