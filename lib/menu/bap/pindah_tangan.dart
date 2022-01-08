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
  List<Invetory> allInvs = [];
  List<StaffModel> allStaff = [];
  List<BapModel> allBap = [];

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
  String? jumlahBaru;

  var isAInv = true;

  File? pdf;

  int? dikurangi;

  String idSUrat = '';

  int? hasilToPnd;
  List<InvToUpdate> hasilToUpdate = [];

  TextEditingController countToSend = TextEditingController();

  var isloading = false;

  // cek berhasil kirim data
  var newInvScs = false; // untuk kirim new inv
  var updateInvScs = false; // untuk kirim new inv
  var sendPdf = false; // untuk kirim new inv

  void ambilData() async {
    if (allInvs.isNotEmpty || allStaff.isNotEmpty || allBap.isNotEmpty) {
      print('data lengkap 3 jumlah inv  ${allInvs.length}\n$allStaff\n$allBap');
      isloading = true;
    } else {
      Invetory.ambilData();
      StaffModel.ambilData();
      BapModel.ambilData();
      allInvs = Invetory.allInv;
      allBap = BapModel.allBap;
      allStaff = StaffModel.allStaf;
      print(
          'data lengkap 3 jumlah inv  ${allInvs.length}\n jumlah Staf ${allStaff.length} \n jumlah Bap ${allBap.length}');
      for (var data in allBap) {
        print('${data.idSurat}');
      }
      setState(() {
        isloading = false;
      });
    }
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
  void dispose() {
    // jika keluar screen tanpa kirim data maka akan reset data kembali
    if (selectedInv.isNotEmpty &&
        newInvScs == true &&
        updateInvScs == true &&
        sendPdf == true) {
      allInvs.clear();
      print('mengosongkan inv karena kembali tanpa kirim');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Invetory.invCount();
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
        child: isloading == true
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
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
                        IconButton(
                          onPressed: () {
                            idSUrat = idSurat.text;
                            print('masuk fungsi jumlah bap = ${allBap.length}');
                            // jika bap yang dimasukkan tidak sesuai
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
                            for (var data in allBap) {
                              print('${data.idSurat}');
                            }
                            selectedBap = allBap.firstWhere(
                                (element) => element.idSurat == idSurat.text);
                            print('nilai bap ${selectedBap!.idSurat}');
                            selectedStaff = allStaff.firstWhere((element) =>
                                element.id == selectedBap!.idPihak2);
                            print('nilai staf ${selectedStaff!.id}');
                            selectedInv = allInvs
                                .where((element) =>
                                    element.idSurat == selectedBap!.idSurat &&
                                    element.newJumlah > 0)
                                .toList();
                            print('nilai inv ${selectedInv.length}');
                            print(
                                'bap=${selectedBap!.idSurat} -- staff=${selectedStaff!.nama} -- inv=$selectedInv');
                            setState(() {});
                            idSurat.text = '';
                            //////// jika inv yang ada pada surat kosong semua /////////
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
                            ///////////////////////////////////////////////////////
                            //////////////// selesai mencari bap //////////////////
                          },
                          icon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                    height:
                                        MediaQuery.of(context).size.height * .7,
                                  ),
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    '  Masukkan id surat yang akan di pindah tangan',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 10),
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
                                      // jika jumlah inv hanya 1
                                      // selectedInv[index].new_jumlah = 0
                                      // invToSend[index].new_jumlah = 1
                                      if (selectedInv[index].newJumlah <= 1) {
                                        invToSend.add(selectedInv[index]);
                                        hasilToUpdate.add(InvToUpdate(
                                            index: int.parse(
                                                selectedInv[index].id),
                                            newJumlah: 0));
                                        print(
                                            'jumlah untuk update = ${hasilToUpdate[index].newJumlah} \n jumlah untuk new = ${selectedInv[index].newJumlah}');
                                        tabel = await TblBarang.dataBarang(
                                            invToSend,
                                            invToSend[index]
                                                .newJumlah
                                                .toString());
                                        selectedInv.removeAt(index);
                                        setState(() {});
                                      }
                                      // jika jumlah inventaris lebih dari 1 maka akan meminta input jumlah yang akan dipindah
                                      else {
                                        showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                                  title: Text('Jumlah'),
                                                  content: BuildInput(
                                                    controllers: countToSend,
                                                    obsText: false,
                                                    kyType:
                                                        TextInputType.number,
                                                    hnt: 'jumalah inventaris',
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
                                                        )),
                                                    TextButton(
                                                        onPressed: () async {
                                                          // jumlah awal akan dikurangi inputan = selectedInv - countToSend
                                                          print(
                                                              'jumlah awal sebelum dikurangi ${selectedInv[index].newJumlah}');
                                                          invToSend
                                                              .add(Invetory(
                                                            id: selectedInv[
                                                                    index]
                                                                .id,
                                                            idSurat:
                                                                selectedInv[
                                                                        index]
                                                                    .idSurat,
                                                            idInventory:
                                                                selectedInv[
                                                                        index]
                                                                    .idInventory,
                                                            idPemilik:
                                                                selectedInv[
                                                                        index]
                                                                    .idPemilik,
                                                            status: selectedInv[
                                                                    index]
                                                                .status,
                                                            nama: selectedInv[
                                                                    index]
                                                                .nama,
                                                            merk: selectedInv[
                                                                    index]
                                                                .merk,
                                                            jumlah: selectedInv[
                                                                    index]
                                                                .jumlah,
                                                            newJumlah:
                                                                int.parse(
                                                                    countToSend
                                                                        .text),
                                                            jumlahPinjam:
                                                                selectedInv[
                                                                        index]
                                                                    .jumlahPinjam,
                                                            idAwal: selectedInv[
                                                                    index]
                                                                .idAwal,
                                                            keterangan:
                                                                selectedInv[
                                                                        index]
                                                                    .keterangan,
                                                            kategory:
                                                                selectedInv[
                                                                        index]
                                                                    .kategory,
                                                            model: selectedInv[
                                                                    index]
                                                                .model,
                                                            sn: selectedInv[
                                                                    index]
                                                                .sn,
                                                            subKategory:
                                                                selectedInv[
                                                                        index]
                                                                    .subKategory,
                                                            pathPhoto:
                                                                selectedInv[
                                                                        index]
                                                                    .pathPhoto,
                                                          ));

                                                          hasilToUpdate.add(InvToUpdate(
                                                              idInv: selectedInv[
                                                                      index]
                                                                  .idInventory,
                                                              idSurat:
                                                                  selectedInv[index]
                                                                      .idSurat,
                                                              index: int.parse(
                                                                  selectedInv[index]
                                                                      .id),
                                                              newJumlah: selectedInv[
                                                                          index]
                                                                      .newJumlah -
                                                                  int.parse(
                                                                      countToSend
                                                                          .text)));
                                                          setState(() {});
                                                          Navigator.pop(
                                                              context);
                                                          tabel = await TblBarang
                                                              .dataBarang(
                                                                  invToSend,
                                                                  0.toString());
                                                          // print(
                                                          //     'jumlah setelah dikurangi inputan ${invToSend[index].newJumlah}');
                                                          selectedInv
                                                              .removeAt(index);
                                                          setState(() {});
                                                        },
                                                        child: Text(
                                                          'Selesai',
                                                          style: TextStyle(
                                                            color: Colors.green,
                                                          ),
                                                        ))
                                                  ],
                                                ));
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
                                                Text('ID Surat'),
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
                                                Text(
                                                    selectedInv[index].idSurat),
                                                Text(selectedInv[index].nama),
                                                Text(selectedInv[index].merk),
                                                Text(selectedInv[index]
                                                    .newJumlah
                                                    .toString()),
                                                Text(selectedInv[index]
                                                    .keterangan),
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
                              if (tabel != null)
                                Image(image: MemoryImage(tabel!))
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
                                                          sign.clear();
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
                                                                  points: sign
                                                                      .points,
                                                                  penColor:
                                                                      Colors
                                                                          .black,
                                                                  penStrokeWidth:
                                                                      2);

                                                          var fileSign =
                                                              await signature
                                                                  .toPngBytes();

                                                          ttd = fileSign;
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
                                                          sign2.clear();
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
                                                                  points: sign2
                                                                      .points,
                                                                  penColor:
                                                                      Colors
                                                                          .black,
                                                                  penStrokeWidth:
                                                                      2);

                                                          var fileSign =
                                                              await signature
                                                                  .toPngBytes();

                                                          ttd2 = fileSign;
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
                          var rd = new Random().nextInt(99999);
                          idSuratNew = 'PND111$rd';
                          setState(() {
                            isloading = true;
                          });
                          // print('$invToSend , $selectedStaff2 , $ttd , $ttd2');
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
                            return;
                          } else {
                            ////////////////////////////////////////////////////////////
                            ///////////////// mulai mengirim data //////////////////////
                            // mengirim data inv baru ke backend untuk pindah tangan
                            // mengudate jumlah inv sebelumnya
                            // mengirim pdf
                            for (var data in invToSend) {
                              print(
                                  'nilai yang akan di update \n id surat -> $idSuratNew, \n id selected staf2 id -> ${selectedStaff2!.id}, \n id inventory -> ${data.idInventory}, \n nama  ->${data.nama}, \n merk -> ${data.merk}, \n new_jumlah -> ${data.newJumlah}, \n keterangan -> ${data.keterangan}, \n kategory -> ${data.kategory},  ${data.model},\n sn ->  ${data.sn}, \n sub kategory ->  ${data.subKategory}, \n path photo -> ${data.pathPhoto}');
                              var response = await http.post(
                                  Uri.parse(
                                      CommonUser.baseUrl + '/new_inv_pnd'),
                                  body: ({
                                    'id_surat': idSuratNew,
                                    'status': 'pindah tangan',
                                    'id_pemilik': selectedStaff2!.id,
                                    'id_inventory': data.idInventory,
                                    'nama': data.nama,
                                    'merk': data.merk,
                                    'jumlah': 0.toString(),
                                    'new_jumlah': data.newJumlah.toString(),
                                    'jumlah_pinjam': 0.toString(),
                                    'keterangan': data.keterangan,
                                    'model': data.model,
                                    'sn': data.sn,
                                    'kategory': data.kategory,
                                    'sub_kategory': data.subKategory,
                                    'path_photo': data.pathPhoto,
                                  }));
                              if (response.statusCode == 200) {
                                print(
                                    'berhasil kirim data baru untuk pindah tangan');
                                newInvScs = true;
                                Invetory.tambahInv(
                                  'id', // String id
                                  idSuratNew!, // String idSurat
                                  'pindah tangan', // String status
                                  selectedStaff2!.id!, // String idPemilik
                                  data.idInventory, // String idInventory
                                  data.nama, // String nama
                                  data.merk, // String merk
                                  data.sn, // string sn
                                  data.model, // String model
                                  0, //int jumlah
                                  data.newJumlah, // int new_jumlah
                                  0, // int jumlahPinjam
                                  'null', // String id awal
                                  data.keterangan, // String keterangan
                                  data.kategory, // String Kategory
                                  data.subKategory, // String subKategory
                                  data.pathPhoto, // String path_photo
                                  () {
                                    setState(() {});
                                  },
                                );
                              } else {
                                print(
                                    'gagal untuk membuat inv baru untuk pindah tangan');
                              }
                            }
                            // update jumlah baru
                            for (var data in hasilToUpdate) {
                              print('${data.index} - ${data.newJumlah}');
                              var res = await http.post(
                                  Uri.parse(CommonUser.baseUrl +
                                      '/edit_inv_surat_pnd/${data.index}'),
                                  body: ({
                                    'new_jumlah': data.newJumlah.toString(),
                                  }));
                              if (res.statusCode == 200) {
                                Invetory.editInvPnd(
                                  data.idSurat.toString(),
                                  data.idInv!,
                                  data.newJumlah,
                                );
                                print(
                                    'berhasil update data bew jumlah untuk pnd dan akan menghapus inventaris jika jumlahnya 0');
                                updateInvScs = true;
                                if (data.newJumlah == 0) {
                                  var response = await http.post(Uri.parse(
                                      CommonUser.baseUrl +
                                          '/delete_inv/${data.index}'));
                                  if (response.statusCode == 200) {
                                    allInvs.removeWhere((element) =>
                                        element.idSurat == idSUrat);
                                    print(
                                        'menghapus inventory dengan status karena pindah tangan');
                                    setState(() {});
                                  }
                                }
                              } else {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Gagal mengirim data, coba lagi nanti")));
                                print('gagal update new jumlah pnd');
                              }
                            }
                            if (newInvScs == false || updateInvScs == false) {
                              return;
                            }
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
                            /////////////// mengirim pdf ////////////
                            var req = new http.MultipartRequest('POST',
                                Uri.parse(CommonUser.baseUrl + '/store_bap'));
                            req.headers.addAll(
                                ({'Content-Type': 'multipart/form-data'}));
                            req.fields.addAll({
                              'id_phk1': selectedStaff!.id.toString(),
                              'id_phk2': selectedStaff2!.id.toString(),
                              'tag': 'pindah',
                              'jumlah_inv': invToSend.length.toString(),
                              'nomor_surat': idSuratNew.toString(),
                              'id_surat': idSuratNew.toString(),
                            });
                            req.files.add(await http.MultipartFile.fromPath(
                                'pdf', pdf!.path));
                            var responses = await req.send();
                            print(responses.statusCode);
                            var ress =
                                await http.Response.fromStream(responses);
                            if (responses.statusCode == 200) {
                              var rr = jsonDecode(ress.body);
                              var idss = rr['data']['id'];
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
                              sendPdf = true;
                              setState(() {});
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) => AllBAP()));
                              print(
                                  'berhasil mengirim file pdf ================================================================================');
                            } else {
                              print('gagal mengirim file');
                            }
                          }
                        },
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

class InvToUpdate {
  String? idSurat;
  String? idInv;
  int index;
  int newJumlah;
  InvToUpdate({
    required this.index,
    required this.newJumlah,
    this.idInv,
    this.idSurat,
  });
}
