import 'package:cloud_firestore/cloud_firestore.dart';

class Db {
  final FirebaseFirestore _fb = FirebaseFirestore.instance;
  CollectionReference stickers() {
    return _fb.collection('stickers');
  }
}
