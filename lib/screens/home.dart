import 'dart:math';
import 'dart:ui';

import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:chiringuito/screens/add.dart';
import 'package:chiringuito/screens/comments.dart';
import 'package:chiringuito/screens/detalle.dart';
import 'package:chiringuito/screens/help.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var h = Get.put(HomeController());

    Map<String, BannerAd> ads = <String, BannerAd>{};

    for (var i = 0; i < (h.stickers.length); i++) {
      if (i % 4 == 0) {
        ads['myBanner$i'] = BannerAd(
          adUnitId: 'ca-app-pub-6592025069346248/2775240563',
          size: AdSize.banner,
          request: AdRequest(
            keywords: [
              'eventos deportivos',
              'ver futbol',
              'futbol tv',
              'dazn f1',
              'nba',
              'nba hoy',
              'liga smartbank',
              'liga santander',
              'universidad online',
              'miss padel',
              'les corts futbol sala',
              'champions league',
              'futbol',
              'chiringuito de jugones',
              'alfredo duro',
              'cristobal soria',
              'deporte',
              'pedrerol',
              'twitter'
            ],
          ),
          listener: BannerAdListener(onAdClosed: (ad) => ad.dispose()),
        );

        ads['myBanner$i']!.load();
      }
    }

    Future<void> likesAdd(Sticker _sticker) async {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference _likesReference = Db().stickers().doc(_sticker.id);

        DocumentSnapshot _snapshot = await transaction.get(_likesReference);

        int newFollowerCount = _snapshot.get('likes') + 1;

        // Perform an update on the document
        transaction.update(_likesReference, {'likes': newFollowerCount});

        h.addFavoritos(_sticker.id);

        // Return the new count
        //return newFollowerCount;
      });
    }

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: h.seleccionado.isNotEmpty
                ? Text(
                    h.seleccionado.length.toString() +
                        '/' +
                        '30' +
                        ' seleccionado',
                    textAlign: TextAlign.center)
                : const Text('Chiringuito Stickers'),
            actions: [
              IconButton(
                  onPressed: () => h.compartir(), icon: Icon(Icons.share)),
              IconButton(
                  onPressed: () => Get.to(Help()),
                  icon: const Icon(Icons.help_center))
            ],
          ),
          body: h.stickers.isEmpty
              ? Shimmer(
                  gradient: LinearGradient(colors: [
                    Colors.white54,
                    Theme.of(context).primaryColor,
                    Colors.white54
                  ]),
                  child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: 30,
                      itemBuilder: (_, index) => Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)))),
                                )
                              ],
                            ),
                          )))
              : SizedBox(
                  height: Get.size.height,
                  width: Get.size.width,
                  child: ListView.separated(
                      cacheExtent: 300,
                      padding: EdgeInsets.all(8),
                      itemBuilder: (_, index) {
                        Sticker _sticker = h.stickers.elementAt(index);
                        return GestureDetector(
                            onTap: () {
                              if (h.seleccionado.length < 30) {
                                bool _select = false;
                                h.seleccionado.forEach((element) {
                                  if (element == index) {
                                    _select = true;
                                  }
                                });
                                print(_select);
                                if (_select && h.seleccionado.isNotEmpty) {
                                  h.seleccionado.remove(index);
                                } else {
                                  h.seleccionado.add(index);
                                }
                                print(h.stickers.elementAt(index).id);

                                print(h.seleccionado);
                              }
                            },
                            child: Card(
                              elevation: 3,
                              clipBehavior: Clip.antiAlias,
                              color: (h.seleccionado.contains(index) &&
                                      h.seleccionado.isNotEmpty)
                                  ? Colors.lightBlueAccent
                                  : null,
                              child: SizedBox(
                                height: 170,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: (Get.size.width / 3.6),
                                          bottom: 8,
                                          top: 8),
                                      child: Image.network(
                                        _sticker.imageUrl!,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Center(
                                          child: Text('No se puede actualizar'),
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
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              onPressed: () =>
                                                  likesAdd(_sticker),
                                              icon: h.favoritos
                                                      .contains(_sticker.id)
                                                  ? Icon(Icons.favorite,
                                                      color: Colors.blueAccent)
                                                  : Icon(
                                                      Icons.favorite_border)),
                                          Text('${_sticker.likes}'),
                                          IconButton(
                                              onPressed: () =>
                                                  Get.to(() => Comments(
                                                        id: _sticker.id,
                                                      )),
                                              icon: Icon(
                                                  Icons.add_comment_outlined)),
                                          Text('${_sticker.comments}')
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10)
                                  ],
                                ),
                              ),
                            ));
                      },
                      separatorBuilder: (_, index) {
                        if ((index % 4 == 0) && ads['myBanner$index'] != null) {
                          return Container(
                              alignment: Alignment.center,
                              width:
                                  ads['myBanner$index']!.size.width.toDouble(),
                              height:
                                  ads['myBanner$index']!.size.height.toDouble(),
                              child: AdWidget(ad: ads['myBanner$index']!));
                        }
                        return Container();
                      },
                      itemCount: h.stickers.length),
                ),
          floatingActionButton: h.seleccionado.length < 3
              ? FloatingActionButton.extended(
                  onPressed: () => null,
                  label: Text(
                      'Selecciona + ${3 - h.seleccionado.length} Stickers'))
              : FloatingActionButton.extended(
                  onPressed: () {
                    List<Sticker> _stickers = [];
                    for (var index in h.seleccionado) {
                      _stickers.add(h.stickers.elementAt(index));
                    }
                    print(_stickers.length);
                    FirebaseAnalytics.instance
                        .setCurrentScreen(screenName: 'Detalle_Page');
                    Get.to(() => Detalle(stickers: _stickers));
                  },
                  label: Text('Añadir'),
                  icon: Icon(Icons.add),
                ),
        ));
  }
}
