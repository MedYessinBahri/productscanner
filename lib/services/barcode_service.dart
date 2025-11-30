import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

class BarcodeService {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  // Scanner un code-barres depuis une image
  Future<List<String>> scanBarcodeFromImage(XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      List<String> results = [];

      for (final barcode in barcodes) {
        if (barcode.displayValue != null) {
          results.add('${barcode.displayValue} (${_getFormatName(barcode.format)})');
        }
      }

      return results.isEmpty ? ['Aucun code-barres détecté'] : results;

    } catch (e) {
      throw Exception('Erreur lors du scan: $e');
    }
  }

  // Obtenir le nom du format du code-barres
  String _getFormatName(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.aztec:
        return 'Aztec';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.code93:
        return 'Code 93';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.itf:
        return 'ITF';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.upca:
        return 'UPC-A';
      case BarcodeFormat.upce:
        return 'UPC-E';
      default:
        return 'Autre format';
    }
  }

  // Nettoyer les ressources
  void dispose() {
    _barcodeScanner.close();
  }
}