import 'dart:io';
import 'dart:math';

import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_stickers/whatsapp_stickers.dart';
import 'package:whatsapp_stickers/exceptions.dart';

class DetalleController extends GetxController {
  GetStorage gs = GetStorage();

  String id =
      ((Random().nextInt(30) * 400) + DateTime.now().microsecond).toString();

  InterstitialAd? myInterstitialAd;

  @override
  void onInit() {
    super.onInit();
    loadAd();
  }

  void createLocalFile(List<Sticker> stickers) async {
    showAd();
    Get.dialog(SimpleDialog(
      title: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Text('Descargando espere...'),
      ),
    ));
    String dir = (await getApplicationDocumentsDirectory()).path;

    var stickerPack = WhatsappStickers(
        identifier: id,
        name: 'Chiringuito WAStickers $id',
        publisher: 'Chinguito WAStickers',
        trayImageFileName:
            WhatsappStickerImage.fromAsset('images/trayImage.png'));

    ;

    for (var sticker in stickers) {
      File stickerFile = File('$dir/${sticker.id}.webp');

      await FirebaseStorage.instance.ref(sticker.id).writeToFile(stickerFile);

      stickerPack.addSticker(
          WhatsappStickerImage.fromFile(stickerFile.path), ['🙃', '😓']);
    }

    Get.back();

    try {
      await stickerPack.sendToWhatsApp();
    } on WhatsappStickersException catch (e) {
      print(e.cause);
    }
  }

  loadAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        //'ca-app-pub-6592025069346248/5401403908',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            myInterstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  showAd() {
    myInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('%ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        loadAd();
      },
      onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
    );
    myInterstitialAd!.show();
    myInterstitialAd = null;
  }
}
