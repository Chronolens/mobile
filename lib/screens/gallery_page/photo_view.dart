import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mobile/services/api_service.dart';

class FullscreenPhotoView extends StatelessWidget {
  final MediaAsset asset;

  const FullscreenPhotoView({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          Center(
            child: FutureBuilder<Widget>(
              future: _loadFullImage(asset),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load image'));
                } else {
                  return snapshot.data!;
                }
              },
            ),
          ),

          // Top buttons for return and bookmark/save/favourite
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  onPressed: () {
                    print("Bookmark button pressed");
                  },
                ),
              ],
            ),
          ),

          // Bottom Buttons for now from left to right Metadata, share, cloud(upload or remove toggle) and delete
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    print("Menu button pressed");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {
                    print("Share button pressed");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                  onPressed: () {
                    print("Cloud button pressed");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    print("Delete button pressed");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Widget> _loadFullImage(MediaAsset asset) async {
    if (asset is LocalMedia) {
      return _getLocalFullImage(asset);
    } else if (asset is RemoteMedia) {
      return _getRemotePreviewImage(asset);
    }
    return const Center(child: Text('Unsupported media type'));
  }

  Future<Widget> _getLocalFullImage(LocalMedia asset) async {
    final assetEntity = await AssetEntity.fromId(asset.id);
    final file = await assetEntity?.file;

    if (file != null) {
      return PhotoView(
        imageProvider: FileImage(file),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      );
    }
    return const Center(child: Text('Could not load image'));
  }

  Future<Widget> _getRemotePreviewImage(RemoteMedia asset) async {
    String imgUrl = await APIServiceClient().getFullImage(asset.id);
    return PhotoView(
      imageProvider: NetworkImage(imgUrl),
      backgroundDecoration: const BoxDecoration(color: Colors.black),
    );
  }
}
