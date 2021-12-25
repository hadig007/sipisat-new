// import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sipisat/menu/bap/add_bap.dart';
import 'package:sipisat/menu/bap/pindah_tangan.dart';
import 'package:sipisat/menu/inventoy/all_inventory.dart';
import 'package:sipisat/menu/peminjaman/peminjaman.dart';
import 'package:sipisat/menu/staff/all_staff.dart';
import 'package:sipisat/menu/umum/log.dart';
import 'package:sipisat/menu/users/all_users.dart';
// import 'package:http/http.dart' as http;
import 'package:sipisat/models/bap_model.dart';
import 'package:sipisat/models/users_model.dart';

import 'auth/login.dart';
import 'menu/bap/all_bap.dart';
import 'menu/staff/add_staff.dart';
import 'models/inventory_model.dart';
import 'models/staff_model.dart';

// ignore: must_be_immutable
class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  List<BuildMenu> user = [
    BuildMenu(
      text: 'Pengguna',
      pathIcon: 'assets/icons/user.png',
      dest: AllUser(),
    ),
    BuildMenu(
      text: 'Staff',
      pathIcon: 'assets/icons/staff.png',
      dest: AllStaff(),
    ),
    BuildMenu(
      text: 'Tambah\nStaff',
      pathIcon: 'assets/icons/add_user.png',
      dest: AddStaff(),
    ),
  ];
  List<BuildMenu> inv = [
    BuildMenu(
      text: 'Inventory',
      pathIcon: 'assets/icons/inventaris.png',
      dest: AllInventory(),
    ),
    BuildMenu(
      text: 'BAP',
      pathIcon: 'assets/icons/file.png',
      dest: AllBAP(),
    ),
    BuildMenu(
      text: 'Buat\nBAP',
      pathIcon: 'assets/icons/add.png',
      dest: AddBAP(),
    ),
  ];
  List<BuildMenu> oth = [
    BuildMenu(
        text: 'Pindah\nTangan',
        pathIcon: 'assets/icons/edit.png',
        dest: PindahTangan()),
    BuildMenu(
        text: 'Pinjam',
        pathIcon: 'assets/icons/peminjaman.png',
        dest: Peminjaman()),
    BuildMenu(
      text: 'Log',
      pathIcon: 'assets/icons/log.png',
      dest: Log(),
    ),
  ];
  List<BuildMenu> menu = [
    // BuildMenu(
    //     text: 'Tambah\nPengguna',
    //     pathIcon: 'assets/icons/add_user.png',
    //     dest: AddUser()),
    BuildMenu(
      text: 'Staff',
      pathIcon: 'assets/icons/staff.png',
      dest: AllStaff(),
    ),
    BuildMenu(
      text: 'Tambah\nStaff',
      pathIcon: 'assets/icons/add_user.png',
      dest: AddStaff(),
    ),
    BuildMenu(
      text: 'Inventory',
      pathIcon: 'assets/icons/inventaris.png',
      dest: AllInventory(),
    ),
    // BuildMenu(
    //   text: 'Tambah\nInventory',
    //   pathIcon: 'assets/icons/inventory.png',
    //   dest: AddInventory(),
    // ),
    BuildMenu(
      text: 'BAP',
      pathIcon: 'assets/icons/file.png',
      dest: AllBAP(),
    ),
    BuildMenu(
      text: 'Buat\nBAP',
      pathIcon: 'assets/icons/add.png',
      dest: AddBAP(),
    ),
    BuildMenu(
        text: 'Pindah\nTangan',
        pathIcon: 'assets/icons/edit.png',
        dest: PindahTangan()),
    BuildMenu(
      text: 'Log',
      pathIcon: 'assets/icons/log.png',
      dest: Log(),
    ),
    BuildMenu(
        text: 'Pinjam',
        pathIcon: 'assets/icons/peminjaman.png',
        dest: Peminjaman())
  ];

  /////////

  static Future<void> ambilData() async {
    // data staff
    List<StaffModel> stafs = await StaffModel.getData();
    print('semua data staff $stafs');
    //ambil data inv
    List<Invetory> invs = await Invetory.getData();
    print('semua data inv $invs');
    // data bap
    List<BapModel> baps = await BapModel.getData();
    print('semua data inv $baps');
    // data user
    List<UserModel> users = await UserModel.getData();
    print('semua data inv $users');
    if (stafs.length != 0 ||
        invs.length != 0 ||
        baps.length != 0 ||
        users.length != 0) {
      print('============ selesai ambil data dari home app =================');
    }
  }

  /////////

  @override
  void initState() {
    ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('SIPISAT'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.lightBlue.shade400,
        actions: [
          // tombol logout
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false);
            },
            icon: Icon(
              Icons.logout,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
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
              // main menu
              Positioned(
                top: size.height * .2,
                child: Container(
                  constraints: BoxConstraints(
                      maxHeight: size.height * .48, maxWidth: size.width),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          // physics: NeverScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 0,
                                        mainAxisSpacing: 0,
                                        mainAxisExtent: 85,
                                        crossAxisCount: 3),
                                itemBuilder: (context, index) => user[index],
                                itemCount: user.length,
                              ),
                              Divider(),
                              // Container(
                              //   height: 2,
                              //   color: Colors.grey.shade100,
                              //   width: size.width * .7,
                              // ),
                              SizedBox(
                                height: 25,
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 0,
                                        mainAxisSpacing: 0,
                                        mainAxisExtent: 80,
                                        crossAxisCount: 3),
                                itemBuilder: (context, index) => inv[index],
                                itemCount: inv.length,
                              ),
                              Divider(),
                              // Container(
                              //   height: 2,
                              //   color: Colors.grey.shade100,
                              //   width: size.width * .7,
                              // ),
                              SizedBox(
                                height: 25,
                              ),
                              GridView.builder(
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 0,
                                        mainAxisSpacing: 0,
                                        mainAxisExtent: 80,
                                        crossAxisCount: 3),
                                itemBuilder: (context, index) => oth[index],
                                itemCount: oth.length,
                              ),
                              // Divider(),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildMenu extends StatelessWidget {
  const BuildMenu({
    Key? key,
    required this.text,
    required this.pathIcon,
    required this.dest,
  }) : super(key: key);

  final String text;
  final String pathIcon;
  final Widget dest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => dest));
          },
          child: Image.asset(
            pathIcon,
            width: 50,
          ),
        ),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
