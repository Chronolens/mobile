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
          
        }
      },
      child: widget.thumbnail,
    );
  }
}
