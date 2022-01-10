import 'package:carousel_slider/carousel_slider.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html';

class Web extends StatefulWidget {
  Web({Key? key}) : super(key: key);

  @override
  _Web createState() => _Web();
}

class _Web extends State<Web> {
  Widget paso(String paso, String titulo, String texto, String imagen,
      bool invertPosition) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        invertPosition
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      paso,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          backgroundColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextRenderer(
                        element: HeadingElement.h3(),
                        text: Text(
                          titulo,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextRenderer(
                        element: HeadingElement.h4(),
                        text: Text(
                          texto,
                          style: TextStyle(fontSize: 24),
                        )),
                  )
                ],
              )
            : ImageRenderer(
                alt: texto,
                link: titulo,
                child: Image.asset(
                  imagen,
                  scale: 4.5,
                ),
              ),
        SizedBox(
          width: 150,
        ),
        invertPosition
            ? ImageRenderer(
                alt: texto,
                link: titulo,
                child: Image.asset(
                  imagen,
                  scale: 4.5,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      paso,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          backgroundColor: Theme.of(context).primaryColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextRenderer(
                        element: HeadingElement.h3(),
                        text: Text(
                          titulo,
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextRenderer(
                        element: HeadingElement.h4(),
                        text: Text(
                          texto,
                          style: TextStyle(fontSize: 24),
                        )),
                  )
                ],
              )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80,
            color: Theme.of(context).primaryColor,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextRenderer(
                    element: HeadingElement.h4(),
                    text: Text(
                      'Chiringuito WAStickers',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                  ),
                ),
                Spacer(),
                TextButton(
                    onPressed: () => null,
                    child: TextRenderer(
                      element: HeadingElement.h6(),
                      text: Text(
                        'Descargar',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                    onPressed: () => null,
                    child: TextRenderer(
                      element: HeadingElement.h6(),
                      text: Text(
                        'Cómo Utilizar',
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
          Expanded(
              child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    image: DecorationImage(
                        alignment: Alignment.center,
                        fit: BoxFit.cover,
                        opacity: 0.7,
                        image: AssetImage('images/app-icon.png'))),
                height: 400,
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                    ),
                    TextRenderer(
                      element: HeadingElement.h1(),
                      text: Text(
                        'Agrega los mejores stickers\ndel Chiringuito para WhatsApp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.6,
                            wordSpacing: 1.5,
                            fontSize: 42,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    ElevatedButton.icon(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(5.0),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(15.0)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ))),
                        onPressed: () => launch(
                            'https://play.google.com/apps/testing/com.ruson.chiringuito'),
                        icon: Icon(
                          Icons.android,
                        ),
                        label: LinkRenderer(
                          link: 'https://play.google.com/com.ruson.chiringuito',
                          anchorText: 'Google Play',
                          child: Text('Google Play',
                              style: TextStyle(
                                fontSize: 24,
                              )),
                        ))
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Column(
                children: [
                  TextRenderer(
                    element: HeadingElement.h2(),
                    text: Text(
                      'Sugiere y puntua stickers\n de chiringuiteros en expansión',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextRenderer(
                    element: HeadingElement.h2(),
                    text: Text(
                      'Comparte en los chats de WhatsApp.\n Haz que tus amigos se mueran de envidia con estos stickers\n del chiringuito de jugones.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, letterSpacing: 1.8),
                    ),
                  )
                ],
              ),
              SizedBox(height: 60),
              Semantics(
                label: 'CarouselSLider',
                slider: true,
                hint: 'show images',
                child: FutureBuilder<QuerySnapshot>(
                    future: Db()
                        .stickers()
                        .orderBy('likes', descending: true)
                        .limit(16)
                        .get(),
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.done) {
                        if (snap.data != null) {
                          List<Sticker> _stickers = snap.data!.docs
                              .map((e) => Sticker.fromFireStore(e))
                              .toList();
                          return CarouselSlider(
                              options: CarouselOptions(
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 3),
                                  height: 400,
                                  initialPage: 0,
                                  viewportFraction: 0.2,
                                  autoPlayAnimationDuration:
                                      Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  scrollDirection: Axis.horizontal),
                              items: List.generate(
                                _stickers.length,
                                (index) => Card(
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                        child: ImageRenderer(
                                          alt: 'Stickers Chiringuito',
                                          link: _stickers[index].imageUrl!,
                                          child: Image.network(
                                            _stickers[index].imageUrl!,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Center(
                                              child: Text(error.toString()),
                                            ),
                                            loadingBuilder:
                                                (_, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16.0, 8.0, 16.0, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: Colors.lightBlue,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 40,
                                                height: 10,
                                              ),
                                              Text(
                                                _stickers[index]
                                                        .likes
                                                        .toString() +
                                                    '  Me gusta',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ));
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              ),
              SizedBox(
                height: 60,
              ),
              TextRenderer(
                element: HeadingElement.h1(),
                text: Text('Cómo usar Chiringuito WAStickers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
              SizedBox(
                height: 30,
              ),
              TextRenderer(
                  element: HeadingElement.h2(),
                  text: Text(
                      'Permite seleccionar tus sticker favortios,\nhacer una paquete y añadirlo a WA.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26))),
              SizedBox(height: 150),
              paso(
                  ' Paso 1',
                  'Selecciona!',
                  'Selecciona 3 o más imágenes\nque más te gusten',
                  'web/icons/seleccionar.jpg',
                  false),
              SizedBox(
                width: 450,
              ),
              paso(
                  ' Paso 2',
                  'Verifica',
                  'Verifica que seleccionaste\ntodo lo que has querido',
                  'web/icons/verificar.jpg',
                  true),
              SizedBox(height: 250),
              paso(
                  ' Paso 3 ',
                  'Añade',
                  'Añade el pack con todo los stickers\nque apareceran en tu Chat para ser\ncompartidos con todo el mundo',
                  'web/icons/add.jpg',
                  false),
              SizedBox(
                height: 150,
              ),
              TextRenderer(
                  element: HeadingElement.h1(),
                  text: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '¿Porqué usar esta aplicación?',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 36),
                    ),
                  )),
              TextRenderer(
                  element: HeadingElement.h2(),
                  text: Text(
                    'Esta aplicación esta en continuo desarrollo, cada vez añadimos nuevas funciones.\n Sobre todo lo que el publico nos comenta.\n Podras seleccionar los mejores stickers sobre el chiringuito de jugones, Alfredo Duro, Pedrerol, Cristobal Soria y más.\n Los podras compartir con tus mejores amigos y familia mediante Whatsapp.\n A parte puedes sugerir nuevas funciones, stickers y no dudes en compartir para ser una comunidad cada vez mas grande',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  )),
              SizedBox(
                height: 200,
              ),
              Container(
                height: 200,
                color: Theme.of(context).primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Condiciones de uso'),
                    Text('Politica de privacidad'),
                    Text('Contactenos')
                  ],
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
