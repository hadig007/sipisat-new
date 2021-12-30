import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/menu/staff/all_staff.dart';
import 'package:http/http.dart' as http;
import 'package:sipisat/models/log_models.dart';
import 'package:sipisat/models/staff_model.dart';

import '../../common.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({Key? key}) : super(key: key);

  @override
  _AddStaffState createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  TextEditingController _name = TextEditingController();
  TextEditingController _nip = TextEditingController();
  TextEditingController _jabatan = TextEditingController();
  TextEditingController _alamat = TextEditingController();

  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.lightBlue.shade300,
          appBar: AppBar(
            title: Text('Tambah Staff'),
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
              : SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 20, vertical: size.height * .2),
                    constraints: BoxConstraints(
                      maxHeight: size.height * .8,
                      maxWidth: size.width,
                    ),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BuildInput(
                              keyName: 'Nama',
                              controllers: _name,
                              actType: TextInputAction.next,
                              obsText: false,
                            ),
                            BuildInput(
                              keyName: 'NIP',
                              controllers: _nip,
                              kyType: TextInputType.number,
                              actType: TextInputAction.next,
                              obsText: false,
                            ),
                            BuildInput(
                              keyName: 'Jabatan',
                              controllers: _jabatan,
                              actType: TextInputAction.next,
                              obsText: false,
                            ),
                            BuildInput(
                              keyName: 'Alamat',
                              controllers: _alamat,
                              actType: TextInputAction.done,
                              obsText: false,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            OutlinedButton(
                              onPressed: () async {
                                setState(() {
                                  isLoading = true;
                                });
                                print(
                                    'hasil inputan ->${_name.text} - ${_nip.text} - ${_jabatan.text} - ${_alamat.text}');
                                final n = num.tryParse(_nip.text);
                                if (_name.text == '' ||
                                    _nip.text == '' ||
                                    _jabatan.text == '' ||
                                    n == null ||
                                    _alamat.text == '') {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: Text('GAGAL!'),
                                            content: Text(
                                                'Gagal, mohon pastikan inputan anda sudah sesuai'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Oke'))
                                            ],
                                          ));
                                } else {
                                  var response = await http.post(
                                      Uri.parse(
                                          CommonUser.baseUrl + '/store_staff'),
                                      body: ({
                                        'nama': _name.text,
                                        'nip': _nip.text,
                                        'jabatan': _jabatan.text,
                                        'alamat': _alamat.text,
                                      }));
                                  if (response.statusCode == 200) {
                                    var res = jsonDecode(response.body);
                                    var idss = res['data']['id'];
                                    StaffModel.tambahStaff(
                                        idss.toString(),
                                        _name.text,
                                        _nip.text,
                                        _jabatan.text,
                                        _alamat.text);
                                    print('berhasil kirim data staff baru');
                                    /////////////// add log
                                    LogModel.sendLog(
                                        idss.toString(),
                                        'add staff',
                                        'null',
                                        'anda menambah ${_name.text} sebagai staf baru');

                                    //////////////// navigasi
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AllStaff()));
                                  } else {
                                    print('gagal mengirim data staff baru');
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text("Gagal"),
                                        content: Text(
                                            "Gagal mengirim data, silahkan coba lagi nanti"),
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
                                }
                              },
                              child: Text(
                                "Simpan",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
    );
  }
}
