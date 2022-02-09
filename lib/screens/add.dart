import 'dart:io';

import 'package:chiringuito/widgets/upload.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
        appBar: AppBar(
          title: Text('Añadir sticker'),
        ),
        body: file.path != 'default'
            ? Upload(path: file.path)
            : Center(
                child: ElevatedButton(
                    onPressed: () async {
                      XFile? xfile = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          maxHeight: 512,
                          maxWidth: 512);

                      // if (animado) {
                      //   file = File(xfile!.path + 'webp');
                      // }
                      setState(() {
                        if (xfile != null) file = File(xfile.path);
                      });
                    },
                    child: Text('Añadir sticker')),
              ),
        bottomSheet: file.path == 'default'
            ? Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Por ahora solo se permite stickers estaticos',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                  )
                ],
              )
            : Divider(
                height: 0.01,
              ));
  }
}
