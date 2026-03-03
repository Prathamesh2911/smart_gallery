import 'dart:io';
import 'package:flutter/material.dart';
import '../models/album_model.dart';

class AlbumTile extends StatelessWidget {
  final AlbumModel album;
  const AlbumTile({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          album.imagePaths.isNotEmpty
              ? Image.file(
            File(album.imagePaths[0]),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
              : Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.photo, size: 60, color: Colors.grey),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
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
        ],
      ),
    );
  }
}
