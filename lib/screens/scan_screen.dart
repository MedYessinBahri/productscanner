import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/barcode_service.dart';
import '../services/image_labeling_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final BarcodeService _barcodeService = BarcodeService();
  final ImageLabelingService _imageLabelingService = ImageLabelingService();
  final ImagePicker _imagePicker = ImagePicker();

  List<String> _scanResults = [];
  bool _isLoading = false;
  String _currentMode = 'Aucun';

  Future<void> _pickImageAndScan(String mode) async {
    setState(() {
      _isLoading = true;
      _scanResults = [];
      _currentMode = mode;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (mode == 'barcode') {
          final results = await _barcodeService.scanBarcodeFromImage(image);
          setState(() => _scanResults = results);
        } else if (mode == 'image') {
          final results = await _imageLabelingService.identifyObjectsInImage(image);
          setState(() => _scanResults = results);
        }
      } else {
        setState(() => _scanResults = ['Aucune image sélectionnée']);
      }
    } catch (e) {
      setState(() => _scanResults = ['Erreur: $e']);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearResults() {
    setState(() {
      _scanResults = [];
      _currentMode = 'Aucun';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Produit 🛒'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_scanResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearResults,
              tooltip: 'Effacer les résultats',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Titre et instructions
            const Text(
              'Choisissez un mode de scan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sélectionnez une image depuis votre galerie',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // Boutons de scan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScanButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Code-barres',
                  mode: 'barcode',
                  color: Colors.blue,
                ),
                _buildScanButton(
                  icon: Icons.photo_camera,
                  label: 'Reconnaissance',
                  mode: 'image',
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),

            // Indicateur de mode actuel
            if (_currentMode != 'Aucun')
              Text(
                _currentMode == 'barcode'
                    ? '🔍 Scan de codes-barres'
                    : '🏷️ Reconnaissance d\'image',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),

            const SizedBox(height: 20),

            // Résultats ou état de chargement
            Expanded(
              child: _buildResultsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton({
    required IconData icon,
    required String label,
    required String mode,
    required Color color,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : () => _pickImageAndScan(mode),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    if (_isLoading) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Analyse en cours...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            'Veuillez patienter',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      );
    }

    if (_scanResults.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Aucun scan effectué',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 10),
          Text(
            'Utilisez les boutons ci-dessus pour\nscanner un code-barres ou identifier une image',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Résultats:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) => Card(
              color: Colors.blue.shade50,
              child: ListTile(
                leading: Icon(
                  _scanResults[index].contains('Erreur') ||
                      _scanResults[index].contains('Aucun')
                      ? Icons.error_outline
                      : Icons.check_circle,
                  color: _scanResults[index].contains('Erreur') ||
                      _scanResults[index].contains('Aucun')
                      ? Colors.orange
                      : Colors.green,
                ),
                title: Text(
                  _scanResults[index],
                  style: TextStyle(
                    fontWeight: _scanResults[index].contains('Erreur') ||
                        _scanResults[index].contains('Aucun')
                        ? FontWeight.normal
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _barcodeService.dispose();
    _imageLabelingService.dispose();
    super.dispose();
  }
}