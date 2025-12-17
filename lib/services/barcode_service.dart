import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BarcodeService {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  // Scanner un code-barres depuis une image et identifier le produit
  Future<List<String>> scanBarcodeFromImage(XFile image) async {
    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      List<String> results = [];

      for (final barcode in barcodes) {
        if (barcode.displayValue != null) {
          final barcodeValue = barcode.displayValue!;
          final formatName = _getFormatName(barcode.format);
          
          // Ajouter le code-barres détecté
          results.add('📊 Code-barres: $barcodeValue ($formatName)');
          
          // Rechercher le produit dans la base de données
          final productInfo = await _lookupProduct(barcodeValue);
          
          if (productInfo != null) {
            results.addAll(productInfo);
          } else {
            results.add('ℹ️ Produit non trouvé dans la base de données');
          }
          
          results.add(''); // Ligne vide pour la séparation
        }
      }

      return results.isEmpty ? ['Aucun code-barres détecté'] : results;

    } catch (e) {
      throw Exception('Erreur lors du scan: $e');
    }
  }

  // Rechercher le produit via Open Food Facts API
  Future<List<String>?> _lookupProduct(String barcode) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 1) {
          final product = data['product'];
          List<String> info = [];

          // Nom du produit
          if (product['product_name'] != null && product['product_name'].toString().isNotEmpty) {
            info.add('📦 Produit: ${product['product_name']}');
          }

          // Marque
          if (product['brands'] != null && product['brands'].toString().isNotEmpty) {
            info.add('🏷️ Marque: ${product['brands']}');
          }

          // Catégories
          if (product['categories'] != null && product['categories'].toString().isNotEmpty) {
            final categories = product['categories'].toString();
            final categoryList = categories.split(',').take(2).join(', ');
            info.add('🗂️ Catégorie: $categoryList');
          }

          // Quantité
          if (product['quantity'] != null && product['quantity'].toString().isNotEmpty) {
            info.add('📏 Quantité: ${product['quantity']}');
          }

          // Nutri-Score
          if (product['nutriscore_grade'] != null) {
            final grade = product['nutriscore_grade'].toString().toUpperCase();
            info.add('🎯 Nutri-Score: $grade');
          }

          // Informations nutritionnelles (pour 100g)
          if (product['nutriments'] != null) {
            final nutriments = product['nutriments'];
            
            if (nutriments['energy-kcal_100g'] != null) {
              info.add('⚡ Énergie: ${nutriments['energy-kcal_100g']} kcal/100g');
            }
            
            if (nutriments['fat_100g'] != null) {
              info.add('🧈 Matières grasses: ${nutriments['fat_100g']}g/100g');
            }
            
            if (nutriments['sugars_100g'] != null) {
              info.add('🍬 Sucres: ${nutriments['sugars_100g']}g/100g');
            }
            
            if (nutriments['proteins_100g'] != null) {
              info.add('💪 Protéines: ${nutriments['proteins_100g']}g/100g');
            }
          }

          // Pays d'origine
          if (product['countries'] != null && product['countries'].toString().isNotEmpty) {
            info.add('🌍 Pays: ${product['countries']}');
          }

          return info.isEmpty ? null : info;
        }
      }
      return null;
    } catch (e) {
      // En cas d'erreur API, retourner null sans faire planter l'app
      return null;
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