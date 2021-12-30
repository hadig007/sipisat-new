import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipisat/auth/login.dart';
import 'package:sipisat/common.dart';
import 'package:sipisat/menu/bap/all_bap.dart';
import 'package:sipisat/menu/inventoy/add_inventory.dart';
import 'package:sipisat/models/inventory_model.dart';
import 'package:sipisat/models/log_models.dart';

import 'detail_inventory.dart';
import 'edit_inventory.dart';

class AllInventory extends StatefulWidget {
  const AllInventory({Key? key}) : super(key: key);

  @override
  _AllInventoryState createState() => _AllInventoryState();
}

enum InvStatus {
  Baru,
  Bap,
  Pindah,
  Pinjam,
}

class _AllInventoryState extends State<AllInventory> {
  // var selected = 'Semua';
  var selected;
  var isLoading = true;
  var isElk = false;
  var isUser = false;
  List<Invetory> inventory = [];
  List<Invetory> allInv = [];

  List<Invetory> newInv = [];
  List<Invetory> bapInv = [];
  List<Invetory> pndInv = [];
  List<Invetory> pjmInv = [];

  List<Invetory> allCat = [];
  List<Invetory> elCat = [];
  List<Invetory> rtCat = [];
  List<Invetory> laCat = [];

  List<Invetory> statRender = [];
  List<Invetory> invToRender = [];
  List<Invetory> catToRender = [];

