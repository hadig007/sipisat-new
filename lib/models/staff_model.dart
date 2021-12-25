import 'dart:convert';

import '../common.dart';
import 'package:http/http.dart' as http;

class StaffModel {
  String? id;
  String nama;
  String nip;
  String jabatan;
  String alamat;

  StaffModel({
    this.id,
    required this.nama,
    required this.nip,
    required this.jabatan,
    required this.alamat,
  });

  static List<StaffModel> allStaf = [];
  static Future<void> ambilData() async {
    var response =
        await http.get(Uri.parse(CommonUser.baseUrl + '/get_staffs'));
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      List data = res['data'];
      for (var dt in data) {
        if (allStaf.length >= data.length) {
          return;
        } else {
          allStaf.insert(
              0,
              StaffModel(
                  id: dt['id'].toString(),
                  nama: dt['nama'],
                  nip: dt['nip'],
                  jabatan: dt['jabatan'],
                  alamat: dt['alamat']));
        }
      }
      print('semua data staff $allStaf');
      print('berhasil mengambil data staff');
    } else {
      print('gagal mengambil data staff');
    }
  }

  static Future<List<StaffModel>> getData() async {
    ambilData();
    return allStaf;
  }

  static void tambahStaff(
      String id, String name, String nip, String jabatan, String alamat) {
    allStaf.insert(
        0,
        StaffModel(
            id: id, nama: name, nip: nip, jabatan: jabatan, alamat: alamat));
  }
}
