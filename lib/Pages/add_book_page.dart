import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:themenavigation/provider/api_provider.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {
      bool success = await Provider.of<ApiProvider>(context, listen: false)
          .createBook(_titleController.text, _authorController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                success ? 'Buku berhasil disimpan' : 'Gagal menyimpan buku'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Tambah Buku Baru", style: GoogleFonts.poppins())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Icon(Icons.library_add_outlined,
                  size: 60,
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.8)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Buku',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Judul tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(
                  labelText: 'Penulis Buku',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Penulis tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              // Tampilkan loading saat tombol ditekan
              Consumer<ApiProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton.icon(
                    icon: provider.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(Icons.save_alt),
                    label: Text(
                        provider.isLoading ? 'Menyimpan...' : 'Simpan Data'),
                    onPressed: provider.isLoading
                        ? null
                        : _saveBook, // Nonaktifkan tombol saat loading
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
