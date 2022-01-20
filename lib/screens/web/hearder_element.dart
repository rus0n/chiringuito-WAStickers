import 'dart:html';

import 'package:chiringuito/styles/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';

class HeaderElement extends StatelessWidget {
  const HeaderElement({Key? key, required this.titulo}) : super(key: key);
  final String titulo;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: Colors.white30),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextRenderer(
            element: HeadingElement.h1(),
            text: Text(
              titulo,
              style: KTextStyles.headerStyle,
            ),
          ),
        ),
      ),
    );
  }
}
