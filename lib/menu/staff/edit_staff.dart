import 'package:flutter/material.dart';

class EditStaff extends StatelessWidget {
  const EditStaff({
    Key? key,
    required this.nama,
    required this.nip,
    required this.alamat,
    required this.jabatan,
    required this.id,
  }) : super(key: key);

  final String nama;
  final String nip;
  final String jabatan;
  final String alamat;
  final String id;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
      ),
    );
  }
}
