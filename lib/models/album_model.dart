import 'package:isar/isar.dart';
part 'album_model.g.dart';

@collection
class AlbumModel {
  Id id = Isar.autoIncrement;
  late String name;
  late DateTime date;
  List<String> imagePaths = []; // rename later to assetIds for clarity

  bool isFavorites = false;

  AlbumModel({
    required this.name,
    required this.date,
    required this.imagePaths, // these will be asset IDs
    this.isFavorites = false,
  });

  AlbumModel.empty();
}
