import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sipisat/common.dart';
import 'package:sipisat/menu/inventoy/add_inventory.dart';
import 'package:sipisat/models/inventory_model.dart';

import 'detail_inventory.dart';
import 'edit_inventory.dart';

class AllInventory extends StatefulWidget {
  const AllInventory({Key? key}) : super(key: key);

  @override
  _AllInventoryState createState() => _AllInventoryState();
}

class _AllInventoryState extends State<AllInventory> {
  var selected = 'Semua';
  var isLoading = true;
  List<Invetory> inventory = Invetory.allInv;
  var isElk = false;
  List<Invetory> inventoryEl = [];
  List<Invetory> inventoryRt = [];
  List<Invetory> inventoryOt = [];
  List<Invetory> render = [];

  ambilData() async {
    if (inventory.isEmpty) {
      Invetory.ambilData();
      inventory =
          inventory.where((element) => element.status == 'baru masuk').toList();
    }
    inventory =
        inventory.where((element) => element.status == 'baru masuk').toList();
    inventoryEl =
        inventory.where((element) => element.kategory == 'Elektronik').toList();
    inventoryRt = inventory
        .where((element) => element.kategory == 'Rumah Tangga')
        .toList();
    inventoryOt =
        inventory.where((element) => element.kategory == 'Lainnya').toList();
    print('berhasil mengambil data inventory \n $inventory');
    render = inventory;
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    ambilData();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: InkWell(
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
              ))),
      backgroundColor: Colors.lightBlue.shade300,
      appBar: AppBar(
        title: Text('Semua Inventaris'),
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
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                ambilData();
                selected = 'Semua';
                render = inventory;
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
                                    render = inventory;
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
                                    render = inventoryEl;
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
                                    render = inventoryRt;
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
                                    render = inventoryOt;
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
                  if (inventory.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info),
                            Text(' Belum ada data inventaris.')
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
                                          render: render,
                                        )));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GridTile(
                                footer: GridTileBar(
                                  backgroundColor: Colors.black54,
                                  title: Text(
                                    render[index].nama.toUpperCase(),
                                    textAlign: TextAlign.center,
                                  ),
                                  leading: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditInventory(
                                            index: index,
                                            render: render,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.edit),
                                    color: Colors.lightBlue,
                                  ),
                                  trailing: IconButton(
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
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      'Batal',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                  TextButton(
                                                      onPressed: () async {
                                                        print(
                                                            'akan menghapus inventaris dengan id ${render[index].id}');
                                                        var response = await http.post(
                                                            Uri.parse(CommonUser
                                                                    .baseUrl +
                                                                '/delete_inv/${render[index].id}'));
                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          inventory.removeWhere(
                                                              (element) =>
                                                                  element.id ==
                                                                  render[index]
                                                                      .id);
                                                          setState(() {});
                                                          print(
                                                              'berhasil hapus photo');
                                                          Navigator.pop(
                                                              context);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      'Berhasil Menghapus Inventaris')));
                                                          setState(() {
                                                            inventory.removeAt(
                                                                index);
                                                            render.removeAt(
                                                                index);
                                                          });
                                                        }
                                                      },
                                                      child: Text(
                                                        'Yakin',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green),
                                                      ))
                                                ],
                                              ));
                                    },
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                  ),
                                ),
                                child: Image.network(
                                  render[index].pathPhoto,
                                  fit: BoxFit.cover,
                                )
                                // Image(
                                //     fit: BoxFit.cover,
                                //     image: NetworkImage(
                                //       // 'https://selular.id/wp-content/uploads/2021/05/m1-mac-mini-angle-100867263-orig-5.jpg'
                                //       render[index].pathPhoto,
                                //     )),
                                ),
                          ),
                        );
                      },
                      itemCount: render.length,
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
      color: Colors.white,
    );
  }
}
