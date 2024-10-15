import 'package:flutter/material.dart';
import 'package:mobile/model/media_asset.dart';
import 'package:mobile/services/sync_manager.dart';
import 'preview_container.dart';

class ImageGrid2 extends StatefulWidget {
  const ImageGrid2({super.key});

  @override
  ImageGridState2 createState() => ImageGridState2();
}

class ImageGridState2 extends State<ImageGrid2> {
  static const _pageSize = 40;  // Number of items to load per page
  final ScrollController _scrollController = ScrollController();

  final List<MediaAsset> _paths = [];
  bool _isLoading = false;
  bool _isLastPage = false;
  int _currentPage = 0;
  final Map<String, Widget?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadAssets();  // Load the first page

    // Set up scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading && !_isLastPage) {
        _loadAssets();  // Load more when reaching the end of the list
      }
    });
  }

  Future<void> _loadAssets() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<MediaAsset> newAssets = await _fetchAssets(_currentPage);
      setState(() {
        if (newAssets.length < _pageSize) {
          _isLastPage = true;  // No more pages
        }
        _paths.addAll(newAssets);  // Add new assets to the list
        _currentPage++;  // Increment page index
      });
    } catch (error) {
      // Handle error
      print('Error loading assets: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<MediaAsset>> _fetchAssets(int page) async {
    final assets = await SyncManager().sync();
    return assets.skip(page * _pageSize).take(_pageSize).toList();
  }

  Future<Widget?> _getThumbnail(MediaAsset asset) async {
    if (_thumbnailCache.containsKey(asset.checksum)) {
      return _thumbnailCache[asset.checksum];
    }

    final Widget thumbnail = await asset.getPreview();
    _thumbnailCache[asset.checksum] = thumbnail;
    return thumbnail;
  }

  Future<void> _refreshList() async {
    setState(() {
      _paths.clear();
      _currentPage = 0;
      _isLastPage = false;
    });
    _loadAssets();  // Reload assets after refreshing
  }

  @override
  void dispose() {
    _scrollController.dispose();  // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _paths.isEmpty && !_isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshList,
              child: GridView.builder(
                controller: _scrollController,  // Attach the scroll controller
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,  // Number of columns in the grid
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
                itemCount: _paths.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _paths.length) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final asset = _paths[index];
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
              ),
            ),
    );
  }
}
