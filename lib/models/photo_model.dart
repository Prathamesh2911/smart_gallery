import 'package:isar/isar.dart';

part 'photo_model.g.dart';

@collection
class PhotoModel {
  Id id = Isar.autoIncrement;
  late String path;
  late DateTime date;
  List<String> labels = []; // AI-generated tags
}
