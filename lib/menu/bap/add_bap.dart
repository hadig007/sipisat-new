import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signature/signature.dart';
import 'package:sipisat/common.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/generate_pdf.dart';
import 'package:sipisat/generate_tabel.dart';
import 'package:sipisat/menu/bap/all_bap.dart';
import 'package:sipisat/menu/bap/pindah_tangan.dart';
import 'package:sipisat/models/bap_model.dart';
import 'package:sipisat/models/inventory_model.dart';
import 'package:sipisat/models/log_models.dart';
import 'package:sipisat/models/staff_model.dart';

class AddBAP extends StatefulWidget {
  const AddBAP({Key? key}) : super(key: key);

  @override
  _AddBAPState createState() => _AddBAPState();
}

class _AddBAPState extends State<AddBAP> {
  List<StaffModel> allStaf = [];
  List data = [];
  String? pihak1;
  String? pihak2;
  StaffModel? phk1;
  StaffModel? phk2;

  List<Invetory> allInv = [];
  List dt = [];
  String? inv;

  Uint8List? tabel;

  List<Invetory> sendInv = [];
  List<Invetory> newInv = [];

  Invetory? selectedInv;
  Invetory? newInventaris;

  var idInv = TextEditingController();

  SignatureController? _signController;
  SignatureController? _signController2;
  Uint8List? sign;
  Uint8List? sign2;

  TextEditingController _jumlahInp = TextEditingController();
  String newJumlah = '';

  // cek apakah berhasil kirim data
  var sendNewInv = false;
  var updateNewInv = false;
  var sendPdf = false;
  var onSend = false;

  int newAdd = 0;
  int toUpdate = 0;

  InvToUpdate? invToUpdate;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  var onScanning = false;

