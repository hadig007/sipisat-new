import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:sipisat/common.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/generate_pdf.dart';
import 'package:sipisat/generate_tabel.dart';
// import 'package:sipisat/home_app.dart';
import 'package:sipisat/models/bap_model.dart';
import 'package:sipisat/models/inventory_model.dart';
import 'package:sipisat/models/log_models.dart';
import 'package:sipisat/models/staff_model.dart';

import 'all_bap.dart';

// ignore: must_be_immutable
class PindahTangan extends StatefulWidget {
  // const PindahTangan({Key? key}) : super(key: key);

  @override
  _PindahTanganState createState() => _PindahTanganState();
}

class _PindahTanganState extends State<PindahTangan> {
  TextEditingController idSurat = TextEditingController();
  List<Invetory> allInvs = Invetory.allInv;
  List<StaffModel> allStaff = StaffModel.allStaf;
  List<BapModel> allBap = BapModel.allBap;

  List<Invetory> selectedInv = [];
  List<Invetory> invToSend = [];
  StaffModel? selectedStaff;
  StaffModel? selectedStaff2;
  String? pihak2;
  BapModel? selectedBap;

  var sign = SignatureController();
  var sign2 = SignatureController();
  Uint8List? ttd;
  Uint8List? ttd2;
  Uint8List? tabel;
  String? idSuratNew;
  int updateJumlah = 0;
  int? jumlahBaru;

  var isAInv = true;

  File? pdf;

  int? dikurangi;

  TextEditingController countToSend = TextEditingController();

  void ambilData() async {
    if (allInvs.isNotEmpty || allStaff.isEmpty || allBap.isEmpty) {
      print('data lengkap 3 \n$allInvs\n$allStaff\n$allBap');
    }
    Invetory.ambilData();
    StaffModel.ambilData();
    BapModel.ambilData();
  }

