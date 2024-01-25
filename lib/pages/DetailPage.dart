import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/komentar_dialog.dart';
import 'package:lapor_book/components/status_dialog.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lapor_book/components/input_widget.dart';

class DetailPage extends StatefulWidget {
  DetailPage({super.key});
  @override
  State<StatefulWidget> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLoading = false;

  String? status;
  String? komentar;
  TextEditingController komenController = TextEditingController();

  Future launch(String uri) async {
    if (uri == '') return;
    if (!await launchUrl(Uri.parse(uri))) {
      throw Exception('Tidak dapat memanggil : $uri');
    }
  }

  void statusDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatusDialog(
          laporan: laporan,
        );
      },
    );
  }

  void komentarDialog(Laporan laporan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return KomentarDialog(
          laporan: laporan,
          // komentar: komentar,
        );
      },
    );
  }

  void tambahLike(Laporan laporan) {
    setState(() {
      laporan.like = (laporan.like ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference komentarCollection = firestore.collection('komentar');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Detail Laporan',
          style: headerStyle(level: 3, dark: false),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        laporan.judul,
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 15),
                      laporan.gambar != ''
                          ? Image.network(laporan.gambar!)
                          : Image.asset('assets/istock-default.jpg'),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          laporan.status == 'Posted'
                              ? textStatus(
                                  'Posted', Colors.yellow, Colors.black)
                              : laporan.status == 'Process'
                                  ? textStatus(
                                      'Process', Colors.green, Colors.white)
                                  : textStatus(
                                      'Done', Colors.blue, Colors.white),
                          textStatus(
                              laporan.instansi, Colors.white, Colors.black),
                        ],
                      ),
                      Container(
                        width: 100,
                        child: ElevatedButton(
                          onPressed: () {
                            tambahLike(laporan);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Like'),
                        ),
                      ),
                      Text('Jumlah Like : ${laporan.like ?? 0}'),
                      SizedBox(height: 20),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Center(child: Text('Nama Pelapor')),
                        subtitle: Center(
                          child: Text(laporan.nama),
                        ),
                        trailing: SizedBox(width: 45),
                      ),
                      ListTile(
                        leading: Icon(Icons.date_range),
                        title: Center(child: Text('Tanggal Laporan')),
                        subtitle: Center(
                          child: Text(DateFormat('dd MMMM yyyy')
                              .format(laporan.tanggal)),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {
                            launch(laporan.maps);
                          },
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        'Deskripsi Laporan',
                        style: headerStyle(level: 3),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(laporan.deskripsi ?? ''),
                      ),
                      if (akun.role == 'admin')
                        Container(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                status = laporan.status;
                              });
                              statusDialog(laporan);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Ubah Status'),
                          ),
                        ),
                      Container(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () {
                            // setState(() {
                            //   komentar = laporan.komentar as String?;
                            // });
                            // komentarDialog(laporan);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: primaryColor,
                                content: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        laporan.judul,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 20),
                                      TextField(
                                        // waitt
                                        controller: komenController,
                                        keyboardType: TextInputType.text,
                                        decoration: customInputDecoration(
                                            'Tambahkan Komentar'),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          addComment(laporan.docId);
                                          Navigator.pushReplacementNamed(
                                              context, '/detail',
                                              arguments: {
                                                'laporan': laporan,
                                                'akun': akun,
                                              });
                                          // print(komentar);
                                          // addKomentar(akun);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text('Posting Komentar'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Tambahkan Komentar'),
                        ),
                      ),
                      SizedBox(height: 50),
                      Text(
                        'List Komentar',
                        style: headerStyle(level: 3),
                      ),
                      // ListView(
                      //   children: [
                      //     FutureBuilder<QuerySnapshot>(
                      //       future: komentarCollection.get(),
                      //       builder: (_, snapshot){
                      //         if(snapshot.hasData){
                      //           return Column(
                      //             children: snapshot.data.docs.map((e) => ),
                      //           )
                      //         }else{
                      //           return Text('Tidak ada komentar')
                      //         }
                      //       }),
                      //   ],
                      // )
                      const SizedBox(height: 10),
                      FutureBuilder<List<Komentar>>(
                        future: getComment(laporan.docId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('Tidak ada komentar');
                          } else if (snapshot.hasError) {
                            return Text('Error has occured: &{snapshot.error}');
                          } else {
                            // Menampilkan daftar komentar
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                Komentar comment = snapshot.data![index];
                                return ListTile(
                                  title: Text(comment.nama),
                                  subtitle: Text(comment.isi),
                                  trailing: Text(
                                    DateFormat('dd MMM yyyy HH:mm')
                                        .format(comment.time),
                                  ),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Container textStatus(String text, var bgcolor, var textcolor) {
    return Container(
      width: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgcolor,
        border: Border.all(width: 1, color: primaryColor),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(color: textcolor),
      ),
    );
  }

  Future<List<Komentar>> getComment(String docId) async {
    try {
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('laporan')
          .doc(docId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      List<Komentar> comments = commentSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Komentar(
          nama: data['nama'] ?? '',
          isi: data['isi'] ?? '',
          time: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();

      return comments;
    } catch (e) {
      print('Error getting comment: $e');
      return [];
    }
  }

  Future<void> addComment(String docId) async {
    try {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      Akun akun = arguments['akun'];
      CollectionReference laporanCollection =
          FirebaseFirestore.instance.collection('laporan');

      String commentText = komenController.text.trim();

      String commentId = DateTime.now().toIso8601String() +
          Random().nextInt(10000000).toString();

      await laporanCollection
          .doc(docId)
          .collection('comments')
          .doc(commentId)
          .set({
        'uid': akun.uid,
        'nama': akun.nama,
        'isi': commentText,
        // 'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment Added'),
        ),
      );
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error adding comment.'),
        ),
      );
    }
  }
}
