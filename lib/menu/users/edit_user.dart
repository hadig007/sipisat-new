import 'package:flutter/material.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/menu/users/all_users.dart';
import 'package:http/http.dart' as http;

import '../../common.dart';

class EditUser extends StatefulWidget {
  const EditUser({
    Key? key,
    required this.nama,
    required this.kontak,
    required this.alamat,
    required this.jabatan,
    required this.id,
    required this.password,
  }) : super(key: key);

  final String nama;
  final String kontak;
  final String jabatan;
  final String alamat;
  final String id;
  final String password;

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  void dataUser() {
    print(
        'edit - data yang diambil ${widget.nama} - ${widget.kontak} - ${widget.alamat} - ${widget.jabatan}');
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _name = TextEditingController(text: widget.nama);
    TextEditingController _kontak = TextEditingController(text: widget.kontak);
    TextEditingController _jabatan =
        TextEditingController(text: widget.jabatan);
    TextEditingController _alamat = TextEditingController(text: widget.alamat);
    TextEditingController _password =
        TextEditingController(text: widget.password);
    dataUser();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text('Edit'),
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
          margin:
              EdgeInsets.symmetric(horizontal: 20, vertical: size.height * .2),
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
                    actType: TextInputAction.next,
                    obsText: false,
                  ),
                  BuildInput(
                    keyName: 'Sandi Baru',
                    controllers: _password,
                    actType: TextInputAction.done,
                    obsText: true,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      print(
                          'hasil inputan ->${widget.id} - ${widget.password} - ${_name.text} - ${_kontak.text} - ${_jabatan.text} - ${_alamat.text}- ${_password.text}');
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
                            Uri.parse(
                                CommonUser.baseUrl + '/edit_user/${widget.id}'),
                            body: ({
                              'nama': _name.text,
                              'kontak': _kontak.text,
                              'jabatan': _jabatan.text,
                              'alamat': _alamat.text,
                              'password': widget.password,
                            }));
                        if (response.statusCode == 200) {
                          print('berhasil update data user');
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => AllUser()));
                        } else {
                          print('gagal update data user');
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
    );
  }
}
