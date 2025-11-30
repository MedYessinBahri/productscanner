import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

class ImageLabelingService {
  final ImageLabeler _imageLabeler = ImageLabeler(
    options: ImageLabelerOptions(confidenceThreshold: 0.7),
  );

  // Identifier les objets dans une image
  Future<List<String>> identifyObjectsInImage(XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final labels = await _imageLabeler.processImage(inputImage);

      // Trier par confiance (du plus élevé au plus bas)
      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      List<String> results = [];

      for (final label in labels.take(5)) { // Prendre les 5 premiers résultats
        final confidencePercent = (label.confidence * 100).toStringAsFixed(1);
        results.add('${label.label} - $confidencePercent% de confiance');
      }

      return results.isEmpty ? ['Aucun objet identifié'] : results;

    } catch (e) {
      throw Exception('Erreur lors de la reconnaissance: $e');
    }
  }

  // Nettoyer les ressources
  void dispose() {
    _imageLabeler.close();
  }
}