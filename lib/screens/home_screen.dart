import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/album_provider.dart';
import '../services/album_service.dart';
import '../services/photo_service.dart';
import '../models/album_model.dart';
import '../widgets/album_tile.dart'; // <-- use reusable widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => Provider.of<AlbumProvider>(context, listen: false).fetchAlbums(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final albumProvider = Provider.of<AlbumProvider>(context);
    final albums = albumProvider.albums;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Gallery'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: albums.isEmpty
          ? const Center(child: Text('No albums yet'))
          : GridView.builder(
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
          return AlbumTile(album: album); // <-- use AlbumTile
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            final photos = await PhotoService().getAllImages();
            await AlbumService().createAlbumsFromPhotos(photos);
            await albumProvider.fetchAlbums();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching photos: $e')),
            );
          }
        },
        icon: const Icon(Icons.photo_library),
        label: const Text("Import Photos"),
      ),
    );
  }
}
