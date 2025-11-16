import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:themenavigation/models/book_model.dart';
import 'package:themenavigation/provider/api_provider.dart';

class UpdateBookPage extends StatefulWidget {
  final BookModel book;
  const UpdateBookPage({super.key, required this.book});

  @override
  State<UpdateBookPage> createState() => _UpdateBookPageState();
}

class _UpdateBookPageState extends State<UpdateBookPage> {
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _updateBook() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<ApiProvider>().updateBook(
            widget.book.id,
            _titleController.text,
            _authorController.text,
          );

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Buku berhasil diupdate!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Buku")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "Judul Buku"),
                validator: (v) =>
                    v!.isEmpty ? "Judul tidak boleh kosong" : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _authorController,
                decoration: InputDecoration(labelText: "Penulis"),
                validator: (v) =>
                    v!.isEmpty ? "Penulis tidak boleh kosong" : null,
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Update Buku"),
                onPressed: _updateBook,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
