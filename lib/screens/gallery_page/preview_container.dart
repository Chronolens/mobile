import 'package:flutter/material.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/api_service.dart';

class PreviewContainer extends StatefulWidget {
  final MediaAsset asset;
  final Widget? thumbnail;

  const PreviewContainer({super.key, required this.asset, this.thumbnail});

  @override
  PreviewContainerState createState() => PreviewContainerState();
}

class PreviewContainerState extends State<PreviewContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.asset is LocalMedia &&
            ((widget.asset as LocalMedia).remoteId == null)) {
          print('File tapped: ${(widget.asset as LocalMedia).path}');
          APIServiceClient()
              .uploadFileStream((widget.asset as LocalMedia).path);
        } else {
          print("This is remote: ${widget.asset.checksum}");
        }
      },
      child: widget.thumbnail,
    );
  }
}
                //if (_isUploaded) // Widget for the icon, still need to change all icons to the icon pack in the design
                //  Positioned(
                //    top: 8.0,  
                //    right: 8.0, 
                //    child: Icon(
                //      Icons.cloud_done, 
                //      size: 24.0,       
                //      color: Colors.purple.shade400, 
                //    ),
                //  ),
