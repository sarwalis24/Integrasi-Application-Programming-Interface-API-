import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import
import 'package:image_picker/image_picker.dart'; // Import
import 'package:provider/provider.dart';
import 'package:themenavigation/models/mhs_model.dart';
import 'package:themenavigation/provider/mhs_provider.dart';
import 'dart:io'; // Import

class UpdateMhsPage extends StatefulWidget {
  final MhsModel mhs;
  const UpdateMhsPage({super.key, required this.mhs});

  @override
  State<UpdateMhsPage> createState() => _UpdateMhsPageState();
}

class _UpdateMhsPageState extends State<UpdateMhsPage> {
  late TextEditingController _nimController;
  late TextEditingController _namaController;
  final _formKey = GlobalKey<FormState>();
  
  File? _selectedImage; // State untuk gambar baru
  String? _existingImagePath; // State untuk gambar lama

  @override
  void initState() {
    super.initState();
    _nimController = TextEditingController(text: widget.mhs.nim);
    _namaController = TextEditingController(text: widget.mhs.nama);
    _existingImagePath = widget.mhs.imagePath; // Simpan path gambar lama
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _existingImagePath = null; // Hapus gambar lama jika gambar baru dipilih
      });
    }
  }

  void _updateMhs() {
    if (_formKey.currentState!.validate()) {
      final updatedMhs = MhsModel(
        id: widget.mhs.id,
        nim: _nimController.text,
        nama: _namaController.text,
        // Pilih path gambar baru jika ada, jika tidak, gunakan path lama
        imagePath: _selectedImage?.path ?? _existingImagePath, 
      );
      Provider.of<MhsProvider>(context, listen: false).updateMhs(updatedMhs);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan gambar yang akan ditampilkan di Avatar
    ImageProvider? avatarImage;
    if (_selectedImage != null) {
      avatarImage = FileImage(_selectedImage!); // Gambar baru
    } else if (_existingImagePath != null && _existingImagePath!.isNotEmpty) {
      avatarImage = FileImage(File(_existingImagePath!)); // Gambar lama
    } else {
      avatarImage = null; // Tidak ada gambar
    }

    return Scaffold(
      appBar: AppBar(title: Text("Update Mahasiswa", style: GoogleFonts.poppins())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatarImage, // Tampilkan gambar
                  child: avatarImage == null
                      ? Icon(Icons.camera_alt_outlined, size: 50, color: Colors.grey[600])
                      : null,
                ),
              ),
               Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: Text("Ubah Foto Profil"),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nimController,
                decoration: InputDecoration(
                  labelText: 'NIM', 
                  prefixIcon: Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) { /* ... validasi ... */ },
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.update),
                label: const Text('Update Data'),
                onPressed: _updateMhs,
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