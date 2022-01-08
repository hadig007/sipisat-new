import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static File? pdfA;
  static Future<File> generatorSurat(
    String idSurat,
    String nomorSurat,
    String nama1,
    String nip1,
    String jabatan1,
    String alamat1,
    String nama2,
    String nip2,
    String jabatan2,
    String alamat2,
    Uint8List sign1,
    Uint8List sign2,
    // List data,
    Uint8List tabel,
  ) async {
    print("masuk ke pdf view");

    var tahun = DateFormat('y').format(DateTime.now());
    var bulan = DateFormat('LLLL').format(DateTime.now());
    var tanggal = DateFormat('d').format(DateTime.now());
    var hari = DateFormat('EEEE').format(DateTime.now());

    // String formattedDate = DateFormat('mm:ss').format(DateTime.now());

    // ignore: unnecessary_null_comparison
    if (hari != null) {
      if (hari == 'Sunday') {
        hari = "Minggu";
      } else if (hari == "Monday") {
        hari = "Senin";
      } else if (hari == "Tuesday") {
        hari = "Selasa";
      } else if (hari == "Wednesday") {
        hari = "Rabu";
      } else if (hari == "Thursday") {
        hari = "Kamis";
      } else if (hari == "Friday") {
        hari = "Jumat";
      } else if (hari == "Saturday") {
        hari = "Sabtu";
      } else {
        hari = "Nama hari tidak ditemukan";
      }
    }
    // ignore: unnecessary_null_comparison
    if (bulan != null) {
      if (bulan == 'January') {
        bulan = "January";
      } else if (bulan == 'February') {
        bulan = "Februari";
      } else if (bulan == 'March') {
        bulan = "Maret";
      } else if (bulan == 'April') {
        bulan = "April";
      } else if (bulan == 'May') {
        bulan = "Mei";
      } else if (bulan == 'June') {
        bulan = "Juni";
      } else if (bulan == 'July') {
        bulan = "Juli";
      } else if (bulan == 'August') {
        bulan = "Agustus";
      } else if (bulan == 'September') {
        bulan = "September";
      } else if (bulan == 'October') {
        bulan = "Oktober";
      } else if (bulan == 'November') {
        bulan = "November";
      } else if (bulan == 'December') {
        bulan = "Desember";
      } else {
        bulan = "Nama bulan tidak ditemukan";
      }
    }
    final pdf = Document();
    final imagejg =
        (await rootBundle.load('assets/images/logo.jpg')).buffer.asUint8List();
    final ttd =
        (await rootBundle.load('assets/images/ttd.png')).buffer.asUint8List();

    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.legal,
        margin: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        clip: true,
        build: (context) => Column(
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Image(MemoryImage(imagejg), width: 60),
              SizedBox(width: 10),
              Column(children: [
                Text(
                  "PEMERINTAH KABUPATEN PADANG LAWAS UTARA",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "SEKRETARIAT DAERAH KABUPATEN",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "JL. Gunungtua-Padangsidimpuan Km 3.5 Gunungtua Kode Pos : 22753",
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Telepon : (0635) 510810 - 510655 Faks : (0635) 510001",
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ])
            ]),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 10),
              child: Divider(height: 2),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text(
                "BERITA ACARA SERAH TERIMA BARANG",
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
                textAlign: TextAlign.center,
              ),
              Text(
                "Nomor : 020 / $nomorSurat / 2021",
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ]),
            SizedBox(height: 10),
            // form nama2 kedua pihak
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                      "Pada Hari ini $hari  $tanggal $bulan $tahun, kami yang bertanda tangan di bawah ini",
                      style: TextStyle(
                        fontSize: 10,
                      )),
                  SizedBox(height: 5),
                  //pihak pertama
                  Row(
                    children: [
                      Text(
                        "1",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 10),
                      // key
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nama",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text("NIP",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text("Pekerjaan",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text("Alamat",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(": ${nama1.toUpperCase()}",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                          Text(": $nip1",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text(": $jabatan1",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text(": $alamat1",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                      // value
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 10),
                    child: Text(
                        "Dalam hal ini disebut sebagai : _______ pihak pertama",
                        style: TextStyle(
                          fontSize: 10,
                        )),
                  ),
                  //pihak kedua
                  Row(
                    children: [
                      Text(
                        "2",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 10),
                      // key
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nama",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text("NIP",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text("Pekerjaan",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text("Alamat",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(": ${nama2.toUpperCase()}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              )),
                          Text(": $nip2",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text(": $jabatan2",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                          Text(": $alamat2",
                              style: TextStyle(
                                fontSize: 10,
                              )),
                        ],
                      ),
                      // value
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                        "Dalam hal ini disebut sebagai : _______ pihak kedua",
                        style: TextStyle(
                          fontSize: 10,
                        )),
                  ),
                  SizedBox(height: 20),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Pasal 1",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10)),
                        Text(
                          "Pihak Pertama telah menyerahkan kepada Pihak Kedua Barang-barang tersebut berikut :",
                          style: TextStyle(fontSize: 10),
                        ),
                      ]),
                  SizedBox(height: 20),
                  Image(MemoryImage(tabel)),

                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pihak Kedua telah menerima dari Pihak Pertama pada Pasal 1 diatas dalam keadaan baik dan lengkap",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Demikian Berita Acara Serah Terima ini diperbuat dalam rangkap 2 (dua) untuk dapat dipergunakan seperlunya",
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // tanda tangan pihak pihak
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // pihak 1
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("PIHAK PERTAMA",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("YANG MENYERAHKAN",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                constraints:
                                    BoxConstraints(minHeight: 60, minWidth: 30),
                                child: Image(MemoryImage(sign1),
                                    width: 50, height: 50),
                              ),
                              Text("${nama1.toUpperCase()}",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("NIP. $nip1",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                        // pihak 2
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("PIHAK KEDUA",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("YANG MENERIMA",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                constraints:
                                    BoxConstraints(minHeight: 60, minWidth: 30),
                                child: Image(MemoryImage(sign2),
                                    width: 50, height: 50),
                              ),
                              Text("${nama2.toUpperCase()}",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("NIP. $nip2",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                      ]),
                  SizedBox(height: 20),
                  // tanda tangan sekda
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    // pihak 2
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("MENGETAHUI",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("KEPALA BAGIAN UMUM",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Image(MemoryImage(ttd), width: 40),
                          Text("MASJUNI SIREGAR",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("NIP : 19751203 201001 2 009",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                  ])
                ],
              ),
            )
          ],
        ),
      ),
    );
    return saveDocument(name: "surat_$idSurat.pdf", pdf: pdf);
  }

  static Future<File> saveDocument(
      {required String name, required Document pdf}) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);
    pdfA = file;

    return file;
  }
}
