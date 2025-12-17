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
  String _currentMode = 'none';

  Future<void> _showImageSourceDialog(String mode) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir la source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.camera_alt, color: colorScheme.primary),
                ),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.photo_library, color: colorScheme.secondary),
                ),
                title: const Text('Choisir de la galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (source != null) {
      await _pickImageAndScan(mode, source);
    }
  }

  Future<void> _pickImageAndScan(String mode, ImageSource source) async {
    setState(() {
      _isLoading = true;
      _scanResults = [];
      _currentMode = mode;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
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
      setState(() => _scanResults = ['Erreur: ${e.toString()}']);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearResults() {
    setState(() {
      _scanResults = [];
      _currentMode = 'none';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_scanResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearResults,
              tooltip: 'Effacer les résultats',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Mode Selection Cards
            _buildModeSelectionCards(context),
            const SizedBox(height: 32),

            // Results Section
            Expanded(child: _buildResultsSection(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelectionCards(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionnez un mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                context,
                icon: Icons.qr_code,
                title: 'Code-barres',
                subtitle: 'Scanner un produit',
                mode: 'barcode',
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildModeCard(
                context,
                icon: Icons.image_search,
                title: 'Reconnaissance',
                subtitle: 'Identifier un objet',
                mode: 'image',
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String mode,
        required Color color,
      }) {
    final isSelected = _currentMode == mode;
    final isDisabled = _isLoading;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isDisabled ? null : () => _showImageSourceDialog(mode),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDisabled
                      ? Colors.grey
                      : colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Analyse en cours...',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onBackground.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (_scanResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner_outlined,
              size: 80,
              color: colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun scan effectué',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Sélectionnez un mode et choisissez une image pour commencer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Résultats (${_scanResults.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text(
                _currentMode == 'barcode' ? 'Code-barres' : 'Reconnaissance',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _currentMode == 'barcode'
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.secondary.withOpacity(0.1),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _scanResults.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final result = _scanResults[index];
              
              // Skip empty lines
              if (result.trim().isEmpty) {
                return const SizedBox(height: 4);
              }
              
              final isError = result.contains('Erreur') || result.contains('Aucun');

              return Card(
                color: isError
                    ? colorScheme.error.withOpacity(0.1)
                    : colorScheme.surface,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isError
                          ? colorScheme.error.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isError ? Icons.error_outline : Icons.check_circle,
                      color: isError
                          ? colorScheme.error
                          : Colors.green,
                    ),
                  ),
                  title: Text(
                    result,
                    style: TextStyle(
                      fontWeight: isError ? FontWeight.normal : FontWeight.w500,
                      color: isError
                          ? colorScheme.error
                          : null,
                    ),
                  ),
                ),
              );
            },
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