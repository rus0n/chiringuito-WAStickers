import 'dart:io';

import 'package:chiringuito/db/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';

class Upload extends StatefulWidget {
  Upload({Key? key, required this.path}) : super(key: key);
  final String path;
  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  @override
  Widget build(BuildContext context) {
    Map<String, bool> protagonistas = {
      'Cristobal Soria': false,
      'Pedrerol': false,
      'Alfredo duro': false,
      'Juanfe': false,
      'Iñigo': false,
      "D'Alessandro": false,
      'Juanma Rodriguez': false,
      'Edu Velasco': false,
      'Jota Jordi': false,
      'Lobo Carrasco': false,
      'Fermin': false,
      'El ingeniero': false,
      'Roncero': false
    };

    File file = File(widget.path);

    Future<File> testCompressAndGetFile(File file, String targetPath) async {
      var result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path, targetPath,
          quality: 88,
          minHeight: 512,
          minWidth: 512,
          format: CompressFormat.webp);

      print(file.lengthSync());
      print(result!.lengthSync());

      return result;
    }

    return Column(
      children: [
        Image.file(File(widget.path)),
        Expanded(
            child: ListView.builder(
                itemCount: protagonistas.length,
                itemBuilder: (_, index) {
                  String protagonista = protagonistas.keys.elementAt(index);
                  return CheckboxListTile(
                      title: Text(protagonista),
                      value: protagonistas.values.elementAt(index),
                      onChanged: (value) {
                        setState(() {
                          protagonistas[protagonista] = value!;
                        });
                      });
                })),
        ElevatedButton.icon(
            onPressed: () async {
              Get.dialog(
                  AlertDialog(
                    title: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  barrierDismissible: false);
              String reference = Db().stickers().doc().id;

              file = await testCompressAndGetFile(file, file.path + '.webp');

              await FirebaseStorage.instance.ref(reference).putFile(file);
              await FirebaseStorage.instance
                  .ref(reference)
                  .updateMetadata(SettableMetadata(contentType: '.webp'));

              await Db().stickers().doc(reference).set({
                'imageUrl': await FirebaseStorage.instance
                    .ref(reference)
                    .getDownloadURL(),
                'emojis': [],
                'likes': 0,
                'comments': 0,
                'creado': Timestamp.now(),
                'animado': false
              });
              Get.back();
            },
            icon: Icon(Icons.post_add),
            label: Text('Publicar'))
      ],
    );
  }
}
