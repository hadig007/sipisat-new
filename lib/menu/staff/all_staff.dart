import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/models/staff_model.dart';
import 'package:http/http.dart' as http;

import '../../common.dart';

class AllStaff extends StatefulWidget {
  const AllStaff({Key? key}) : super(key: key);

  @override
  _AllStaffState createState() => _AllStaffState();
}

class _AllStaffState extends State<AllStaff> {
  List<StaffModel> staff = [];
  var isLoading = true;
  var num = 1;
  Future<void> ambilData() async {
    staff = await StaffModel.getData();
    if (staff.isNotEmpty) {
      isLoading = false;
      setState(() {});
    }
  }

  void detailStaff(int index) {
    showDialog(
      context: context,
      builder: (_) => DetailStaf(
        staff: staff,
        context: context,
        index: index,
      ),
    );
  }

  void editStaf(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: EditStaff(
          index: index,
          staff: staff,
        ),
      ),
    );
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
      appBar: AppBar(
        title: Text('Semua Staff'),
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
                staff = await StaffModel.getData();
                setState(() {});
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: size.height * .1,
                    left: 20,
                    right: 20,
                    bottom: size.height * .12),
                constraints: BoxConstraints(maxHeight: size.height * .8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            if (num > staff.length) {
                              num = 1;
                            }
                            return ListTile(
                                leading: InkWell(
                                  onTap: () {
                                    detailStaff(index);
                                  },
                                  child: Chip(
                                    label: Text(
                                      '${num++}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.lightBlue,
                                  ),
                                ),
                                title: InkWell(
                                  onTap: () {
                                    detailStaff(index);
                                  },
                                  child: Text(
                                    staff[index].nama.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                subtitle: InkWell(
                                  onTap: () {
                                    detailStaff(index);
                                  },
                                  child: Text(
                                    staff[index].jabatan,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                trailing: Container(
                                  width: 100,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            editStaf(index);
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.lightBlue,
                                          )),
                                      IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: Text("Yakin?"),
                                                content: Text(
                                                    "Apakah anda yakin untuk menghapus."),
                                                actions: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context, false);
                                                          print(
                                                              "batal menghapus");
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
                                                          Navigator.pop(
                                                              context, true);
                                                          print(
                                                              "akan menghapus staff dengan id->${staff[index].id}");
                                                          var response = await http.post(
                                                              Uri.parse(CommonUser
                                                                      .baseUrl +
                                                                  '/delete_staff/${staff[index].id}'));
                                                          if (response
                                                                  .statusCode ==
                                                              200) {
                                                            var res =
                                                                jsonDecode(
                                                                    response
                                                                        .body);
                                                            print(
                                                                "berhasil menghapus data staff -> $res");
                                                            setState(() {
                                                              staff.removeAt(
                                                                  index);
                                                            });
                                                          } else {
                                                            print(
                                                                "berhasil menghapus data staff");
                                                          }
                                                        },
                                                        child: Text(
                                                          "Yakin",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.green),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ))
                                    ],
                                  ),
                                ));
                          },
                          itemCount: staff.length,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

class DetailStaf extends StatelessWidget {
  const DetailStaf({
    Key? key,
    required this.staff,
    required this.context,
    required this.index,
  }) : super(key: key);

  final List<StaffModel> staff;
  final BuildContext context;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [Text("Detail Staf".toUpperCase()), Divider()],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Nama",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          Text(
            staff[index].nama.toUpperCase(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            "NIP",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          Text(
            staff[index].nip,
            style: TextStyle(
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "Jabatan",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            staff[index].jabatan,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Text(
            "Alamat",
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            staff[index].alamat,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Oke'))
      ],
    );
  }
}

// ignore: must_be_immutable
class EditStaff extends StatefulWidget {
  EditStaff({Key? key, required this.index, required this.staff})
      : super(key: key);

  List<StaffModel> staff = [];
  final int index;

  @override
  _EditStaffState createState() => _EditStaffState();
}

class _EditStaffState extends State<EditStaff> {
  var isGagal = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    TextEditingController _name =
        TextEditingController(text: widget.staff[widget.index].nama);
    TextEditingController _nip =
        TextEditingController(text: widget.staff[widget.index].nip);
    TextEditingController _jabatan =
        TextEditingController(text: widget.staff[widget.index].jabatan);
    TextEditingController _alamat =
        TextEditingController(text: widget.staff[widget.index].alamat);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Ubah Data Staf".toUpperCase(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BuildInput(keyName: 'Nama', controllers: _name, obsText: false),
              BuildInput(keyName: 'NIP', controllers: _nip, obsText: false),
              BuildInput(
                  keyName: 'Jabatan', controllers: _jabatan, obsText: false),
              BuildInput(
                  keyName: 'Alamat', controllers: _alamat, obsText: false),
              isGagal
                  ? SizedBox(
                      height: 10,
                    )
                  : SizedBox(),
              isGagal
                  ? Row(
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 20,
                        ),
                        Text(
                          '  Gagal, Mohon Periksa inputan anda!',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                print(
                    'hasil inputan data staff untuk edit->${_name.text} - ${_nip.text} - ${_jabatan.text} - ${_alamat.text}');
                final n = num.tryParse(_nip.text);
                if (_name.text == '' ||
                    _nip.text == '' ||
                    _jabatan.text == '' ||
                    n == null ||
                    _alamat.text == '') {
                  setState(() {
                    isGagal = true;
                  });
                } else {
                  var response = await http.post(
                      Uri.parse(CommonUser.baseUrl +
                          '/edit_staff/${widget.staff[widget.index].id}'),
                      body: ({
                        'nama': _name.text,
                        'nip': _nip.text,
                        'jabatan': _jabatan.text,
                        'alamat': _alamat.text,
                      }));
                  if (response.statusCode == 200) {
                    print(response.statusCode);
                    print('berhasil mengupdate data staff');
                    setState(() {
                      widget.staff[widget.index].nama = _name.text;
                      widget.staff[widget.index].nip = _nip.text;
                      widget.staff[widget.index].jabatan = _jabatan.text;
                      widget.staff[widget.index].alamat = _alamat.text;
                    });
                    Navigator.pop(context);
                  } else {
                    print('gagal mengupdate data staff');
                  }
                }
              },
              child: Text(
                'Simpan',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        )
      ],
    );
  }
}
