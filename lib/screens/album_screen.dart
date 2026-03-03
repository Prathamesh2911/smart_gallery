import 'package:flutter/material.dart';
import '../database/isar_service.dart';
import '../models/album_model.dart';
import '../widgets/album_tile.dart'; // <-- use reusable widget

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen> {
  late Future<List<AlbumModel>> _albumsFuture;

  @override
  void initState() {
    super.initState();
    _albumsFuture = IsarService.getAlbums();
  }

  void _reloadAlbums() {
    setState(() {
      _albumsFuture = IsarService.getAlbums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final album = AlbumModel(
            name: 'Sample Album',
            date: DateTime.now(),
            imagePaths: [],
          );
          await IsarService.addAlbum(album);
          _reloadAlbums();
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Album"),
      ),
      body: FutureBuilder<List<AlbumModel>>(
        future: _albumsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No albums yet'));
          }

          final albums = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return AlbumTile(album: album); // <-- use AlbumTile widget
            },
          );
        },
      ),
    );
  }
}
