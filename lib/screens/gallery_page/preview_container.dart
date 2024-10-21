import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/screens/gallery_page/photo_view.dart'; // Import the new screen

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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullscreenPhotoView(asset: widget.asset),
          ),
        );
      },
      child: widget.thumbnail,
    );
  }
}
