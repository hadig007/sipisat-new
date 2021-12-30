// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:sipisat/common.dart';
import 'package:sipisat/models/bap_model.dart';
import 'package:sipisat/models/staff_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum Kategory {
  Semua,
  SerahTerima,
  PindahTangan,
  Peminjaman,
}

class AllBAP extends StatefulWidget {
  const AllBAP({Key? key}) : super(key: key);

  @override
  _AllBAPState createState() => _AllBAPState();
}

class _AllBAPState extends State<AllBAP> {
  var isLoading = true;
  var isExpanded = false;
  List<BapModel> allBap = BapModel.baps;
  List<StaffModel> allStaff = StaffModel.allStaf;
  List<StaffModel> phk1 = [];
  List<StaffModel> phk2 = [];

  // kategory bap
  List<BapModel> semua = [];
  List<BapModel> serahTerima = [];
  List<BapModel> pindahTangan = [];
  List<BapModel> peminjaman = [];

  List<BapModel>? render;

  ambilData() async {
    BapModel.ambilData();
    allBap = await BapModel.getData();
    semua = allBap;
    serahTerima = allBap.where((element) => element.tag == 'bap').toList();
    pindahTangan = allBap.where((element) => element.tag == 'pindah').toList();
    peminjaman = allBap.where((element) => element.tag == 'pinjam').toList();
    render = allBap;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        actions: [
          PopupMenuButton(
              // icon: Icon(Icons.filter_alt_outlined),
              onSelected: (Kategory kategory) {
                print(kategory);
                if (kategory == Kategory.Semua) {
                  render = semua;
                  setState(() {});
                }
                if (kategory == Kategory.SerahTerima) {
                  render = serahTerima;
                  setState(() {});
                }
                if (kategory == Kategory.PindahTangan) {
                  render = pindahTangan;
                  setState(() {});
                }
                if (kategory == Kategory.Peminjaman) {
                  render = peminjaman;
                  setState(() {});
                }
              },
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text("Semua"),
                      value: Kategory.Semua,
                    ),
                    PopupMenuItem(
                      child: Text("Serah Terima"),
                      value: Kategory.SerahTerima,
                    ),
                    PopupMenuItem(
                      child: Text("Pindah Tangan"),
                      value: Kategory.PindahTangan,
                    ),
                    PopupMenuItem(
                      child: Text("Peminjaman"),
                      value: Kategory.Peminjaman,
                    ),
                  ])
        ],
        title: Text('Semua BAP'),
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
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  allBap = [];
                  BapModel.ambilData();
                  allBap = await BapModel.getData();
                  setState(() {});
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (allBap.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info),
                              Text(' Belum ada data BAP.')
                            ],
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          // phk1.addAll(allStaff.where((element) =>
                          //     element.id == render![index].idPihak1));
                          // phk2.addAll(allStaff.where((element) =>
                          //     element.id == render![index].idPihak2));
                          int num = 0;
                          num = num + 1;
                          return Card(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Chip(
                                        label: Text(render![index].idSurat),
                                        backgroundColor: Colors.orangeAccent,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          print(
                                              'akan memprint pdf dengan nomor surat ${allBap[index].nomorSurat} link ${allBap[index].pdf} - id ${allBap[index].id}');
                                          launch(CommonUser.baseUrl +
                                              '/download_pdf/${render![index].id}');
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.download),
                                            Text(' Download Pdf')
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  // Divider(),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Column(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.start,
                                  //       children: [
                                  //         Text(
                                  //           "Pihak 1",
                                  //         ),
                                  //         Text(
                                  //           "Pihak 2",
                                  //         ),
                                  //         Text(
                                  //           "Nomor Surat",
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     Column(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.end,
                                  //       children: [
                                  //         Text(phk1[index].nama.toUpperCase()),
                                  //         phk2.isEmpty
                                  //             ? Text('-')
                                  //             : Text(phk2[index]
                                  //                 .nama
                                  //                 .toUpperCase()),
                                  //         Text(render![index].nomorSurat),
                                  //       ],
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: render!.length,
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
