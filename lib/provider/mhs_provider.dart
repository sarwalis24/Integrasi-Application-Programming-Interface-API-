import 'package:flutter/material.dart';
import 'package:themenavigation/db/my_db.dart';
import 'package:themenavigation/models/mhs_model.dart';

class MhsProvider with ChangeNotifier {
  List<MhsModel> _mahasiswa = [];
  final MyDb _db = MyDb();

  List<MhsModel> get mahasiswa => _mahasiswa;

  MhsProvider() {
    _loadMahasiswa();
  }

  Future<void> _loadMahasiswa() async {
    _mahasiswa = await _db.getMahasiswa();
    notifyListeners();
  }

  Future<void> addMhs(MhsModel mhs) async {
    await _db.insertMhs(mhs);
    await _loadMahasiswa();
  }

  Future<void> updateMhs(MhsModel mhs) async {
    await _db.updateMhs(mhs);
    await _loadMahasiswa();
  }

  Future<void> deleteMhs(int id) async {
    await _db.deleteMhs(id);
    await _loadMahasiswa();
  }
}
