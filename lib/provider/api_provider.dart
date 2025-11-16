import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themenavigation/models/book_model.dart';

class ApiProvider with ChangeNotifier {
  // Pastikan IP benar & server aktif
  final String _baseUrl = "http://192.168.110.85/api/index.php";

  String _token = "";
  String _userId = "";
  bool _isLoading = false;
  List<BookModel> _books = [];
  String _apiErrorMessage = "";

  // =============================
  // GETTERS
  // =============================
  bool get isLoading => _isLoading;
  List<BookModel> get books => _books;
  String get apiErrorMessage => _apiErrorMessage;
  bool get isLoggedIn => _token.isNotEmpty;

  // Header standar untuk request authenticated
  Map<String, String> get _authHeaders => {
        'Content-Type': 'application/json',
        'Client-Service': 'frontend-client',
        'Auth-Key': 'simplerestapi',
        'User-ID': _userId,
        'Authorization': _token,
      };

  // Header untuk login (tanpa token)
  final Map<String, String> _loginHeaders = {
    'Content-Type': 'application/json',
    'Client-Service': 'frontend-client',
    'Auth-Key': 'simplerestapi',
  };

  ApiProvider() {
    _loadTokenFromPrefs();
  }

  // =============================
  // HELPERS
  // =============================
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool _bodyIndicatesSuccess(String? body) {
    if (body == null) return false;
    final b = body.toLowerCase();
    return b.contains('created') ||
        b.contains('success') ||
        b.contains('updated') ||
        b.contains('deleted') ||
        b.contains('ok');
  }

