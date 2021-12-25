import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signature/signature.dart';
import 'package:sipisat/common.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/generate_pdf.dart';
import 'package:sipisat/generate_tabel.dart';
import 'package:sipisat/menu/bap/all_bap.dart';
import 'package:sipisat/models/bap_model.dart';
import 'package:sipisat/models/inventory_model.dart';
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
  // StaffModel? inventory;

  Uint8List? tabel;

  List<Invetory>? sendInv;

  var idInv = TextEditingController();

  SignatureController? _signController;
  SignatureController? _signController2;
  Uint8List? sign;
  Uint8List? sign2;

  TextEditingController _jumlahInp = TextEditingController();
  String newJumlah = '';

  ambilDataStaff() async {
    allStaf = StaffModel.allStaf;
    if (allInv.isEmpty) {
      allInv = Invetory.allInv;
    }
    setState(() {});
  }

  ambilDataInv() async {
    allInv = Invetory.invs;
    allInv = allInv.where((element) => element.status == 'baru masuk').toList();
  }

  tambahInv() {
    var invs = allInv
        .firstWhere((element) => element.idInventory.toString() == idInv.text);
    print(
        'sebelum - jumlah dari ${invs.nama} adalah ${invs.jumlah} dikurangi dengan ${_jumlahInp.text}');
    if (invs.jumlah > 0) {
      setState(() {
        sendInv!.add(invs);
        invs.jumlah = invs.jumlah - int.parse(_jumlahInp.text);
      });
      print('sesudah - jumlah dari ${invs.nama} adalah ${invs.jumlah}');
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Habis"),
          content: Text("Inventaris yang anda pilih sudah tidak tersedia"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Oke'))
          ],
        ),
      );
    }
    print('berhasil menambah inv $sendInv! - length -> ${sendInv!.length}');
    idInv.text = '';
  }

  var isLoading = false;
  @override
  void initState() {
    sendInv = [];
    ambilDataStaff();
    ambilDataInv();
    _signController = SignatureController(
      exportBackgroundColor: Colors.white,
      penStrokeWidth: 2,
    );
    _signController2 = SignatureController(
      exportBackgroundColor: Colors.white,
      penStrokeWidth: 2,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _jumlahInp.dispose();
    allInv.clear();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(sendInv!.length);
    setState(() {});
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
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
                    child: ListView(
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
                                  phk1 = allStaf.firstWhere(
                                      (element) => element.nama == this.pihak1);
                                });
                                print('nilai dari pilihanCategory -> $pihak1');
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
                                  phk2 = allStaf.firstWhere(
                                      (element) => element.nama == this.pihak2);
                                });
                                print('nilai dari pilihanCategory -> $pihak2');
                              },
                              items: allStaf
                                  .map((e) => DropdownMenuItem(
                                        child: Text(e.nama),
                                        value: e.nama,
                                      ))
                                  .toList()),
                        TextField(
                          controller: idInv,
                          decoration: InputDecoration(
                              hintText: 'masukkan id inventaris'),
                        ),
                        TextButton(
                            onPressed: () async {
                              var loading = false;
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'Batal',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              if (_jumlahInp.text != '') {
                                                tambahInv();
                                                tabel =
                                                    await TblBarang.dataBarang(
                                                        sendInv!,
                                                        _jumlahInp.text);
                                                setState(() {
                                                  loading = true;
                                                });
                                                newJumlah = _jumlahInp.text;
                                                _jumlahInp.text = '';
                                                Navigator.pop(context);
                                              } else {
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: loading
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : Text('Selesai'),
                                          ),
                                        ],
                                        title: Text("Jumlah Inventaris"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            BuildInput(
                                              keyName:
                                                  'Jumlah Inventaris yang akan ditambah',
                                              controllers: _jumlahInp,
                                              obsText: false,
                                              actType: TextInputAction.done,
                                              kyType: TextInputType.number,
                                            )
                                          ],
                                        ),
                                      ));
                            },
                            child: Text('Cari Inv')),
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
                                                controller: _signController!,
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
                                                      _signController!.clear();
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
                                                                  _signController!
                                                                      .points,
                                                              penColor:
                                                                  Colors.black,
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
                                                controller: _signController2!,
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
                                                      _signController2!.clear();
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
                                                                  _signController2!
                                                                      .points,
                                                              penColor:
                                                                  Colors.black,
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
                                  });
                                  var rd = new Random().nextInt(99999);
                                  String idSurat = 'BAP111' + rd.toString();
                                  // INVENTARIS //
                                  // update data inventaris
                                  var scs = false;
                                  for (var data in sendInv!) {
                                    print(
                                        'nilai yang akan di update $idSurat, ${phk2!.id}, ${data.idInventory}-BAP, ${data.nama},  ${data.merk},  $newJumlah,  ${data.keterangan},  ${data.kategory},  ${data.model},  ${data.sn},  ${data.subKategory},  ${data.pathPhoto}');
                                    var resp = await http.post(
                                        Uri.parse(
                                            CommonUser.baseUrl + '/new_inv'),
                                        body: ({
                                          'id_surat': '$idSurat',
                                          'status': 'bap',
                                          'id_pemilik': phk2!.id,
                                          'id_inventory': '${data.idInventory}',
                                          'nama': data.nama,
                                          'merk': data.merk,
                                          'new_jumlah': newJumlah,
                                          'jumlah': 'null',
                                          'keterangan': data.keterangan,
                                          'kategory': data.kategory,
                                          'model': data.model,
                                          'sn': data.sn,
                                          'sub_kategory': data.subKategory,
                                          'path_photo': data.pathPhoto,
                                        }));
                                    if (resp.statusCode == 200) {
                                      print(
                                          'berhasil membuat data inv baru untuk bap');
                                    } else {
                                      print(
                                          'gagal membuat data inv baru untuk bap ${resp.statusCode}');
                                    }

                                    print(
                                        'jumlah inv ${data.jumlah} - ${data.id}');
                                    var res = await http.post(
                                        Uri.parse(CommonUser.baseUrl +
                                            '/edit_inv_surat/${data.id}'),
                                        body: ({
                                          'jumlah': data.jumlah.toString(),
                                        }));
                                    if (res.statusCode == 200) {
                                      print('berhasil update data');
                                      scs = true;
                                    } else {
                                      print('gagal update ${resp.statusCode}');
                                    }
                                    print(
                                        'mengupdate inventaris dengan id ${data.id}');
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
                                  // kirim semua data ke backend
                                  var request = new http.MultipartRequest(
                                      'POST',
                                      Uri.parse(
                                          CommonUser.baseUrl + '/store_bap'));
                                  request.headers.addAll(
                                      {'Content-Type': 'multipart/form-data'});
                                  request.fields.addAll({
                                    'id_phk1': phk1!.id.toString(),
                                    'id_phk2': phk2!.id.toString(),
                                    'tag': 'bap',
                                    'jumlah_inv': sendInv!.length.toString(),
                                    'id_surat': idSurat.toString(),
                                    'nomor_surat': idSurat.toString()
                                  });
                                  request.files.add(
                                      await http.MultipartFile.fromPath(
                                          'pdf', pdf.path));
                                  print(pdf);

                                  // mengirim file
                                  if (scs == true) {
                                    var responses = await request.send();
                                    print(responses.statusCode);
                                    var res = await http.Response.fromStream(
                                        responses);

                                    if (responses.statusCode == 200) {
                                      var resp = jsonDecode(res.body);
                                      var idss = resp['data']['id'];
                                      BapModel.addBAP(
                                          idss.toString(),
                                          idSurat,
                                          idSurat,
                                          phk1!.id.toString(),
                                          phk2!.id.toString(),
                                          sendInv!.length.toString(),
                                          'pdf');
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => AllBAP()));
                                      print(
                                          'berhasil mengirim file pdf ================================================================================');
                                    } else {
                                      print('gagal mengirim file');
                                    }
                                  } else {
                                    // var rr =
                                    //     jsonDecode(resp.statusCode.toString());
                                    print(
                                        'gagal membuat data inv baru untuk bap ');
                                    return;
                                  }
                                }

                                ///
                                //   )
                                // },
                                ,
                                child: Text("Selesai"))
                          ],
                        )
                      ],
                    ),
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
                data: sendInv![index].idInventory,
                size: 70,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    sendInv![index].nama.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        'Merk :',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(sendInv![index].merk),
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
                          Text(sendInv![index].idInventory),
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
