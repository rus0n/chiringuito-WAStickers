import 'package:cloud_firestore/cloud_firestore.dart';

class Sticker {
  String id;
  String? imageUrl;
  List<String>? emojis;
  int likes = 0;

  Sticker({required this.id, this.imageUrl, this.emojis, required this.likes});

  factory Sticker.fromFireStore(DocumentSnapshot snap) {
    return Sticker(
        id: snap.id,
        imageUrl: snap.get('imageUrl'),
        emojis: ['🙃'], //snap.get('emojis'),
        likes: snap.get('likes'));
  }
}
