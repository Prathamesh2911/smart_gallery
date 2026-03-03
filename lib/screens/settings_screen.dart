import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

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
  String? _serverUrl;

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
            /// GOOGLE SIGN IN
            ElevatedButton.icon(
              onPressed: () async {
                await _googleService.signIn();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signed in with Google")),
                  );
                }
              },
              icon: const Icon(Icons.login),
              label: const Text("Sign in with Google"),
            ),

            const SizedBox(height: 12),

            /// GOOGLE SIGN OUT
            ElevatedButton.icon(
              onPressed: () async {
                await _googleService.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Signed out from Google")),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text("Sign out"),
            ),

            const Divider(height: 32),

            /// START / STOP SHARING SERVER
            ElevatedButton.icon(
              onPressed: () async {
                if (_serverRunning) {
                  await _shareService.stopServer();

                  setState(() {
                    _serverRunning = false;
                    _serverUrl = null;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sharing server stopped")),
                    );
                  }
                } else {
                  await _shareService.startServer();

                  final ip = "10.0.2.2"; // emulator IP
                  final url =
                      "http://$ip:8080?token=${_shareService.token}";

                  setState(() {
                    _serverRunning = true;
                    _serverUrl = url;
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Server started: $url")),
                    );
                  }
                }
              },
              icon: Icon(_serverRunning ? Icons.stop : Icons.share),
              label: Text(_serverRunning ? "Stop Sharing" : "Start Sharing"),
            ),

            const SizedBox(height: 20),

            /// SHOW QR IF SERVER RUNNING
            if (_serverRunning && _serverUrl != null)
              Column(
                children: [
                  const Text(
                    "Scan this QR to connect:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  QrImageView(
                    data: _serverUrl!,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ],
              ),

            const Divider(height: 32),

            /// OPEN QR SCANNER
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QRScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("Scan QR to Connect"),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// QR SCANNER SCREEN (Using mobile_scanner)
////////////////////////////////////////////////////////////////

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) async {
          if (_isProcessing) return;

          final barcode = capture.barcodes.first;
          final String? url = barcode.rawValue;

          if (url != null) {
            _isProcessing = true;

            print("📷 QR scanned: $url"); // Debug print

            await controller.stop();

            try {
              final response = await http.get(Uri.parse(url));

              print("✅ Connected to server at $url");
              print("Response status: ${response.statusCode}");
              print("Response body: ${response.body}");

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Response: ${response.body}")),
                );
              }
            } catch (e) {
              print("❌ Error connecting to server: $e");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            }

            if (mounted) {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
