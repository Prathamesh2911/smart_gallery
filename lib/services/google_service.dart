import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/photoslibrary.readonly',
    ],
  );

  // Sign in and return the account
  Future<GoogleSignInAccount?> signIn() async {
    return await _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // Fetch photos from Google Photos
  Future<List<dynamic>> fetchGooglePhotos() async {
    final account = await _googleSignIn.signIn();
    final headers = await account?.authHeaders;
    if (headers == null) throw Exception("No auth headers");

    final response = await http.get(
      Uri.parse('https://photoslibrary.googleapis.com/v1/mediaItems?pageSize=20'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch photos: ${response.body}");
    }

    final data = jsonDecode(response.body);
    return data['mediaItems'] ?? [];
  }
}
