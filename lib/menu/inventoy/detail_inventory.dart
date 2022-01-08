// import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sipisat/models/inventory_model.dart';
import 'dart:ui' as ui;

// ignore: must_be_immutable
class DetailInventory extends StatefulWidget {
  DetailInventory({
    required this.render,
    required this.index,
    required this.isUser,
    Key? key,
  }) : super(key: key);

  List<Invetory> render = [];
  int index;
  bool? isUser;

  @override
  _DetailInventoryState createState() => _DetailInventoryState();
}

class _DetailInventoryState extends State<DetailInventory> {
  RenderRepaintBoundary? boundary;
  GlobalKey gl = GlobalKey();
  GlobalKey gl2 = GlobalKey();
  var dw = false;
  @override
  Widget build(BuildContext context) {
    // print(widget.render!);
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        title: Text('Detail Inventaris'),
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
        margin: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                RepaintBoundary(
                  key: gl2,
                  child: Image(
                    width: MediaQuery.of(context).size.width * .7,
                    height: MediaQuery.of(context).size.width * .5,
                    fit: BoxFit.fill,
                    repeat: ImageRepeat.noRepeat,
                    image: NetworkImage(
                      // 'https://selular.id/wp-content/uploads/2021/05/m1-mac-mini-angle-100867263-orig-5.jpg'
                      widget.render[widget.index].pathPhoto,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID Inventaris',
                              style: keyStyle,
                            ),
                            Text(
                              widget.render[widget.index].idInventory,
                              style: valueStyle,
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            print(
                                'akan mendownload qr dengan id ${widget.render[widget.index].idInventory}');
                            showModalBottomSheet(
                                context: context,
                                builder: (_) => Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        RepaintBoundary(
                                          key: gl,
                                          child: QrImage(
                                            data: widget.render[widget.index]
                                                .idInventory,
                                            size: 350,
                                            backgroundColor: Colors.white,
                                          ),
                                        ),
                                        TextButton(
                                            onPressed: () async {
                                              final status = await Permission
                                                  .storage.status;
                                              if (!status.isGranted) {
                                                await Permission.storage
                                                    .request();
                                              }

                                              boundary = gl.currentContext!
                                                      .findRenderObject()
                                                  as RenderRepaintBoundary?;
                                              ui.Image image =
                                                  await boundary!.toImage();
                                              ByteData? byteData =
                                                  await image.toByteData(
                                                      format: ui
                                                          .ImageByteFormat.png);
                                              Uint8List qr = byteData!.buffer
                                                  .asUint8List();
                                              final result =
                                                  await ImageGallerySaver.saveImage(
                                                      qr,
                                                      name:
                                                          'Qr_${widget.render[widget.index].idInventory}',
                                                      quality: 100);
                                              setState(() {
                                                dw = false;
                                              });
                                              final isSuccess =
                                                  result['isSuccess'];
                                              if (isSuccess) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Berhasil download qr')));
                                              }
                                            },
                                            child: Text("Download")),
                                      ],
                                    ));
                          },
                          child: QrImage(
                            data: widget.render[widget.index].idInventory,
                            size: 70,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Nama',
                      style: keyStyle,
                    ),
                    Text(
                      widget.render[widget.index].nama.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Merk',
                      style: keyStyle,
                    ),
                    Text(
                      widget.render[widget.index].merk,
                      style: valueStyle,
                    ),
                    Text(
                      'Kategori',
                      style: keyStyle,
                    ),
                    Text(
                      widget.render[widget.index].kategory,
                      style: valueStyle,
                    ),
                    if (widget.render[widget.index].model != 'null')
                      Text(
                        'Model',
                        style: keyStyle,
                      ),
                    if (widget.render[widget.index].model != 'null')
                      Text(
                        widget.render[widget.index].model,
                        style: valueStyle,
                      ),
                    if (widget.render[widget.index].sn != 'null')
                      Text(
                        'SN',
                        style: keyStyle,
                      ),
                    if (widget.render[widget.index].sn != 'null')
                      Text(
                        widget.render[widget.index].sn,
                        style: valueStyle,
                      ),
                    if (widget.render[widget.index].subKategory != 'null')
                      Text(
                        'Sub Kategory',
                        style: keyStyle,
                      ),
                    if (widget.render[widget.index].subKategory != 'null')
                      Text(
                        widget.render[widget.index].subKategory,
                        style: valueStyle,
                      ),
                    if (widget.isUser == false)
                      Text(
                        'Jumlah',
                        style: keyStyle,
                      ),
                    if (widget.isUser == false)
                      Text(
                        widget.render[widget.index].jumlah.toString(),
                        style: valueStyle,
                      ),
                    Text(
                      'Keterangan',
                      style: keyStyle,
                    ),
                    Text(
                      widget.render[widget.index].keterangan,
                      style: valueStyle,
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

  TextStyle valueStyle = TextStyle(fontSize: 20, height: 1.3);

  TextStyle keyStyle = TextStyle(color: Colors.grey, fontSize: 17, height: 1.3);
}
