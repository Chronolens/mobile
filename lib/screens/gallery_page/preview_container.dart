import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/api_service.dart';

class PreviewContainer extends StatelessWidget {
  final MediaAsset asset;
  final Uint8List? thumbnail;

  const PreviewContainer({Key? key, required this.asset, this.thumbnail})
      : super(key: key);

  // #TODO:

  @override
  Widget build(BuildContext context) {
    return thumbnail != null
        ? GestureDetector(
            onTap: () async {
              if (asset is LocalMedia) {
                print('File tapped: ${(asset as LocalMedia).path}');
                APIServiceClient().uploadFileStream((asset as LocalMedia).path);
              } else {
                print("This is remote: ${asset.checksum}");
              }
            },
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: MemoryImage(thumbnail!),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          )
        : Container(
            color: Colors.grey,
          );
  }
}
