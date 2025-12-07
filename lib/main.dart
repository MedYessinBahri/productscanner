import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/theme_provider.dart';

// Configuration Firebase avec VOS données
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyBw0QVX4r3qk1ENz8X4I9RVrG8mPKczLLY",
  appId: "1:1008565481874:android:e4146786bba53f05c0114b",
  messagingSenderId: "1008565481874",
  projectId: "productinfoscanner",
  storageBucket: "productinfoscanner.firebasestorage.app",
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔄 Initialisation de Firebase...');
  try {
    await Firebase.initializeApp(options: firebaseConfig);
    print('✅ Firebase initialisé avec succès!');
  } catch (e) {
    print('❌ Erreur Firebase: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Smart Product Scanner',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.grey[900],
          ),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                return const HomeScreen();
              }

              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}