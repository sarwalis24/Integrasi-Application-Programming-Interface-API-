import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // <-- 1. IMPORT kIsWeb
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

// --- Pages ---
import 'package:themenavigation/pages/add_mhs_page.dart';
import 'package:themenavigation/pages/home_page.dart';
import 'package:themenavigation/pages/login_page.dart';
import 'package:themenavigation/pages/mhs_list_page.dart';
import 'package:themenavigation/pages/profile_page.dart';
import 'package:themenavigation/pages/produk_page.dart';
import 'package:themenavigation/pages/settings_page.dart';
import 'package:themenavigation/pages/splash_page.dart';

// --- Providers ---
import 'package:themenavigation/provider/mhs_provider.dart';
import 'package:themenavigation/provider/api_provider.dart';
import 'package:themenavigation/pages/book_list_page.dart';
import 'package:themenavigation/pages/add_book_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- 2. TAMBAHKAN KONDISI (!kIsWeb) ---
  // Hanya minta izin jika BUKAN di platform web
  if (!kIsWeb) {
    await _requestStoragePermission();
  }
  // ------------------------------------
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MhsProvider()),
        ChangeNotifierProvider(create: (context) => ApiProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _requestStoragePermission() async {
  await [
    Permission.storage,
    Permission.photos,
    Permission.videos,
    Permission.audio,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALET WARNA (TETAP SAMA) ---
    const Color primaryColor = Color(0xFF00695C);
    // ... (sisa palet warna) ...

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Flutter',
      theme: ThemeData(
        // ... (Tema Anda tetap sama) ...
      ),
      
      initialRoute: '/splash',
      
      routes: {
        // ... (Semua rute Anda tetap sama) ...
        '/splash': (context) => const SplashPage(),
        '/settings': (context) => const SettingsPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) {
          final String username =
              ModalRoute.of(context)!.settings.arguments as String;
          return HomePage(username: username);
        },
        '/profile': (context) {
          final String username =
              ModalRoute.of(context)!.settings.arguments as String;
          return ProfilePage(username: username);
        },
        '/produk': (context) => ProdukPage(),
        '/mhs_list': (context) => const MhsListPage(),
        '/add_mhs': (context) => const AddMhsPage(),
        '/book_list': (context) => const BookListPage(),
        '/add_book': (context) => const AddBookPage(),
      },
    );
  }
}