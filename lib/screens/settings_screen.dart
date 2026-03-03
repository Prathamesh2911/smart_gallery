import 'package:flutter/material.dart';
import '../services/google_service.dart';
import '../services/share_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GoogleService _googleService = GoogleService();
  final ShareService _shareService = ShareService();

  bool _serverRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await _googleService.signIn();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Signed in with Google")),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text("Sign in with Google"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await _googleService.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Signed out from Google")),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign out"),
            ),
            const Divider(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                if (_serverRunning) {
                  await _shareService.stopServer();
                  setState(() => _serverRunning = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sharing server stopped")),
                  );
                } else {
                  await _shareService.startServer();
                  setState(() => _serverRunning = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Sharing server started on port 8080")),
                  );
                }
              },
              icon: Icon(_serverRunning ? Icons.stop : Icons.share),
              label: Text(_serverRunning ? "Stop Sharing" : "Start Sharing"),
            ),
          ],
        ),
      ),
    );
  }
}
