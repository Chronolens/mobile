import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'preview_container.dart';

class ImageGrid extends StatefulWidget {
  const ImageGrid({super.key});

  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  static const _pageSize = 100;
  final PagingController<int, AssetEntity> _pagingController =
      PagingController(firstPageKey: 0);

  final Map<String, Uint8List?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _loadAssets(pageKey);
    });
  }

  Future<void> _loadAssets(int pageKey) async {
    try {
      
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.fromTypes([RequestType.image,RequestType.video])
      );

      if (paths.isNotEmpty) {
        final List<AssetEntity> newAssets = await paths[0].getAssetListPaged(
          page: pageKey,
          size: _pageSize,
        );

        final isLastPage = newAssets.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newAssets);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newAssets, nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<Uint8List?> _getThumbnail(AssetEntity asset) async {
    if (_thumbnailCache.containsKey(asset.id)) {
      return _thumbnailCache[asset.id];
    }

    final Uint8List? thumbnail = await asset.thumbnailData;
    _thumbnailCache[asset.id] = thumbnail; 
    return thumbnail;
  }




  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, AssetEntity>(
      pagingController: _pagingController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      builderDelegate: PagedChildBuilderDelegate<AssetEntity>(
        itemBuilder: (context, asset, index) {
          return FutureBuilder<Uint8List?>(
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
