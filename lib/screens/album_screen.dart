import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../database/isar_service.dart';
import '../models/album_model.dart';
import '../widgets/album_tile.dart';
import '../providers/user_provider.dart';
import 'photo_viewer_screen.dart';

class AlbumsData {
  final List<AlbumModel> albums;
  final AlbumModel? favorites;
  AlbumsData(this.albums, this.favorites);
}

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  late Future<AlbumsData> _albumsDataFuture;

  @override
  void initState() {
    super.initState();
    _reloadAlbums();
  }

  void _reloadAlbums() {
    setState(() {
      _albumsDataFuture = _loadAlbumsData();
    });
  }

  Future<AlbumsData> _loadAlbumsData() async {
    final albums = await IsarService.getAlbums();
    final favorites = await IsarService.getFavoritesAlbum();
    return AlbumsData(albums, favorites);
  }

  Future<void> _createAlbum() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Album"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Album name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("Create"),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final album = AlbumModel(
        name: name,
        date: DateTime.now(),
        imagePaths: [],
      );
      await IsarService.addAlbum(album);
      _reloadAlbums();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Album '$name' created")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
              child: user?.photoUrl == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createAlbum,
        icon: const Icon(Icons.add),
        label: const Text("Add Album"),
      ),
      body: FutureBuilder<AlbumsData>(
        future: _albumsDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final albumsData = snapshot.data;
          if (albumsData == null) {
            return const Center(child: Text("No albums found"));
          }

          final albums = albumsData.albums;
          final favAlbum = albumsData.favorites;

          final tiles = <Widget>[];

          // Add Favorites tile only if it exists
          if (favAlbum != null) {
            tiles.add(
              GestureDetector(
                onTap: () async {
                  final favoritePhotos = await Future.wait(
                    favAlbum.imagePaths.map((id) => AssetEntity.fromId(id)),
                  );
                  final validPhotos =
                  favoritePhotos.whereType<AssetEntity>().toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoViewerScreen(
                        photos: validPhotos,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: AlbumTile(
                  album: favAlbum,
                  onDelete: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Favorites cannot be deleted")),
                    );
                  },
                ),
              ),
            );
          }

          // Other albums (exclude Favorites)
          tiles.addAll(
            albums.where((a) => !a.isFavorites).map(
                  (album) => AlbumTile(
                album: album,
                onDelete: () async {
                  await IsarService.deleteAlbum(album.id);
                  _reloadAlbums();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Album '${album.name}' deleted")),
                  );
                },
              ),
            ),
          );

          return GridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: tiles,
          );
        },
      ),
    );
  }
}
