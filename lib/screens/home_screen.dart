import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

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
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            const Text(
              'Fonctionnalités à venir:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text('• Scan de codes-barres (ML Kit)'),
            const Text('• Reconnaissance d\'images (ML Kit)'),
            const Text('• Historique des produits'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Ajouter le scan plus tard
              },
              child: const Text('Commencer le scan'),
            ),
          ],
        ),
      ),
    );
  }
}