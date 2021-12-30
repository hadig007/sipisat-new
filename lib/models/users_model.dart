import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common.dart';

class UserModel {
  String id;
  String nama;
  String kontak;
  String jabatan;
  String alamat;
  String password;

  UserModel({
    required this.id,
    required this.nama,
    required this.kontak,
    required this.jabatan,
    required this.alamat,
    required this.password,
  });
  static List<UserModel> allUser = [];
  static Future<void> ambilData() async {
    var response = await http.get(Uri.parse(CommonUser.baseUrl + '/get_users'));
    if (response.statusCode == 200) {
      print('berhasil mengambil data users');
      var res = jsonDecode(response.body);
      List data = res['data'];
      for (var dt in data) {
        if (allUser.length >= data.length) {
          return;
        } else {
          allUser.insert(
              0,
              UserModel(
                  id: dt['id'].toString(),
                  password:
                      dt['password'] == null ? 'password' : dt['password'],
                  nama: dt['name'],
                  kontak: dt['kontak'],
                  jabatan: dt['jabatan'],
                  alamat: dt['alamat']));
        }
      }
      print('semua data users $allUser');
      print('selesai mengambil semua data user');
    } else {
      print('gagal mengambil data users');
    }
  }

  static Future<List<UserModel>> getData() async {
    ambilData();
    return allUser;
  }

  static void tambahUser(String id, String nama, String kontak, String jabatan,
      String alamat, String password, Function setState) {
    allUser.insert(
      0,
      UserModel(
        id: id,
        nama: nama,
        kontak: kontak,
        jabatan: jabatan,
        alamat: alamat,
        password: password,
      ),
    );
    setState();
  }

  static void editUser(String id, String nama, String kontak, String jabatan,
      String alamat, String password, Function setState) {
    UserModel toEdit = allUser.firstWhere((element) => element.id == id);
    toEdit.id = id;
    toEdit.nama = nama;
    toEdit.kontak = kontak;
    toEdit.jabatan = jabatan;
    toEdit.alamat = alamat;
    setState();
  }
}
