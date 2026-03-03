import 'package:flutter/material.dart';
import '../database/isar_service.dart';
import '../models/album_model.dart';

class AlbumProvider extends ChangeNotifier {
  List<AlbumModel> albums = [];

  // Fetch albums from Isar
  Future<void> fetchAlbums() async {
    albums = await IsarService.getAlbums();
    notifyListeners(); // tells UI to rebuild
  }

  // Optional: Add a new album
  Future<void> addAlbum(AlbumModel album) async {
    await IsarService.addAlbum(album);
    await fetchAlbums(); // refresh the list
  }
}