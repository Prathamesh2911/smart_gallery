import 'package:isar/isar.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/album_model.dart';
import '../database/isar_service.dart';

class AlbumService {
  Future<void> createAlbumsFromPhotos(List<AssetEntity> photos) async {
    Map<String, List<String>> grouped = {};

    // Group photos by date
    for (var photo in photos) {
      final date = photo.createDateTime;
      final key = "${date.year}-${date.month}-${date.day}";

      final file = await photo.file;
      if (file == null) continue;

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(file.path);
    }

    // Create albums in Isar
    for (var entry in grouped.entries) {

      // ✅ CHECK IF ALBUM ALREADY EXISTS (ADD HERE)
      final existing = await IsarService.isar.albumModels
          .filter()
          .nameEqualTo("Memories ${entry.key}")
          .findFirst();

      if (existing != null) {
        print("Album already exists. Skipping.");
        continue; // skip creating duplicate
      }

      // Convert date string back to DateTime
      final parts = entry.key.split('-');
      final albumDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );

      final album = AlbumModel(
        name: "Memories ${entry.key}",
        date: albumDate,
        imagePaths: entry.value,
      );

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.albumModels.put(album);
      });

      print("Album saved.");
    }
  }
}