// lib/pages/home_page.dart
import 'package:flutter/material.dart'; // <-- IMPORT UTAMA YANG HILANG
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themenavigation/provider/mhs_provider.dart';
import 'package:themenavigation/provider/api_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart'; // <-- Import untuk kIsWeb

class HomePage extends StatelessWidget {
  final String username;
  const HomePage({super.key, required this.username});

  Future<void> _writeFile(BuildContext context) async {
    if (!context.mounted) return;
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/sample.txt';
      final file = File(filePath);
      await file.writeAsString("Hello World from Flutter! - User: $username");
      print('File berhasil ditulis di: $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('File berhasil ditulis'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      print('Gagal menulis file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal menulis file: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _readFile(BuildContext context) async {
    if (!context.mounted) return;
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/sample.txt';
      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        print('Isi file: $contents');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Isi file: $contents')),
        );
      } else {
        print('File tidak ditemukan: $filePath');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('File sample.txt belum dibuat'),
              backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      print('Gagal membaca file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal membaca file: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mhsProvider = context.watch<MhsProvider>();
    final apiProvider = context.watch<ApiProvider>();
    final jumlahMahasiswa = mhsProvider.mahasiswa.length;
    final jumlahBuku = apiProvider.books.length;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              primaryColor.withOpacity(0.05)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            _buildWelcomeCard(context, username, primaryColor),
            const SizedBox(height: 24),
            Text(
              "Akses Cepat",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildQuickAccessCard(
                  context: context,
                  icon: Icons.shopping_bag_outlined,
                  label: "Produk",
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/produk'),
                ),
                _buildQuickAccessCard(
                  context: context,
                  icon: Icons.school_outlined,
                  label: "Data Mahasiswa",
                  subtitle: "$jumlahMahasiswa Data (SQLite)",
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/mhs_list'),
                ),
                _buildQuickAccessCard(
                  context: context,
                  icon: Icons.menu_book_outlined,
                  label: "Data Buku",
                  subtitle: "$jumlahBuku Data (API)",
                  color: Colors.deepOrangeAccent,
                  onTap: () => Navigator.pushNamed(context, '/book_list'),
                ),
                _buildQuickAccessCard(
                  context: context,
                  icon: Icons.person_pin_outlined,
                  label: "Profil Saya",
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/profile',
                      arguments: username),
                ),
                _buildQuickAccessCard(
                  context: context,
                  icon: Icons.settings_outlined,
                  label: "Pengaturan",
                  color: Colors.purple,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),

            // Sembunyikan jika di web
            if (!kIsWeb) ...[
              const SizedBox(height: 24),
              Text(
                "File Manager (Tes)",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildFileManagerCard(context),
            ],
          ],
        ),
      ),
      drawer: _buildAppDrawer(context, username, primaryColor),
    );
  }

  Widget _buildAppDrawer(
      BuildContext context, String username, Color primaryColor) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              username,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              "$username@gmail.com",
              style: GoogleFonts.poppins(),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : 'U',
                style: TextStyle(fontSize: 40.0, color: primaryColor),
              ),
            ),
            decoration: BoxDecoration(
              color: primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text('Home',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text('Profile',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile', arguments: username);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: Text('Produk',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/produk');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text('Data Mahasiswa (SQLite)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/mhs_list');
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text('Data Buku (API)',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/book_list');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text('Pengaturan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Logout',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500, color: Colors.redAccent)),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');
              await Provider.of<ApiProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(
      BuildContext context, String username, Color primaryColor) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              primaryColor,
              Color.lerp(primaryColor, Colors.black, 0.2)!
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Selamat Datang Kembali,",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              username,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: color),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold, shadows: []),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileManagerCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              icon: Icon(Icons.save_alt,
                  color: Theme.of(context).colorScheme.primary),
              label: const Text('Write File (Temp)'),
              onPressed: () => _writeFile(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.read_more_outlined, color: Colors.teal),
              label: const Text('Read File (Temp)'),
              onPressed: () => _readFile(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: Colors.teal.withOpacity(0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
