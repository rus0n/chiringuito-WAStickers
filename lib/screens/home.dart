import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:chiringuito/screens/add.dart';
import 'package:chiringuito/screens/detalle.dart';
import 'package:chiringuito/screens/help.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var h = Get.put(HomeController());

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
            leading: h.seleccionado.isNotEmpty
                ? Center(
                    child: Text(
                      h.seleccionado.length.toString() + '/' + '30',
                      textAlign: TextAlign.center,
                    ),
                  )
                : null,
            title: const Text('Chiringuito Stickers'),
            actions: [
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
                  child: GridView.builder(
                      padding: EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 8 / 9,
                      ),
                      itemCount: 30,
                      itemBuilder: (_, index) => Card(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)))),
                                )
                              ],
                            ),
                          )))
              : RefreshIndicator(
                  onRefresh: () async => h.stickers.refresh(),
                  child: GridView.builder(
                      cacheExtent: (h.stickers.length / 5) * 100,
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 8.0 / 9.0,
                      ),
                      itemCount: h.stickers.length,
                      itemBuilder: (_, index) {
                        Sticker _sticker = h.stickers.elementAt(index);
                        return GestureDetector(
                          onTap: () {
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

                            print(h.seleccionado);
                          },
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            color: (h.seleccionado.contains(index) &&
                                    h.seleccionado.isNotEmpty)
                                ? Colors.lightBlueAccent
                                : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 16 / 11,
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
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 8.0, 16.0, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      IconButton(
                                          onPressed: () => likesAdd(_sticker),
                                          icon: h.favoritos
                                                  .contains(_sticker.id)
                                              ? Icon(Icons.favorite,
                                                  color: Colors.blueAccent)
                                              : Icon(Icons.favorite_border)),
                                      Text(_sticker.likes.toString() +
                                          '  Me gusta')
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ),
          bottomSheet: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  alignment: Alignment.center,
                  width: h.myBanner.size.width.toDouble(),
                  height: h.myBanner.size.height.toDouble(),
                  child: AdWidget(ad: h.myBanner))
            ],
          ),
          floatingActionButton: h.seleccionado.length < 3
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: FloatingActionButton.extended(
                      onPressed: () => null,
                      label: Text(
                          'Selecciona ${3 - h.seleccionado.length} Stickers')),
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      List<Sticker> _stickers = [];
                      for (var index in h.seleccionado) {
                        _stickers.add(h.stickers.elementAt(index));
                      }
                      Get.to(() => Detalle(stickers: _stickers));
                    },
                    label: Text('Añadir'),
                    icon: Icon(Icons.add),
                  ),
                ),
        ));
  }
}
