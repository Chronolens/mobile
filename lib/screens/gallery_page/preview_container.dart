import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:mobile/services/api_service.dart';

class PreviewContainer extends StatefulWidget {
  final AssetEntity asset;
  final Uint8List? thumbnail;

  const PreviewContainer({Key? key, required this.asset, this.thumbnail})
      : super(key: key);

  @override
  _PreviewContainerState createState() => _PreviewContainerState();
}

class _PreviewContainerState extends State<PreviewContainer> {
  bool _isUploaded = false; 

  Future<String?> _getFilePath(AssetEntity asset) async {
    final file = await asset.file;
    return file?.path;
  }

  Future<void> _uploadFile(String filePath) async {
    print('File tapped: ${widget.asset.title}');
    await APIServiceClient().upload(filePath);
    
    setState(() {
      _isUploaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.thumbnail != null
        ? GestureDetector(
            onTap: () async {
              var filePath = await _getFilePath(widget.asset);

              if (filePath != null) {
                await _uploadFile(filePath);
              } else {
                print('Error: Unable to retrieve file path');
              }
            },
            child: Stack(
              children: [
                
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(widget.thumbnail!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                if (_isUploaded) // Widget for the icon, still need to change all icons to the icon pack in the design
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
            ),
          )
        : Container(
            color: Colors.grey, 
          );
  }
}
