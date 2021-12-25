import 'package:flutter/material.dart';

class DetailUser extends StatelessWidget {
  const DetailUser({
    Key? key,
    required this.nama,
    required this.kontak,
    required this.alamat,
    required this.jabatan,
  }) : super(key: key);

  final String nama;
  final String kontak;
  final String jabatan;
  final String alamat;

  void dataUser() {
    print('detail - data yang diambil $nama - $kontak - $alamat - $jabatan');
  }

  @override
  Widget build(BuildContext context) {
    dataUser();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text('Detail'),
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
      body: Container(
        width: double.infinity,
        margin:
            EdgeInsets.symmetric(horizontal: 20, vertical: size.height * .1),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'DETAIL PENGGUNA',
                      style: TextStyle(fontSize: 22),
                    ),
                    Divider(),
                    Text(
                      "Nama",
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey, height: 2),
                    ),
                    Text(
                      nama.toUpperCase(),
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      "Nomor Hp/Kontak",
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey, height: 2),
                    ),
                    Text(
                      kontak,
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Jabatan",
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey, height: 2),
                    ),
                    Text(
                      jabatan,
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Alamat",
                      style: TextStyle(
                          fontSize: 15, color: Colors.grey, height: 2),
                    ),
                    Text(
                      alamat,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
