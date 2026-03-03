import 'dart:io';
import 'dart:math';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

class ShareService {
  HttpServer? _server;
  late String _token;

  String get token => _token;

  Future<void> startServer() async {
    _token = _generateToken();

    final handler = (Request request) {
      final tokenParam = request.url.queryParameters['token'];
      if (tokenParam != _token) {
        return Response.forbidden("Invalid or missing token");
      }
      return Response.ok("Smart Gallery Server Running Securely");
    };

    _server = await io.serve(handler, '0.0.0.0', 8080);
    print("Server running on port 8080 with token $_token");
  }

  Future<void> stopServer() async {
    await _server?.close();
  }

  String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(16, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
