import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/sync_manager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'preview_container.dart';

class ImageGrid extends StatefulWidget {
  const ImageGrid({super.key});

  @override
  ImageGridState createState() => ImageGridState();
}

class ImageGridState extends State<ImageGrid> {
  static const _pageSize = 40;
  final PagingController<int, MediaAsset> _pagingController =
      PagingController(firstPageKey: 0);

  final Map<String, Widget?> _thumbnailCache = {};
  List<MediaAsset> paths = [];
  bool _isPathsLoaded = false; // Add this flag

  Future<void> initSyncManager() async {
    paths = await SyncManager().sync();
    setState(() {
      _isPathsLoaded = true; // Update the flag after paths are loaded
    });
  }

  @override
  void initState() {
    super.initState();
    initSyncManager().then((_) {
      _pagingController.addPageRequestListener((pageKey) {
        if (_isPathsLoaded) {
          _loadAssets(pageKey);
        }
      });
    });
  }

  Future<void> _loadAssets(int pageKey) async {
    try {
      print("before paths");
      if (paths.isNotEmpty) {
        final List<MediaAsset> newAssets =
            paths.skip(pageKey * _pageSize).take(_pageSize).toList();
        print("assets ${newAssets.length}");
        final isLastPage = newAssets.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newAssets);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newAssets, nextPageKey);
        }
      }
      print("after paths");
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<Widget?> _getThumbnail(MediaAsset asset) async {
    if (_thumbnailCache.containsKey(asset.checksum)) {
      return _thumbnailCache[asset.checksum];
    }

    final Widget thumbnail = await asset.getPreview();
    _thumbnailCache[asset.checksum] = thumbnail;
    return thumbnail;


  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until paths are loaded
    if (!_isPathsLoaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return PagedGridView<int, MediaAsset>(
      pagingController: _pagingController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      builderDelegate: PagedChildBuilderDelegate<MediaAsset>(
        itemBuilder: (context, asset, index) {
          return FutureBuilder<Widget?>(
            future: _getThumbnail(asset),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return PreviewContainer(
                  asset: asset,
                  thumbnail: snapshot.data,
                );
              } else {
                return Container(
                  color: Colors.grey[300],
                );
              }
            },
          );
        },
        firstPageErrorIndicatorBuilder: (context) => Center(
          child: Text('Failed to load images'),
        ),
        newPageErrorIndicatorBuilder: (context) => Center(
          child: Text('Failed to load more images'),
        ),
        noItemsFoundIndicatorBuilder: (context) => Center(
          child: Text('No images found'),
        ),
      ),
    );
  }
}
