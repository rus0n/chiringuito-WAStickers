import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Help extends StatefulWidget {
  Help({Key? key}) : super(key: key);

  @override
  _HelpState createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLines: 6,
              decoration: const InputDecoration(
                  hintText: 'Feedback', border: OutlineInputBorder()),
              controller: _controller,
            ),
          ),
          ElevatedButton.icon(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('feedback')
                      .doc()
                      .set({'mensaje': _controller.text});
                  _controller.clear();
                  Get.snackbar('Enviado!',
                      'Gracias por tu mensaje, nos inspiraremos en ello');
                }
              },
              icon: const Icon(Icons.send),
              label: const Text('Enviar Feedback'))
        ],
      ),
    );
  }
}
