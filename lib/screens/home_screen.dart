import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/photo_service.dart';
import 'photo_viewer_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AssetEntity> _photos = [];
  bool _loading = true;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkAndLoadPhotos();
  }

  Future<void> _checkAndLoadPhotos() async {
    final result = await PhotoManager.requestPermissionExtend();
    if (!result.isAuth) {
      setState(() {
        _permissionDenied = true;
        _loading = false;
      });
      return;
    }
    await _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    try {
      final photos = await PhotoService().getAllImages();
      setState(() {
        _photos = photos;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading photos: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Gallery"),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _permissionDenied
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Gallery permission denied"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await PhotoManager.openSetting();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      )
          : _photos.isEmpty
          ? const Center(child: Text("No photos found"))
          : GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return FutureBuilder<File?>(
            future: photo.originFile, // safer than photo.file
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoViewerScreen(
                        photos: _photos,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Image.file(
                  snapshot.data!,
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
