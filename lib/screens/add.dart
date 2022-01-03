import 'dart:io';
import 'dart:typed_data';

import 'package:chiringuito/db/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Add extends StatefulWidget {
  Add({Key? key}) : super(key: key);

  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir sticker'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              List<XFile>? xfile = await ImagePicker().pickMultiImage();
              var progress = 0.obs;

              Get.dialog(AlertDialog(
                  title: CircularProgressIndicator(
                value: (progress.value / xfile!.length),
              )));

              for (var xfile in xfile) {
                String reference = Db().stickers().doc().id;

                File file = File(xfile.path);

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
                  'likes': 0
                });
                progress.value++;
              }
              Get.back();
            },
            child: Text('AÑadir sticker')),
      ),
    );
  }
}
