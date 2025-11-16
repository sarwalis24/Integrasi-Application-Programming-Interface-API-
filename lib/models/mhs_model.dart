class MhsModel {
  int? id;
  String nama, nim;
  String? imagePath; // <-- TAMBAHKAN PROPERTI INI

  MhsModel({this.id, required this.nim, required this.nama, this.imagePath}); // <-- TAMBAHKAN DI KONSTRUKTOR

  factory MhsModel.fromMap(Map<String, dynamic> map) => MhsModel(
        id: map['id'],
        nim: map['nim'],
        nama: map['nama'],
        imagePath: map['imagePath'], // <-- TAMBAHKAN DARI MAP
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nim': nim,
        'nama': nama,
        'imagePath': imagePath, // <-- TAMBAHKAN KE MAP
      };
}