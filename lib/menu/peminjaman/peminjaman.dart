import 'package:flutter/material.dart';
import 'package:sipisat/menu/peminjaman/add_peminjaman.dart';
import 'package:sipisat/models/inventory_model.dart';
import 'package:http/http.dart' as http;
import 'package:sipisat/models/log_models.dart';

import '../../common.dart';

class Pinjam extends StatefulWidget {
  const Pinjam({Key? key}) : super(key: key);

  @override
  _PinjamState createState() => _PinjamState();
}

class _PinjamState extends State<Pinjam> {
  List<Invetory> allInv = [];
  List<Invetory> invToRender = [];
  Invetory? selInv;
  Invetory? invToUpdate;

  void ambilData() {
    allInv = Invetory.allInv;
    invToRender =
        allInv.where((element) => element.status == 'pinjam').toList();
    print('jumlah inv dengan status pinjam adalah ${invToRender.length}');
    setState(() {});
  }

  @override
  void initState() {
    ambilData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => Peminjaman()));
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
      appBar: AppBar(
        title: Text('Peminjaman'),
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
      body: RefreshIndicator(
        onRefresh: () async {
          ambilData();
        },
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemBuilder: (context, index) {
            return Card(
              elevation: 5,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: Image(
                          image: NetworkImage(invToRender[index].pathPhoto,
                              scale: 1),
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invToRender[index].nama.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Peminjam : ',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  invToRender[index].idPemilik,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'ID Surat : ',
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(
                                  invToRender[index].idSurat,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.circular(4)),
                          child: IconButton(
                              onPressed: () {
                                /////////// menghapus inventeris jika sudah yakin
                                // 1. hapus inventory dengan idsurat  yang sama dengan id awal
                                // 1. ambil inventaris asli dengan id yang sama
                                // 2. tambah jumlahnya sesuai jumlah pinjam yang ada
                                // 2. update/ tambah jumlah inventaris ke jumlah semula
                                print(
                                    'detail inv pinjam - id awal ${invToRender[index].idAwal} - id surat ${invToRender[index].idSurat} dan inv ini akan dihapus jika sudah sukses');
                                selInv = allInv.firstWhere((element) =>
                                    element.idSurat ==
                                        invToRender[index].idAwal &&
                                    element.idInventory ==
                                        invToRender[index].idInventory);
                                int jumlahUpdate = 0;

                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text("Kembalikan"),
                                          content: Text(
                                              "Anda yakin Inventaris telah dikembalikan, jika ya maka akan dihapus dari data pinjam."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Batal",
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                            TextButton(
                                                onPressed: () async {
                                                  if (selInv!.status ==
                                                      'baru masuk') {
                                                    jumlahUpdate = selInv!
                                                            .jumlah +
                                                        selInv!.jumlahPinjam;
                                                    selInv!.jumlah =
                                                        jumlahUpdate;
                                                    selInv!.jumlahPinjam = 0;
                                                  } else if (selInv!.status ==
                                                      'bap') {
                                                    jumlahUpdate = selInv!
                                                            .newJumlah +
                                                        selInv!.jumlahPinjam;
                                                    selInv!.newJumlah =
                                                        jumlahUpdate;
                                                    selInv!.jumlahPinjam = 0;
                                                  } else if (selInv!.status ==
                                                      'pindah tangan') {
                                                    jumlahUpdate = selInv!
                                                            .newJumlah +
                                                        selInv!.jumlahPinjam;
                                                    selInv!.newJumlah =
                                                        jumlahUpdate;
                                                    selInv!.jumlahPinjam = 0;
                                                  }
                                                  print(
                                                      'detail inv yang akan diupdate - ${selInv!.idSurat} - jumlah awal ${selInv!.jumlah} , ${selInv!.newJumlah} dan hasil akhir adalah $jumlahUpdate');
                                                  print(
                                                      'selanjutnya akan mengupdate data ke server');
                                                  var resp = await http.post(
                                                      Uri.parse(CommonUser
                                                              .baseUrl +
                                                          '/edit_inv_surat_pjm/${selInv!.id}'),
                                                      body: ({
                                                        'jumlah_pinjam': selInv!
                                                            .jumlahPinjam
                                                            .toString(),
                                                        'jumlah': selInv!.jumlah
                                                            .toString(),
                                                        'new_jumlah': selInv!
                                                            .newJumlah
                                                            .toString(),
                                                      }));
                                                  if (resp.statusCode == 200) {
                                                    Invetory.editInvPjm(
                                                        'pinjam',
                                                        selInv!.idInventory,
                                                        selInv!.jumlah,
                                                        selInv!.newJumlah,
                                                        selInv!.jumlahPinjam,
                                                        () {
                                                      setState(() {});
                                                    });
                                                    var response = await http
                                                        .post(Uri.parse(CommonUser
                                                                .baseUrl +
                                                            '/delete_inv/${invToRender[index].id}'));
                                                    if (response.statusCode ==
                                                        200) {
                                                      LogModel.sendLog(
                                                        'id',
                                                        'pinjam',
                                                        invToRender[index]
                                                            .idSurat,
                                                        'anda menerima menutup peminjaman dengan id ${invToRender[index].idSurat}',
                                                      );
                                                      allInv.remove(
                                                          invToRender[index]);
                                                      setState(() {});
                                                      print(
                                                          'berhasil update data untuk peminjaman');
                                                      Navigator.pop(context);
                                                    }
                                                  } else {
                                                    print(
                                                        'gagal update data untuk peminjaman ${resp.statusCode}');
                                                  }
                                                },
                                                child: Text("Yakin",
                                                    style: TextStyle(
                                                        color: Colors.green))),
                                          ],
                                        ));
                              },
                              icon: Icon(Icons.check)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: invToRender.length,
        ),
      ),
    );
  }
}
