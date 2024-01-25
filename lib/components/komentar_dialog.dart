import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lapor_book/components/input_widget.dart';
import 'package:lapor_book/components/styles.dart';
import 'package:lapor_book/models/akun.dart';
import 'package:lapor_book/models/laporan.dart';

class KomentarDialog extends StatefulWidget {
  final Laporan laporan;
  // final Komentar komentar;

  KomentarDialog({
    required this.laporan,
    // required this.komentar,
  });

  @override
  _KomentarDialogState createState() => _KomentarDialogState();
}

class _KomentarDialogState extends State<KomentarDialog> {
  late String komentar;
  bool _isLoading = false;
  final _firestore = FirebaseFirestore.instance;
  TextEditingController komenController = TextEditingController();

  // void addKomentar(Akun akun) async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   CollectionReference transaksiCollection = _firestore.collection('laporan');
  //   try {
  //     await transaksiCollection.doc(widget.laporan.docId).set({
  //       'nama': akun.nama,
  //       'isi': komentar,
  //     }).catchError((e) {
  //       throw e;
  //     });
  //     Navigator.popAndPushNamed(context, '/dashboard');
  //   } catch (e) {
  //     final snackbar = SnackBar(content: Text(e.toString()));
  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // komentar = widget.laporan.komentar as String;
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Laporan laporan = arguments['laporan'];
    Akun akun = arguments['akun'];

    return AlertDialog(
      backgroundColor: primaryColor,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.laporan.judul,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              // waitt
              controller: komenController,
              keyboardType: TextInputType.text,
              decoration: customInputDecoration('Tambahkan Komentar'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addComment(laporan.docId);
                // Navigator.pushReplacementNamed(context, '/detail', arguments: {
                //   'laporan': laporan,
                //   'akun': akun,
                // });
                // print(komentar);
                // addKomentar(akun);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Posting Komentar'),
            ),
          ],
        ),
      ),
    );
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
        'comment': commentText,
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
