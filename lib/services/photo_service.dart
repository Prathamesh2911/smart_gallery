import 'package:photo_manager/photo_manager.dart';

class PhotoService {
  Future<List<AssetEntity>> getAllImages() async {
    final permission = await PhotoManager.requestPermissionExtend();

    print("Permission granted: ${permission.isAuth}");

    if (!permission.isAuth) {
      throw Exception("Permission denied");
    }

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    print("Albums found: ${albums.length}");

    if (albums.isEmpty) {
      print("No albums found on device.");
      return [];
    }

    final recentAlbum = albums.first;

    final photos = await recentAlbum.getAssetListPaged(
      page: 0,
      size: 100,
    );

    print("Photos fetched: ${photos.length}");

    return photos;
  }
}