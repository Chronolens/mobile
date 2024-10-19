import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:photo_manager/photo_manager.dart';

class LocalMedia extends MediaAsset {
  String? remoteId;
  String path;
  String id;
  AssetEntity? asset;
  Widget? thumbnailWidget;

  LocalMedia(this.remoteId, this.path, this.id, super.checksum, super.timestamp)
      : asset = null;

  @override
  bool eq(MediaAsset other) {
    if (other is! LocalMedia) {
      return false;
    }

    if (other.remoteId != remoteId) {
      return false;
    }

    return true;
  }

  @override
  Future<Widget> getPreview() async {
    asset ??= await AssetEntity.fromId(id);
    if (thumbnailWidget == null) {
      final thumbnail = await asset?.thumbnailData;

      thumbnailWidget = thumbnail != null
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
    return thumbnailWidget!;
  }
}
