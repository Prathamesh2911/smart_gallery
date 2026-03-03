import 'dart:io';
import 'package:flutter/material.dart';
import '../models/photo_model.dart';

class PhotoCard extends StatelessWidget {
  final PhotoModel photo;
  const PhotoCard({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Image.file(
            File(photo.path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (photo.labels.isNotEmpty)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  photo.labels.join(", "),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
