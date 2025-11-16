// lib/models/book_model.dart

class BookModel {
  final int id;
  final String title;
  final String author;

  BookModel({required this.id, required this.title, required this.author});

  // Factory untuk mengubah JSON (dari API) menjadi objek BookModel
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      // Konversi ID ke int, bisa jadi string atau int dari API
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      author: json['author'] ?? 'Tanpa Penulis',
    );
  }

  // Method untuk mengubah objek menjadi JSON (untuk POST/PUT)
  Map<String, dynamic> toJson() => {
        
        'title': title,
        'author': author,
      };
}
