// import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:sipisat/common.dart';
import 'package:sipisat/models/bap_model.dart';
import 'package:sipisat/models/staff_model.dart';
import 'package:url_launcher/url_launcher.dart';

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

  ambilData() async {
    BapModel.ambilData();
    allBap = await BapModel.getData();
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
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.lightBlue.shade300,
        appBar: AppBar(
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
                            phk1.addAll(allStaff.where((element) =>
                                element.id == allBap[index].idPihak1));
                            phk2.addAll(allStaff.where((element) =>
                                element.id == allBap[index].idPihak2));
                            int num = 0;
                            num = num + 1;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Chip(
                                          label: Text(allBap[index].idSurat),
                                          backgroundColor: Colors.orangeAccent,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            print(
                                                'akan memprint pdf dengan nomor surat ${allBap[index].nomorSurat} link ${allBap[index].pdf} - id ${allBap[index].id}');
                                            launch(CommonUser.baseUrl +
                                                '/download_pdf/${allBap[index].id}');
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
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pihak 1",
                                            ),
                                            Text(
                                              "Pihak 2",
                                            ),
                                            Text(
                                              "Nomor Surat",
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                phk1[index].nama.toUpperCase()),
                                            // Text(phk2[index].nama == null
                                            //     ? '-'
                                            //     : phk2[index]
                                            //         .nama
                                            //         .toUpperCase()),
                                            Text(allBap[index].nomorSurat),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: allBap.length,
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