  @override
  void initState() {
    ambilData();
    sign = SignatureController(
      exportBackgroundColor: Colors.white,
      penStrokeWidth: 2,
    );
    sign2 = SignatureController(
      exportBackgroundColor: Colors.white,
      penStrokeWidth: 2,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var rd = new Random().nextInt(99999);
    idSuratNew = 'PND111$rd';
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        title: Text('Pindah Tangan'),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // if (selectedBap == null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: BuildInput(
                      controllers: idSurat,
                      obsText: false,
                      kyType: TextInputType.number,
                      brd: InputBorder.none,
                      hnt: 'Masukkan id surat',
                    ),
                  )),
                  OutlinedButton(
                    onPressed: () {
                      /// cek jika id yang dimasukkan ada atau tidak
                      // idSurat.text = '';
                      // allBap.removeWhere(
                      //     (element) => element.idSurat != idSurat.text);
                      print('masuk fungsi jumlah bap = ${allBap.length}');
                      if (allBap.isEmpty) {
                        print('kosong');
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                                  title: Text('Tidak Ditemukan'),
                                  content: Text(
                                      "Mohon cek lagi id surat yang anda masukkan."),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Coba lagi'))
                                  ],
                                ));
                        idSurat.text = '';
                        return;
                      }
                      //////////
                      selectedBap = allBap.firstWhere(
                          (element) => element.idSurat == idSurat.text);
                      print('nilai bap ${selectedBap!.idSurat}');
                      selectedStaff = allStaff.firstWhere(
                          (element) => element.id == selectedBap!.idPihak1);
                      print('nilai staf ${selectedStaff!.id}');
                      selectedInv = allInvs
                          .where((element) =>
                              element.idSurat == selectedBap!.idSurat &&
                              element.jumlah != 0)
                          .toList();
                      print('nilai inv ${selectedInv.length}');
                      print(
                          'bap=${selectedBap!.idSurat} -- staff=${selectedStaff!.nama} -- inv=$selectedInv');
                      setState(() {});
                      idSurat.text = '';
                      //////// jika inv yang ada pada surat kosng semua /////////
                      if (selectedInv.isEmpty) {
                        isAInv = false;
                        setState(() {});
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text("Inventaris habis"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Coba Lagi"))
                            ],
                          ),
                        );
                      }
                      ////////////
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        Text(
                          '   Cari BAP',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent),
                  ),
                ],
              ),
            ),
            // Card(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 10),
            //     child: BuildInput(
            //       controllers: idSurat,
            //       obsText: false,
            //       kyType: TextInputType.number,
            //       brd: InputBorder.none,
            //       hnt: 'Masukkan id surat',
            //     ),
            //   ),
            // ),
            // if (selectedBap == null)
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 5),
            //   child: OutlinedButton(
            //     onPressed: () {
            //       /// cek jika id yang dimasukkan ada atau tidak
            //       allBap.removeWhere(
            //           (element) => element.idSurat != idSurat.text);
            //       print('masuk fungsi jumlah bap = ${allBap.length}');
            //       if (allBap.isEmpty) {
            //         print('kosong');
            //         showDialog(
            //             context: context,
            //             builder: (_) => AlertDialog(
            //                   title: Text('Tidak Ditemukan'),
            //                   content: Text(
            //                       "Mohon cek lagi id surat yang anda masukkan."),
            //                   actions: [
            //                     TextButton(
            //                         onPressed: () {
            //                           Navigator.pop(context);
            //                         },
            //                         child: Text('Coba lagi'))
            //                   ],
            //                 ));
            //         idSurat.text = '';
            //         return;
            //       }
            //       //////////
            //       selectedBap = allBap
            //           .firstWhere((element) => element.idSurat == idSurat.text);
            //       print('nilai bap ${selectedBap!.idSurat}');
            //       selectedStaff = allStaff.firstWhere(
            //           (element) => element.id == selectedBap!.idPihak1);
            //       print('nilai staf ${selectedStaff!.id}');
            //       selectedInv = allInvs
            //           .where((element) =>
            //               element.idSurat == selectedBap!.idSurat &&
            //               element.jumlah != 0)
            //           .toList();
            //       print('nilai inv ${selectedInv.length}');
            //       print(
            //           'bap=${selectedBap!.idSurat} -- staff=${selectedStaff!.nama} -- inv=$selectedInv');
            //       setState(() {});
            //       idSurat.text = '';
            //       //////// jika inv yang ada pada surat kosng semua /////////
            //       if (selectedInv.isEmpty) {
            //         isAInv = false;
            //         setState(() {});
            //         showDialog(
            //           context: context,
            //           builder: (_) => AlertDialog(
            //             title: Text("Inventaris habis"),
            //             actions: [
            //               TextButton(
            //                   onPressed: () {
            //                     Navigator.pop(context);
            //                   },
            //                   child: Text("Coba Lagi"))
            //             ],
            //           ),
            //         );
            //       }
            //       ////////////
            //     },
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Icon(
            //           Icons.search,
            //           color: Colors.white,
            //         ),
            //         Text(
            //           '   Cari BAP',
            //           style: TextStyle(color: Colors.white),
            //         ),
            //       ],
            //     ),
            //     style: OutlinedButton.styleFrom(
            //         backgroundColor: Colors.pinkAccent),
            //   ),
            // ),
            if (isAInv == true)
              Card(
                child: selectedStaff == null
                    ? Container(
                        height: MediaQuery.of(context).size.height * .3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .7,
                            ),
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                            ),
                            Text(
                              '  Masukkan id surat yang akan di pindah tangan',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10),
                            )
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            BuilData(selectedStaff2: selectedStaff),
                            Divider(),
                            if (selectedStaff2 == null)
                              DropdownButton(
                                hint: Text('Pilih Pihak 2'),
                                isExpanded: true,
                                value: pihak2,
                                onChanged: (value) {
                                  print(value);
                                  setState(() {
                                    this.pihak2 = (value as String?)!;
                                    selectedStaff2 = allStaff.firstWhere(
                                        (element) =>
                                            element.nama == this.pihak2);
                                  });
                                  print(
                                      'nilai dari pilihanCategory -> $pihak2');
                                },
                                items: allStaff
                                    .map((e) => DropdownMenuItem(
                                          child: Text(e.nama),
                                          value: e.nama,
                                        ))
                                    .toList(),
                              ),
                            if (selectedStaff2 != null)
                              BuilData(selectedStaff2: selectedStaff2),
                          ],
                        ),
                      ),
              ),
            if (selectedStaff2 != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                      children: [
                        invToSend.isEmpty
                            ? Text(
                                'Anda harus memilih minimal 1 inventaris',
                                style: TextStyle(color: Colors.red),
                              )
                            : Text('Klik Inventaris untuk memilih'),
                        Divider(),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                print('hasil ${selectedInv[index].jumlah}');
// jika jumlah inventory lebih dari satu
// maka akan meminta inputan untuk jumlah yang akan di pindah tangan
                                if (selectedInv[index].jumlah > 1) {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: Text('Masukkan Jumlah'),
                                            content: BuildInput(
                                              controllers: countToSend,
                                              obsText: false,
                                              kyType: TextInputType.number,
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text(
                                                    'Batal',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )),
                                              TextButton(
                                                  onPressed: () async {
// tambah inv ke sendInv jika
// 1. tambah ke sendToInv -> tabel -> done
// 2. update sendToInv kirim ke backend sebagai inventory baru -> done
// 3. update jumlah inventory sebelumnya
                                                    jumlahBaru = int.parse(
                                                        countToSend.text);
                                                    int jumlahAwal =
                                                        selectedInv[index]
                                                            .jumlah;
                                                    dikurangi = int.parse(
                                                        countToSend.text);
                                                    int hasil =
                                                        jumlahAwal - dikurangi!;
                                                    updateJumlah = hasil;
                                                    print(
                                                        'jumlah inventory setelah dikurangi $updateJumlah');
                                                    setState(() {
                                                      invToSend.add(Invetory(
                                                          id: selectedInv[index]
                                                              .id,
                                                          idSurat:
                                                              selectedInv[index]
                                                                  .idSurat,
                                                          status:
                                                              selectedInv[index]
                                                                  .status,
                                                          idInventory:
                                                              selectedInv[index]
                                                                  .idInventory,
                                                          nama: selectedInv[index]
                                                              .nama,
                                                          merk:
                                                              selectedInv[index]
                                                                  .merk,
                                                          jumlah: int.parse(
                                                              countToSend.text),
                                                          keterangan:
                                                              selectedInv[index]
                                                                  .keterangan,
                                                          kategory:
                                                              selectedInv[index]
                                                                  .kategory,
                                                          pathPhoto:
                                                              selectedInv[index]
                                                                  .pathPhoto));
                                                      selectedInv.removeWhere(
                                                          (element) =>
                                                              element.id ==
                                                              selectedInv[index]
                                                                  .id);
                                                    });
                                                    tabel = await TblBarang
                                                        .dataBarang(invToSend,
                                                            countToSend.text);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'Selesai',
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  )),
                                            ],
                                          ));
                                } else {
                                  int jumlahAwal = selectedInv[index].jumlah;
                                  int hasil = jumlahAwal - 1;
                                  updateJumlah = hasil;
                                  print(
                                      'jumlah inventory setelah dikurangi $updateJumlah');
                                  setState(() {
                                    invToSend.add(selectedInv.firstWhere(
                                        (element) =>
                                            element.id ==
                                            selectedInv[index].id));
                                    selectedInv.removeWhere((element) =>
                                        element.id == selectedInv[index].id);
                                  });
                                  tabel = await TblBarang.dataBarang(
                                      invToSend,
                                      countToSend.text == ''
                                          ? '1'
                                          : countToSend.text);
                                  setState(() {});
                                }
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Nama'),
                                          Text('Merk'),
                                          Text('Jumlah'),
                                          Text('Keterangan'),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(selectedInv[index].nama),
                                          Text(selectedInv[index].merk),
                                          Text(selectedInv[index]
                                              .jumlah
                                              .toString()),
                                          Text(selectedInv[index].keterangan),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider()
                                ],
                              ),
                            );
                          },
                          itemCount: selectedInv.length,
                        ),
                        if (tabel != null) Image(image: MemoryImage(tabel!))
                      ],
                    ),
                  ),
                ),
              ),
            if (selectedStaff2 != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Tanda Tangan'),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text('Tanda pihak 1'),
                              SizedBox(
                                height: 5,
                              ),
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
                                              controller: sign,
                                              backgroundColor: Colors.white,
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
                                                    sign.clear();
                                                  },
                                                  child: Text(
                                                    "Hapus",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    var signature =
                                                        SignatureController(
                                                            points: sign.points,
                                                            penColor:
                                                                Colors.black,
                                                            penStrokeWidth: 2);

                                                    var fileSign =
                                                        await signature
                                                            .toPngBytes();

                                                    ttd = fileSign;
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: Text(
                                                    "Simpan",
                                                    style: TextStyle(
                                                        color: Colors.green),
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
                                  height: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey)),
                                  child: ttd == null
                                      ? Center(
                                          child: Text(
                                            'belum ada tanda tangan',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        )
                                      : Image(image: MemoryImage(ttd!)),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text('Tanda pihak 2'),
                              SizedBox(
                                height: 5,
                              ),
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
                                              controller: sign2,
                                              backgroundColor: Colors.white,
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
                                                    sign2.clear();
                                                  },
                                                  child: Text(
                                                    "Hapus",
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    var signature =
                                                        SignatureController(
                                                            points:
                                                                sign2.points,
                                                            penColor:
                                                                Colors.black,
                                                            penStrokeWidth: 2);

                                                    var fileSign =
                                                        await signature
                                                            .toPngBytes();

                                                    ttd2 = fileSign;
                                                    Navigator.of(context).pop();
                                                    setState(() {});
                                                  },
                                                  child: Text(
                                                    "Simpan",
                                                    style: TextStyle(
                                                        color: Colors.green),
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
                                  height: 70,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey)),
                                  child: ttd2 == null
                                      ? Center(
                                          child: Text(
                                            'belum ada tanda tangan',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                            ),
                                          ),
                                        )
                                      : Image(image: MemoryImage(ttd2!)),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            if (selectedStaff2 != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: OutlinedButton(
                  onPressed: () async {
                    print('$invToSend , $selectedStaff2 , $ttd , $ttd2');
                    // melakukan checking sebelum kirim data ke api
                    if (selectedStaff2!.id == '' ||
                        invToSend.isEmpty ||
                        ttd == null ||
                        ttd2 == null) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Gagal"),
                          content: Text('Pastikan semua inputan benar.'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Oke'))
                          ],
                        ),
                      );
                    } else {
                      // pdf
                      pdf = await PdfApi.generatorSurat(
                        idSuratNew!,
                        idSuratNew!,
                        selectedStaff!.nama,
                        selectedStaff!.nip,
                        selectedStaff!.jabatan,
                        selectedStaff!.alamat,
                        selectedStaff2!.nama,
                        selectedStaff2!.nip,
                        selectedStaff2!.jabatan,
                        selectedStaff2!.jabatan,
                        ttd!,
                        ttd2!,
                        tabel!,
                      );
                    }
                    // untuk mengirim data inv baru ke backend untuk pindah tangan
                    for (var data in invToSend) {
                      print(
                          'nilai yang akan di update $idSuratNew, ${selectedStaff2!.id}, ${data.idInventory}, ${data.nama},  ${data.merk},  ${countToSend.text},  ${data.keterangan},  ${data.kategory},  ${data.model},  ${data.sn},  ${data.subKategory},  ${data.pathPhoto}');

                      //////  update jumlah inventory jika masih sisa

                      // if (updateJumlah != 0) {
                      print('update' + updateJumlah.toString());
                      var res = await http.post(
                          Uri.parse(CommonUser.baseUrl +
                              // /edit_inv_surat_pnd/
                              '/edit_inv_surat_pnd/${data.id}'),
                          body: ({
                            'new_jumlah': updateJumlah.toString(),
                          }));
                      if (res.statusCode == 200) {
                        print('berhasil update data');
                      } else {
                        print('gagal update new jumlah');
                      }
                      print('mengupdate inventaris dengan id ${data.id}');
                      ///////////// mengirim pdf ////////////
                      var req = new http.MultipartRequest(
                          'POST', Uri.parse(CommonUser.baseUrl + '/store_bap'));
                      req.headers
                          .addAll(({'Content-Type': 'multipart/form-data'}));
                      req.fields.addAll({
                        'id_phk1': selectedStaff!.id.toString(),
                        'id_phk2': selectedStaff2!.id.toString(),
                        'tag': 'pindah',
                        'jumlah_inv': invToSend.length.toString(),
                        'nomor_surat': idSuratNew.toString(),
                        'id_surat': idSuratNew.toString(),
                      });
                      req.files.add(
                          await http.MultipartFile.fromPath('pdf', pdf!.path));
                      print(pdf);
                      var responses = await req.send();
                      print(responses.statusCode);
                      var ress = await http.Response.fromStream(responses);

                      if (responses.statusCode == 200) {
                        // ignore: unnecessary_null_comparison
                        String newJumlah = jumlahBaru.toString() == null
                            ? '1'
                            : jumlahBaru.toString();
                        print(
                            'nilai yang akan di update $idSuratNew, ${selectedStaff2!.id}, ${data.idInventory}, ${data.nama},  ${data.merk},  $newJumlah,  ${data.keterangan},  ${data.kategory},  ${data.model},  ${data.sn},  ${data.subKategory},  ${data.pathPhoto}');
                        var resp = jsonDecode(ress.body);
                        var idss = resp['data']['id'];
                        var response = await http.post(
                            Uri.parse(CommonUser.baseUrl + '/new_inv_pnd'),
                            body: ({
                              'id_surat': idSuratNew,
                              'status': 'pindah tangan',
                              'id_pemilik': selectedStaff2!.id,
                              'id_inventory': data.idInventory,
                              'nama': data.nama,
                              'merk': data.merk,
                              'new_jumlah': countToSend.text.isEmpty
                                  ? '1'
                                  : countToSend.text,
                              'jumlah': 'null',
                              'jumlah_pinjam': 'null',
                              'keterangan': data.keterangan,
                              'kategory': data.kategory,
                              'model': data.model,
                              'sn': data.sn,
                              'sub_kategory': data.subKategory,
                              'path_photo': data.pathPhoto,
                            }));
                        if (response.statusCode == 200) {
                          print('berhasil kirim data baru untuk pindah tangan');
                        } else {
                          print(
                              'gagal untuk membuat inv baru untuk pindah tangan');
                        }
                        BapModel.addBAP(
                            idss.toString(),
                            idSuratNew!,
                            idSuratNew!,
                            idSuratNew!,
                            selectedStaff!.id!,
                            selectedStaff2!.id!,
                            countToSend.toString(),
                            'pdf');
                        LogModel.sendLog(
                          'id',
                          'add pnd',
                          idSuratNew!,
                          'anda mambuat bap untuk pindah tangan dengan id $idSuratNew!',
                        );
                        Invetory.hapus(data.id);
                        setState(() {});
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => AllBAP()));
                        print(
                            'berhasil mengirim file pdf ================================================================================');
                      } else {
                        print('gagal mengirim file');
                      }
                      ///////////////////////////////////////
                    }
                  },
                  // },
                  child: Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TandaTangan extends StatefulWidget {
  TandaTangan({
    Key? key,
    required this.sign,
    required this.sign2,
    required this.ttd,
    required this.ttd2,
  }) : super(key: key);

  var sign = SignatureController();
  var sign2 = SignatureController();
  Uint8List? ttd;
  Uint8List? ttd2;

  @override
  _TandaTanganState createState() => _TandaTanganState();
}

