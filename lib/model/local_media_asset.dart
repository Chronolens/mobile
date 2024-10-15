import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalMedia extends MediaAsset {
  String? remoteId;
  String path;
  String id;
  AssetEntity? asset;

  LocalMedia(
      this.remoteId, this.path, this.id, super.checksum, super.timestamp)
    : asset = null;

  @override
  Future<Widget> getPreview() async {
    asset ??= await AssetEntity.fromId(id);
    final thumbnail = await asset?.thumbnailData;

    return thumbnail != null
        ? Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: Image.memory(thumbnail).image,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              if (remoteId !=
                  null) // Widget for the icon, still need to change all icons to the icon pack in the design
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Icon(
                    Icons.cloud_done,
                    size: 24.0,
                    color: Colors.purple.shade400,
                  ),
                ),
            ],
          )
        : Container(
            color: Colors.grey,
          );
  }
}
