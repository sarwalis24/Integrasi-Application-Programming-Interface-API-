// lib/provider/api_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themenavigation/models/book_model.dart'; // Sesuaikan path

class ApiProvider with ChangeNotifier {
  //
  // --- ! PERBAIKAN: TAMBAHKAN http:// ! ---
  //
  final String _baseUrl = "http://192.168.110.85/api/index.php";
  //
  // ------------------------------------------

  String _token = "";
  String _userId = "";
  bool _isLoading = false;
  List<BookModel> _books = [];
  String _apiErrorMessage = "";

  // Getters
  bool get isLoading => _isLoading;
  List<BookModel> get books => _books;
  String get apiErrorMessage => _apiErrorMessage;
  bool get isLoggedIn => _token.isNotEmpty;

  // Header standar untuk request yang butuh otentikasi
  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Client-Service': 'frontend-client',
        'Auth-Key': 'simplerestapi',
        'User-ID': _userId,
        'Authorization': _token,
      };

  // Header untuk login
  final Map<String, String> _loginHeaders = {
    'Content-Type': 'application/json',
    'Client-Service': 'frontend-client',
    'Auth-Key': 'simplerestapi',
  };

  ApiProvider() {
    _loadTokenFromPrefs();
  }

  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token') ?? '';
    _userId = prefs.getString('api_user_id') ?? '';
    if (isLoggedIn) {
      print("Token API berhasil dimuat dari Prefs: $_token");
      getBooks(); // Otomatis ambil data buku
    }
    notifyListeners();
  }

  // 1. FUNGSI LOGIN (POST)
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _apiErrorMessage = "";
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/auth/login"),
            headers: _loginHeaders,
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(Duration(seconds: 10));

      _setLoading(false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['id'].toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_token', _token);
        await prefs.setString('api_user_id', _userId);

        await getBooks();
        return true;
      } else {
        // --- PERBAIKAN: Ambil pesan error dari API ---
        _apiErrorMessage =
            "Login API Gagal: ${jsonDecode(response.body)['message']}";
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _apiErrorMessage =
          "Error Koneksi: $e"; // Error koneksi (misal: Firewall/IP salah)
      print(_apiErrorMessage);
      return false;
    }
  }

  // 3. FUNGSI READ (GET)
  Future<void> getBooks() async {
    if (!isLoggedIn) return;
    _setLoading(true);
    _apiErrorMessage = "";

    try {
      final response = await http
          .get(
            Uri.parse("$_baseUrl/book"),
            headers: _authHeaders,
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // --- PERBAIKAN: API Anda mengembalikan List, bukan Map ---
        final List<dynamic> data = jsonDecode(response.body);
        _books = data.map((json) => BookModel.fromJson(json)).toList();
      } else {
        _books = [];
        _apiErrorMessage =
            "Gagal mengambil buku: ${jsonDecode(response.body)['message']}";
      }
    } catch (e) {
      _books = [];
      _apiErrorMessage = "Get Books Error: $e";
      print(_apiErrorMessage);
    }
    _setLoading(false);
    notifyListeners(); // Selalu notifikasi UI setelah selesai
  }

  // 2. FUNGSI CREATE (POST)
  Future<bool> createBook(String title, String author) async {
    _setLoading(true);
    _apiErrorMessage = "";
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/book/create"),
        headers: _authHeaders,
        body: jsonEncode({"title": title, "author": author}),
      );

      if (response.statusCode == 201) {
        // 201 = Created
        await getBooks(); // Ambil ulang daftar buku
        _setLoading(false);
        return true;
      }
      _apiErrorMessage =
          "Gagal membuat buku: ${jsonDecode(response.body)['message']}";
      _setLoading(false);
      return false;
    } catch (e) {
      _apiErrorMessage = "Create Book Error: $e";
      _setLoading(false);
      return false;
    }
  }

  // 4. FUNGSI UPDATE (PUT)
  Future<bool> updateBook(int bookId, String title, String author) async {
    _setLoading(true);
    _apiErrorMessage = "";
    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/book/update/$bookId"), // Gunakan ID buku
        headers: _authHeaders,
        body: jsonEncode({"title": title, "author": author}),
      );

      if (response.statusCode == 200) {
        await getBooks(); // Ambil ulang daftar buku
        _setLoading(false);
        return true;
      }
      _apiErrorMessage =
          "Gagal update buku: ${jsonDecode(response.body)['message']}";
      _setLoading(false);
      return false;
    } catch (e) {
      _apiErrorMessage = "Update Book Error: $e";
      _setLoading(false);
      return false;
    }
  }

  // 5. FUNGSI DELETE
  Future<bool> deleteBook(int bookId) async {
    _setLoading(true);
    _apiErrorMessage = "";
    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/book/delete/$bookId"),
        headers: _authHeaders,
      );

      if (response.statusCode == 200) {
        await getBooks(); // Ambil ulang daftar buku
        _setLoading(false);
        return true;
      }
      _apiErrorMessage =
          "Gagal delete buku: ${jsonDecode(response.body)['message']}";
      _setLoading(false);
      return false;
    } catch (e) {
      _apiErrorMessage = "Delete Book Error: $e";
      _setLoading(false);
      return false;
    }
  }

  // 6. FUNGSI LOGOUT (POST)
  Future<void> logout() async {
    if (isLoggedIn) {
      try {
        await http.post(
          Uri.parse("$_baseUrl/auth/logout"),
          headers: _authHeaders,
        );
      } catch (e) {
        print("API Logout Error: $e");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    await prefs.remove('api_user_id');
    _token = '';
    _userId = '';
    _books = [];
    print("Logout API dan Prefs berhasil");
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