  String _extractMessageFromResponseBody(String body) {
    // Try parse JSON first
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded.containsKey('message')) {
        return decoded['message'].toString();
      }
      // If it's map with 'data' and maybe 'message'
      if (decoded is Map && decoded.isNotEmpty) {
        return decoded.values.join(' | ');
      }
      // If it's list or other, just return raw
      return body;
    } catch (_) {
      // Not JSON, return body raw (trim)
      return body.trim();
    }
  }

  // =============================
  // LOAD TOKEN DARI SHARED PREFS
  // =============================
  Future<void> _loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token') ?? '';
    _userId = prefs.getString('api_user_id') ?? '';

    if (isLoggedIn) {
      debugPrint("Token API dimuat: $_token");
      await getBooks();
    }

    notifyListeners();
  }

  // =============================
  // LOGIN (POST)
  // =============================
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
          .timeout(const Duration(seconds: 10));

      _setLoading(false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _token = data['token'] ?? '';
        _userId = (data['id'] ?? '').toString();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_token', _token);
        await prefs.setString('api_user_id', _userId);

        await getBooks();
        return true;
      } else {
        _apiErrorMessage =
            "Login API gagal: ${_extractMessageFromResponseBody(response.body)}";
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _apiErrorMessage = "Error koneksi: $e";
      debugPrint(_apiErrorMessage);
      return false;
    }
  }

  // =============================
  // READ BOOKS (GET)
  // =============================
  Future<void> getBooks() async {
    // jika aplikasi menggunakan login/token; kalau tidak, kamu bisa comment check ini
    if (!isLoggedIn) return;

    _setLoading(true);
    _apiErrorMessage = "";

    try {
      final response = await http
          .get(
            Uri.parse("$_baseUrl/book"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("GET STATUS: ${response.statusCode}");
      debugPrint("GET BODY: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is List) {
            _books = decoded.map((json) => BookModel.fromJson(json)).toList();
          } else if (decoded is Map && decoded['data'] is List) {
            _books =
                (decoded['data'] as List).map((j) => BookModel.fromJson(j)).toList();
          } else {
            // Unexpected JSON shape — try to handle if it's a single object or string
            _books = [];
            _apiErrorMessage = "Format data buku tidak terduga.";
          }
        } catch (e) {
          // response isn't JSON (maybe plain text) — set empty and show message
          _books = [];
          _apiErrorMessage = "Get Books: respons bukan JSON.";
          debugPrint("GetBooks parse error: $e");
        }
      } else {
        final msg = _extractMessageFromResponseBody(response.body);
        _books = [];
        _apiErrorMessage = "Gagal mengambil buku: $msg";
      }
    } catch (e) {
      _books = [];
      _apiErrorMessage = "Get Books Error: $e";
      debugPrint(_apiErrorMessage);
    }

    _setLoading(false);
    notifyListeners();
  }

  // =============================
  // CREATE BOOK (POST)
  // =============================
  Future<bool> createBook(String title, String author) async {
    _setLoading(true);
    _apiErrorMessage = "";

    try {
      final bodyJson = jsonEncode({"title": title, "author": author});
      final response = await http.post(
        Uri.parse("$_baseUrl/book/create"),
        headers: _authHeaders,
        body: bodyJson,
      );

      debugPrint('CREATE STATUS: ${response.statusCode}');
      debugPrint('CREATE BODY: ${response.body}');

      // Accept common success signals: 201, 200, or body contains keywords
      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          _bodyIndicatesSuccess(response.body)) {
        // Try to refresh list if possible
        await getBooks();
        _setLoading(false);
        return true;
      }

      // Not success → try to extract readable message
      final msg = _extractMessageFromResponseBody(response.body);
      _apiErrorMessage = "Gagal membuat buku: $msg";

      _setLoading(false);
      return false;
    } catch (e) {
      _apiErrorMessage = "Create Book Error: $e";
      debugPrint('CREATE ERROR: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================
  // UPDATE BOOK (PUT)
  // =============================
  Future<bool> updateBook(int bookId, String title, String author) async {
    _setLoading(true);
    _apiErrorMessage = "";

    try {
      final bodyJson = jsonEncode({"title": title, "author": author});
      final response = await http.put(
        Uri.parse("$_baseUrl/book/update/$bookId"),
        headers: _authHeaders,
        body: bodyJson,
      );

      debugPrint('UPDATE STATUS: ${response.statusCode}');
      debugPrint('UPDATE BODY: ${response.body}');

      if (response.statusCode == 200 || _bodyIndicatesSuccess(response.body)) {
        await getBooks();
        _setLoading(false);
        return true;
      }

      final msg = _extractMessageFromResponseBody(response.body);
      _apiErrorMessage = "Gagal update buku: $msg";
      _setLoading(false);
      return false;
    } catch (e) {
      _apiErrorMessage = "Update Book Error: $e";
      debugPrint('UPDATE ERROR: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================
  // DELETE BOOK
  // =============================
  Future<bool> deleteBook(int bookId) async {
    _setLoading(true);
    _apiErrorMessage = "";

    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/book/delete/$bookId"),
        headers: _authHeaders,
      );

      debugPrint('DELETE STATUS: ${response.statusCode}');
      debugPrint('DELETE BODY: ${response.body}');

      if (response.statusCode == 200 || _bodyIndicatesSuccess(response.body)) {
        // Update local list to remove immediately (optimistic)
        _books.removeWhere((book) => book.id == bookId);
        notifyListeners();

        // Also try refresh (optional)
        // await getBooks();

        _setLoading(false);
        return true;
      }

      final msg = _extractMessageFromResponseBody(response.body);
      _apiErrorMessage = "Gagal delete buku: $msg";
      _setLoading(false);
      return false;
    } catch (e) {
      _apiErrorMessage = "Delete Book Error: $e";
      debugPrint('DELETE ERROR: $e');
      _setLoading(false);
      return false;
    }
  }

  // =============================
  // LOGOUT
  // =============================
  Future<void> logout() async {
    if (isLoggedIn) {
      try {
        await http.post(
          Uri.parse("$_baseUrl/auth/logout"),
          headers: _authHeaders,
        );
      } catch (e) {
        debugPrint("API Logout Error: $e");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    await prefs.remove('api_user_id');

    _token = '';
    _userId = '';
    _books = [];

    debugPrint("Logout API dan Prefs berhasil");
    notifyListeners();
  }
}