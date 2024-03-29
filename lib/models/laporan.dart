class Laporan {
  final String uid;
  final String docId;
  final String judul;
  final String instansi;
  String? deskripsi;
  String? gambar;
  int? like;
  final String nama;
  final String status;
  final DateTime tanggal;
  final String maps;
  List<Komentar>? komentar;

  Laporan({
    required this.uid,
    required this.docId,
    required this.judul,
    required this.instansi,
    this.deskripsi,
    this.gambar,
    this.like,
    required this.nama,
    required this.status,
    required this.tanggal,
    required this.maps,
    this.komentar,
  });
}

class Komentar {
  final String nama;
  final String isi;
  // final DateTime time;

  Komentar({required this.nama, required this.isi});
}
