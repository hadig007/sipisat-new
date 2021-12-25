import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';
// import 'package:pdf/widgets.dart';

// ignore: must_be_immutable
class PdfView extends StatelessWidget {
  final File file;
  PdfView({required this.file});

  @override
  Widget build(BuildContext context) {
    final name = basename(file.path);
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Stack(
          children: [
            PDFView(
              filePath: file.path,
            ),
            // Card(
            //   margin: EdgeInsets.only(
            //     top: MediaQuery.of(context).size.height * 0.85,
            //     left: 20,
            //     right: 20,
            //   ),
            //   elevation: 3,
            //   child: Container(
            //     margin: EdgeInsets.symmetric(horizontal: 20),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         TextButton(
            //             onPressed: () {
            //               Navigator.of(context).pop();
            //             },
            //             child: Row(
            //               children: [
            //                 Icon(Icons.arrow_back),
            //                 Text("Kembali"),
            //               ],
            //             )),
            //         SizedBox(width: 50),
            //         TextButton(
            //             onPressed: () {
            //               uploadData!();
            //             },
            //             child: Text("Simpan")),
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