class _TandaTanganState extends State<TandaTangan> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Tanda Tangan'),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text('Tanda pihak 1'),
                    SizedBox(
                      height: 5,
                    ),
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
                                    controller: widget.sign,
                                    backgroundColor: Colors.white,
                                    height: 200,
                                    width: 300,
                                  ),
                                ),
                                Container(
                                  width: 300,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          widget.sign.clear();
                                        },
                                        child: Text(
                                          "Hapus",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          var signature = SignatureController(
                                              points: widget.sign.points,
                                              penColor: Colors.black,
                                              penStrokeWidth: 2);

                                          var fileSign =
                                              await signature.toPngBytes();

                                          widget.ttd = fileSign;
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        child: Text(
                                          "Simpan",
                                          style: TextStyle(color: Colors.green),
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
                        height: 70,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: widget.ttd == null
                            ? Center(
                                child: Text(
                                  'belum ada tanda tangan',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            : Image(image: MemoryImage(widget.ttd!)),
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Text('Tanda pihak 2'),
                    SizedBox(
                      height: 5,
                    ),
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
                                    controller: widget.sign2,
                                    backgroundColor: Colors.white,
                                    height: 200,
                                    width: 300,
                                  ),
                                ),
                                Container(
                                  width: 300,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          widget.sign2.clear();
                                        },
                                        child: Text(
                                          "Hapus",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          var signature = SignatureController(
                                              points: widget.sign2.points,
                                              penColor: Colors.black,
                                              penStrokeWidth: 2);

                                          var fileSign =
                                              await signature.toPngBytes();

                                          widget.ttd2 = fileSign;
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        child: Text(
                                          "Simpan",
                                          style: TextStyle(color: Colors.green),
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
                        height: 70,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: widget.ttd2 == null
                            ? Center(
                                child: Text(
                                  'belum ada tanda tangan',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              )
                            : Image(image: MemoryImage(widget.ttd2!)),
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BuilData extends StatelessWidget {
  const BuilData({
    Key? key,
    required this.selectedStaff2,
  }) : super(key: key);

  final StaffModel? selectedStaff2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama"),
            Text("Nip"),
            Text("Jabatan"),
            Text("Alamat"),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(selectedStaff2!.nama),
            Text(selectedStaff2!.nip),
            Text(selectedStaff2!.jabatan),
            Text(selectedStaff2!.alamat),
          ],
        ),
      ],
    );
  }
}
