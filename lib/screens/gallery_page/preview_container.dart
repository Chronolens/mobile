import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mobile/services/api_service.dart';

class PreviewContainer extends StatelessWidget {
  final AssetEntity asset;
  final Uint8List? thumbnail;

  const PreviewContainer({Key? key, required this.asset, this.thumbnail})
      : super(key: key);

  Future<String?> _getFilePath(AssetEntity asset) async {
    final file = await asset.file;
    return file?.path;
  }


  // #TODO:

  @override
  Widget build(BuildContext context) {
    return thumbnail != null
        ? GestureDetector(
            onTap: () async {
              var filePath = await _getFilePath(asset);
              
              if (filePath != null) {
                print('File tapped: ${asset.title}');
                APIServiceClient().uploadFileStream(filePath);
              } else {
                print('Error: Unable to retrieve file path');
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
