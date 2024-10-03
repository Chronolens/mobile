import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PreviewContainer extends StatelessWidget {
  final AssetEntity asset;
  final Uint8List? thumbnail;

  const PreviewContainer({Key? key, required this.asset, this.thumbnail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return thumbnail != null
        ? GestureDetector(
            onTap: () {
              print('File tapped: ${asset.title}');
              // #TODO: Implement the logic to upload a photo
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
            color: Colors.grey, // Placeholder while loading thumbnails
          );
  }
}
