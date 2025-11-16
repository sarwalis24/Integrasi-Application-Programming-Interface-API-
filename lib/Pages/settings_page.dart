import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pengaturan"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text("Tema Aplikasi"),
            subtitle: Text("Pilih mode terang atau gelap (belum aktif)"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur tema belum diimplementasikan')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_none),
            title: Text("Notifikasi"),
            subtitle: Text("Atur preferensi notifikasi (belum aktif)"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Fitur notifikasi belum diimplementasikan')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text("Bahasa"),
            subtitle: Text("Pilih bahasa aplikasi (belum aktif)"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fitur bahasa belum diimplementasikan')),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("Tentang Aplikasi"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Aplikasi Praktikum',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Sarwalis',
              );
            },
          ),
        ],
      ),
    );
  }
}
