import 'dart:io';

import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:chiringuito/widgets/upload.dart';
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
  File file = File('default');
  @override
  Widget build(BuildContext context) {
    bool animado = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir sticker'),
      ),
      body: file.path != 'default'
          ? Upload(path: file.path)
          : Center(
              child: ElevatedButton(
                  onPressed: () async {
                    XFile? xfile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    Get.dialog(AlertDialog(
                        title: Center(child: CircularProgressIndicator())));

                    // if (animado) {
                    //   file = File(xfile!.path + 'webp');
                    // }
                    setState(() {
                      if (xfile != null) file = File(xfile.path);
                    });

                    Get.back();
                  },
                  child: Text('Añadir sticker')),
            ),
    );
  }
}
