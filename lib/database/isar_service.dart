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

  // ✅ New method to delete album
  static Future<void> deleteAlbum(int id) async {
    await isar.writeTxn(() async {
      await isar.albumModels.delete(id);
    });
  }
}
