import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // <-- Import image_picker
import 'package:provider/provider.dart';
import 'package:themenavigation/models/mhs_model.dart';
import 'package:themenavigation/provider/mhs_provider.dart';
import 'dart:io'; // <-- Import dart:io untuk File

class AddMhsPage extends StatefulWidget {
  const AddMhsPage({super.key});

  @override
  State<AddMhsPage> createState() => _AddMhsPageState();
}

class _AddMhsPageState extends State<AddMhsPage> {
  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  File? _selectedImage; // <-- State untuk menyimpan file gambar

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK MENGAMBIL GAMBAR ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Ambil dari galeri

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Simpan file yang dipilih
      });
    }
  }
  // ------------------------------------

  void _saveMhs() {
    if (_formKey.currentState!.validate()) {
      final mhs = MhsModel(
        nim: _nimController.text,
        nama: _namaController.text,
        imagePath: _selectedImage?.path, // <-- Masukkan path gambar
      );
      Provider.of<MhsProvider>(context, listen: false).addMhs(mhs);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data ${mhs.nama} berhasil disimpan'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mohon isi semua field'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Mahasiswa Baru", style: GoogleFonts.poppins())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // --- WIDGET PILIH FOTO ---
              GestureDetector(
                onTap: _pickImage, // Panggil fungsi ambil gambar
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _selectedImage != null 
                      ? FileImage(_selectedImage!) // Tampilkan gambar jika ada
                      : null,
                  child: _selectedImage == null
                      ? Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey[600]) // Ikon placeholder
                      : null,
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: Text("Pilih Foto Profil"),
                ),
              ),
              // -------------------------
              const SizedBox(height: 32),
              TextFormField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'NIM Mahasiswa',
                  prefixIcon: Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Mahasiswa',
                  prefixIcon: Icon(Icons.person_outline),
                   filled: true,
                   fillColor: Colors.white,
                ),
                 validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.save_alt),
                label: const Text('Simpan Data'),
                onPressed: _saveMhs,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}