  ambilData() async {
    if (inventory.isEmpty) {
      setState(() {
        isLoading = true;
      });
      //////////
      var response =
          await http.get(Uri.parse(CommonUser.baseUrl + '/get_invs'));
      if (response.statusCode == 200) {
        List datas = jsonDecode(response.body);
        for (var data in datas) {
          if (inventory.length >= datas.length) {
            return;
          } else {
            inventory.insert(
              0,
              Invetory(
                  id: data['id'].toString(),
                  idSurat: data['id_surat'] == null ? 'null' : data['id_surat'],
                  idInventory: data['id_inventory'],
                  status: data['status'],
                  nama: data['nama'],
                  merk: data['merk'],
                  jumlah: data['new_jumlah'] == 'null'
                      ? int.parse(data['jumlah'])
                      : int.parse(data['new_jumlah']),
                  keterangan: data['keterangan'],
                  kategory: data['kategory'],
                  pathPhoto: data['path_photo'],
                  model: data['model'],
                  sn: data['sn'],
                  subKategory: data['sub_kategory']),
            );
          }
        }
      }
      allInv = inventory;
      newInv =
          allInv.where((element) => element.status == 'baru masuk').toList();
      bapInv = allInv.where((element) => element.status == 'bap').toList();
      pndInv =
          allInv.where((element) => element.status == 'pindah tangan').toList();
      pjmInv = allInv.where((element) => element.status == 'pinjam').toList();

      statRender = newInv;

      /////////////////////////
    }
    ///////////
    SharedPreferences sh = await SharedPreferences.getInstance();
    final level = sh.getString('level');
    print("$isUser, $level");
    if (level == 'user') {
      setState(() {
        isUser = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  cekToken() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    final id = sh.getString('id');
    print('allinv========================================== init $id');
    if (id == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    }
    setState(() {});
  }

  @override
  void initState() {
    ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      floatingActionButton: isUser == false
          ? InkWell(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => AddInventory()));
              },
              child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.pinkAccent),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  )))
          : SizedBox(),
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        title: Text('Semua Inventaris'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lightBlue.shade400,
        leading: isUser == false
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            : SizedBox(),
        actions: [
          if (isUser == true)
            IconButton(
                onPressed: () async {
                  SharedPreferences sh = await SharedPreferences.getInstance();
                  sh.clear();
                  cekToken();
                },
                icon: Icon(Icons.logout)),
          if (isUser == false)
            PopupMenuButton(
                onSelected: (InvStatus status) {
                  print(status);
                  if (status == InvStatus.Baru) {
                    statRender = newInv;
                  }
                  if (status == InvStatus.Bap) {
                    statRender = bapInv;
                  }
                  if (status == InvStatus.Pindah) {
                    statRender = pndInv;
                  }
                  if (status == InvStatus.Pinjam) {
                    statRender = pjmInv;
                  }
                  setState(() {
                    print(
                        'akan merender inv dengan status $status \n $statRender');
                  });
                },
                itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text('Baru'),
                        value: InvStatus.Baru,
                      ),
                      PopupMenuItem(
                        child: Text('BAP'),
                        value: InvStatus.Bap,
                      ),
                      PopupMenuItem(
                        child: Text('Pindah Tangan'),
                        value: InvStatus.Pindah,
                      ),
                      PopupMenuItem(
                        child: Text('Pinjam'),
                        value: InvStatus.Pinjam,
                      ),
                    ])
        ],
      ),
      body: isLoading == true
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ambilData();
                setState(() {});
              },
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.lightBlue.shade400),
                    child: Container(
                      height: 25,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selected = 'Semua';
                                    // allInv = statRender;
                                    invToRender = allCat;
                                    // catToRender = statRender;
                                  });
                                },
                                child: Text(
                                  'Semua',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: selected == "Semua"
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              ),
                              selected == "Semua" ? BuildGaris() : SizedBox()
                            ],
                          ),
                          SizedBox(
                            width: 30,
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selected = "Elektronik";
                                    invToRender = elCat;
                                  });
                                },
                                child: Text(
                                  'Elektronik',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: selected == "Elektronik"
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              ),
                              selected == "Elektronik"
                                  ? BuildGaris()
                                  : SizedBox()
                            ],
                          ),
                          SizedBox(
                            width: 30,
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selected = "Rumah Tangga";
                                    invToRender = rtCat;
                                    // catToRender = statRender;
                                  });
                                },
                                child: Text(
                                  'Rumah Tangga',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: selected == "Rumah Tangga"
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              ),
                              selected == "Rumah Tangga"
                                  ? BuildGaris()
                                  : SizedBox()
                            ],
                          ),
                          SizedBox(
                            width: 30,
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selected = "Lainnya";
                                    invToRender = laCat;
                                    // catToRender = statRender;
                                    print(
                                        'akan merender inv dengan status $statRender -> kategory $selected');
                                  });
                                },
                                child: Text(
                                  'Lainnya',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: selected == "Lainnya"
                                          ? FontWeight.bold
                                          : FontWeight.normal),
                                ),
                              ),
                              selected == "Lainnya" ? BuildGaris() : SizedBox()
                            ],
                          ),
                          SizedBox(
                            width: 30,
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(20),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3 / 2),
                      itemBuilder: (context, index) {
                        //////////////////
                        allCat = statRender;
                        elCat = statRender
                            .where(
                                (element) => element.kategory == 'Elektronik')
                            .toList();
                        rtCat = statRender
                            .where(
                                (element) => element.kategory == 'Rumah Tangga')
                            .toList();
                        laCat = statRender
                            .where((element) => element.kategory == 'Lainnya')
                            .toList();

                        // invToRender = statRender;
                        // invToRender = statRender;
                        invToRender = allCat;
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DetailInventory(
                                          index: index,
                                          render: invToRender,
                                        )));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GridTile(
                              footer: GridTileBar(
                                backgroundColor: Colors.black54,
                                title: Text(
                                  invToRender[index].nama.toUpperCase(),
                                  textAlign: TextAlign.center,
                                ),
                                leading: isUser == false
                                    ? IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditInventory(
                                                index: index,
                                                render: invToRender,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.edit),
                                        color: Colors.lightBlue,
                                      )
                                    : SizedBox(),
                                trailing: isUser == false
                                    ? IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                    title: Text('Yakin'),
                                                    content: Text(
                                                        'Apakah anda yakin untuk menghapus Inventaris ini.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          'Batal',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                      TextButton(
                                                          onPressed: () async {
                                                            print(
                                                                'akan menghapus inventaris dengan id ${invToRender[index].id}');
                                                            var response = await http
                                                                .post(Uri.parse(
                                                                    CommonUser
                                                                            .baseUrl +
                                                                        '/delete_inv/${invToRender[index].id}'));
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              LogModel.sendLog(
                                                                'id',
                                                                'delete inv',
                                                                '${invToRender[index].idInventory}',
                                                                'anda menghapus invetaris dengan id ${invToRender[index].idInventory}',
                                                              );
                                                              inventory.removeWhere(
                                                                  (element) =>
                                                                      element
                                                                          .id ==
                                                                      invToRender[
                                                                              index]
                                                                          .id);
                                                              setState(() {});
                                                              print(
                                                                  'berhasil hapus photo');
                                                              Navigator.pop(
                                                                  context);
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      SnackBar(
                                                                          content:
                                                                              Text('Berhasil Menghapus Inventaris')));
                                                              setState(() {
                                                                inventory
                                                                    .removeAt(
                                                                        index);
                                                                invToRender
                                                                    .removeAt(
                                                                        index);
                                                              });
                                                            }
                                                          },
                                                          child: Text(
                                                            'Yakin',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green),
                                                          ))
                                                    ],
                                                  ));
                                        },
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                      )
                                    : SizedBox(),
                              ),
                              child: Image.network(
                                invToRender[index].pathPhoto,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: invToRender.length,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class BuildGaris extends StatelessWidget {
  const BuildGaris({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      width: MediaQuery.of(context).size.width * .12,
      color: Colors.lightBlue.shade100,
    );
  }
}
