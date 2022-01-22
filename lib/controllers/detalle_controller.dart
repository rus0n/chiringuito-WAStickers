import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
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

  addPack(List<Sticker> stickers) async {
    showAd();
    Get.dialog(SimpleDialog(
      title: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
            Text('Descargando espere...'),
          ],
        ),
      ),
    ));
    String dir = (await getApplicationDocumentsDirectory()).path;

    Directory packDirectory = Directory('$dir/$id');

    if (!await packDirectory.exists()) {
      packDirectory.create();
    }

    Map pack = {
      "identifier": id,
      "name": "Chringuito Stickers $id",
      "publisher": "Chiringuito Stickers",
      "tray_image_file": '',
      "image_data_version": "1",
      "avoid_cache": false,
      "publisher_email": "devinfojob@gmail.com",
      "publisher_website": "https://chiringuitostickers.com",
      "privacy_policy_website":
          "https://github.com/vincekruger/flutter_whatsapp_stickers",
      "license_agreement_website":
          "https://github.com/vincekruger/flutter_whatsapp_stickers",
      "stickers": []
    };

    List stickersPack = [];

    for (var sticker in stickers) {
      File stickerFile = File('${packDirectory.path}/${sticker.id}.webp');

      await FirebaseStorage.instance.ref(sticker.id).writeToFile(stickerFile);

      stickersPack.add({
        "image_file": "${sticker.id}.webp",
        "emojis": ["☕", "🙂"]
      });
    }

    pack['stickers'] = stickersPack;

    File jsonFile = File('$dir/sticker_packs/sticker_packs.json');

    String jsonString = await jsonFile.readAsStringSync();

    Map jsonMap = jsonDecode(jsonString);

    List stickerPackList = jsonMap['stickers_packs'];

    stickerPackList.add(pack);

    jsonFile.writeAsStringSync(jsonEncode(jsonMap));

    WhatsAppStickers().addStickerPack(
        stickerPackIdentifier: id,
        stickerPackName: "Chringuito Stickers $id",
        listener: _listener);
  }

  Future<void> _listener(StickerPackResult action, bool result,
      {String? error}) async {
    print(error);
    print(action);
    print(result);
  }

  createLocalFile(List<Sticker> stickers) async {
    showAd();
    Get.dialog(SimpleDialog(
      title: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
            Text('Descargando espere...'),
          ],
        ),
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
        adUnitId: //'ca-app-pub-3940256099942544/1033173712',
            'ca-app-pub-6592025069346248/5401403908',
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
