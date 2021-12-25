import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common.dart';

class Invetory {
  String id;
  String idSurat;
  String status;
  String idInventory;
  String nama;
  String merk;
  int jumlah;
  // String? newJumlah;
  String keterangan;
  String kategory;
  String pathPhoto;
  String? sn;
  String? model;
  String? subKategory;

  Invetory({
    required this.id,
    required this.idSurat,
    required this.status,
    required this.idInventory,
    required this.nama,
    required this.merk,
    required this.jumlah,
    // this.newJumlah,
    required this.keterangan,
    required this.kategory,
    required this.pathPhoto,
    this.model,
    this.subKategory,
    this.sn,
  });
  static List<Invetory> allInv = [];
  static List<Invetory> get invs {
    return [...allInv];
  }

  static void hapus(String index) {
    allInv.removeWhere((element) => element.id == index);
    print('berhasil hapus inv dengan id $index');
  }

  static Future<void> ambilData() async {
    var response = await http.get(Uri.parse(CommonUser.baseUrl + '/get_invs'));
    if (response.statusCode == 200) {
      List datas = jsonDecode(response.body);
      for (var data in datas) {
        if (allInv.length >= datas.length) {
          return;
        } else {
          allInv.insert(
            0,
            Invetory(
                id: data['id'].toString(),
                idSurat: data['id_surat'] == null ? 'null' : data['id_surat'],
                idInventory: data['id_inventory'],
                status: data['status'],
                nama: data['nama'],
                merk: data['merk'],
                jumlah: data['new_jumlah'] == 'null'
                    ? int.parse(data['jumlah'])
                    : int.parse(data['new_jumlah']),
                keterangan: data['keterangan'],
                kategory: data['kategory'],
                pathPhoto: data['path_photo'],
                model: data['model'],
                sn: data['sn'],
                subKategory: data['sub_kategory']),
          );
        }
        // print(data['path_photo']);
      }
      print('semua data inventory $allInv');
      print('berhasil mengambil data inventory');
    } else {
      print('gagal mengambil data inventory');
    }
  }

  static Future<List<Invetory>> getData() async {
    ambilData();
    return allInv;
  }

  static void tambahInv(
    String id,
    String idSurat,
    String status,
    String idInventory,
    String nama,
    String merk,
    String sn,
    String model,
    int jumlah,
    String keterangan,
    String kategory,
    String subKategory,
    String pathPhoto,
    Function sesState,
  ) {
    allInv.add(
      Invetory(
        id: id,
        idSurat: idSurat,
        status: status,
        idInventory: idInventory,
        nama: nama,
        merk: merk,
        sn: sn,
        model: model,
        jumlah: jumlah,
        keterangan: keterangan,
        kategory: kategory,
        subKategory: subKategory,
        pathPhoto: pathPhoto,
      ),
    );
  }

  static void editInv(
      String id,
      String idSurat,
      String status,
      String idInventory,
      String nama,
      String merk,
      String sn,
      String model,
      int jumlah,
      String keterangan,
      String kategory,
      String subKategory,
      String pathPhoto,
      Function sesState) {
    Invetory toEdit = allInv.firstWhere((element) => element.id == id);
    toEdit.id = id;
    toEdit.idSurat = idSurat;
    toEdit.idInventory = idInventory;
    toEdit.status = status;
    toEdit.nama = nama;
    toEdit.merk = merk;
    toEdit.jumlah = jumlah;
    toEdit.sn = sn;
    toEdit.model = model;
    toEdit.keterangan = keterangan;
    toEdit.kategory = kategory;
    toEdit.subKategory = subKategory;
    toEdit.pathPhoto = pathPhoto;
    sesState();
  }
}
