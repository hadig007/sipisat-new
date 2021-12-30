import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sipisat/component/textfield.dart';
import 'package:sipisat/models/inventory_model.dart';
import 'package:http/http.dart' as http;
import 'package:sipisat/models/log_models.dart';

import '../../common.dart';

// ignore: must_be_immutable
class EditInventory extends StatefulWidget {
  EditInventory({
    required this.render,
    required this.index,
    Key? key,
  }) : super(key: key);

  List<Invetory>? render;
  int index;
  @override
  _EditInventoryState createState() => _EditInventoryState();
}

class _EditInventoryState extends State<EditInventory> {
  // List<Invetory> widget.render! = Invetory.widget.render!;
  // inputan umum
  TextEditingController _name = TextEditingController();
  TextEditingController _merk = TextEditingController();
  TextEditingController _jumlah = TextEditingController();
  TextEditingController _keterangan = TextEditingController();
  // kategory elektronik
  TextEditingController _model = TextEditingController();
  TextEditingController _sn = TextEditingController();

  List category = ['Elektronik', 'Rumah Tangga', 'Lainnya'];
  List subCategory = ['Komputer', 'Laptop', 'Printer', 'Televisi', 'Lainnya'];

  String? newValue;
  String? newScValues;
  int invId = 111;
  File? photoInventory;

  ambilData() {
    // inputan umum
    _name = TextEditingController(text: widget.render![widget.index].nama);
    _merk = TextEditingController(text: widget.render![widget.index].merk);
    _jumlah = TextEditingController(
        text: widget.render![widget.index].jumlah.toString());
    _keterangan =
        TextEditingController(text: widget.render![widget.index].keterangan);
    // kategory elektronik
    _model = TextEditingController(text: widget.render![widget.index].model);
    _sn = TextEditingController(text: widget.render![widget.index].sn);

    newValue = widget.render![widget.index].kategory;
    // newScValue = widget.render![widget.index].subKategory;
  }

