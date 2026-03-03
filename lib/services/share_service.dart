import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

class ShareService {

  HttpServer? _server;

  Future<void> startServer() async {
    final handler = (Request request) {
      return Response.ok("Smart Gallery Server Running");
    };

    _server = await io.serve(
      handler,
      '0.0.0.0',
      8080,
    );

    print("Server running on port 8080");
  }

  Future<void> stopServer() async {
    await _server?.close();
  }
}