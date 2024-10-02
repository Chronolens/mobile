import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';


class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<AssetEntity> _assets = [];
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });


    if (Platform.isAndroid){
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = int.parse(androidInfo.version.release);

      if (androidVersion >= 13) {
         if (await Permission.photos.isDenied || await Permission.videos.isDenied ) {
            setState(() {
              _isLoading = false;
              _hasMore = false;
              _errorMessage = "Permission denied. Access to the storage is needed to display your gallery.";
            });
            await [
              Permission.photos,
              Permission.videos,
            ].request();
         }
      }
      else { 
        if ( await Permission.storage.isDenied ) {
            setState(() {
              _isLoading = false;
              _hasMore = false;
              _errorMessage = "Permission denied. Access to the storage is needed to display your gallery.";
            });
            await Permission.storage.request();
        }
      }
    }

    // #TODO: Automatic loading

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    if (paths.isNotEmpty) {
      final List<AssetEntity> newAssets = await paths[0].getAssetListPaged(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        if (newAssets.length < _pageSize) {
          _hasMore = false;
        }
        _assets.addAll(newAssets);
        _isLoading = false;
        _currentPage++;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasMore = false;
        _errorMessage = "No images found in your gallery.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _loadAssets();
        }
        return false;
      },
      child: _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _assets.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _assets.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                return FutureBuilder<Uint8List?>(
                  future: _assets[index].thumbnailData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: MemoryImage(snapshot.data!),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      );
                    }
                    return Container(
                      color: Colors.grey,
                    );
                  },
                );
              },
            ),
    );
  }
}
