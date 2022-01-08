import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sipisat/models/inventory_model.dart';

// ignore: must_be_immutable
class TblBarang extends StatefulWidget {
  static List<Invetory> dd = [];
  //  method menggenerate tabel menjadi png
  static Future<Uint8List> dataBarang(
      List<Invetory> dataBarang, String jumlah) async {
    dd = dataBarang;
    final sc = await _screenshotController.captureFromWidget(buildSc(jumlah));
    return sc;
  }

  static int angka = 0;
  static ScreenshotController _screenshotController = ScreenshotController();
  @override
  _TblBarangState createState() => _TblBarangState();

  // method untuk generate tabel
  static DataTable buildSc(String jumlah) {
    angka = 1;
    return DataTable(
      headingRowHeight: 17,
      headingRowColor:
          MaterialStateColor.resolveWith((states) => Colors.grey.shade300),
      dataRowHeight: 14,
      columnSpacing: 20,
      columns: [
        DataColumn(
            label: Text(
          "No",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Nama Barang",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Merk",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Jumlah",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Satuan",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Keterangan",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
      ],
      rows: dd
          .map(
            (e) => DataRow(
              color: MaterialStateColor.resolveWith(
                  (states) => Colors.grey.shade100),
              cells: [
                DataCell(
                  Text(
                    '${angka++}',
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    e.nama.toString(),
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    e.merk.toString(),
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    e.newJumlah.toString(),
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    'Unit',
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    e.keterangan.toString(),
                    style: TextStyle(fontSize: 7),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _TblBarangState extends State<TblBarang> {
  Uint8List? img;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    String? jumlah;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Screenshot(
              controller: TblBarang._screenshotController,
              child: TblBarang.buildSc(jumlah!),
            ),
            TextButton(
                onPressed: () async {
                  final sc = await TblBarang._screenshotController
                      .captureFromWidget(TblBarang.buildSc(jumlah));
                  img = sc;
                  print(sc);
                },
                child: Text("Ambil SC")),
            Container(
                width: 200,
                child:
                    img == null ? Container() : Image(image: MemoryImage(img!)))
          ],
        ),
      ),
    );
  }
}
