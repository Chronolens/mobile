import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mobile/services/api_service.dart';

// TODO: Possibly transform into stateful so we can update the UI when the asset is uploaded to the cloud
// but it might not be necessary since the user can just go back and re-enter the fullscreen view
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

          // Bottom Buttons for now from left to right Metadata, share, cloud (upload/remove toggle), and delete/transfer
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

                _buildCloudIcon(asset),

                _buildDeleteOrTransferIcon(asset),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // If asset is local, either upload to cloud or show cloud icon if already in cloud
  // For remote asset, show cloud icon to remove from cloud TODO: Implement remove from cloud
  Widget _buildCloudIcon(MediaAsset asset) {

    if (asset is LocalMedia) {
      if (asset.remoteId != null) {
        return IconButton(
          icon: const Icon(Icons.cloud_done, color: Colors.lightBlueAccent),
          onPressed: () {
            print("Already in cloud: ${asset.remoteId}");
          },
        );
      } else {
        return IconButton(
          icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
          onPressed: () async {
            print("Uploading local asset: ${asset.path}");
            await APIServiceClient().uploadFileStream(asset.path);
          },
        );
      }

    }
    else if (asset is RemoteMedia) {
      return IconButton(
        icon: const Icon(Icons.cloud, color: Colors.lightBlueAccent),
        onPressed: () {
          print("Remove from cloud not implemented yet");
        },
      );
    }

    return Container(); 
  }


  // If asset is local show delete icon, if remote show download icon
  // TODO: Implement delete and download
  Widget _buildDeleteOrTransferIcon(MediaAsset asset) {

    if (asset is RemoteMedia) {
      return IconButton(
        icon: const Icon(Icons.download, color: Colors.white),
        onPressed: () {
          print("Downloading not implemented yet");
        },
      );
    } 

    else if (asset is LocalMedia) {
      return IconButton(
        icon: const Icon(Icons.delete, color: Colors.white),
        onPressed: () {
          print("Deleting not implemented yet");
        },
      );
    }
    else {
      return Container(); 
    }
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
