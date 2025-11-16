// lib/pages/book_list_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:themenavigation/models/book_model.dart';
import 'package:themenavigation/provider/api_provider.dart';
import 'update_book_page.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final apiProvider = context.watch<ApiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Data Buku 📚", style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<ApiProvider>().getBooks();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add_book");
        },
        child: Icon(Icons.add),
      ),
      body: _buildBookList(context, apiProvider),
    );
  }

  Widget _buildBookList(BuildContext context, ApiProvider provider) {
    if (provider.isLoading && provider.books.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (!provider.isLoggedIn) {
      return Center(child: Text("Silakan login ulang."));
    }

    if (provider.books.isEmpty) {
      return Center(child: Text("Belum ada data buku."));
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: provider.books.length,
      itemBuilder: (context, index) {
        final book = provider.books[index];

        return Card(
          elevation: 3,
          margin: EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            leading: CircleAvatar(child: Icon(Icons.menu_book)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpdateBookPage(book: book),
                      ),
                    );
                  },
                ),

                // Tombol Delete
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool confirm = await _confirmDelete(context);

                    if (confirm) {
                      await Provider.of<ApiProvider>(context, listen: false)
                          .deleteBook(book.id);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Hapus Buku"),
              content: Text("Yakin ingin menghapus?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("Batal"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("Hapus", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
