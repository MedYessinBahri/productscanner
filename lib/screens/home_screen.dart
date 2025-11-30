import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'scan_screen.dart'; // ← AJOUTEZ CET IMPORT

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Scanner 🛒'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo et bienvenue
            const Icon(Icons.shopping_cart, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              'Bienvenue, ${user?.email ?? 'Utilisateur'}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Firebase Authentication Réussie! ✅',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            const SizedBox(height: 30),

            // Fonctionnalités disponibles
            const Text(
              'Fonctionnalités disponibles:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildFeatureItem('📷 Scan de codes-barres', 'Utilise ML Kit'),
            _buildFeatureItem('🏷️ Reconnaissance d\'images', 'Identification d\'objets'),
            _buildFeatureItem('🔐 Authentification sécurisée', 'Avec Firebase'),
            const SizedBox(height: 40),

            // Bouton principal pour scanner
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(
                'Commencer le scan',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Boutons secondaires
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSmallButton(
                  icon: Icons.history,
                  label: 'Historique',
                  onPressed: () {
                    // À implémenter plus tard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Historique à venir!')),
                    );
                  },
                ),
                const SizedBox(width: 15),
                _buildSmallButton(
                  icon: Icons.settings,
                  label: 'Paramètres',
                  onPressed: () {
                    // À implémenter plus tard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paramètres à venir!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // Barre de navigation inférieure
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, color: Colors.blue),
                    onPressed: () {},
                  ),
                  const Text('Accueil', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScanScreen()),
                      );
                    },
                  ),
                  const Text('Scan', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      // À implémenter plus tard
                    },
                  ),
                  const Text('Profil', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}