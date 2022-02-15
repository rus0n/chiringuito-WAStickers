import 'package:cloud_firestore/cloud_firestore.dart';

class Sticker {
  String id;
  String? imageUrl;
  List<String>? emojis;
  int? likes = 0;
  int? comments = 0;
  bool animado = false;
  DateTime creado;

  Sticker(
      {required this.id,
      this.imageUrl,
      this.emojis,
      this.likes,
      this.comments,
      required this.animado,
      required this.creado});

  factory Sticker.fromFireStore(DocumentSnapshot snap) {
    return Sticker(
        id: snap.id,
        imageUrl: snap.get('imageUrl'),
        emojis: ['🙃'], //snap.get('emojis'),
        likes: snap.get('likes'),
        comments: snap.get('comments'),
        animado: snap.get('animado'),
        creado: snap.get('creado').toDate());
  }
}
