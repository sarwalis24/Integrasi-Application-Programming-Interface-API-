import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pastikan GoogleFonts diimpor
import 'package:intl/intl.dart';

class ProdukPage extends StatelessWidget {
  ProdukPage({super.key});

  // Data dummy (tidak berubah)
  final List<Map<String, dynamic>> dataProduk = [
    {
      'nama': 'Laptop Pro',
      'harga_asli': 16500000,
      'diskon': 10,
      'rating': 4.5,
      'gambar':
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&q=60',
    },
    {
      'nama': 'Mouse Gaming',
      'harga_asli': 750000,
      'diskon': 0,
      'rating': 4.8,
      'gambar':
          'https://images.pexels.com/photos/7915429/pexels-photo-7915429.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'nama': 'Keyboard Mekanikal',
      'harga_asli': 1500000,
      'diskon': 20,
      'rating': 4.7,
      'gambar':
          'https://images.pexels.com/photos/841228/pexels-photo-841228.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'nama': 'Headset Keren',
      'harga_asli': 950000,
      'diskon': 0,
      'rating': 4.6,
      'gambar':
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=60',
    },
    {
      'nama': 'Webcam HD',
      'harga_asli': 1000000,
      'diskon': 15,
      'rating': 4.4,
      'gambar':
          'https://images.pexels.com/photos/6634181/pexels-photo-6634181.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'nama': 'Monitor 24 inch',
      'harga_asli': 2500000,
      'diskon': 0,
      'rating': 4.9,
      'gambar':
          'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=500&q=60',
    },
    {
      'nama': 'Meja Ergonomis', 'harga_asli': 3100000, 'diskon': 5,
      'rating': 4.2, // Diskon 5% ditambahkan
      'gambar':
          'https://images.pexels.com/photos/1957478/pexels-photo-1957478.jpeg?auto=compress&cs=tinysrgb&w=600',
    },
    {
      'nama': 'Kursi Gaming',
      'harga_asli': 2800000,
      'diskon': 0,
      'rating': 4.6,
      'gambar':
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=60',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final formatAngka = NumberFormat("#,##0", "id_ID");
    final Color primaryColor =
        Theme.of(context).colorScheme.primary; // Ambil warna utama tema

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daftar Produk ✨", // Judul lebih menarik
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor, // Gunakan warna tema
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100], // Latar belakang body sedikit abu-abu
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0), // Padding lebih besar
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0, // Spasi lebih besar
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.7, // Rasio agar kartu lebih tinggi
        ),
        itemCount: dataProduk.length,
        itemBuilder: (context, index) {
          final produk = dataProduk[index];
          final int hargaAsli = produk['harga_asli'];
          final int diskon = produk['diskon'];
          final double hargaSetelahDiskon = hargaAsli * (1 - diskon / 100);
          final double rating = produk['rating'];

          return Material(
            // Bungkus Card dengan Material untuk efek bayangan yang lebih baik
            elevation: 6.0, // Bayangan lebih tebal
            shadowColor: primaryColor.withOpacity(0.3), // Warna bayangan
            borderRadius: BorderRadius.circular(20.0), // Sudut lebih tumpul
            child: InkWell(
              // Beri efek ripple saat disentuh
              borderRadius: BorderRadius.circular(20.0),
              onTap: () {
                // TODO: Navigasi ke halaman detail produk
                print('Tap on: ${produk['nama']}');
              },
              child: ClipRRect(
                // Potong konten sesuai border radius
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Warna dasar kartu
                    // Bisa tambahkan gradient jika suka:
                    // gradient: LinearGradient(
                    //   colors: [Colors.white, Colors.grey[50]!],
                    //   begin: Alignment.topLeft,
                    //   end: Alignment.bottomRight,
                    // ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Gambar & Diskon ---
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.1, // Rasio gambar sedikit landscape
                            child: Image.network(
                              produk['gambar'],
                              fit: BoxFit.cover,
                              // Animasi Hero untuk transisi ke detail (jika ada)
                              // Mencegah error gambar tidak dimuat
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.broken_image,
                                      color: Colors.grey[400]),
                                );
                              },
                              // Loading indicator
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ));
                              },
                            ),
                          ),
                          if (diskon > 0)
                            Positioned(
                              top: 10,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      )
                                    ]),
                                child: Text(
                                  '$diskon% OFF',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      // --- Detail Produk ---
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment
                                .spaceBetween, // Dorong harga ke bawah
                            children: [
                              // Nama Produk
                              Text(
                                produk['nama'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, // Lebih tebal
                                  fontSize: 15, // Sedikit lebih besar
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Rating & Harga
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- Rating Bintang ---
                                  Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.amber, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height:
                                          4), // Jarak antara rating dan harga
                                  // --- Harga ---
                                  if (diskon > 0)
                                    Text(
                                      'Rp ${formatAngka.format(hargaAsli)}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[500],
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 11,
                                      ),
                                    ),
                                  Text(
                                    'Rp ${formatAngka.format(hargaSetelahDiskon)}',
                                    style: GoogleFonts.poppins(
                                      color: primaryColor, // Gunakan warna tema
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
