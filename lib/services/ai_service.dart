import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class AIService {
  final ImageLabeler _labeler =
  ImageLabeler(options: ImageLabelerOptions());

  Future<List<String>> getLabels(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final labels = await _labeler.processImage(inputImage);

    return labels.map((label) => label.label).toList();
  }

  void dispose() {
    _labeler.close();
  }
}