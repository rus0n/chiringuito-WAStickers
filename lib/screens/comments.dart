import 'dart:math';

import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Comments extends StatelessWidget {
  const Comments({Key? key, required this.id}) : super(key: key);
  final String id;
  @override
  Widget build(BuildContext context) {
    var c = Get.find<HomeController>();
    TextEditingController _controller = TextEditingController();

    Future<void> commentsAdd(bool sumar) async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference _likesReference = Db().stickers().doc(id);

        DocumentSnapshot _snapshot = await transaction.get(_likesReference);

        int newFollowerCount;
        if (sumar) {
          newFollowerCount = _snapshot.get('comments') + 1;
        } else {
          newFollowerCount = _snapshot.get('comments') - 1;
        }

        // Perform an update on the document
        transaction.update(_likesReference, {'comments': newFollowerCount});

        // Return the new count
        //return newFollowerCount;
      });
    }

    addComment() {
      if (_controller.text.isNotEmpty) {
        Db().stickers().doc(id).collection('comentarios').doc().set({
          'texto': _controller.text,
          'user': c.user.value!.user!.uid.substring(0, 5)
        });
        commentsAdd(true);
        _controller.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Comentarios'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: Db()
                    .stickers()
                    .doc(id)
                    .collection('comentarios')
                    .snapshots(),
                builder: (_, snap) {
                  print(snap.connectionState);
                  if (snap.connectionState == ConnectionState.active) {
                    if (snap.data!.docs.isNotEmpty) {
                      return ListView.builder(
                          itemCount: snap.data!.docs.length,
                          itemBuilder: (_, index) {
                            return ListTile(
                              tileColor: snap.data!.docs
                                      .elementAt(index)
                                      .get('texto')
                                      .toString()
                                      .trim()
                                      .contains(snap.data!.docs
                                          .elementAt(index)
                                          .get('user'))
                                  ? Colors.yellowAccent[100]
                                  : null,
                              onTap: () => _controller.text = '@' +
                                  snap.data!.docs.elementAt(index).get('user') +
                                  ' ',
                              leading: Icon(
                                Icons.account_box,
                                color: Color.lerp(
                                    Theme.of(context).primaryColor,
                                    Colors.purple,
                                    Random().nextDouble()),
                              ),
                              title: Text(snap.data!.docs
                                  .elementAt(index)
                                  .get('texto')),
                              trailing: snap.data!.docs
                                          .elementAt(index)
                                          .get('user') ==
                                      c.user.value!.user!.uid.substring(0, 5)
                                  ? IconButton(
                                      onPressed: () {
                                        Db()
                                            .stickers()
                                            .doc(id)
                                            .collection('comentarios')
                                            .doc(snap.data!.docs
                                                .elementAt(index)
                                                .id)
                                            .delete();
                                        commentsAdd(false);
                                      },
                                      icon: Icon(Icons.delete))
                                  : null,
                              subtitle: Text(
                                  snap.data!.docs.elementAt(index).get('user')),
                            );
                          });
                    }
                    return Center(
                      child: Text('No hay comentarios'),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                    suffix: IconButton(
                        onPressed: () => addComment(), icon: Icon(Icons.send)),
                    border: InputBorder.none,
                    hintText: 'Añade un comentario...')),
          )
        ],
      ),
    );
  }
}
