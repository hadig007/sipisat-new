import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:signature/signature.dart';
import 'package:sipisat/common.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/generate_pdf_pnd.dart';
import 'package:sipisat/generate_tabel_pnd.dart';
import 'package:sipisat/models/bap_model.dart';
import 'package:sipisat/models/inventory_model.dart';
import 'package:sipisat/models/log_models.dart';
import 'package:sipisat/models/staff_model.dart';
// import 'package:sipisat/preview_pdf.dart';
import 'package:http/http.dart' as http;

class Peminjaman extends StatefulWidget {
  const Peminjaman({Key? key}) : super(key: key);

  @override
  _PeminjamanState createState() => _PeminjamanState();
}

class _PeminjamanState extends State<Peminjaman> {
  TextEditingController invCon = TextEditingController();

  TextEditingController nama = TextEditingController();
  TextEditingController instansi = TextEditingController();
  TextEditingController alamat = TextEditingController();
  TextEditingController kontak = TextEditingController();

  List<Invetory> allInv = [];
  List<StaffModel> allStaff = [];
  List<BapModel> allBap = [];
  StaffModel? phk1;

  Uint8List? tabel;

  List<Invetory> srch = [];
  List<Invetory> invToSend = [];

  Invetory? selInv;

  var isPeminjam = false;
  var isError = false;
  var isLoading = false;

  // cek status pengiriman data
  var sendNewData = false;
  var updateData = false;
  var sendPdf = false;

  List<InvToUpdatePjm> invToUpdatePjm = [];

  String? pjawab;

  Uint8List? ttd;
  Uint8List? ttd2;

  List<StaffModel> pemilik = [];

  SignatureController? sign;
  SignatureController? sign2;

  File? pdf;

  int? hasil;
  // tanggal peminjaman
  DateTime selectedDate1 = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  var isTanggal2 = false;
  int newJumlahInput = 0;

