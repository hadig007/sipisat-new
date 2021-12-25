class LogModel {
  String id;
  String idKegiatan;
  String kegiatan;
  String waktu;
  String? nama1;
  String? nama2;
  String? inventory;

  LogModel({
    required this.id,
    required this.idKegiatan,
    required this.kegiatan,
    required this.waktu,
    this.nama1,
    this.nama2,
    this.inventory,
  });
}
