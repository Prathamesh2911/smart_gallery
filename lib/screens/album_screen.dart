import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/album_model.dart';
import '../widgets/album_tile.dart';
import '../providers/user_provider.dart'; // <-- NEW

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
    final userProvider = Provider.of<UserProvider>(context); // <-- NEW
    final user = userProvider.user; // <-- NEW

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
              return AlbumTile(album: album);
            },
          );
        },
      ),
    );
  }
}
