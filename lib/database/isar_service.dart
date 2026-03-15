import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/album_model.dart';

class IsarService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [AlbumModelSchema],
      directory: dir.path,
    );
  }

  static Future<List<AlbumModel>> getAlbums() async {
    return await isar.albumModels.where().findAll();
  }

  static Future<void> addAlbum(AlbumModel album) async {
    await isar.writeTxn(() async {
      await isar.albumModels.put(album);
    });
  }

  static Future<void> deleteAlbum(int id) async {
    await isar.writeTxn(() async {
      await isar.albumModels.delete(id);
    });
  }

  // Favorites helpers
  static Future<AlbumModel?> getFavoritesAlbum() async {
    return await isar.albumModels.filter().isFavoritesEqualTo(true).findFirst();
  }

  static Future<void> saveFavorites(List<String> ids) async {
    await isar.writeTxn(() async {
      var favAlbum = await getFavoritesAlbum();
      if (favAlbum == null) {
        favAlbum = AlbumModel(
          name: "Favorites",
          date: DateTime.now(),
          imagePaths: ids,
          isFavorites: true,
        );
      } else {
        favAlbum.imagePaths = ids;
      }
      await isar.albumModels.put(favAlbum);
    });
  }
}
