import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class PhotoViewerScreen extends StatefulWidget {
  final List<AssetEntity> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<void> _deletePhoto(AssetEntity photo) async {
    await PhotoManager.editor.deleteWithIds([photo.id]);
    setState(() {
      widget.photos.removeAt(_currentIndex);
    });
    if (widget.photos.isEmpty) {
      Navigator.pop(context);
    }
  }

  Future<void> _sharePhoto(AssetEntity photo) async {
    final file = await photo.file;
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final currentPhoto = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.photos.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final photo = widget.photos[index];
          return FutureBuilder<File?>(
            future: photo.originFile, // safer than photo.file
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return Center(
                child: Image.file(snapshot.data!, fit: BoxFit.contain),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.black54,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Favorite button
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: favProvider.isFavorite(currentPhoto.id)
                    ? Colors.red
                    : Colors.white,
              ),
              onPressed: () {
                favProvider.toggleFavorite(currentPhoto.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      favProvider.isFavorite(currentPhoto.id)
                          ? "Added to favorites"
                          : "Removed from favorites",
                    ),
                  ),
                );
              },
            ),
            // Share button
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _sharePhoto(currentPhoto),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePhoto(currentPhoto),
            ),
          ],
        ),
      ),
    );
  }
}
