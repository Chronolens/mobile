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
  late List<MediaAsset> assets = [];
  List<List<int>> assetChunkIndexes = [];
  final SyncManager syncManager = SyncManager();
  bool _isAssetsLoaded = false;

  Future<void> initSyncManager() async {
    assets = await syncManager.getAssetStructure();
    assetChunkIndexes = syncManager.splitIntoChunks(assets, _pageSize);
    setState(() {
      _isAssetsLoaded = true; // Mark assets as loaded
    });
  }

  @override
  void initState() {
    // Load assets and only after loading, add the paging listener
    initSyncManager().then((_) {
      _pagingController.addPageRequestListener((pageKey) {
        _loadAssets(pageKey);
      });
    });
    super.initState();
  }

  Future<void> _loadAssets(int pageKey) async {
    try {
      print("Loading assets");
      print("Assets Length is ${assets.length}");
      if (assets.isNotEmpty) {
        final List<MediaAsset> newAssets = assets
            .getRange(
                assetChunkIndexes[pageKey][0], assetChunkIndexes[pageKey][1])
            .toList();

        print("before resolver");
        List<MediaAsset> resolvedAssets = await syncManager.resolver(newAssets);
        print("assets ${resolvedAssets.length}");
        final isLastPage = assets.length - 1 == assetChunkIndexes[pageKey][1];
        if (isLastPage) {
          _pagingController.appendLastPage(resolvedAssets);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(resolvedAssets, nextPageKey);
        }
      }
      print("Finished Loading assets");
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<Widget?> _getThumbnail(MediaAsset asset) async {
    if (_thumbnailCache.containsKey(asset.checksum)) {
      return _thumbnailCache[asset.checksum];
    }

    final Widget thumbnail = await asset.getPreview();
    _thumbnailCache[asset.checksum!] = thumbnail;
    return thumbnail;
  }

  Future<void> _refreshList() async {
    assets = await syncManager.getAssetStructure();
    assetChunkIndexes = syncManager.splitIntoChunks(assets, _pageSize);
    _thumbnailCache.clear();
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until paths are loaded
    return _isAssetsLoaded // Only display grid if assets are loaded
        ? RefreshIndicator(
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
            ))
        : Center(
            child:
                CircularProgressIndicator()); // Loading indicator before assets are loaded
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