  ambilDataInv() async {
    List<Invetory> inv = await Invetory.getData();
    if (allInv.isNotEmpty || allStaf.isNotEmpty) {
      print('data lengkap 3 jumlah inv  ${allInv.length}\n$allStaf');
      isLoading = true;
    } else {
      Invetory.ambilData();
      StaffModel.ambilData();
      BapModel.ambilData();

      allInv = inv.where((element) => element.status == 'baru masuk').toList();
      allStaf = StaffModel.allStaf;
      print(
          'data lengkap jumlah inv  ${allInv.length}\n jumlah Staf ${allStaf.length}');
      for (var data in allInv) {
        print('${data.jumlah}');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  var isLoading = false;
  @override
  void initState() {
    ambilDataInv();
    _signController = SignatureController(
      exportBackgroundColor: Colors.white,
      penStrokeWidth: 2,
    );
    _signController2 = SignatureController(
      exportBackgroundColor: Colors.white,
      penStrokeWidth: 2,
    );
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (sendNewInv == false || updateNewInv == false || sendPdf == false) {
      allInv.clear();
      print('mereset');
    }
    if (controller != null) {
      controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Invetory.invCount();
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        title: Text('Buat BAP'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lightBlue.shade400,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading == true
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  onSend == true
                      ? Text(
                          'Sedang mengirim data ...',
                          style: TextStyle(color: Colors.white),
                        )
                      : Text(
                          'Sedang Mengambil data ...',
                          style: TextStyle(color: Colors.white),
                        )
                ],
              ),
            )
          : SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 20, vertical: size.height * .05),
                constraints: BoxConstraints(
                  maxHeight: size.height * .8,
                  maxWidth: size.width,
                ),
                child: Card(
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    child: Stack(children: [
                      if (onScanning == true)
                        Container(
                          // padding:,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: QRView(
                              key: qrKey,
                              onQRViewCreated: (value) {
                                this.controller = value;
                                controller!.scannedDataStream.listen((event) {
                                  idInv.text = '';
                                  // result = event;
                                  // qrIdInv = result!.code;
                                  idInv.text = event.code;
                                  onScanning = false;
                                  if (idInv.text != '') {
                                    onScanning = false;
                                    setState(() {});
                                  }
                                });
                                print('hasil scan 2 ${idInv.text}');
                              }),
                        ),
                      if (onScanning == false)
                        ListView(
                          children: [
                            Container(
                              height: 100,
                              width: double.infinity,
                              child: phk1 == null
                                  ? Center(
                                      child: Text(
                                        'Pihak 1 Belum Di Pilih',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : dataPihak(phk1!),
                            ),
                            if (phk1 == null)
                              DropdownButton(
                                  hint: Text('Pilih Pihak 1'),
                                  isExpanded: true,
                                  value: pihak1,
                                  onChanged: (value) {
                                    print(value);
                                    setState(() {
                                      this.pihak1 = value as String?;
                                      phk1 = allStaf.firstWhere((element) =>
                                          element.nama == this.pihak1);
                                    });
                                    print(
                                        'nilai dari pilihanCategory -> $pihak1');
                                  },
                                  items: allStaf
                                      .map((e) => DropdownMenuItem(
                                            child: Text(e.nama),
                                            value: e.nama,
                                          ))
                                      .toList()),
                            Container(
                              height: 100,
                              width: double.infinity,
                              child: phk2 == null
                                  ? Center(
                                      child: Text(
                                        'Pihak 2 Belum Di Pilih',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : dataPihak(phk2!),
                            ),
                            Divider(),
                            if (phk2 == null)
                              DropdownButton(
                                  hint: Text('Pilih Pihak 2'),
                                  isExpanded: true,
                                  value: pihak2,
                                  onChanged: (value) {
                                    print(value);
                                    setState(() {
                                      this.pihak2 = value as String?;
                                      phk2 = allStaf.firstWhere((element) =>
                                          element.nama == this.pihak2);
                                    });
                                    print(
                                        'nilai dari pilihanCategory -> $pihak2');
                                  },
                                  items: allStaf
                                      .map((e) => DropdownMenuItem(
                                            child: Text(e.nama),
                                            value: e.nama,
                                          ))
                                      .toList()),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: BuildInput(
                                          obsText: false,
                                          hnt: 'Masukkan ID Inventaris',
                                          controllers: idInv,
                                          brd: InputBorder.none,
                                        )),
                                        IconButton(
                                            onPressed: () async {
                                              var loading = false;
                                              //// 1. jika jumlah inventaris 1 maka langsung ditambah
                                              //// 2. jika lebih dari satu maka akan meminta input jumlah yang akan di tambah
                                              selectedInv = allInv.firstWhere(
                                                  (element) =>
                                                      element.idInventory ==
                                                      idInv.text);
                                              var isAvailable = allInv.any(
                                                  (element) =>
                                                      element.idInventory ==
                                                      idInv.text);

                                              print(
                                                  'apakah ada inv => $isAvailable ');
                                              if (isAvailable == false) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "Data tidak ditemukan")));
                                                return;
                                              } else if (isAvailable == true) {
                                                print(
                                                    'akan muncul show dialog');
                                                selectedInv = allInv.firstWhere(
                                                    (element) =>
                                                        element.idInventory ==
                                                        idInv.text);
                                                // jika jumlah inv adalah 1 langsung tambah ke sendInv
                                                print(
                                                    'jumlah inv ${selectedInv!.jumlah} -- ${selectedInv!.newJumlah}');
                                                if (selectedInv!.jumlah == 1) {
                                                  selectedInv!.jumlah = 0;
                                                  selectedInv!.newJumlah = 1;
                                                  newInv.add(selectedInv!);
                                                  // generate newInevtaris menjadi tabel
                                                  tabel = await TblBarang
                                                      .dataBarang(
                                                          newInv, 1.toString());
                                                  _jumlahInp.text = '';
                                                  idInv.text = '';
                                                  setState(() {});
                                                }
                                                // jika jumlah inv lebih dari satu
                                                else if (selectedInv!.jumlah >
                                                    1) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: Text(
                                                          "Jumlah Inventaris"),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              'Jumlah Inventaris saat ini = ${selectedInv!.jumlah}'),
                                                          BuildInput(
                                                            keyName: 'Jumlah',
                                                            controllers:
                                                                _jumlahInp,
                                                            obsText: false,
                                                            actType:
                                                                TextInputAction
                                                                    .done,
                                                            kyType:
                                                                TextInputType
                                                                    .number,
                                                          )
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text(
                                                            'Batal',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            newAdd = newAdd +
                                                                int.parse(
                                                                    _jumlahInp
                                                                        .text);
                                                            toUpdate = selectedInv!
                                                                    .jumlah -
                                                                int.parse(
                                                                    _jumlahInp
                                                                        .text);
                                                            newInv.add(
                                                              Invetory(
                                                                id: selectedInv!
                                                                    .id,
                                                                idSurat:
                                                                    selectedInv!
                                                                        .idSurat,
                                                                idInventory:
                                                                    selectedInv!
                                                                        .idInventory,
                                                                idPemilik:
                                                                    selectedInv!
                                                                        .idPemilik,
                                                                status:
                                                                    selectedInv!
                                                                        .status,
                                                                nama:
                                                                    selectedInv!
                                                                        .nama,
                                                                merk:
                                                                    selectedInv!
                                                                        .merk,
                                                                jumlah: selectedInv!
                                                                        .jumlah -
                                                                    int.parse(
                                                                        _jumlahInp
                                                                            .text),
                                                                newJumlah: 0 +
                                                                    int.parse(
                                                                        _jumlahInp
                                                                            .text),
                                                                jumlahPinjam:
                                                                    selectedInv!
                                                                        .jumlahPinjam,
                                                                idAwal:
                                                                    selectedInv!
                                                                        .idAwal,
                                                                keterangan:
                                                                    selectedInv!
                                                                        .keterangan,
                                                                kategory:
                                                                    selectedInv!
                                                                        .kategory,
                                                                model:
                                                                    selectedInv!
                                                                        .model,
                                                                sn: selectedInv!
                                                                    .sn,
                                                                subKategory:
                                                                    selectedInv!
                                                                        .subKategory,
                                                                pathPhoto:
                                                                    selectedInv!
                                                                        .pathPhoto,
                                                              ),
                                                            );
                                                            for (var data
                                                                in newInv) {
                                                              print(
                                                                  'jumlah = $toUpdate\nnew_jumlah = $newAdd\n====== isi list ====== \nid = ${data.id}\nid surat = ${data.idSurat}\nstatus = ${data.status}\nstatus = ${data.status}\nid inventory = ${data.idInventory}\nid pemilik = ${data.idPemilik}\nnama = ${data.nama}\nmerk = ${data.merk}\njumlah = ${data.jumlah}\nnew jumlah = ${data.newJumlah}\njumlah pinjam = ${data.jumlahPinjam}\nketerangan = ${data.keterangan}\nkategory = ${data.kategory}\nmodel = ${data.model}\nsn = ${data.sn}\nsub kategory = ${data.subKategory}\npath photo = ${data.pathPhoto}');
                                                            }

                                                            // newInventaris = selectedInv;
                                                            // mengurangi jumlah awal dengan jumlah inputan
                                                            // newInv!.add(newInventaris!);
                                                            // generate newInevtaris menjadi tabel
                                                            tabel = await TblBarang
                                                                .dataBarang(
                                                                    newInv,
                                                                    newInv
                                                                        .toString());
                                                            _jumlahInp.text =
                                                                '';
                                                            idInv.text = '';
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: loading
                                                              ? Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                )
                                                              : Text('Selesai'),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } else {
                                                  print('tak tersedia');
                                                }
                                              }
                                            },
                                            icon: Icon(
                                              Icons.search,
                                              color: Colors.grey,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      print('masuk fungsi scan qr code');
                                      onScanning = !onScanning;
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.qr_code))
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            tabel == null
                                ? Text('belum ada data')
                                : Image(image: MemoryImage(tabel!)),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text('Pihak 1'),
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (_) => Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 300,
                                                  height: 200,
                                                  child: Signature(
                                                    controller:
                                                        _signController!,
                                                    backgroundColor:
                                                        Colors.white,
                                                    height: 200,
                                                    width: 300,
                                                  ),
                                                ),
                                                Container(
                                                  width: 300,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          _signController!
                                                              .clear();
                                                        },
                                                        child: Text(
                                                          "Hapus",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          var signature =
                                                              SignatureController(
                                                                  points:
                                                                      _signController!
                                                                          .points,
                                                                  penColor:
                                                                      Colors
                                                                          .black,
                                                                  penStrokeWidth:
                                                                      2);

                                                          var fileSign =
                                                              await signature
                                                                  .toPngBytes();

                                                          sign = fileSign;
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {});
                                                        },
                                                        child: Text(
                                                          "Simpan",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 130,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: sign == null
                                            ? Center(
                                                child: Text(
                                                "Tanda tangan belum ada 1",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey),
                                              ))
                                            : Image(image: MemoryImage(sign!)),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Pihak 2'),
                                    InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (_) => Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 300,
                                                  height: 200,
                                                  child: Signature(
                                                    controller:
                                                        _signController2!,
                                                    backgroundColor:
                                                        Colors.white,
                                                    height: 200,
                                                    width: 300,
                                                  ),
                                                ),
                                                Container(
                                                  width: 300,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          _signController2!
                                                              .clear();
                                                        },
                                                        child: Text(
                                                          "Hapus",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          var signature =
                                                              SignatureController(
                                                                  points:
                                                                      _signController2!
                                                                          .points,
                                                                  penColor:
                                                                      Colors
                                                                          .black,
                                                                  penStrokeWidth:
                                                                      2);

                                                          var fileSign =
                                                              await signature
                                                                  .toPngBytes();

                                                          sign2 = fileSign;
                                                          Navigator.of(context)
                                                              .pop();
                                                          setState(() {});
                                                        },
                                                        child: Text(
                                                          "Simpan",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 130,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 1)),
                                        child: sign2 == null
                                            ? Center(
                                                child: Text(
                                                "Tanda tangan belum ada",
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey),
                                              ))
                                            : Image(image: MemoryImage(sign2!)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_back),
                                        Text(" Batal"),
                                      ],
                                    )),
                                TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                        onSend = true;
                                      });
                                      var rd = new Random().nextInt(99999);
                                      String idSurat = 'BAP111' + rd.toString();
                                      // INVENTARIS //
                                      // 1. buat invetaris baru dengan status bap
                                      // 2. update jumlah inv asli
                                      // 3. kirim pdf ke backend
                                      // mengirim inv baru
                                      for (var data in newInv) {
                                        print(
                                            'nilai yang akan di update $idSurat, ${phk2!.id}, ${data.idInventory}, ${data.nama},  ${data.merk},  $newJumlah,  ${data.keterangan},  ${data.kategory},  ${data.model},  ${data.sn},  ${data.subKategory},  ${data.pathPhoto}');
                                        var resp = await http.post(
                                            Uri.parse(CommonUser.baseUrl +
                                                '/new_inv'),
                                            body: ({
                                              'id_surat': idSurat,
                                              'status': 'bap',
                                              'id_pemilik': phk2!.id,
                                              'id_inventory': data.idInventory,
                                              'nama': data.nama,
                                              'merk': data.merk,
                                              'new_jumlah':
                                                  data.newJumlah.toString(),
                                              'jumlah': 0.toString(),
                                              'jumlah_pinjam': 0.toString(),
                                              'keterangan': data.keterangan,
                                              'kategory': data.kategory,
                                              'model': data.model,
                                              'sn': data.sn,
                                              'sub_kategory': data.subKategory,
                                              'path_photo': data.pathPhoto,
                                            }));
                                        if (resp.statusCode == 200) {
                                          // update jumlah dilakukan
                                          sendNewInv = true;

                                          var re = jsonDecode(resp.body);
                                          int idss = re['data']['id'];
                                          print(
                                              'berhasil membuat data inv baru untuk bap');
                                          Invetory.tambahInv(
                                              idss.toString(), // String id
                                              idSurat, // String idSurat
                                              'bap', // String status
                                              phk2!.id!, // String idPemilik
                                              data.idInventory, // String idInventory
                                              data.nama, // String nama
                                              data.merk, // String merk
                                              data.sn, // String sn
                                              data.model, // String model
                                              0, // int jumlah
                                              data.newJumlah, // int newJumlah
                                              0, // int jumlah pinjam
                                              'null', // int jumlah pinjam
                                              data.keterangan,
                                              data.kategory,
                                              data.subKategory,
                                              data.pathPhoto, () {
                                            setState(() {});
                                          });
                                          print(
                                              'id yang akan di update - ${data.id} dengan jumlah ${data.jumlah}');
                                          var resss = await http.post(
                                              Uri.parse(CommonUser.baseUrl +
                                                  '/edit_inv_surat/${data.id}'),
                                              body: ({
                                                'jumlah':
                                                    data.jumlah.toString(),
                                              }));
                                          if (resss.statusCode == 200) {
                                            updateNewInv = true;
                                            print('berhasil update data');
                                            Invetory.editInvBap(
                                                'bap', // String status
                                                data.idInventory, // String idInventory
                                                data.jumlah, // int jumlah
                                                () {});
                                          } else {
                                            print(
                                                'gagal update ${resss.statusCode}');
                                          }
                                        } else {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "Gagal mengirim data, coba lagi nanti")));
                                          print(
                                              'gagal membuat data inv baru untuk bap ${resp.statusCode}');
                                        }
                                        // menghapus inventory jika jumlahnya 0
                                        if (data.jumlah == 0) {
                                          var response = await http.post(
                                              Uri.parse(CommonUser.baseUrl +
                                                  '/delete_inv/${data.id}'));
                                          if (response.statusCode == 200) {
                                            allInv.removeWhere((element) =>
                                                element.id == data.id);
                                            print(
                                                'menghapus inventory dengan status karena bap dan jumlahnya sudah 0');
                                            setState(() {});
                                          }
                                        }
                                      }
                                      if (sendNewInv == false ||
                                          updateNewInv == false) {
                                        return;
                                      }
                                      //// SURAT /////
                                      // generate inputan kedalam pdf
                                      File pdf = await PdfApi.generatorSurat(
                                        idSurat,
                                        idSurat,
                                        phk1!.nama,
                                        phk1!.nip,
                                        phk1!.jabatan,
                                        phk1!.alamat,
                                        phk2!.nama,
                                        phk2!.nip,
                                        phk2!.jabatan,
                                        phk2!.alamat,
                                        sign!,
                                        sign2!,
                                        tabel!,
                                      );
                                      /////////////////////////////
                                      // kirim semua data ke backend
                                      var request = new http.MultipartRequest(
                                          'POST',
                                          Uri.parse(CommonUser.baseUrl +
                                              '/store_bap'));
                                      request.headers.addAll({
                                        'Content-Type': 'multipart/form-data'
                                      });
                                      request.fields.addAll({
                                        'id_phk1': phk1!.id.toString(),
                                        'id_phk2': phk2!.id.toString(),
                                        'tag': 'bap',
                                        'jumlah_inv': sendInv.length.toString(),
                                        'id_surat': idSurat.toString(),
                                        'nomor_surat': idSurat.toString()
                                      });
                                      request.files.add(
                                          await http.MultipartFile.fromPath(
                                              'pdf', pdf.path));
                                      print(pdf);

                                      // mengirim file
                                      var responses = await request.send();
                                      print(responses.statusCode);
                                      var res = await http.Response.fromStream(
                                          responses);

                                      if (responses.statusCode == 200) {
                                        sendPdf = true;
                                        var resp = jsonDecode(res.body);
                                        var idss = resp['data']['id'];
                                        BapModel.addBAP(
                                            idss.toString(),
                                            idSurat,
                                            idSurat,
                                            idSurat,
                                            phk1!.id.toString(),
                                            phk2!.id.toString(),
                                            sendInv.length.toString(),
                                            'pdf');
                                        LogModel.sendLog(
                                          idss.toString(),
                                          'add bap',
                                          idSurat,
                                          'anda membuat bap baru dengan id $idSurat',
                                        );
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => AllBAP()));
                                        print(
                                            'berhasil mengirim file pdf ================================================================================');
                                      } else {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    "Gagal mengirim data, coba lagi nanti")));
                                        print('gagal mengirim file');
                                      }
                                    },
                                    child: Text("Selesai"))
                              ],
                            )
                          ],
                        ),
                    ]),
                  ),
                ),
              ),
            ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget InvToSend(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          color: Colors.lightGreen.shade100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              QrImage(
                data: sendInv[index].idInventory,
                size: 70,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    sendInv[index].nama.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        'Merk :',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(sendInv[index].merk),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'ID Inventaris :',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Text(sendInv[index].idInventory),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Row dataPihak(StaffModel pihak) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama"),
            SizedBox(
              height: 5,
            ),
            Text("NIP"),
            SizedBox(
              height: 5,
            ),
            Text("Jabatan"),
            SizedBox(
              height: 5,
            ),
            Text("Alamat"),
            SizedBox(
              height: 5,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(pihak.nama.toUpperCase()),
            SizedBox(
              height: 5,
            ),
            Text(pihak.nip),
            SizedBox(
              height: 5,
            ),
            Text(pihak.jabatan),
            SizedBox(
              height: 5,
            ),
            Text(pihak.alamat),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ],
    );
  }
}
