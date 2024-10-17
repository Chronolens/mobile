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
  List<MediaAsset> assets = [];
  List<List<int>> assetChunkIndexes = [];
  bool _isPathsLoaded = false; // Add this flag
  final SyncManager syncManager = SyncManager();

  Future<void> initSyncManager() async {
    List<MediaAsset> newAssets = await syncManager.getAssetStructure();
    print("before chunks");
    assetChunkIndexes = syncManager.splitIntoChunks(newAssets, _pageSize);
    print("after chunks");
    assets = newAssets;
    setState(() {
      _isPathsLoaded = true; // Update the flag after paths are loaded
    });
    print("after setState()");
  }

  @override
  void initState() {
    super.initState();
    initSyncManager().then((_) {
        print("arrived at pageController");
      _pagingController.addPageRequestListener((pageKey) {
        print("entered at pageController");
        if (_isPathsLoaded) {
          print("arrived at loadAssets()");
          _loadAssets(pageKey);
        }
      });
    });
  }

  Future<void> _loadAssets(int pageKey) async {
    try {
      print("before paths");
      if (assets.isNotEmpty) {
        final List<MediaAsset> newAssets = assets
            .getRange(
                assetChunkIndexes[pageKey][0], assetChunkIndexes[pageKey][1])
            .toList();

        List<MediaAsset> resolvedAssets = await syncManager.resolver(newAssets);
        print("assets ${resolvedAssets.length}");
        final isLastPage = resolvedAssets.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(resolvedAssets);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(resolvedAssets, nextPageKey);
        }
      }
      print("after paths");
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<Widget?> _getThumbnail(MediaAsset asset) async {
    //if (_thumbnailCache.containsKey(asset.checksum)) {
    //  return _thumbnailCache[asset.checksum];
    //}

    final Widget thumbnail = await asset.getPreview();
    //_thumbnailCache[asset.checksum] = thumbnail;
    return thumbnail;
  }

  Future<void> _refreshList() async {
    assets = await syncManager.getAssetStructure();
    _thumbnailCache.clear();
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until paths are loaded
    return RefreshIndicator(
        onRefresh: _refreshList,
        child: PagedGridView<int, MediaAsset>(
          pagingController: _pagingController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 2.0,
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
        ));
  }
}
