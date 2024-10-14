import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'image_grid.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  GalleryPageState createState() => GalleryPageState();
}

class GalleryPageState extends State<GalleryPage> {
  bool _permissionState = false; 

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = int.parse(androidInfo.version.release);

      if (androidVersion >= 13) {
        var statusPhotos = await Permission.photos.request();
        var statusVideos = await Permission.videos.request();
        setState(() {
          _permissionState = statusPhotos.isGranted && statusVideos.isGranted;
        });
      } else {
        var statusStorage = await Permission.storage.request();
        setState(() {
          _permissionState = statusStorage.isGranted;
        });
      }
    }
    // #TODO: Handle iOS permissions
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionState) {
      return Center(
        child: Text(
          'No permissions to access media',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    else {
      return const ImageGrid();
    }
  }
}






