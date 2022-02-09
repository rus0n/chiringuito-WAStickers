import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:chiringuito/screens/detalle.dart';
import 'package:chiringuito/screens/list_stickers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var h = Get.put(HomeController());

    return Obx(() => DefaultTabController(
          length: 2,
          child: Scaffold(
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
              ],
              bottom: const TabBar(tabs: [
                Tab(text: 'Destacados'),
                Tab(
                  text: 'Más reciente',
                )
              ]),
            ),
            body: TabBarView(children: [
              ListSticker(
                stickers: h.destacadoStickers,
                ads: h.ads,
              ),
              ListSticker(stickers: h.recienteStickers, ads: h.ads1)
            ]),
            floatingActionButton: h.seleccionado.length < 3
                ? FloatingActionButton.extended(
                    onPressed: () => null,
                    label: Text(
                        'Selecciona + ${3 - h.seleccionado.length} Stickers'))
                : FloatingActionButton.extended(
                    onPressed: () {
                      List<Sticker> _stickers = [];
                      _stickers = h.destacadoStickers
                          .where(
                            (p0) => h.seleccionado.contains(p0.id),
                          )
                          .toList();
                      print(_stickers.length);
                      FirebaseAnalytics.instance
                          .setCurrentScreen(screenName: 'Detalle_Page');
                      Get.to(() => Detalle(stickers: _stickers));
                    },
                    label: Text('Añadir'),
                    icon: Icon(Icons.add),
                  ),
          ),
        ));
  }
}
