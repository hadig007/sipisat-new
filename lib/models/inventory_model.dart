import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common.dart';

class Invetory {
  String id;
  String idSurat;
  String status;
  String idPemilik;
  String idInventory;
  String nama;
  String merk;
  int jumlah;
  int newJumlah;
  int jumlahPinjam;
  String idAwal;
  String keterangan;
  String model;
  String sn;
  String kategory;
  String subKategory;
  String pathPhoto;

  Invetory({
    required this.id,
    required this.idSurat,
    required this.status,
    required this.idPemilik,
    required this.idInventory,
    required this.nama,
    required this.merk,
    required this.jumlah,
    required this.newJumlah,
    required this.jumlahPinjam,
    required this.idAwal,
    required this.keterangan,
    required this.kategory,
    required this.pathPhoto,
    required this.model,
    required this.subKategory,
    required this.sn,
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
        if (allInv.length == datas.length) {
          return;
        } else {
          allInv.insert(
            0,
            Invetory(
              id: data['id'].toString(),
              idSurat: data['id_surat'],
              idInventory: data['id_inventory'],
              idPemilik: data['id_pemilik'],
              status: data['status'],
              nama: data['nama'],
              merk: data['merk'],
              jumlah: int.parse(data['jumlah']),
              newJumlah: int.parse(data['new_jumlah']),
              jumlahPinjam: int.parse(data['jumlah_pinjam']),
              idAwal: data['id_awal'] == null ? 'null' : data['id_awal'],
              keterangan: data['keterangan'],
              kategory: data['kategory'],
              model: data['model'] == null ? 'null' : data['model'],
              sn: data['sn'] == null ? 'null' : data['sn'],
              subKategory:
                  data['sub_kategory'] == null ? 'null' : data['sub_kategory'],
              pathPhoto: data['path_photo'],
            ),
          );
        }
        // print(data['path_photo']);
      }
      print('semua data inventory $allInv');
      print('berhasil mengambil data inventory');
      invCount();
    } else {
      print('gagal mengambil data inventory');
    }
  }

  static Future<List<Invetory>> getData() async {
    ambilData();
    return allInv;
  }

  // hitung inventory
  static Future<InvCount> invCount() async {
    int allInvCount = 0;
    List<Invetory> baruMasuk = [];
    int baruMasukAll = 0;
    int baruMasukEl = 0;
    int baruMasukRt = 0;
    int baruMasukLa = 0;
    // List<Invetory> baruMasukAllList = [];
    List<Invetory> baruMasukElList = [];
    List<Invetory> baruMasukRtList = [];
    List<Invetory> baruMasukLaList = [];
    List<Invetory> bap = [];
    int bapAll = 0;
    int bapEl = 0;
    int bapRt = 0;
    int bapLa = 0;
    List<Invetory> bapElList = [];
    List<Invetory> bapRtList = [];
    List<Invetory> bapLaList = [];
    List<Invetory> pindahTangan = [];
    int pindahTanganAll = 0;
    int pindahTanganEl = 0;
    int pindahTanganRt = 0;
    int pindahTanganLa = 0;
    List<Invetory> pindahTanganElLIst = [];
    List<Invetory> pindahTanganRtLIst = [];
    List<Invetory> pindahTanganLaLIst = [];
    List<Invetory> pinjam = [];
    int pinjamAll = 0;
    int pinjamEl = 0;
    int pinjamRt = 0;
    int pinjamLa = 0;
    List<Invetory> pinjamElList = [];
    List<Invetory> pinjamRtList = [];
    List<Invetory> pinjamLaList = [];

    baruMasuk =
        allInv.where((element) => element.status == 'baru masuk').toList();
    for (var data in baruMasuk) {
      baruMasukAll += data.jumlah;
    }
    baruMasukElList =
        baruMasuk.where((element) => element.kategory == "Elektronik").toList();
    for (var data in baruMasukElList) {
      baruMasukEl += data.jumlah;
    }
    baruMasukRtList = baruMasuk
        .where((element) => element.kategory == "Rumah Tangga")
        .toList();
    for (var data in baruMasukRtList) {
      baruMasukRt += data.jumlah;
    }
    baruMasukLaList =
        baruMasuk.where((element) => element.kategory == "Lainnya").toList();
    for (var data in baruMasukLaList) {
      baruMasukLa += data.jumlah;
    }
    /////////
    bap = allInv.where((element) => element.status == 'bap').toList();
    for (var data in bap) {
      bapAll += data.newJumlah;
    }
    bapElList =
        bap.where((element) => element.kategory == 'Elektronik').toList();
    for (var data in bapElList) {
      bapEl += data.newJumlah;
    }
    bapRtList =
        bap.where((element) => element.kategory == 'Rumah Tangga').toList();
    for (var data in bapRtList) {
      bapRt += data.newJumlah;
    }
    bapLaList = bap.where((element) => element.kategory == 'Lainnya').toList();
    for (var data in bapLaList) {
      bapLa += data.newJumlah;
    }
    ////////////////
    pindahTangan =
        allInv.where((element) => element.status == 'pindah tangan').toList();

    for (var data in pindahTangan) {
      pindahTanganAll += data.newJumlah;
    }
    pindahTanganElLIst = pindahTangan
        .where((element) => element.kategory == 'Elektronik')
        .toList();
    for (var data in pindahTanganElLIst) {
      pindahTanganEl += data.newJumlah;
    }
    pindahTanganRtLIst = pindahTangan
        .where((element) => element.kategory == 'Rumah Tangga')
        .toList();
    for (var data in pindahTanganRtLIst) {
      pindahTanganRt += data.newJumlah;
    }
    pindahTanganLaLIst =
        pindahTangan.where((element) => element.kategory == 'Lainnya').toList();
    for (var data in pindahTanganLaLIst) {
      pindahTanganLa += data.newJumlah;
    }
    ////////////////

    pinjam = allInv.where((element) => element.status == 'pinjam').toList();
    for (var data in pinjam) {
      pinjamAll += data.jumlahPinjam;
    }
    pinjamElList =
        pinjam.where((element) => element.kategory == 'Elektronik').toList();
    for (var data in pinjamElList) {
      pinjamEl += data.jumlahPinjam;
    }
    pinjamRtList =
        pinjam.where((element) => element.kategory == 'Rumah Tangga').toList();
    for (var data in pinjamRtList) {
      pinjamRt += data.jumlahPinjam;
    }
    pinjamLaList =
        pinjam.where((element) => element.kategory == 'Lainnya').toList();
    for (var data in pinjamLaList) {
      pinjamLa += data.jumlahPinjam;
    }
    allInvCount = baruMasukAll + bapAll + pindahTanganAll + pinjamAll;

    InvCount invCount = InvCount(
        allCount: allInvCount,
        baruMasuk: baruMasukAll,
        bap: bapAll,
        pindahTangan: pindahTanganAll,
        pinjam: pinjamAll);

    print(
        '========= informasi jumlah inventaris =========== \n======== jumlah semua inventaris : $allInvCount ========\ninventory baru masuk = ${baruMasuk.length}\nSemua = $baruMasukAll | Elektronik = $baruMasukEl | Rumah Tangga = $baruMasukRt | Lainnya = $baruMasukLa\ninventory bap = ${bap.length}\nSemua = $bapAll | Elektronik = $bapEl | Rumah Tangga = $bapRt | Lainnya = $bapLa\ninventory Pindah Tangan = ${pindahTangan.length}\nSemua = $pindahTanganAll | Elektronik = $pindahTanganEl | Rumah Tangga = $pindahTanganRt | Lainnya = $pindahTanganLa\ninventory Pinjam = ${pinjam.length}\nSemua = $pinjamAll | Elektronik = $pinjamEl | Rumah Tangga = $pinjamRt | Lainnya = $pinjamLa\n=================================================');
    return invCount;
  }
  // inventory bap = ${bap
  //       .length}\n inventory pindah tangan = ${pindahTangan.length}\n inventory pinjam = ${pinjam.length}');

  static void tambahInv(
    String id,
    String idSurat,
    String status,
    String idPemilik,
    String idInventory,
    String nama,
    String merk,
    String sn,
    String model,
    int jumlah,
    int newJumlah,
    int jumlahPinjam,
    String idAwal,
    String keterangan,
    String kategory,
    String subKategory,
    String pathPhoto,
    Function sesState,
  ) {
    allInv.insert(
      0,
      Invetory(
        id: id,
        idSurat: idSurat,
        status: status,
        idPemilik: idPemilik,
        idInventory: idInventory,
        nama: nama,
        merk: merk,
        sn: sn,
        model: model,
        jumlah: jumlah,
        newJumlah: newJumlah,
        jumlahPinjam: jumlahPinjam,
        idAwal: idAwal,
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
      String idPemilik,
      String idInventory,
      String nama,
      String merk,
      String sn,
      String model,
      int jumlah,
      int newJumlah,
      int jumlahPinjam,
      String keterangan,
      String kategory,
      String subKategory,
      String pathPhoto,
      Function setState) {
    Invetory toEdit = allInv.firstWhere((element) => element.id == id);
    toEdit.id = id;
    toEdit.idSurat = idSurat;
    toEdit.idPemilik = idPemilik;
    toEdit.idInventory = idInventory;
    toEdit.status = status;
    toEdit.nama = nama;
    toEdit.merk = merk;
    toEdit.jumlah = jumlah;
    toEdit.newJumlah = newJumlah;
    toEdit.jumlahPinjam = jumlahPinjam;
    toEdit.sn = sn;
    toEdit.model = model;
    toEdit.keterangan = keterangan;
    toEdit.kategory = kategory;
    toEdit.subKategory = subKategory;
    toEdit.pathPhoto = pathPhoto;
    setState();
  }

  static void editInvBap(
    String status,
    String idInventory,
    int jumlah,
    Function setState,
  ) {
    Invetory toEdit = allInv.firstWhere(
      (element) =>
          element.status == 'baru masuk' && element.idInventory == idInventory,
    );
    toEdit.jumlah = jumlah;
    setState();
  }

  static void editInvPnd(
    String idSurat,
    String idInventory,
    int newJumlah,
  ) {
    Invetory toEdit = allInv.firstWhere(
      (element) =>
          element.idSurat == idSurat && element.idInventory == idInventory,
    );
    toEdit.newJumlah = newJumlah;
  }

  static void editInvPjm(
    String status,
    String idInventory,
    int jumlah,
    int newJumlah,
    int jumlahPinjam,
    Function setState,
  ) {
    Invetory toEdit = allInv.firstWhere(
      (element) =>
          element.status != 'pinjam' && element.idInventory == idInventory,
    );
    toEdit.jumlah = jumlah;
    toEdit.newJumlah = newJumlah;
    toEdit.jumlahPinjam = jumlahPinjam;
    setState();
    print(
        'detail update data untuk peminjaman jumlah ${toEdit.jumlah} - new jumlah ${toEdit.newJumlah} - jumlah pinjam ${toEdit.jumlahPinjam}');
  }
}

class InvCount {
  int allCount;
  int baruMasuk;
  int bap;
  int pindahTangan;
  int pinjam;

  InvCount({
    required this.allCount,
    required this.baruMasuk,
    required this.bap,
    required this.pindahTangan,
    required this.pinjam,
  });
}
