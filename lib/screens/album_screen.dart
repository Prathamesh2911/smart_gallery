import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/isar_service.dart';
import '../models/album_model.dart';
import '../widgets/album_tile.dart';
import '../providers/user_provider.dart';

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
              return AlbumTile(
                album: album,
                onDelete: () async {
                  await IsarService.deleteAlbum(album.id);
                  _reloadAlbums();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Album '${album.name}' deleted")),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
