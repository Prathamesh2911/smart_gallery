import 'package:flutter/material.dart';
import '../database/isar_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favorites => _favoriteIds;

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await IsarService.saveFavorites(_favoriteIds.toList());
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    final favAlbum = await IsarService.getFavoritesAlbum();
    _favoriteIds.clear();
    if (favAlbum != null) {
      _favoriteIds.addAll(favAlbum.imagePaths);
    }
    notifyListeners();
  }
}
