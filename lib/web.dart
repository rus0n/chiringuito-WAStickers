import 'package:carousel_slider/carousel_slider.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seo_renderer/seo_renderer.dart';

class Web extends StatefulWidget {
  Web({Key? key}) : super(key: key);

  @override
  _Web createState() => _Web();
}

class _Web extends State<Web> {
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
                        onPressed: () => null,
                        icon: Icon(
                          Icons.android,
                        ),
                        label: Text('Google Play',
                            style: TextStyle(
                              fontSize: 24,
                            )))
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Column(
                children: [
                  Text(
                    'Sugiere y puntua stickers\n de chiringuiteros en expansión',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Comparte en los chats de WhatsApp.\n Haz que tus amigos se mueran de envidia con estos stickers\n del chiringuito de jugones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, letterSpacing: 1.8),
                  )
                ],
              ),
              SizedBox(height: 30),
              FutureBuilder<QuerySnapshot>(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Expanded(
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
                                            child: CircularProgressIndicator(
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
              SizedBox(
                height: 40,
              ),
              TextRenderer(
                text: Text('Cómo usar Chiringuito WAStickers',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      color: Theme.of(context).primaryColor,
                    )),
              )
            ],
          ))
        ],
      ),
    );
  }
}
