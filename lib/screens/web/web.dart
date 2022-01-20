import 'package:carousel_slider/carousel_slider.dart';
import 'package:chiringuito/screens/web/body_photo.dart';
import 'package:chiringuito/screens/web/hearder_element.dart';
import 'package:chiringuito/styles/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html';

class Web extends StatelessWidget {
  const Web({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _controller = ScrollController();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 1.6,
        leadingWidth: 80,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'web/icons/android-icon-192x192.png',
          ),
        ),
        title: TextRenderer(
          element: HeadingElement.h1(),
          text: Text('Chiringuito WASticker', style: KTextStyles.headerStyle),
        ),
        actions: [
          MediaQuery.of(context).size.width > 800
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _controller.animateTo(100,
                          duration: Duration(seconds: 1),
                          curve: Curves.decelerate),
                      child: HeaderElement(
                        titulo: 'Descargar',
                      ),
                    ),
                    GestureDetector(
                      child: HeaderElement(titulo: 'Cómo utilizar'),
                      onTap: () => _controller.animateTo(1500,
                          duration: Duration(seconds: 1),
                          curve: Curves.decelerate),
                    ),
                    HeaderElement(titulo: 'Nuevas ideas'),
                    SizedBox(width: 10)
                  ],
                )
              : Container(),
        ],
      ),
      body: SingleChildScrollView(
        controller: _controller,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              height: MediaQuery.of(context).size.width / 3.4,
              width: Size.infinite.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextRenderer(
                      element: HeadingElement.h1(),
                      text: Text(
                        'Agrega los mejores packs de stickers\nde El Chiringuito de Jugones',
                        textAlign: TextAlign.center,
                        style: KTextStyles.h1.copyWith(
                            fontSize: MediaQuery.of(context).size.width / 28,
                            color: Colors.white),
                      )),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton.icon(
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.all(5.0),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(15.0)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ))),
                      onPressed: () => launch(
                          'https://play.google.com/apps/testing/com.ruson.chiringuito'),
                      icon: Icon(
                        Icons.android,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: LinkRenderer(
                        link: 'https://play.google.com/com.ruson.chiringuito',
                        anchorText: 'Google Play',
                        child: Text('Google Play',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 800
                                        ? 28
                                        : 14,
                                color: Colors.black)),
                      ))
                ],
              ),
            ),
            SizedBox(height: 100),
            TextRenderer(
                element: HeadingElement.h1(),
                text: Text(
                  'Descarga, comparte y contribuye con\nnuestra gran comunidad del chiringuito',
                  textAlign: TextAlign.center,
                  style: KTextStyles.h3.copyWith(
                      fontSize: MediaQuery.of(context).size.width / 28),
                )),
            SizedBox(
              height: 30,
            ),
            TextRenderer(
                element: HeadingElement.h1(),
                text: Text(
                    'Cualquiera puede tener los mejores packs\nen sus chats de Whatsapp del chiringuito inside',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width / 48,
                        height: 1.6,
                        wordSpacing: 1.6,
                        letterSpacing: 1.6))),
            SizedBox(
              height: 100,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: List.generate(
                  5,
                  (index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 6,
                          child: Image.asset('web/images/${index + 1}.webp'),
                        ),
                      )),
            ),
            SizedBox(
              height: 100,
            ),
            TextRenderer(
                element: HeadingElement.h1(),
                text: Text(
                  'Cómo utilizar Stickers del Chiringuito',
                  style: KTextStyles.h3
                      .copyWith(color: Theme.of(context).primaryColor),
                )),
            SizedBox(
              height: 80,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width / 1.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BodyPhoto(
                        texto: 'Selecciona los stickers\nque más te gustan',
                        paso: '1',
                        foto: 'web/images/seleccionar_mockup.jpg'),
                    SizedBox(
                      height: 100,
                    ),
                    BodyPhoto(
                        texto:
                            'Mira todas las imagenes\nque se añadiran a un pack\n de WhatsApp',
                        paso: '2',
                        foto: 'web/images/vereficar_mockup.jpg'),
                    SizedBox(
                      height: 100,
                    ),
                    BodyPhoto(
                        texto:
                            'WhatsApp te pregunta\nsi quieres añadir el pack\n¡LISTO!',
                        paso: '3',
                        foto: 'web/images/add_mockup.jpg'),
                  ],
                )),
            SizedBox(
              height: 100,
            ),
            TextRenderer(
                element: HeadingElement.h1(),
                text: Text(
                  'Nuevas ideas u Opiniones',
                  style: KTextStyles.h3,
                )),
            SizedBox(height: 50),
            ElevatedButton.icon(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(5.0),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                    backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).primaryColor),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ))),
                onPressed: () => launch('https://twitter.com/PacksStickers'),
                icon: Icon(Icons.post_add),
                label: TextRenderer(
                    element: HeadingElement.h3(),
                    text: Text('Twitter',
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width > 800 ? 28 : 14,
                        )))),
            SizedBox(
              height: 50,
            ),
            Container(
              height: 300,
              color: Theme.of(context).primaryColor,
              child: TextRenderer(
                  element: HeadingElement.h5(),
                  text: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text(
                      'Esta aplicación para Android(de momento) permite añadir packs de stickers del chiringuito de jugones para Whatsapp de una manera facil y en pocos pasos. El chiringuito de jugones es un programa de televisión de españa, en el canal de Mega perteneciente al grupo mediaset, donde debaten y opinan de la actualidad del fútbol. Tienen ademas un canal de Twitch y de Youtube llamado El ChiringuitoTV y el Chiringuito Inside, tambien lo restramiten en la web de mitele',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
