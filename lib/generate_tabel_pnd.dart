import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:sipisat/models/inventory_model.dart';

// ignore: must_be_immutable
class TblBarangPnd extends StatefulWidget {
  static List<Invetory> dd = [];
  //  method menggenerate tabel menjadi png
  static Future<Uint8List> dataBarang(List<Invetory> dataBarang, String jumlah,
      String kelengkapan, String kondisi) async {
    dd = dataBarang;
    final sc = await _screenshotController
        .captureFromWidget(buildSc(jumlah, kelengkapan, kondisi));
    return sc;
  }

  static int angka = 0;
  static ScreenshotController _screenshotController = ScreenshotController();
  @override
  _TblBarangPndState createState() => _TblBarangPndState();

  // method untuk generate tabel
  static DataTable buildSc(String jumlah, String kelengkapan, String kondisi) {
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
          "Nama",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Kategory",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "SN",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Kelengkapan",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Kondisi",
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          "Jumlah",
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
                    e.kategory.toString(),
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    e.sn!,
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    kelengkapan,
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    kondisi,
                    style: TextStyle(fontSize: 7),
                  ),
                ),
                DataCell(
                  Text(
                    jumlah.toString(),
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

class _TblBarangPndState extends State<TblBarangPnd> {
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
    String? kondisi;
    String? kelengpakan;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Screenshot(
              controller: TblBarangPnd._screenshotController,
              child: TblBarangPnd.buildSc(jumlah!, kelengpakan!, kondisi!),
            ),
            TextButton(
                onPressed: () async {
                  final sc = await TblBarangPnd._screenshotController
                      .captureFromWidget(
                          TblBarangPnd.buildSc(jumlah, kelengpakan, kondisi));
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
