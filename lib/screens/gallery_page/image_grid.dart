import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:mobile/services/database_service.dart';
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
  late DatabaseService database;
  final Map<String, Widget?> _thumbnailCache = {};

  List<MediaAsset> allAssets = [];

  List<RemoteMedia> remoteAssets = [];

  List<LocalMedia> localAssets = [];
  bool _isAssetsLoaded = false; // Add this flag

  Isolate? _localMediaIsolate;
  ReceivePort? _receivePort;

  Future<void> initSyncManager() async {
    database = await DatabaseService.create();
    remoteAssets = await SyncManager().getAssetStructure(database);
    mergeMediaAssets();
    setState(() {
      _isAssetsLoaded = true; // Update the flag after paths are loaded
    });
  }

  @override
  void initState() {
    super.initState();
    initSyncManager().then((_) {
      _pagingController.addPageRequestListener((pageKey) {
        if (_isAssetsLoaded) {
          _loadAssets(pageKey);
        }
      });
    });
    _startLoadingLocalAssets();
  }

  void mergeMediaAssets() {
    allAssets = SyncManager().mergeAssets(localAssets, remoteAssets);
    _pagingController.refresh();
  }

  Future<void> _loadAssets(int pageKey) async {
    try {
      if (allAssets.isNotEmpty) {
        final List<MediaAsset> newAssets =
            allAssets.skip(pageKey * _pageSize).take(_pageSize).toList();
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

  Future<Widget?> _getThumbnail(MediaAsset asset) async {
    if (_thumbnailCache.containsKey(asset.checksum)) {
      return _thumbnailCache[asset.checksum];
    }

    final Widget thumbnail = await asset.getPreview();
    _thumbnailCache[asset.checksum!] = thumbnail;
    return thumbnail;
  }

  Future<void> _refreshList() async {
    localAssets = [];
    remoteAssets = [];
    allAssets = [];
    remoteAssets = await SyncManager().getAssetStructure(database);
    _startLoadingLocalAssets();
    mergeMediaAssets();
    _thumbnailCache.clear();
    _pagingController.refresh();
  }

  void _startLoadingLocalAssets() async {
    // Clean up any existing isolate before starting a new one
    _stopLocalMediaIsolate();

    _receivePort = ReceivePort();

    // Identify the root isolate to pass to the background isolate.
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    // Spawn the isolate and pass the SendPort for communication
    _localMediaIsolate = await Isolate.spawn(
      backgroundMediaLoader,
      [_receivePort!.sendPort, rootIsolateToken],
    );

    // Listen to messages from the isolate
    _receivePort!.listen((message) {
      if (message is List<LocalMedia>) {
        // Update the localAssets with the list received from the isolate
        localAssets += List.from(message);
        mergeMediaAssets();
      } else if (message == "done") {
        print("Local media loading completed.");
      }
    });
  }

  void _stopLocalMediaIsolate() {
    if (_localMediaIsolate != null) {
      _localMediaIsolate!.kill(priority: Isolate.immediate);
      _receivePort?.close(); // Close the port
      _localMediaIsolate = null;
      _receivePort = null;
    }
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
    _stopLocalMediaIsolate();
    database.close();
    super.dispose();
  }
}