  @override
  void initState() {
    ambilData();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        title: Text('Edit Inventory'),
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
              EdgeInsets.symmetric(horizontal: 20, vertical: size.height * .05),
          constraints: BoxConstraints(
            maxHeight: size.height * .8,
            maxWidth: size.width,
          ),
          child: Card(
            elevation: 5,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                // mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BuildInput(
                    keyName: 'Nama Barang',
                    controllers: _name,
                    actType: TextInputAction.next,
                    obsText: false,
                  ),
                  BuildInput(
                    keyName: 'Merk',
                    controllers: _merk,
                    actType: TextInputAction.next,
                    obsText: false,
                  ),
                  // category
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                          hint: Text('Pilih Category'),
                          isExpanded: true,
                          value: newValue,
                          onChanged: (value) {
                            print(value);
                            this.newValue = value as String?;
                            // if(newValue=='')
                            setState(() {});
                            print('nilai dari pilihanCategory -> $newValue');
                          },
                          items: category
                              .map((e) => DropdownMenuItem(
                                    child: Text(e),
                                    value: e,
                                  ))
                              .toList()),
                    ),
                  ),
                  // if (newValue == 'Elektronik')
                  newValue == 'Elektronik'
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.lightBlue.shade50,
                              borderRadius: BorderRadius.circular(4)),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                BuildInput(
                                    keyName: 'Model',
                                    controllers: _model,
                                    obsText: false),
                                BuildInput(
                                    keyName: 'SN',
                                    controllers: _sn,
                                    kyType: TextInputType.number,
                                    obsText: false),
                                DropdownButton(
                                    onChanged: (value) {
                                      print(
                                          'sub kategory dipilih adalah $newScValues - $value');
                                      setState(() {
                                        this.newScValues = value as String?;
                                      });
                                    },
                                    hint: Text('Pilih '),
                                    isExpanded: true,
                                    value: newScValues,
                                    items: subCategory
                                        .map((e) => DropdownMenuItem(
                                              child: Text(e),
                                              value: e,
                                            ))
                                        .toList())
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                  if (newValue == 'Rumah Tangga')
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(4)),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BuildInput(
                                keyName: 'Model',
                                controllers: _model,
                                obsText: false),
                          ],
                        ),
                      ),
                    ),
                  Divider(),
                  // menu sesuai kategory
                  BuildInput(
                    keyName: 'Jumlah',
                    controllers: _jumlah,
                    kyType: TextInputType.number,
                    actType: TextInputAction.next,
                    obsText: false,
                  ),
                  BuildInput(
                    keyName: 'Keterangan',
                    controllers: _keterangan,
                    actType: TextInputAction.done,
                    kyType: TextInputType.multiline,
                    obsText: false,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final photos = await ImagePicker()
                              .getImage(source: ImageSource.camera);
                          File photo = File(photos!.path);
                          setState(() {
                            photoInventory = photo;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt_outlined),
                            Text(' Buka Kamera')
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final photos = await ImagePicker()
                              .getImage(source: ImageSource.gallery);
                          File photo = File(photos!.path);
                          setState(() {
                            photoInventory = photo;
                          });
                        },
                        child: Row(
                          children: [Icon(Icons.photo), Text(' Buka Galeri')],
                        ),
                      ),
                    ],
                  ),
                  Container(
                      height: 200,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey)),
                      child: photoInventory != null
                          ? Image.file(
                              photoInventory!,
                              fit: BoxFit.cover,
                            )
                          : Image(
                              image: NetworkImage(
                                  widget.render![widget.index].pathPhoto))),
                  SizedBox(
                    height: 10,
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      var rd = new Random();
                      invId += rd.nextInt(999999);
                      invId += rd.nextInt(999999);
                      print(
                        'hasil inputan -> \n id Inventory => $invId \n Nama => ${_name.text} \n Merk => ${_merk.text} \n Jumlah => ${_jumlah.text} \n Keterangan => ${_keterangan.text} \n Model => ${_model.text} \n SN => ${_sn.text} \n Kategori => $newValue \n SubKategory => $newScValues',
                      );
                      final n = num.tryParse(_jumlah.text);
                      if (_name.text == '' ||
                          _merk.text == '' ||
                          _jumlah.text == '' ||
                          newValue == '' ||
                          n == null ||
                          _keterangan.text == '') {
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
                        ////////////////////
                        print('data lengkap otw kirim ke backend');
                        final request = new http.MultipartRequest(
                            'POST',
                            Uri.parse(CommonUser.baseUrl +
                                '/edit_inv/${widget.render![widget.index].id}'));
                        request.headers
                            .addAll({'Content-Type': 'multipart/form-data'});
                        request.fields.addAll({
                          'id_surat': 'null',
                          'status': 'baru masuk',
                          'id_pemilik': 'null',
                          'id_inventory': invId.toString(),
                          'nama': _name.text,
                          'merk': _merk.text,
                          'jumlah': _jumlah.text,
                          'new_jumlah': 'null',
                          'keterangan': _keterangan.text,
                          'model': _model.text.isEmpty ? 'null' : _model.text,
                          'sn': _sn.text.isEmpty ? 'null' : _sn.text,
                          'kategory': newValue!,
                          'sub_kategory':
                              newScValues == null ? 'null' : newScValues!,
                        });
                        if (photoInventory != null) {
                          request.files.add(await http.MultipartFile.fromPath(
                              'path_photo', photoInventory!.path));
                        } else {
                          print('mengirim edit tanpa tanpa poto');
                        }
                        //////////
                        var response = await request.send();
                        if (response.statusCode == 200) {
                          print('berhasil kirim data inventory baru');
                          var res = await http.Response.fromStream(response);
                          var re = jsonDecode(res.body);
                          var photo = re['data']['path_photo'];
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Berhasil Edit Inventory"),
                            ),
                          );
                          Invetory.editInv(
                              widget.render![widget.index].id,
                              'null',
                              'baru masuk',
                              invId.toString(),
                              _name.text,
                              _merk.text,
                              _sn.text,
                              _model.text,
                              int.parse(_jumlah.text),
                              _keterangan.text,
                              newValue!,
                              newScValues == null ? 'null' : newScValues!,
                              photo, () {
                            setState(() {});
                          });
                          LogModel.sendLog(
                            'id',
                            'edit inv',
                            invId.toString(),
                            'anda mengedit data inv dengan id ${invId.toString()}',
                          );
                          Navigator.pop(context);
                        } else {
                          print(
                              'gagal mengirim data inventory baru ${response.statusCode}');
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
                        ///////////////////
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
