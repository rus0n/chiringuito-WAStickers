import 'dart:io';

import 'package:chiringuito/controllers/detalle_controller.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Detalle extends StatelessWidget {
  const Detalle({Key? key, required this.stickers}) : super(key: key);

  final List<Sticker> stickers;

  @override
  Widget build(BuildContext context) {
    var d = Get.put(DetalleController());

    Future<void> likesAdd(Sticker _sticker) async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference _likesReference = Db().stickers().doc(_sticker.id);

        DocumentSnapshot _snapshot = await transaction.get(_likesReference);

        int newFollowerCount = _snapshot.get('likes') + 1;

        // Perform an update on the document
        transaction.update(_likesReference, {'likes': newFollowerCount});

        // Return the new count
        //return newFollowerCount;
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Stickers Seleccionados'),
          actions: [
            IconButton(
                onPressed: () => Get.dialog(SimpleDialog(
                      title: Text('Informacion'),
                      children: [
                        Text(
                            'Si se necesita instalar un nuevo paquete ya que sobrepasa los 30 stickers, se hace de forma automatica. Si no se actualizará el paquete actual.')
                      ],
                    )),
                icon: Icon(Icons.info))
          ],
        ),
        body: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 8.0 / 9.0,
            ),
            itemCount: stickers.length,
            itemBuilder: (_, index) {
              Sticker _sticker = stickers.elementAt(index);
              return Card(
                clipBehavior: Clip.antiAlias,
                color: Colors.lightBlueAccent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 16 / 11,
                        child: Image.network(
                          _sticker.imageUrl!,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              onPressed: () => likesAdd(_sticker),
                              icon: Icon(Icons.favorite_outline)),
                          Text(_sticker.likes.toString() + '  Me gusta')
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
        bottomSheet: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateColor.resolveWith(
                        (states) => Color.fromRGBO(7, 94, 84, 1))),
                onPressed: () => d.createLocalFile(stickers),
                child: Text('Añadir a WhatsApp'))
          ],
        ));
  }
}
