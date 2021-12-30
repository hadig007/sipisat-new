import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfApiPnd {
  static File? pdfA;
  static Future<File> generatorSurat(
    String idSurat,
    String nama,
    String instansi,
    String alamat,
    String kontak,
    String admin,
    Uint8List sign1,
    Uint8List sign2,
    Uint8List tabel,
    DateTime pinjam,
    DateTime kembali,
  ) async {
    print("masuk ke pdf view");

    var tahun = DateFormat('y').format(DateTime.now());
    var bulan = DateFormat('LLLL').format(DateTime.now());
    var tanggal = DateFormat('d').format(DateTime.now());
    var hari = DateFormat('EEEE').format(DateTime.now());

    // String formattedDate = DateFormat('mm:ss').format(DateTime.now());
    var bulanPinjam = DateFormat('LLLL').format(pinjam);
    var bulanKembali = DateFormat('LLLL').format(kembali);

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
        bulan = "Januari";
        bulanPinjam = "Januari";
      } else if (bulan == 'February') {
        bulan = "Februari";
        bulanPinjam = "Februari";
      } else if (bulan == 'March') {
        bulan = "Maret";
        bulanPinjam = "Maret";
      } else if (bulan == 'April') {
        bulan = "April";
        bulanPinjam = "April";
      } else if (bulan == 'May') {
        bulan = "Mei";
        bulanPinjam = "Mei";
      } else if (bulan == 'June') {
        bulan = "Juni";
        bulanPinjam = "Juni";
      } else if (bulan == 'July') {
        bulan = "Juli";
        bulanPinjam = "Juli";
      } else if (bulan == 'August') {
        bulan = "Agustus";
        bulanPinjam = "Agustus";
      } else if (bulan == 'September') {
        bulan = "September";
        bulanPinjam = "September";
      } else if (bulan == 'October') {
        bulan = "Oktober";
        bulanPinjam = "Oktober";
      } else if (bulan == 'November') {
        bulan = "November";
        bulanPinjam = "November";
      } else if (bulan == 'December' || bulanPinjam == 12.toString()) {
        bulan = "Desember";
        bulanPinjam = "Desember";
      } else {
        bulan = "Nama bulan tidak ditemukan";
        bulanPinjam = "Nama bulan tidak ditemukan";
      }
    }
    final pdf = Document();
    final imagejg =
        (await rootBundle.load('assets/images/logo.jpg')).buffer.asUint8List();
    // final ttd =
    //     (await rootBundle.load('assets/images/ttd.png')).buffer.asUint8List();

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
                  style: TextStyle(),
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Telepon : (0635) 510810 - 510655 Faks : (0635) 510001",
                  style: TextStyle(),
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
                "SURAT PEMINJAMAN",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ]),
            SizedBox(height: 30),
            // form nama2 kedua pihak
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // SizedBox(width: 10),
                      // key
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nama", style: TextStyle()),
                          Text("Instansi", style: TextStyle()),
                          Text("Alamat", style: TextStyle()),
                          Text("Nomor Handphone", style: TextStyle()),
                        ],
                      ),
                      SizedBox(width: 30),
                      ////////////////////////////////////////
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(": ${nama.toUpperCase()}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          Text(": $instansi", style: TextStyle()),
                          Text(": $alamat", style: TextStyle()),
                          Text(": $kontak", style: TextStyle()),
                        ],
                      ),
                      // value
                    ],
                  ),
                  SizedBox(height: 20),
                  //tanggal
                  Row(children: [
                    Container(
                        width: 130,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Tanggal Peminjaman", style: TextStyle()),
                              Text("Tanggal Pengembalian", style: TextStyle()),
                            ])),
                    Container(
                        // width: ,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(": ${pinjam.day} $bulanPinjam ${pinjam.year} ",
                              style: TextStyle()),
                          Text(
                              ": ${kembali.day} $bulanKembali ${kembali.year} ",
                              style: TextStyle()),
                        ])),
                  ]),
                  SizedBox(height: 20),
                  Column(children: [
                    Text(
                      "       Sehubungan dengan telah dilakukannya peminjaman barang oleh pihak yang bersangkutan, diharapkan barang yang telah dipinjam dikembalikan dengan kondisi yang baik. Adapun rincian barang yang telah dipinjam, yaitu:",
                      style: TextStyle(),
                    ),
                  ]),
                  SizedBox(height: 20),
                  Image(MemoryImage(tabel)),
                  SizedBox(height: 20),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('CATATAN : ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Barang-barang yang dipinjamkan ',
                                children: [
                                  TextSpan(
                                      text: 'Wajib ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text:
                                          'dikembalikan dengan kondisi sebelumnya.',
                                      style: TextStyle()),
                                ]),
                          ),
                          Text(
                              'Kerusakan atau kehilangan barang-barang yang dipinjamkan akan diganti dengan'),
                          Text('waktu yang secepatnya')
                        ])
                  ]),

                  SizedBox(height: 20),
                  // tanda tangan pihak pihak
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // pihak 1
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Pihak Peminjam",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                constraints:
                                    BoxConstraints(minHeight: 60, minWidth: 30),
                                child: Image(MemoryImage(sign1),
                                    width: 50, height: 50),
                              ),
                              Text("${nama.toUpperCase()}",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                        // pihak 2
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Gunung Tua, $tanggal, $bulan, $tahun ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("Telah Diverifikasi dan Disetujui",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Container(
                                constraints:
                                    BoxConstraints(minHeight: 60, minWidth: 30),
                                child: Image(MemoryImage(sign2),
                                    width: 50, height: 50),
                              ),
                              Text("${admin.toUpperCase()}",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                      ]),
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
