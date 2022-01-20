import 'dart:html';

import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';

class BodyPhoto extends StatelessWidget {
  const BodyPhoto(
      {Key? key, required this.texto, required this.paso, required this.foto})
      : super(key: key);

  final String texto;
  final String paso;
  final String foto;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paso $paso',
              style: TextStyle(
                  backgroundColor: Theme.of(context).primaryColor,
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),
            Container(
              width: 450,
              child: TextRenderer(
                  element: HeadingElement.h4(),
                  text: Text(
                    texto,
                    style: TextStyle(fontSize: 28),
                  )),
            )
          ],
        ),
        Image.asset(
          foto,
          scale: 4,
        ),
      ],
    );
  }
}
