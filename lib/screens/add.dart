import 'dart:io';
import 'dart:typed_data';

import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
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
    bool animado = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir sticker'),
        actions: [
          Switch(
              onChanged: (value) {
                setState(() {
                  animado = value;
                });
              },
              value: animado)
        ],
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () async {
                  List<XFile>? xfile = await ImagePicker().pickMultiImage();
                  var progress = 0.obs;

                  Get.dialog(AlertDialog(
                      title: CircularProgressIndicator(
                    value: (progress.value / xfile!.length),
                  )));

                  for (var xfile in xfile) {
                    String reference = Db().stickers().doc().id;

                    File file;

                    if (animado) {
                      file = File(xfile.path + 'webp');
                    }
                    file = File(xfile.path);

                    file =
                        await testCompressAndGetFile(file, file.path + '.webp');

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
                      'animado': animado
                    });

                    progress.value++;
                  }
                  Get.back();
                },
                child: Text('AÑadir sticker')),
            ElevatedButton(
                onPressed: () {
                  print('push');
                  List<Sticker> stickers = Get.put(HomeController()).stickers;
                  print(stickers.length);
                  for (var sticker in stickers) {
                    Db().stickers().doc(sticker.id).update({'animado': false});
                    Future.delayed(Duration(seconds: 1));
                    print(sticker.id);
                  }
                },
                child: Text('Actuailizar todo'))
          ],
        ),
      ),
    );
  }
}
