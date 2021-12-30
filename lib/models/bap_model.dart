import 'dart:convert';

import 'package:http/http.dart' as http;
// import 'package:sipisat/models/inventory_model.dart';

import '../common.dart';

class BapModel {
  final String id;
  final String idSurat;
  final String tag;
  final String nomorSurat;
  final String idPihak1;
  final String idPihak2;
  final String jumlahInv;
  final String pdf;
  BapModel({
    required this.id,
    required this.idSurat,
    required this.tag,
    required this.nomorSurat,
    required this.idPihak1,
    required this.jumlahInv,
    required this.idPihak2,
    required this.pdf,
  });

  static List<BapModel> allBap = [];
  static List<BapModel> get baps {
    return [...allBap];
  }

  static Future<void> ambilData() async {
    var response = await http.get(Uri.parse(CommonUser.baseUrl + '/get_baps'));
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      List datas = res['data'];
      for (var data in datas) {
        if (allBap.length == datas.length) {
          return;
        } else {
          allBap.insert(
            0,
            BapModel(
                id: data['id'].toString(),
                tag: data['tag'],
                idSurat: data['id_surat'].toString(),
                nomorSurat: data['nomor_surat'].toString(),
                idPihak1: data['id_phk1'].toString(),
                idPihak2: data['id_phk2'].toString(),
                jumlahInv: data['jumlah_inv'].toString(),
                pdf: data['pdf'].toString()),
          );
        }
      }
      print('berhasil mengambil semua data bap');
    } else {
      print('gagal mengambil semua data bap');
    }
  }

  static Future<List<BapModel>> getData() async {
    ambilData();
    return allBap;
  }

  static void addBAP(
      String id,
      String idSurat,
      String nomorSurat,
      String idPihak1,
      String idPihak2,
      String jumlahInv,
      String pdf,
      String tag) {
    allBap.insert(
        0,
        BapModel(
            id: id,
            tag: tag,
            idSurat: idSurat,
            nomorSurat: nomorSurat,
            idPihak1: idPihak1,
            jumlahInv: jumlahInv,
            idPihak2: idPihak2,
            pdf: pdf));
  }
}
