import 'dart:convert';
import 'dart:io';

import 'package:chiringuito/models/stickers_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DetalleController extends GetxController {
  int id = 1;

  @override
  void onInit() {
    super.onInit();
    checkWhatsapp();
    prepareDirectory();
    checkInstallStatus();
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

    print('plataforma $_platformVersion');
    print(_whatsAppInstalled);
    print(_whatsAppConsumerAppInstalled);
    print(_whatsAppSmbAppInstalled);
  }

  Map<String, dynamic> jsonFilePack(List<Sticker> stickers) {
    return {
      "identifier": "$id",
      "name": "Chiringuito-Stickers-$id",
      "publisher": "Chiringuito stickers App",
      "tray_image_file": "tray_icon.png",
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

  prepareDirectory() async {
    _applicationDirectory = await getApplicationDocumentsDirectory();
    //Creamos las carpeta necesaria
    _stickerPacksDirectory =
        Directory("${_applicationDirectory?.path}/sticker_packs");
    _stickerPacksConfigFile =
        File("${_stickerPacksDirectory?.path}/sticker_packs.json");

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
    bool packInstalled =
        await _waStickers.isStickerPackInstalled(id.toString());
    print('paquete instalado: $packInstalled');
    if (packInstalled) {
      id = id++;
    }
  }

  Future<bool> downloadSticker(List<Sticker> _stickers) async {
    // creamos la carpeta donde iran los stickers
    Directory? packageDirectory =
        Directory('${_stickerPacksDirectory!.path}/$id')
          ..create(recursive: true);

    for (var _sticker in _stickers) {
      File file = File('${packageDirectory.path}/${_sticker.id}.webp')
        ..createSync(recursive: false);

      await FirebaseStorage.instance.ref(_sticker.id).writeToFile(file);
      print(file.uri);
    }

    //añadimos el tray-image
    File file = File('${packageDirectory.path}/tray_icon.png')
      ..createSync(recursive: false);

    await FirebaseStorage.instance.ref('trayImage.png').writeToFile(file);

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
    print(contentsOfFile);
    print(_stickerPacksConfig);
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

    _waStickers.updatedStickerPacks(id.toString());
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, targetPath,
        quality: 95,
        minHeight: 512,
        minWidth: 512,
        format: CompressFormat.webp);
    file.delete();
    print(result!.lengthSync());

    return result;
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
}
