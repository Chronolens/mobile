import 'package:flutter/material.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/api_service.dart';

class PreviewContainer extends StatelessWidget {
  final MediaAsset asset;
  final Widget? thumbnail;

  const PreviewContainer({super.key, required this.asset, this.thumbnail});

  // #TODO:

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (asset is LocalMedia && ((asset as LocalMedia).remoteId == null)) {
          print('File tapped: ${(asset as LocalMedia).path}');
          APIServiceClient().uploadFileStream((asset as LocalMedia).path);
        } else {
          print("This is remote: ${asset.checksum}");
        }
      },
      child: thumbnail,
    );
  }
}