  TextEditingController inputJumlah = TextEditingController();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  var onScanning = false;

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate2, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate2)
      setState(() {
        selectedDate2 = picked;
        isTanggal2 = true;
      });
  }

  void ambilData() async {
    Invetory.ambilData();
    StaffModel.ambilData();
    allInv = Invetory.allInv;
    allStaff = await StaffModel.getData();
    allBap = BapModel.baps;
    print('$allInv === \n$allStaff');
    setState(() {});
  }

  @override
  void initState() {
    ambilData();
    sign = SignatureController(
        exportBackgroundColor: Colors.white,
        penColor: Colors.black,
        penStrokeWidth: 2);
    sign2 = SignatureController(
        exportBackgroundColor: Colors.white,
        penColor: Colors.black,
        penStrokeWidth: 2);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Invetory.invCount();
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        title: Text('Peminjaman'),
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
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: onScanning == true
                  ? Container(
                      // padding:,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: QRView(
                          key: qrKey,
                          onQRViewCreated: (value) {
                            this.controller = value;
                            controller!.scannedDataStream.listen((event) {
                              invCon.text = '';
                              // result = event;
                              // qrIdInv = result!.code;
                              invCon.text = event.code;
                              onScanning = false;
                              if (invCon.text != '') {
                                onScanning = false;
                                setState(() {});
                              }
                            });
                            print('hasil scan 2 ${invCon.text}');
                          }),
                    )
                  : SingleChildScrollView(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 120,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue.shade100,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: pjawab == null
                                              ? Column(
                                                  children: [
                                                    Text(
                                                      'penanggung jawab belum dipilih',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Penanggug jawab',
                                                    ),
                                                    Divider(),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text('Nama'),
                                                            Text('NIP'),
                                                            Text('Jabatan'),
                                                            Text('Alamat'),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(phk1!.nama
                                                                .toUpperCase()),
                                                            Text(phk1!.nip),
                                                            Text(phk1!.jabatan),
                                                            Text(phk1!.alamat)
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (pjawab == null)
                                    DropdownButton(
                                        hint: Text('Pilih Penangung Jawab'),
                                        isExpanded: true,
                                        value: pjawab,
                                        onChanged: (value) {
                                          print(value);
                                          setState(() {
                                            this.pjawab = value as String?;
                                            phk1 = allStaff.firstWhere(
                                                (element) =>
                                                    element.nama == pjawab);
                                          });
                                          print(
                                              'nilai dari pilihanCategory -> $pjawab');
                                        },
                                        items: allStaff
                                            .map((e) => DropdownMenuItem(
                                                  child: Text(e.nama),
                                                  value: e.nama,
                                                ))
                                            .toList()),
                                  ///////////////////////////////////////////////////
                                  ///////////////////////////////////////////////////
                                  SizedBox(
                                    height: 10,
                                  ),
                                  // isPeminjam == true
                                  // ?
                                  Container(
                                    height: 120,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.lightBlue.shade100,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: !isPeminjam
                                        ? Center(
                                            child: Text(
                                                "Belum ada data peminjam",
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          )
                                        : Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Data Peminjam'),
                                              Divider(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('Nama'),
                                                      Text('Instansi'),
                                                      Text('Alamat'),
                                                      Text('Nomor Hp')
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(nama.text
                                                          .toUpperCase()),
                                                      Text(instansi.text),
                                                      Text(alamat.text),
                                                      Text(kontak.text)
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                  ),
                                  if (isPeminjam == false)
                                    TextButton(
                                        onPressed: () {
                                          isError = false;
                                          setState(() {});
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: Text(
                                                  "Masukkan Data Peminjam"),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Divider(),
                                                  BuildInput(
                                                    controllers: nama,
                                                    obsText: false,
                                                    hnt: 'Nama',
                                                  ),
                                                  BuildInput(
                                                    controllers: instansi,
                                                    obsText: false,
                                                    hnt: 'Intansi',
                                                  ),
                                                  BuildInput(
                                                    controllers: alamat,
                                                    obsText: false,
                                                    hnt: 'Alamat',
                                                  ),
                                                  BuildInput(
                                                    controllers: kontak,
                                                    obsText: false,
                                                    hnt: 'Nomor Handphone',
                                                    kyType:
                                                        TextInputType.number,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  isError == true
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Icon(
                                                              Icons.error,
                                                              color: Colors.red,
                                                              size: 20,
                                                            ),
                                                            Text(
                                                              '  Data tidak sesuai!',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 13),
                                                            )
                                                          ],
                                                        )
                                                      : SizedBox()
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'Batal',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final n = num.tryParse(
                                                        kontak.text);
                                                    if (nama.text == '' ||
                                                        instansi.text == '' ||
                                                        alamat.text == '' ||
                                                        kontak.text == '' ||
                                                        n == null) {
                                                      isError = true;
                                                      setState(() {});
                                                    } else {
                                                      isPeminjam = true;
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: Text(
                                                    'Simpan',
                                                    style: TextStyle(
                                                        color: Colors.green),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: isPeminjam == true
                                            ? Text("Ubah Data Peminjam")
                                            : Text("Masukkan Data Peminjam"))
                                ],
                              ),
                              Divider(),
                              // input id inventaris
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey.shade200),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: BuildInput(
                                          controllers: invCon,
                                          obsText: false,
                                          brd: InputBorder.none,
                                          hnt: 'Masukkan ID Inventaris',
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            srch = allInv
                                                .where((element) =>
                                                    element.idInventory ==
                                                    invCon.text)
                                                .toList();
                                            srch.removeWhere((element) =>
                                                element.jumlah == 0 &&
                                                element.newJumlah == 0);
                                            setState(() {});
                                            print(
                                                'hasil pencarian ${srch.length}');
                                          },
                                          icon: Icon(
                                            Icons.search,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              print(
                                                  'masuk fungsi scan qr code');
                                              onScanning = !onScanning;
                                              setState(() {});
                                            },
                                            icon: Icon(
                                              Icons.qr_code,
                                              color: Colors.lightBlue,
                                            ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              //////// pilih inventaris /////////////
                              // if (srch.isNotEmpty)
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    20,
                                  ),
                                  child: Container(
                                    height: 200,
                                    child: srch.isEmpty
                                        ? Center(
                                            child: Text(
                                              "list inventaris",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      selInv = srch[index];
                                                      if (selInv == null) {
                                                        return;
                                                      }
                                                      // jika jumlah inventaris yang dipilih lebih dari 1
                                                      // maka akan meminta inputan jumlah yang akan dipinjam
                                                      if (selInv!.jumlah > 1 ||
                                                          selInv!.newJumlah >
                                                              1) {
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (_) =>
                                                                    AlertDialog(
                                                                      title: Text(
                                                                          'Jumlah'),
                                                                      content:
                                                                          BuildInput(
                                                                        controllers:
                                                                            inputJumlah,
                                                                        obsText:
                                                                            false,
                                                                        hnt:
                                                                            'masukkan jumlah inventaris',
                                                                        kyType:
                                                                            TextInputType.number,
                                                                      ),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'Batal',
                                                                            style:
                                                                                TextStyle(color: Colors.red),
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            // jika yang diklik statusnya adalah baru masuk
                                                                            newJumlahInput =
                                                                                int.parse(inputJumlah.text);

                                                                            if (selInv!.status ==
                                                                                'baru masuk') {
                                                                              int jumlahAwal = selInv!.jumlah;
                                                                              int jumlahAkhir = jumlahAwal - newJumlahInput;
                                                                              invToUpdatePjm.add(InvToUpdatePjm(
                                                                                index: int.parse(selInv!.id),
                                                                                jumlah: jumlahAkhir,
                                                                                newJumlah: 0,
                                                                                jumlahPinjam: newJumlahInput,
                                                                                idInv: selInv!.idInventory,
                                                                              ));
                                                                              print('inventaris yang akan dipinjam adalah baru masuk dengan jumlah awal $jumlahAwal jumlah yang akan dipinjam adalah $newJumlahInput dan hasil updatenya adakah $jumlahAkhir');
                                                                            } else if (selInv!.status ==
                                                                                'pindah tangan') {
                                                                              int jumlahAwal = selInv!.newJumlah;
                                                                              int jumlahAkhir = jumlahAwal - newJumlahInput;
                                                                              invToUpdatePjm.add(InvToUpdatePjm(
                                                                                index: int.parse(selInv!.id),
                                                                                jumlah: 0,
                                                                                newJumlah: jumlahAkhir,
                                                                                jumlahPinjam: newJumlahInput,
                                                                                idInv: selInv!.idInventory,
                                                                              ));
                                                                              print('inventaris yang akan dipinjam adalah baru masuk dengan jumlah awal $jumlahAwal jumlah yang akan dipinjam adalah $newJumlahInput dan hasil updatenya adakah $jumlahAkhir');
                                                                            } else if (selInv!.status ==
                                                                                'bap') {
                                                                              int jumlahAwal = selInv!.newJumlah;
                                                                              int jumlahAkhir = jumlahAwal - newJumlahInput;
                                                                              invToUpdatePjm.add(InvToUpdatePjm(
                                                                                index: int.parse(selInv!.id),
                                                                                jumlah: 0,
                                                                                newJumlah: jumlahAkhir,
                                                                                jumlahPinjam: newJumlahInput,
                                                                                idInv: selInv!.idInventory,
                                                                              ));
                                                                              print('inventaris yang akan dipinjam adalah baru masuk dengan jumlah awal $jumlahAwal jumlah yang akan dipinjam adalah $newJumlahInput dan hasil updatenya adakah $jumlahAkhir');
                                                                            }
                                                                            ////////////////////////////
                                                                            invToSend.add(Invetory(
                                                                              id: selInv!.id,
                                                                              idSurat: selInv!.idSurat,
                                                                              status: selInv!.status,
                                                                              idPemilik: selInv!.idPemilik,
                                                                              idInventory: selInv!.idInventory,
                                                                              nama: selInv!.nama,
                                                                              merk: selInv!.merk,
                                                                              jumlah: 0,
                                                                              newJumlah: 0,
                                                                              jumlahPinjam: newJumlahInput,
                                                                              idAwal: selInv!.idAwal,
                                                                              keterangan: selInv!.keterangan,
                                                                              kategory: selInv!.kategory,
                                                                              pathPhoto: selInv!.pathPhoto,
                                                                              model: selInv!.model,
                                                                              subKategory: selInv!.subKategory,
                                                                              sn: selInv!.sn,
                                                                            ));
                                                                            tabel = await TblBarangPnd.dataBarang(
                                                                                invToSend,
                                                                                1.toString(),
                                                                                'lengkap',
                                                                                'baik');
                                                                            srch.remove(selInv);
                                                                            inputJumlah.text =
                                                                                "";
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'Simpan',
                                                                            style:
                                                                                TextStyle(color: Colors.green),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ));
                                                      } else if (selInv!
                                                                  .jumlah ==
                                                              1 ||
                                                          selInv!.newJumlah ==
                                                              1) {
                                                        // jika inventaris yang dipilih itu berstatus baru masuk dan jumlahnya hanya 1
                                                        // maka jumlah -1 dan jumalah pinjam +1
                                                        invToSend.add(Invetory(
                                                          id: selInv!.id,
                                                          idSurat:
                                                              selInv!.idSurat,
                                                          idInventory: selInv!
                                                              .idInventory,
                                                          idPemilik:
                                                              selInv!.idPemilik,
                                                          status:
                                                              selInv!.status,
                                                          jumlah: 0,
                                                          newJumlah: 0,
                                                          jumlahPinjam: 1,
                                                          idAwal:
                                                              selInv!.idAwal,
                                                          nama: selInv!.nama,
                                                          merk: selInv!.merk,
                                                          sn: selInv!.sn,
                                                          model: selInv!.model,
                                                          keterangan: selInv!
                                                              .keterangan,
                                                          subKategory: selInv!
                                                              .subKategory,
                                                          pathPhoto:
                                                              selInv!.pathPhoto,
                                                          kategory:
                                                              selInv!.kategory,
                                                        ));

                                                        invToUpdatePjm.add(
                                                            InvToUpdatePjm(
                                                                index: int.parse(
                                                                    selInv!.id),
                                                                jumlah: 0,
                                                                newJumlah: 0,
                                                                jumlahPinjam: 1,
                                                                idInv: selInv!
                                                                    .idInventory));
                                                        tabel =
                                                            await TblBarangPnd
                                                                .dataBarang(
                                                                    invToSend,
                                                                    1.toString(),
                                                                    'lengkap',
                                                                    'baik');
                                                        srch.remove(selInv);
                                                        setState(() {});
                                                      }
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text("Nama"),
                                                            Text("kategory"),
                                                            Text("ID Surat"),
                                                            // Text("Pemegang"),
                                                            Text("SN"),
                                                            Text("Jumlah"),
                                                            Divider(),
                                                          ],
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Text(srch[index]
                                                                .nama
                                                                .toUpperCase()),
                                                            Text(srch[index]
                                                                .kategory),
                                                            Text(srch[index]
                                                                        .idSurat ==
                                                                    'null'
                                                                ? '-'
                                                                : srch[index]
                                                                    .idSurat),
                                                            Text(srch[index]
                                                                        .sn ==
                                                                    'null'
                                                                ? '-'
                                                                : srch[index]
                                                                    .sn),
                                                            if (srch[index]
                                                                    .status ==
                                                                'baru masuk')
                                                              Text(srch[index]
                                                                  .jumlah
                                                                  .toString()),
                                                            if (srch[index]
                                                                    .status ==
                                                                'pindah tangan')
                                                              Text(srch[index]
                                                                  .newJumlah
                                                                  .toString()),
                                                            if (srch[index]
                                                                    .status ==
                                                                'bap')
                                                              Text(srch[index]
                                                                  .newJumlah
                                                                  .toString()),
                                                            Divider(),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(),
                                                ],
                                              );
                                            },
                                            itemCount: srch.length,
                                          ),
                                  ),
                                ),
                              ),
                              ///////////////////////// tabel barang /////////////////////////
                              Container(
                                padding: EdgeInsets.all(20),
                                margin: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Center(
                                  child: invToSend.isEmpty
                                      ? Text(
                                          "Inventaris dipilih belum ada",
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      : Image(image: MemoryImage(tabel!)),
                                ),
                              ),
                              Divider(),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("Tanggal Peminjaman : "),
                                      Text("${selectedDate1.toLocal()}"
                                          .split(' ')[0])
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Tanggal Pengembalian : "),
                                      isTanggal2 == false
                                          ? TextButton(
                                              onPressed: () {
                                                _selectDate(context);
                                              },
                                              child: Text('Pilih tanggal'))
                                          : Text("${selectedDate2.toLocal()}"
                                              .split(' ')[0])
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                              //////////// Tanda Tangan //////////////
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Tanda Tangan"),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (_) => Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 300,
                                                      height: 200,
                                                      child: Signature(
                                                        controller: sign!,
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
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              sign!.clear();
                                                            },
                                                            child: Text(
                                                              "Hapus",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              var signature = SignatureController(
                                                                  points: sign!
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
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                              "Simpan",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green),
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: ttd == null
                                                ? Center(
                                                    child: Text(
                                                    "Tanda tangan belum ada",
                                                    style: TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.grey),
                                                  ))
                                                : Image(
                                                    image: MemoryImage(ttd!)),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (_) => Padding(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 300,
                                                      height: 200,
                                                      child: Signature(
                                                        controller: sign2!,
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
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          TextButton(
                                                            onPressed: () {
                                                              sign2!.clear();
                                                            },
                                                            child: Text(
                                                              "Hapus",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              var signature = SignatureController(
                                                                  points: sign2!
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
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                              "Simpan",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .green),
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
                                                    color: Colors.grey,
                                                    width: 1)),
                                            child: ttd2 == null
                                                ? Center(
                                                    child: Text(
                                                    "Tanda tangan belum ada",
                                                    style: TextStyle(
                                                        fontSize: 8,
                                                        color: Colors.grey),
                                                  ))
                                                : Image(
                                                    image: MemoryImage(ttd2!)),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              /////////////////////////////////
                              /////////// kirim //////////////
                              OutlinedButton(
                                  onPressed: () async {
                                    isLoading = true;
                                    setState(() {});
                                    ///////////////// pengecekan sebelum kirim data/////////////
                                    final k = num.tryParse(kontak.text);
                                    if (phk1 == null ||
                                        nama.text == '' ||
                                        alamat.text == '' ||
                                        kontak.text == '' ||
                                        k == null ||
                                        instansi.text == '' ||
                                        selectedDate2.hour != 00) {
                                      print('data belum lengkap');
                                      showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                                title: Text("Gagal"),
                                                content: Text(
                                                    'Mohon cek kembali data yang anda masukkan.'),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Oke"))
                                                ],
                                              ));
                                      return;
                                    }
                                    var rd = new Random().nextInt(99999);
                                    String idSurat = 'PJM123' + rd.toString();
                                    // menambah inventaris baru dengan status pinjam
                                    for (var data in invToSend) {
                                      print(
                                          'nilai yang akan di update $idSurat, ${nama.text}, ${data.idInventory}, ${data.nama},  ${data.merk},  ${newJumlahInput == 0 ? '1' : newJumlahInput},  ${data.keterangan},  ${data.kategory},  ${data.model},  ${data.sn},  ${data.subKategory},  ${data.pathPhoto}');
                                      var response = await http.post(
                                          Uri.parse(CommonUser.baseUrl +
                                              '/new_inv_pjm'),
                                          body: ({
                                            'id_surat': idSurat,
                                            'status': 'pinjam',
                                            'id_pemilik': nama.text,
                                            'id_inventory': data.idInventory,
                                            'nama': data.nama,
                                            'merk': data.merk,
                                            'new_jumlah': 0.toString(),
                                            'jumlah': 0.toString(),
                                            'jumlah_pinjam':
                                                data.jumlahPinjam.toString(),
                                            'id_awal': data.idSurat,
                                            'keterangan': data.keterangan,
                                            'kategory': data.kategory,
                                            'model': data.model,
                                            'sn': data.sn,
                                            'sub_kategory': data.subKategory,
                                            'path_photo': data.pathPhoto,
                                          }));
                                      if (response.statusCode == 200) {
                                        sendNewData = true;
                                        var res = jsonDecode(response.body);
                                        int idss = res['data']['id'];
                                        Invetory.tambahInv(
                                            idss.toString(),
                                            idSurat,
                                            'pinjam',
                                            data.idPemilik,
                                            data.idInventory,
                                            nama.text,
                                            data.merk,
                                            data.sn,
                                            data.model,
                                            0,
                                            0,
                                            data.jumlahPinjam,
                                            data.idSurat,
                                            data.keterangan,
                                            data.kategory,
                                            data.subKategory,
                                            data.pathPhoto, () {
                                          setState(() {});
                                        });
                                        print(
                                            'berhasil update inventaris untuk pinjam');
                                      } else {
                                        print(
                                            'gagal mengirim data ${response.statusCode}');
                                      }
                                    }
                                    ////////////////
                                    for (var data in invToUpdatePjm) {
                                      print(
                                          'data yang akan di update jumlah ${data.jumlah} - new jumlah ${data.newJumlah} - jumlah pinjam ${data.jumlahPinjam}');
                                      var resp = await http.post(
                                          Uri.parse(CommonUser.baseUrl +
                                              '/edit_inv_surat_pjm/${data.index}'),
                                          body: ({
                                            'jumlah_pinjam':
                                                data.jumlahPinjam.toString(),
                                            'jumlah': data.jumlah.toString(),
                                            'new_jumlah':
                                                data.newJumlah.toString(),
                                          }));
                                      if (resp.statusCode == 200) {
                                        updateData = true;
                                        Invetory.editInvPjm(
                                            'pinjam',
                                            data.idInv,
                                            data.jumlah,
                                            data.newJumlah,
                                            data.jumlahPinjam, () {
                                          setState(() {});
                                        });
                                        print(
                                            'berhasil update data untuk peminjaman');
                                      } else {
                                        print(
                                            'gagal update data untuk peminjaman ${resp.statusCode}');
                                      }
                                    }
                                    /////////////////////
                                    pdf = await PdfApiPnd.generatorSurat(
                                      'idSurat',
                                      nama.text,
                                      instansi.text,
                                      alamat.text,
                                      kontak.text,
                                      phk1!.nama,
                                      ttd!,
                                      ttd2!,
                                      tabel!,
                                      selectedDate1,
                                      selectedDate2,
                                    );
                                    // mengirim inventory baru sebagai pinjaman
                                    var request = new http.MultipartRequest(
                                        'POST',
                                        Uri.parse(
                                            CommonUser.baseUrl + '/store_bap'));
                                    request.headers.addAll({
                                      'Content-Type': 'multipart/form-data'
                                    });
                                    request.fields.addAll({
                                      'id_phk1': phk1!.id.toString(),
                                      'id_phk2': nama.text,
                                      'tag': 'pinjam',
                                      'jumlah_inv': invToSend.length.toString(),
                                      'id_surat': idSurat.toString(),
                                      'nomor_surat': idSurat.toString()
                                    });
                                    request.files.add(
                                        await http.MultipartFile.fromPath(
                                            'pdf', pdf!.path));
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
                                          nama.text,
                                          invToSend.length.toString(),
                                          'pdf');

                                      LogModel.sendLog(
                                        idSurat,
                                        'add pjm',
                                        idSurat,
                                        'anda membuat bap untuk peminjaman inventaris dengan id $idSurat',
                                      );
                                      Navigator.pop(context);
                                      print(
                                          'berhasil mengirim file pdf ================================================================================');
                                    } else {
                                      print('gagal mengirim file');
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.pinkAccent,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .3)),
                                  child: Text(
                                    "Simpan",
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }
}

class InvToUpdatePjm {
  int index;
  int jumlah;
  int newJumlah;
  int jumlahPinjam;
  String idInv;
  InvToUpdatePjm({
    required this.index,
    required this.jumlah,
    required this.newJumlah,
    required this.jumlahPinjam,
    required this.idInv,
  });
}
