import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sipisat/common.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/menu/users/add_user.dart';
import 'package:sipisat/models/log_models.dart';
import 'package:sipisat/models/users_model.dart';

class AllUser extends StatefulWidget {
  const AllUser({Key? key}) : super(key: key);

  static List<UserModel>? allUser;
  @override
  _AllUserState createState() => _AllUserState();
}

class _AllUserState extends State<AllUser> {
  List<UserModel> users = UserModel.allUser;

  var isLoading = true;
  var num = 1;
  void ambilData() async {
    users = UserModel.allUser;
    if (users.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade300,
      floatingActionButton: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddUser()));
          },
          child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.pinkAccent),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ))),
      appBar: AppBar(
        title: Text('Semua Pengguna'),
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                users = await UserModel.getData();
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: size.height * .1,
                    left: 20,
                    right: 20,
                    bottom: size.height * .1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            if (num > users.length) {
                              num = 1;
                            }
                            TextEditingController _name =
                                TextEditingController(text: users[index].nama);
                            TextEditingController _kontak =
                                TextEditingController(
                                    text: users[index].kontak);
                            TextEditingController _jabatan =
                                TextEditingController(
                                    text: users[index].jabatan);
                            TextEditingController _alamat =
                                TextEditingController(
                                    text: users[index].alamat);
                            TextEditingController _password =
                                TextEditingController(
                                    text: users[index].password);

                            return ListTile(
                                leading: Chip(
                                  label: InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) => detailUser(index));
                                    },
                                    child: Text(
                                      '${num++}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  backgroundColor: Colors.lightBlue,
                                ),
                                title: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => detailUser(index));
                                  },
                                  child: Text(
                                    users[index].nama.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                subtitle: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (_) => detailUser(index));
                                  },
                                  child: Text(
                                    users[index].jabatan,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text("Edit Pengguna"),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          BuildInput(
                                                            keyName: 'Nama',
                                                            controllers: _name,
                                                            actType:
                                                                TextInputAction
                                                                    .next,
                                                            obsText: false,
                                                          ),
                                                          BuildInput(
                                                            keyName: 'Kontak',
                                                            controllers:
                                                                _kontak,
                                                            kyType:
                                                                TextInputType
                                                                    .number,
                                                            actType:
                                                                TextInputAction
                                                                    .next,
                                                            obsText: false,
                                                          ),
                                                          BuildInput(
                                                            keyName: 'Jabatan',
                                                            controllers:
                                                                _jabatan,
                                                            actType:
                                                                TextInputAction
                                                                    .next,
                                                            obsText: false,
                                                          ),
                                                          BuildInput(
                                                            keyName: 'Alamat',
                                                            controllers:
                                                                _alamat,
                                                            actType:
                                                                TextInputAction
                                                                    .next,
                                                            obsText: false,
                                                          ),
                                                          BuildInput(
                                                            keyName:
                                                                'Sandi Baru',
                                                            controllers:
                                                                _password,
                                                            actType:
                                                                TextInputAction
                                                                    .done,
                                                            obsText: true,
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        'Batal',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )),
                                                  TextButton(
                                                      onPressed: () async {
                                                        //////
                                                        // print(
                                                        //     'hasil inputan ->${widget.id} - ${widget.password} - ${_name.text} - ${_kontak.text} - ${_jabatan.text} - ${_alamat.text}- ${_password.text}');
                                                        final n = int.tryParse(
                                                            _kontak.text);
                                                        if (_name.text == '' ||
                                                            _kontak.text ==
                                                                '' ||
                                                            _jabatan.text ==
                                                                '' ||
                                                            n == null ||
                                                            _alamat.text ==
                                                                '' ||
                                                            _password.text ==
                                                                '' ||
                                                            _password.text
                                                                    .length <
                                                                6) {
                                                          showDialog(
                                                              context: context,
                                                              builder: (_) =>
                                                                  AlertDialog(
                                                                    title: Text(
                                                                        'GAGAL!'),
                                                                    content: Text(
                                                                        'Gagal, mohon pastikan inputan anda sudah sesuai'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text('Oke'))
                                                                    ],
                                                                  ));
                                                        } else {
                                                          var response = await http.post(
                                                              Uri.parse(CommonUser
                                                                      .baseUrl +
                                                                  '/edit_user/${users[index].id}'),
                                                              body: ({
                                                                'nama':
                                                                    _name.text,
                                                                'kontak':
                                                                    _kontak
                                                                        .text,
                                                                'jabatan':
                                                                    _jabatan
                                                                        .text,
                                                                'alamat':
                                                                    _alamat
                                                                        .text,
                                                                'password':
                                                                    _password
                                                                        .text,
                                                              }));
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            print(
                                                                'berhasil update data user');
                                                            UserModel.editUser(
                                                                users[index].id,
                                                                _name.text,
                                                                _kontak.text,
                                                                _jabatan.text,
                                                                _alamat.text,
                                                                _password.text,
                                                                () {
                                                              setState(() {});
                                                            });
                                                            LogModel.sendLog(
                                                                'id',
                                                                'edit user',
                                                                'null',
                                                                'anda mengedit data pengguna ${_name.text}');
                                                            Navigator.pop(
                                                                context);
                                                          } else {
                                                            Navigator.pop(
                                                                context);
                                                            print(
                                                                'gagal update data user ${response.statusCode} - ${users[index].id}');
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Gagal edit user, coba lagi nanti")));
                                                          }
                                                        }
                                                        //////
                                                      },
                                                      child: Text(
                                                        'Simpan',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ))
                                                ],
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.lightBlue,
                                          )),
                                      IconButton(
                                          onPressed: () async {
                                            showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      title: Text('Yakin?'),
                                                      content: Text(
                                                          "Anda yakin untuk menghapus user."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context, false);
                                                          },
                                                          child: Text(
                                                            "Batal",
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            print(
                                                                'akan mengapus user dengan id -> ${users[index].id}');
                                                            var response = await http
                                                                .get(Uri.parse(
                                                                    CommonUser
                                                                            .baseUrl +
                                                                        '/delete_user/${users[index].id}'));
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              var res =
                                                                  jsonDecode(
                                                                      response
                                                                          .body);
                                                              print(
                                                                  'berhasil menghapus data user -> $res');
                                                              LogModel.sendLog(
                                                                'id',
                                                                'delete user',
                                                                'null',
                                                                'anda menghapus ${users[index].nama} dari data pengguna',
                                                              );
                                                              setState(() {
                                                                users.removeAt(
                                                                    index);
                                                              });
                                                            } else {
                                                              print(
                                                                  'gagal menghapus data user');
                                                            }
                                                            Navigator.pop(
                                                                context, false);
                                                          },
                                                          child: Text(
                                                            "Yakin",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ),
                                                        ),
                                                      ],
                                                    ));
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ))
                                    ]));
                          },
                          itemCount: users.length,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  AlertDialog detailUser(int index) {
    return AlertDialog(
      title: Text(
        'Detail Pengguna',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Divider(),
              Text(
                "Nama",
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 2),
              ),
              Text(
                users[index].nama.toUpperCase(),
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Nomor Hp/Kontak",
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 2),
              ),
              Text(
                users[index].kontak,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Jabatan",
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 2),
              ),
              Text(
                users[index].jabatan,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "Alamat",
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 2),
              ),
              Text(
                users[index].alamat,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Oke'))
      ],
    );
  }
}
