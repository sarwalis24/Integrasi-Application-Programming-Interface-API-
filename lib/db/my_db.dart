import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:themenavigation/models/mhs_model.dart'; // Sesuaikan path

class MyDb {
  static Database? _database;
  static const String _tableName = 'mahasiswa';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'mhs_data.db');
    return await openDatabase(
      path,
      version: 2, // <-- UBAH VERSI MENJADI 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // <-- TAMBAHKAN onUpgrade
    );
  }

  // onCreate: Untuk instalasi baru
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      // Tambahkan imagePath TEXT
      'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, nim TEXT, nama TEXT, imagePath TEXT)',
    );
  }

  // onUpgrade: Untuk pengguna yang sudah punya database versi 1
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambahkan kolom baru jika versi lama < 2
      await db.execute('ALTER TABLE $_tableName ADD COLUMN imagePath TEXT');
    }
  }
  
  // Fungsi CRUD (Insert, Get, Update, Delete) TIDAK PERLU DIUBAH
  // karena mereka menggunakan toMap() dan fromMap() dari MhsModel
  // yang sudah kita update sebelumnya.

  Future<void> insertMhs(MhsModel mhs) async {
    final db = await database;
    await db.insert(_tableName, mhs.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<MhsModel>> getMahasiswa() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_tableName);
    return List.generate(maps.length, (i) {
      return MhsModel.fromMap(maps[i]);
    });
  }

  Future<void> updateMhs(MhsModel mhs) async {
    final db = await database;
    await db.update(
      _tableName,
      mhs.toMap(),
      where: 'id = ?',
      whereArgs: [mhs.id],
    );
  }

  Future<void> deleteMhs(int id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}