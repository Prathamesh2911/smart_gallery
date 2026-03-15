import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../models/album_model.dart';

class AlbumTile extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onDelete;

  const AlbumTile({super.key, required this.album, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Show first asset thumbnail, or placeholder
          album.imagePaths.isNotEmpty
              ? FutureBuilder<AssetEntity?>(
            future: AssetEntity.fromId(album.imagePaths.first),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final entity = snapshot.data;
              if (entity == null) {
                return _placeholder();
              }
              return SizedBox.expand(
                child: AssetEntityImage(
                  entity,
                  isOriginal: false,
                  thumbnailSize: const ThumbnailSize(300, 300),
                  fit: BoxFit.cover,
                ),
              );
            },
          )
              : _placeholder(),

          // Gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Album name at bottom
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              album.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Delete button at top-right
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Album"),
                    content: Text("Are you sure you want to delete '${album.name}'?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  onDelete();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.photo, size: 60, color: Colors.grey),
      ),
    );
  }
}
