import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobile/model/local_media_asset.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/model/remote_media_asset.dart';
import 'package:mobile/services/database_service.dart';
import 'package:mobile/services/sync_manager.dart';
import 'preview_container.dart';

class ImageGrid extends StatefulWidget {
  const ImageGrid({super.key});

  @override
  ImageGridState createState() => ImageGridState();
}

class ImageGridState extends State<ImageGrid>
    with AutomaticKeepAliveClientMixin<ImageGrid> {
  static const _pageSize = 64;
  late DatabaseService database;
  final Map<String, Widget?> _thumbnailCache = {};

  @override
  bool get wantKeepAlive => true;

  List<MediaAsset> allAssets = []; // All assets in the database
  List<MediaAsset> displayedAssets = []; // Paginated assets to be displayed
  List<RemoteMedia> remoteAssets = [];
  List<LocalMedia> localAssets = [];

  bool _isAssetsLoaded = false; // Flag to check if assets are loaded
  bool _isLoadingMore = false; // Flag to manage loading state for more assets

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
    _startLoadingLocalAssets();
    initSyncManager();
  }

  void mergeMediaAssets() {
    SyncManager().mergeAssets(allAssets, localAssets, remoteAssets);
    // Load the initial page of assets
    loadMoreAssets();
  }

  Future<void> loadMoreAssets() async {
    if (_isLoadingMore || displayedAssets.length >= allAssets.length) return;

    _isLoadingMore = true; // Set loading flag
    try {
      // Calculate the next batch of assets to load
      final start = displayedAssets.length;
      final end = (start + _pageSize > allAssets.length)
          ? allAssets.length
          : start + _pageSize;

      final newAssets = allAssets.sublist(start, end);
      setState(() {
        displayedAssets.addAll(newAssets); // Add new assets to displayedAssets
      });
    } catch (error) {
      // Handle any errors
      print("Error loading more assets: $error");
    } finally {
      _isLoadingMore = false; // Reset loading flag
    }
  }

  Future<Widget?> _getThumbnail(MediaAsset asset) async {
    if (_thumbnailCache.containsKey(asset.checksum!)) {
      return _thumbnailCache[asset.checksum!];
    }
    final Widget thumbnail = await asset.getPreview();
    _thumbnailCache[asset.checksum!] = thumbnail;
    return thumbnail;
  }

  Future<void> _refreshList() async {
    remoteAssets = await SyncManager().getAssetStructure(database);
    _startLoadingLocalAssets();
  }

  void _startLoadingLocalAssets() async {
    _stopLocalMediaIsolate();

    _receivePort = ReceivePort();
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    _localMediaIsolate = await Isolate.spawn(
      backgroundMediaLoader,
      [_receivePort!.sendPort, rootIsolateToken],
    );

    localAssets = [];
    _receivePort!.listen((message) {
      if (message is List<LocalMedia>) {
        localAssets += message;
        mergeMediaAssets(); // Merge and load more assets when local assets are loaded
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
    super.build(context);
    return _isAssetsLoaded // Only display grid if assets are loaded
        ? RefreshIndicator(
            onRefresh: _refreshList,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              itemCount: displayedAssets.length +
                  (_isLoadingMore ? 1 : 0), // Add one for loading indicator
              itemBuilder: (context, index) {
                if (index >= displayedAssets.length) {
                  // Show loading indicator at the bottom if loading more assets
                  return Center(child: CircularProgressIndicator());
                }

                MediaAsset asset = displayedAssets[index];
                return _buildAssetThumbnail(asset);
              },
              // Load more assets when reaching the end of the grid
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: true,
            ),
          )
        : Center(
            child:
                CircularProgressIndicator()); // Loading indicator before assets are loaded
  }

  Widget _buildAssetThumbnail(MediaAsset asset) {
    return FutureBuilder<Widget?>(
      future: _getThumbnail(asset),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return PreviewContainer(
              asset: asset,
              thumbnail: snapshot.data,
            );
          } else {
            return Container(
              color: Colors.grey[300],
              child: Center(child: Icon(Icons.error)),
            );
          }
        } else {
          return Container(
            color: Colors.grey[300],
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _stopLocalMediaIsolate();
    database.close();
    super.dispose();
  }
}
