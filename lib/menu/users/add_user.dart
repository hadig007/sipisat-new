import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sipisat/common.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/menu/users/all_users.dart';
import 'package:http/http.dart' as http;
import 'package:sipisat/models/users_model.dart';

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController _name = TextEditingController();
  TextEditingController _kontak = TextEditingController();
  TextEditingController _jabatan = TextEditingController();
  TextEditingController _alamat = TextEditingController();
  TextEditingController _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.lightBlue.shade300,
        appBar: AppBar(
          title: Text('Tambah Pengguna'),
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
        body: SingleChildScrollView(
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
                      keyName: 'Kontak',
                      controllers: _kontak,
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
                    BuildInput(
                      keyName: 'Sandi',
                      controllers: _password,
                      actType: TextInputAction.done,
                      obsText: false,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        print(
                            'hasil inputan ->${_name.text} - ${_kontak.text} - ${_jabatan.text} - ${_alamat.text}- ${_password.text}');
                        final n = num.tryParse(_kontak.text);
                        if (_name.text == '' ||
                            _kontak.text == '' ||
                            _jabatan.text == '' ||
                            n == null ||
                            _alamat.text == '' ||
                            _password.text == '' ||
                            _password.text.length < 6) {
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
                              Uri.parse(CommonUser.baseUrl + '/store_user'),
                              body: ({
                                'nama': _name.text,
                                'kontak': _kontak.text,
                                'jabatan': _jabatan.text,
                                'alamat': _alamat.text,
                                'password': _password.text,
                              }));
                          if (response.statusCode == 200) {
                            var res = jsonDecode(response.body);
                            var idss = res['data']['id'];
                            print('berhasil kirim data user baru');
                            UserModel.tambahUser(
                                idss.toString(),
                                _name.text,
                                _kontak.text,
                                _jabatan.text,
                                _alamat.text,
                                _password.text, () {
                              setState(() {});
                            });
                            Navigator.pop(context);
                          } else {
                            print('gagal mengirim data user baru');
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
                                    ));
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
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
