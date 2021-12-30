import 'dart:convert';

import '../common.dart';
import 'package:http/http.dart' as http;

class LogModel {
  String id;
  String? idKegiatan;
  String kegiatan;
  String waktu;
  String teks;
  String? nama1;
  String? nama2;
  String? inventory;

  LogModel({
    required this.id,
    this.idKegiatan,
    required this.kegiatan,
    required this.waktu,
    required this.teks,
    this.nama1,
    this.nama2,
    this.inventory,
  });
  static var dd = DateTime.now();
  static String date = '${dd.day}/${dd.month}/${dd.year}';
  static List<LogModel> allLog = [];
  static void sendLog(
    String id,
    String kegiatan,
    String idKegiatan,
    String teks,
  ) async {
    var rr = await http.post(Uri.parse(CommonUser.baseUrl + '/store_log'),
        body: ({
          'kegiatan': kegiatan,
          'id_kegiatan': idKegiatan.isEmpty ? 'null' : idKegiatan,
          'waktu': date,
          'teks': teks,
        }));
    if (rr.statusCode == 200) {
      allLog.insert(
        0,
        LogModel(id: id, kegiatan: kegiatan, waktu: date, teks: teks),
      );
    }
  }

  static void ambilData() async {
    var response = await http.get(Uri.parse(CommonUser.baseUrl + '/get_logs'));
    if (response.statusCode == 200) {
      print('berhasil ambil semua log');
      var res = jsonDecode(response.body);
      if (allLog.length < res['data'].length || allLog.isEmpty) {
        for (var data in res['data']) {
          allLog.insert(
            0,
            LogModel(
              id: data['id'].toString(),
              kegiatan: data['kegiatan'],
              idKegiatan: data['id_kegiatan'],
              waktu: data['waktu'],
              teks: data['teks'],
            ),
          );
        }
      }
    }
  }

  static Future<List<LogModel>> getLog() async {
    ambilData();
    return allLog;
  }
}
