import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sipisat/common.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/home_app.dart';
import 'package:sipisat/menu/inventoy/all_inventory.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _password = TextEditingController();
  var isLogin = true; // ketika cek token
  var isLoading = false; // ketika tekan tombol login

  cekToken() async {
    setState(() {
      isLogin = true;
    });
    print('cek token');
    SharedPreferences sh = await SharedPreferences.getInstance();
    var id = sh.getString('id');
    final level = sh.getString('level');
    print('login================ token $id level $level =================');
    if (id == null) {
      print('login -  token kosong');

      setState(() {
        isLogin = false;
      });
    } else {
      if (level == 'user') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AllInventory()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => HomeApp()));
      }
    }
  }

  @override
  void initState() {
    cekToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLogin == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Stack(
                children: [
                  // main background
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: size.height,
                      maxWidth: size.width,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.lightBlue.shade200,
                          Colors.lightBlue.shade400
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  // login card
                  Positioned(
                    top: size.height * .35,
                    child: Container(
                      constraints: BoxConstraints(
                          maxHeight: size.height * .4, maxWidth: size.width),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      child: Card(
                        child: isLoading
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Sedang masuk')
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    BuildInput(
                                      controllers: _name,
                                      obsText: false,
                                      hnt: 'Nama',
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    BuildInput(
                                      controllers: _password,
                                      obsText: true,
                                      hnt: 'Sandi',
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          SharedPreferences shr =
                                              await SharedPreferences
                                                  .getInstance();

                                          var response = await http.post(
                                              Uri.parse(CommonUser.baseUrl +
                                                  '/login'),
                                              body: ({
                                                'name': _name.text,
                                                'password': _password.text
                                              }));
                                          if (response.statusCode == 200) {
                                            Map res = jsonDecode(response.body);
                                            print(
                                                'berhasil, selanjutnya memasukkan ke shared preferences');

                                            await shr.setString(
                                                'id', res['token'].toString());
                                            await shr.setString('level',
                                                res['level'].toString());
                                            var id = shr.getString('id');
                                            var level = shr.getString('level');

                                            print(
                                                'berhasil login dengan id $id dan level $level');
                                            if (level == 'admin') {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          HomeApp()));
                                            } else {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          AllInventory()));
                                            }
                                          } else if (response.statusCode >
                                              404) {
                                            print(
                                                'gagal login ${response.statusCode}');
                                            setState(() {
                                              isLoading = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Gagal, coba lagi nanti')));
                                          } else {
                                            print(
                                                'gagal login ${response.statusCode}');
                                            setState(() {
                                              isLoading = false;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'Pengguna tidak ditemukan!')));
                                          }
                                        },
                                        child: Text(
                                          'Masuk',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.pinkAccent,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
