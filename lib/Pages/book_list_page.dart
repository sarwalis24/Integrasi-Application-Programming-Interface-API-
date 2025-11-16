// lib/pages/book_list_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:themenavigation/models/book_model.dart';
import 'package:themenavigation/provider/api_provider.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan 'watch' agar UI otomatis update saat data buku berubah
    final apiProvider = context.watch<ApiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Data Buku (API) 📚",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            tooltip: "Refresh Data",
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Memuat ulang data...'))
              );
              await context.read<ApiProvider>().getBooks();
               ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: _buildBookList(context, apiProvider),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text("Tambah Buku", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        onPressed: () {
          Navigator.pushNamed(context, '/add_book');
        },
      ),
    );
  }

  Widget _buildBookList(BuildContext context, ApiProvider provider) {
    if (provider.isLoading && provider.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!provider.isLoggedIn) {
       return Center(child: Text("Sesi login API tidak ditemukan. Silakan login ulang."));
    }

    if (provider.apiErrorMessage.isNotEmpty && provider.books.isEmpty) {
       return Center(child: Text("Gagal memuat data: ${provider.apiErrorMessage}"));
    }

    if (provider.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Belum ada data buku.",
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.books.length,
      itemBuilder: (context, index) {
        final book = provider.books[index];
        return Card(
           margin: const EdgeInsets.only(bottom: 12.0),
           elevation: 3,
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           child: ListTile(
             contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
             leading: CircleAvatar(child: Icon(Icons.book_online)),
             title: Text(book.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
             subtitle: Text(book.author, style: GoogleFonts.poppins(color: Colors.black54)),
             trailing: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 IconButton(
                   icon: Icon(Icons.edit_outlined, color: Colors.blueAccent),
                   onPressed: () { /* TODO: Navigasi ke Update Book */ },
                 ),
                 IconButton(
                   icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                   onPressed: () { /* TODO: Panggil fungsi Delete Book */ },
                 ),
               ],
             ),
           ),
        );
      },
    );
  }
}