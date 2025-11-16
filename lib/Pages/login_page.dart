// lib/pages/login_page.dart
import 'package:flutter/material.dart'; // <-- IMPORT UTAMA YANG HILANG
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // <-- Import Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themenavigation/provider/api_provider.dart'; // <-- Import ApiProvider

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // <-- Tambahkan FormKey
  String _errorMessage = '';
  bool _isLoading = false; // <-- Tambahkan state loading

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI LOGIN YANG SUDAH DI-UPDATE ---
  void _validateAndLogin() async {
    // 1. Validasi form dulu
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Username dan Password tidak boleh kosong';
      });
      return; // Berhenti jika form tidak valid
    }

    // 2. Ambil data dari provider dan controller
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final username = _usernameController.text;
    final password = _passwordController.text;

    // 3. Set state loading
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 4. Panggil login API
      bool loginApiSuccess = await apiProvider.login(username, password);

      if (loginApiSuccess) {
        // 5. Jika API sukses, simpan username ke SharedPreferences (untuk auto-login)
        await prefs.setString('username', username);

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home', arguments: username);
        }
      } else {
        // 6. Jika API gagal, tampilkan pesan error dari provider
        setState(() {
          _errorMessage = apiProvider.apiErrorMessage.isNotEmpty
              ? apiProvider.apiErrorMessage
              : 'Login API Gagal. Cek kredensial.';
          _isLoading = false;
        });
      }
    } catch (e) {
      // 7. Tangani error (misal: tidak ada koneksi)
      setState(() {
        _errorMessage = 'Terjadi error: $e';
        _isLoading = false;
      });
    }
  }
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            // --- Bungkus Column dengan Form ---
            child: Form(
              key: _formKey, // <-- Hubungkan FormKey
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Selamat Datang",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Masuk untuk melanjutkan ke aplikasi",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    // --- Tambahkan Validator ---
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    // --- Tambahkan Validator ---
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Lupa Password?"),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- Update Tombol Login ---
                  ElevatedButton(
                    // Nonaktifkan tombol saat loading
                    onPressed: _isLoading ? null : _validateAndLogin,
                    child: _isLoading
                        ? const SizedBox(
                            // Tampilkan loading indicator
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text("Login"),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {},
                    child: RichText(
                      text: TextSpan(
                          style: GoogleFonts.poppins(color: Colors.black87),
                          children: [
                            TextSpan(text: "Belum punya akun? "),
                            TextSpan(
                              text: "Daftar di sini",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
