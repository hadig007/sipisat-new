import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sipisat/models/log_models.dart';
import 'package:http/http.dart' as http;

import '../../common.dart';

class Log extends StatefulWidget {
  const Log({Key? key}) : super(key: key);

  @override
  _LogState createState() => _LogState();
}

class _LogState extends State<Log> {
  List<LogModel> logs = [];
  var isloading = true;
  void ambilData() async {
    var response = await http.get(Uri.parse(CommonUser.baseUrl + '/get_logs'));
    if (response.statusCode == 200) {
      print('berhasil ambil semua log');
      var res = jsonDecode(response.body);
      if (logs.length < res['data'].length || logs == []) {
        for (var data in res['data']) {
          logs.insert(
            0,
            LogModel(
              id: data['id'].toString(),
              kegiatan: data['kegiatan'],
              idKegiatan: data['id_kegiatan'],
              waktu: data['waktu'],
              teks: data['teks'],
            ),
          );
          setState(() {
            isloading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Log'),
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
        body: isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    // jika input inventaris
                    // jika membuat bap
                    // jika membuat user
                    // jika membuat staf
                    return Column(
                      children: [
                        ListTile(
                          // trailing: Chip(
                          //   label: Text(logs[index].kegiatan),
                          // ),

                          leading: Chip(
                            label: Text(''),
                            backgroundColor: Colors.green,
                          ),
                          subtitle: Text(logs[index].waktu),
                          title: Text(logs[index].teks),
                        ),
                        Divider()
                      ],
                    );
                  },
                  itemCount: logs.length,
                ),
              ));
  }
}
