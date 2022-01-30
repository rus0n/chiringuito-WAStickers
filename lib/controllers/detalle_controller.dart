import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  int id = 1;

  InterstitialAd? myInterstitialAd;

  @override
  void onInit() {
    super.onInit();
    loadAd();
    prepareDirectory();
    gs.writeIfNull('pack', 1);
    id = gs.read('pack');
    checkInstallStatus();
    checkWhatsapp();
  }

  String _platformVersion = 'Unknown';
  bool _whatsAppInstalled = false;
  bool _whatsAppConsumerAppInstalled = false;
  bool _whatsAppSmbAppInstalled = false;

  Future<void> checkWhatsapp() async {
    String platformVersion;

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await WhatsAppStickers.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    bool whatsAppInstalled = await WhatsAppStickers.isWhatsAppInstalled;
    bool whatsAppConsumerAppInstalled =
        await WhatsAppStickers.isWhatsAppConsumerAppInstalled;
    bool whatsAppSmbAppInstalled =
        await WhatsAppStickers.isWhatsAppSmbAppInstalled;

    _platformVersion = platformVersion;
    _whatsAppInstalled = whatsAppInstalled;
    _whatsAppConsumerAppInstalled = whatsAppConsumerAppInstalled;
    _whatsAppSmbAppInstalled = whatsAppSmbAppInstalled;

    print(_platformVersion);
    print(_whatsAppInstalled);
    print(_whatsAppConsumerAppInstalled);
    print(_whatsAppSmbAppInstalled);
  }

  Map<String, dynamic> jsonFilePack(List<Sticker> stickers) {
    return {
      "identifier": "$id",
      "name": "Chiringuito-Stickers-$id",
      "publisher": "Chiringuitostickers App",
      "tray_image_file": "tray-icon.png",
      "image_data_version": "1",
      "avoid_cache": false,
      "publisher_email": "",
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

  final WhatsAppStickers _waStickers = WhatsAppStickers();

  Directory? _applicationDirectory;
  Directory? _stickerPacksDirectory;
  File? _stickerPacksConfigFile;

  Map<String, dynamic>? _stickerPacksConfig;
  List<dynamic>? _storedStickerPacks;

  bool packInstalled = false;

  prepareDirectory() async {
    _applicationDirectory = await getApplicationDocumentsDirectory();
    //Creamos las carpeta necesaria
    _stickerPacksDirectory =
        Directory("${_applicationDirectory?.path}/sticker_packs");
    _stickerPacksConfigFile =
        File("${_stickerPacksDirectory?.path}/sticker_packs.json");
    _stickerPacksConfigFile!.deleteSync();

    //Creamos el archivo de configuracion si no existe
    if (!await _stickerPacksConfigFile!.exists()) {
      _stickerPacksConfigFile!.createSync(recursive: true);
      _stickerPacksConfig = {
        "android_play_store_link": "",
        "ios_app_store_link": "",
        "sticker_packs": [],
      };
      String contentsOfFile = jsonEncode(_stickerPacksConfig) + "\n";
      _stickerPacksConfigFile!.writeAsStringSync(contentsOfFile, flush: true);
    }

    //Cargamos los packs de configuracion

    _stickerPacksConfig =
        jsonDecode((await _stickerPacksConfigFile!.readAsString()));
    _storedStickerPacks = _stickerPacksConfig!['sticker_packs'];
  }

  checkInstallStatus() async {
    packInstalled = await _waStickers.isStickerPackInstalled(id.toString());
    if (packInstalled) {
      id = id++;
    }
  }

  Future<bool> downloadSticker(List<Sticker> _stickers) async {
    Directory? packageDirectory =
        Directory('${_stickerPacksDirectory!.path}/' + id.toString())
          ..createSync(recursive: true);

    for (var _sticker in _stickers) {
      File file = File(packageDirectory.path + '/' + _sticker.id + '.webp')
        ..createSync(recursive: true);

      await FirebaseStorage.instance.ref(_sticker.id).writeToFile(file);

      print(file.path);
    }

    //añadimos el tray-image
    final byteData = await rootBundle.load('images/trayImage.png');
    List<int> bytes = Uint8List.view(
        byteData.buffer, byteData.offsetInBytes, byteData.lengthInBytes);
    File('${packageDirectory.path}/tray-icon.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    print(packageDirectory.listSync());

    Map<String, dynamic> packageContentsMap = jsonFilePack(_stickers);

    _storedStickerPacks!.removeWhere(
        (item) => item['identifier'] == packageContentsMap['identifier']);
    _storedStickerPacks!.add(packageContentsMap);

    //Añadimos a la configuracion y actualizamos
    _stickerPacksConfig!['sticker_packs'] = _storedStickerPacks;
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String contentsOfFile = encoder.convert(_stickerPacksConfig) + "\n";
    _stickerPacksConfigFile!.deleteSync();
    _stickerPacksConfigFile!.createSync(recursive: true);
    _stickerPacksConfigFile!.writeAsStringSync(contentsOfFile, flush: true);

    print(_stickerPacksConfig);
    _waStickers.updatedStickerPacks(id.toString());
    return true;
  }

  addPack(List<Sticker> _stickers) async {
    Get.dialog(AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Descargando espere...'),
          )
        ],
      ),
    ));

    bool sucess = await downloadSticker(_stickers);

    if (sucess) {
      _waStickers.addStickerPack(
          stickerPackIdentifier: id.toString(),
          stickerPackName: 'Chiringuito Stickers App',
          listener: _listener);
    }
  }

  Future<void> _listener(StickerPackResult action, bool result,
      {String? error}) async {
    print(error);
    print(action);
    print(result);
    Get.back();
    if (action == StickerPackResult.ADD_SUCCESSFUL) {
      print('succesful');
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
