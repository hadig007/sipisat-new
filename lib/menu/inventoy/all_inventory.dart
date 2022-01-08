import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sipisat/auth/login.dart';
import 'package:sipisat/common.dart';
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
  int allInvCount = 0;
  int allNewInv = 0;
  int allBapInv = 0;
  int allPndInv = 0;
  int allPjmInv = 0;
  var selected;
  var isLoading = true;
  var isElk = false;
  var isUser = false;
  var networkError = false;
  var blankInv = false;
  var tambahInv = false;
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
  List<Invetory> catToRender = [];

  ambilData() async {
    inventory = Invetory.allInv;
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
          if (data['jumlah'] != 0 &&
              data['new_jumlah'] != 0 &&
              data['jumlah_pinjam'] != 0) {
            inventory.insert(
              0,
              Invetory(
                id: data['id'].toString(),
                idSurat: data['id_surat'],
                idInventory: data['id_inventory'],
                idPemilik: data['id_pemilik'],
                status: data['status'],
                nama: data['nama'],
                merk: data['merk'],
                jumlah: int.parse(data['jumlah']),
                newJumlah: int.parse(data['new_jumlah']),
                jumlahPinjam: int.parse(data['jumlah_pinjam']),
                idAwal: data['id_awal'] == null ? 'null' : data['id_awal'],
                keterangan: data['keterangan'],
                kategory: data['kategory'],
                model: data['model'] == null ? 'null' : data['model'],
                sn: data['sn'] == null ? 'null' : data['sn'],
                subKategory: data['sub_kategory'] == null
                    ? 'null'
                    : data['sub_kategory'],
                pathPhoto: data['path_photo'],
              ),
            );
          }
        }
        tambahInv = true;
      } else {
        print('gagal mengambil data inventaris');
        setState(() {
          networkError = true;
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    content: Text(
                        'Maaf, gagal mengambil data, silahkan coba lagi nanti'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Okey"))
                    ],
                  ));
        });
      }
      if (inventory.isEmpty) {
        print('data inventaris masih kosong, silahkan tambahkan');
        setState(() {
          blankInv = true;
        });
      }
    }
    // allInv = inventory;
    // newInv = allInv.where((element) => element.status == 'baru masuk').toList();
    // bapInv = allInv.where((element) => element.status == 'bap').toList();
    // pndInv =
    //     allInv.where((element) => element.status == 'pindah tangan').toList();
    // pjmInv = allInv.where((element) => element.status == 'pinjam').toList();
    // statRender = newInv;
    // invToRender = statRender;
    ///////////////////////////////////////////////////////////////////////
    // statRender = inventory;
    // menghitung jumlah semua inventory

    ///

    allCat =
        inventory.where((element) => element.status == 'baru masuk').toList();

    elCat = inventory
        .where((element) =>
            element.kategory == 'Elektronik' && element.status == 'baru masuk')
        .toList();
    rtCat = inventory
        .where((element) =>
            element.kategory == 'Rumah Tangga' &&
            element.status == 'baru masuk')
        .toList();
    laCat = inventory
        .where((element) =>
            element.kategory == 'Lainnya' && element.status == 'baru masuk')
        .toList();
    selected = "Semua";
    catToRender = allCat; //1
    //////////////////////////
    // allInvCount

    SharedPreferences sh = await SharedPreferences.getInstance();
    final level = sh.getString('level');
    print("$isUser, $level");
    if (level == 'user') {
      setState(() {
        isUser = true;
      });
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ///////////
    // if (allInvCount == 0 || inventory.length != allCat.length) {
    //   for (var data in inventory) {
    //     if (data.status == 'baru masuk') {
    //       allNewInv += data.jumlah;
    //     }
    //     if (data.status == 'bap') {
    //       allBapInv += data.newJumlah;
    //     }
    //     if (data.status == 'pinjam') {
    //       allPjmInv += data.jumlahPinjam;
    //     }
    //   }
    //   allInvCount = allNewInv + allBapInv + allPndInv + allPjmInv;
    // }
    // print(
    //     '==========\n jumlah semua inventaris $allInvCount \n jumlah baru -> $allNewInv \n jumlah bap -> $allBapInv  \n jumlah pinjam $allPjmInv \n==========');

    ///////////
    Invetory.invCount();
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
          if (isUser == false)
            IconButton(
                onPressed: () async {
                  InvCount invCount = await Invetory.invCount();
                  showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Detail Alokasi Inventaris',
                                  textAlign: TextAlign.center,
                                ),
                                Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Jumlah semua inventaris : '),
                                          Text(
                                              'inventaris baru masuk/gudang: '),
                                          Text('inventaris bap : '),
                                          Text('pindah tangan : '),
                                          Text('inventaris pinjam : '),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(invCount.allCount.toString()),
                                          Text(invCount.baruMasuk.toString()),
                                          Text(invCount.bap.toString()),
                                          Text(
                                              invCount.pindahTangan.toString()),
                                          Text(invCount.pinjam.toString()),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ));
                },
                icon: Icon(Icons.info)),
          if (isUser == true)
            IconButton(
                onPressed: () async {
                  SharedPreferences sh = await SharedPreferences.getInstance();
                  sh.clear();
                  final id = sh.getString('id');
                  print(
                      'allinv========================================== init $id');
                  if (id == null) {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginPage()));
                  }
                  setState(() {});
                },
                icon: Icon(Icons.logout)),
          // if (isUser == false)
          //   PopupMenuButton(
          //       onSelected: (InvStatus status) {
          //         print(status);
          //         // statRender = allInv;
          //         if (status == InvStatus.Baru) {
          //           statRender = newInv;
          //         }
          //         if (status == InvStatus.Bap) {
          //           statRender = bapInv;
          //         }
          //         if (status == InvStatus.Pindah) {
          //           statRender = pndInv;
          //         }
          //         if (status == InvStatus.Pinjam) {
          //           statRender = pjmInv;
          //         }
          //         setState(() {
          //           invToRender = statRender;
          //           catToRender = invToRender;
          //           print(
          //               'akan merender inv dengan status $status \n $statRender');
          //         });
          //       },
          //       itemBuilder: (_) => [
          //             PopupMenuItem(
          //               child: Text('Baru'),
          //               value: InvStatus.Baru,
          //             ),
          //             PopupMenuItem(
          //               child: Text('BAP'),
          //               value: InvStatus.Bap,
          //             ),
          //             PopupMenuItem(
          //               child: Text('Pindah Tangan'),
          //               value: InvStatus.Pindah,
          //             ),
          //             PopupMenuItem(
          //               child: Text('Pinjam'),
          //               value: InvStatus.Pinjam,
          //             ),
          //           ])
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
                selected = "Semua";
                setState(() {});
              },
              child: Column(
                children: [
                  blankInv == true
                      ? Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.3),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4)),
                          padding: EdgeInsets.all(10),
                          child: Text('Belum ada inventaris, Silahkan tambah.'))
                      : Container(
                          padding: EdgeInsets.all(20),
                          decoration:
                              BoxDecoration(color: Colors.lightBlue.shade400),
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
                                          // invToRender = statRender;
                                          catToRender = allCat;
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
                                    selected == "Semua"
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
                                          selected = "Elektronik";
                                          // invToRender = statRender;
                                          catToRender = elCat;
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
                                          // invToRender = statRender;
                                          catToRender = rtCat;
                                        });
                                      },
                                      child: Text(
                                        'Rumah Tangga',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight:
                                                selected == "Rumah Tangga"
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
                                          // invToRender = statRender;
                                          catToRender = laCat;
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
                                    selected == "Lainnya"
                                        ? BuildGaris()
                                        : SizedBox()
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
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => DetailInventory(
                                          index: index,
                                          render: catToRender,
                                          isUser: isUser,
                                        )));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GridTile(
                              footer: GridTileBar(
                                backgroundColor: Colors.black54,
                                title: Text(
                                  catToRender[index].nama.toUpperCase(),
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
                                                render: catToRender,
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
                                                                'akan menghapus inventaris dengan id ${catToRender[index].id}');
                                                            var response = await http
                                                                .post(Uri.parse(
                                                                    CommonUser
                                                                            .baseUrl +
                                                                        '/delete_inv/${catToRender[index].id}'));
                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              LogModel.sendLog(
                                                                'id',
                                                                'delete inv',
                                                                '${catToRender[index].idInventory}',
                                                                'anda menghapus invetaris dengan id ${catToRender[index].idInventory}',
                                                              );
                                                              inventory.removeWhere(
                                                                  (element) =>
                                                                      element
                                                                          .id ==
                                                                      catToRender[
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
                                catToRender[index].pathPhoto,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: catToRender.length,
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
