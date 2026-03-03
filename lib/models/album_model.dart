import 'package:isar/isar.dart';
part 'album_model.g.dart';

@collection
class AlbumModel {
  Id id = Isar.autoIncrement;
  late String name;
  late DateTime date;
  List<String> imagePaths = [];

  // Named constructor for easy album creation
  AlbumModel({
    required this.name,
    required this.date,
    required this.imagePaths,
  });

  // Default constructor
  AlbumModel.empty();
}