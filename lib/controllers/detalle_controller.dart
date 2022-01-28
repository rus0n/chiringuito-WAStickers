import 'dart:convert';
import 'dart:io';

import 'package:chiringuito/models/stickers_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';

class DetalleController extends GetxController {
  GetStorage gs = GetStorage();

  String id = '1';
  String stickerPackJsonTemp = '';

  InterstitialAd? myInterstitialAd;

  @override
  void onInit() {
    super.onInit();
    loadAd();
    gs.writeIfNull('pack', '1');
    id = gs.read('pack');
  }

  final Map headJson = {
    "android_play_store_link":
        "https://play.google.com/store/apps/details?id=com.ruson.chiringuito",
    "ios_app_store_link": "",
    "sticker_packs": []
  };

  Map jsonFilePack(List<Sticker> stickers) {
    return {
      "identifier": id,
      "name": "Chiringuito Stickers $id",
      "publisher": "Chiringuito stickers",
      "tray_image_file": "trayImage.png",
      "image_data_version": "1",
      "avoid_cache": false,
      "publisher_email": "devinfojob@gmail.com",
      "publisher_website": "https://chiringuitostickers.com/",
      "privacy_policy_website":
          "https://coronayuda.blogspot.com/p/politica-de-privacidad.html",
      "license_agreement_website":
          "https://github.com/vincekruger/flutter_whatsapp_stickers",
      "stickers": List.generate(stickers.length, (index) {
        return {
          "image_file": "${stickers[index].id}.webp",
          "emojis": stickers[index].emojis
        };
      })
    };
  }

  addPack(List<Sticker> stickers) async {
    showAd();
    Get.dialog(
        SimpleDialog(
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
        ),
        barrierDismissible: true); //ponerlo a false
    String dir = (await getApplicationDocumentsDirectory()).path;
    //Creamos el archivo json
    Directory stickerPacksDir = Directory('$dir/sticker_packs');
    if (!await stickerPacksDir.exists()) {
      stickerPacksDir.create();
    }
    //añadimos el pack al archivo json
    Map jsonFile = headJson;
    List stickerPacksList = jsonFile['sticker_packs'];
    stickerPacksList.add(jsonFilePack(stickers));
    jsonFile['sticker_packs'] = stickerPacksList;
    print(stickerPacksList);

    //guardamos el archivo json
    File stickerPacksFile = File('${stickerPacksDir.path}/sticker_packs.json');
    stickerPacksFile.writeAsStringSync(jsonEncode(jsonFile));

    //guardamos los stickers desde los servidores
    Directory packDirectory =
        Directory('${stickerPacksDir.path}/$id'); //carpeta del id

    if (!await packDirectory.exists()) {
      packDirectory.create();
    }

    for (var sticker in stickers) {
      File stickerFile = File('${packDirectory.path}/${sticker.id}.webp');

      await FirebaseStorage.instance.ref(sticker.id).writeToFile(stickerFile);
      print(stickerFile.readAsBytes());
    }

    final byteData = await rootBundle.load('images/trayImage.png');
    final file = File('${packDirectory.path}/trayImage.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    print(packDirectory.listSync());

    //stickerPackJsonTemp = jsonEncode(jsonFile);
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
    if (action == StickerPackResult.ADD_SUCCESSFUL) {
      int pack = int.parse(id);
      pack = pack++;
      gs.write('pack', pack.toString());
      gs.write('jsonFile', stickerPackJsonTemp);
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
