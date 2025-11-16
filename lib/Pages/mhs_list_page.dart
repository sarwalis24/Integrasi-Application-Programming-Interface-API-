// lib/pages/mhs_list_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:themenavigation/pages/add_mhs_page.dart';
import 'package:themenavigation/pages/update_mhs_page.dart';
import 'package:themenavigation/provider/mhs_provider.dart';
import 'package:themenavigation/models/mhs_model.dart'; // <-- IMPORT YANG HILANG
import 'dart:io'; 

class MhsListPage extends StatelessWidget {
  const MhsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Data Mahasiswa 🎓",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Consumer<MhsProvider>(
        builder: (context, provider, child) {
          if (provider.mahasiswa.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada data mahasiswa.",
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.mahasiswa.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mhs = provider.mahasiswa[index];
              String initials = mhs.nama.isNotEmpty
                  ? mhs.nama.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
                  : '?';

              ImageProvider? avatarImage;
              if (mhs.imagePath != null && mhs.imagePath!.isNotEmpty) {
                 try {
                  if (File(mhs.imagePath!).existsSync()) {
                     avatarImage = FileImage(File(mhs.imagePath!));
                  }
                } catch (e) {
                  print("Error loading image: $e");
                  avatarImage = null;
                }
              }

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    backgroundImage: avatarImage,
                    child: avatarImage == null
                        ? Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                        : null,
                  ),

                  title: Text(
                    mhs.nama,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  subtitle: Text(
                    mhs.nim,
                    style: GoogleFonts.poppins(
                        color: Colors.black54, fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.edit_outlined, color: Colors.blueAccent),
                        tooltip: 'Edit Data',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateMhsPage(mhs: mhs),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        tooltip: 'Hapus Data',
                        onPressed: () {
                          _showDeleteConfirmation(context, provider, mhs);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateMhsPage(mhs: mhs),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text("Tambah",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        onPressed: () {
          Navigator.pushNamed(context, '/add_mhs');
        },
      ),
    );
  }

  // Fungsi _showDeleteConfirmation
  void _showDeleteConfirmation(
      BuildContext context, MhsProvider provider, MhsModel mhs) { // <-- Tipe data MhsModel diperlukan
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Konfirmasi Hapus')
          ]),
          content:
              Text('Yakin ingin menghapus data\n"${mhs.nama}" (${mhs.nim})?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Hapus', style: TextStyle(color: Colors.white)),
              onPressed: () {
                provider.deleteMhs(mhs.id!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${mhs.nama} berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}