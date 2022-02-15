import 'dart:io';

import 'package:chiringuito/controllers/bottom_navigator_controller.dart';
import 'package:chiringuito/db/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Upload extends StatefulWidget {
  Upload({Key? key, required this.path}) : super(key: key);
  final String path;
  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  Map<String, bool> protagonistas = {
    'Cristobal Soria': false,
    'Pedrerol': false,
    'Alfredo duro': false,
    'Juanfe': false,
    'Iñigo': false,
    "D'Alessandro": false,
    'Juanma Rodriguez': false,
    'Edu Velasco': false,
    'Jota Jordi': false,
    'Lobo Carrasco': false,
    'Fermin': false,
    'El ingeniero': false,
    'Roncero': false,
    'Futbolista': false,
    'Mesii': false,
    'Cristiano Ronaldo': false
  };

  bool load = false;

  InterstitialAd? myInterstitialAd;

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

  loadAd() {
    InterstitialAd.load(
        adUnitId: //'ca-app-pub-3940256099942544/1033173712',
            'ca-app-pub-6592025069346248/5401403908',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            print('Anuncio cargado');
            setState(() {
              myInterstitialAd = ad;
              load = true;
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    File file = File(widget.path);

    Future<File> testCompressAndGetFile(File file, String targetPath) async {
      var result = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path, targetPath,
          quality: 88,
          minHeight: 512,
          minWidth: 512,
          format: CompressFormat.webp);

      print(file.lengthSync());
      print(result!.lengthSync());

      return result;
    }

    loadAd();

    FirebaseAnalytics.instance.logScreenView(screenName: 'Upload');

    return Column(
      children: [
        SizedBox(
          height: 214,
          width: 214,
          child: Image.file(
            File(widget.path),
            height: 200,
            width: 200,
          ),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: protagonistas.length,
                itemBuilder: (_, index) {
                  String protagonista = protagonistas.keys.elementAt(index);
                  return CheckboxListTile(
                      title: Text(protagonista),
                      value: protagonistas.values.elementAt(index),
                      onChanged: (value) {
                        setState(() {
                          protagonistas[protagonista] = value!;
                        });
                      });
                })),
        ElevatedButton.icon(
            onPressed: () async {
              showAd();
              Get.dialog(
                  AlertDialog(
                    title: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  barrierDismissible: false);
              String reference = Db().stickers().doc().id;

              file = await testCompressAndGetFile(file, file.path + '.webp');

              await FirebaseStorage.instance.ref(reference).putFile(file);
              await FirebaseStorage.instance
                  .ref(reference)
                  .updateMetadata(SettableMetadata(contentType: '.webp'));

              protagonistas.removeWhere((key, value) => value == false);

              await Db().stickers().doc(reference).set({
                'imageUrl': await FirebaseStorage.instance
                    .ref(reference)
                    .getDownloadURL(),
                'emojis': [],
                'likes': 0,
                'comments': 0,
                'creado': Timestamp.now(),
                'animado': false,
                'filtro': protagonistas.keys.toList()
              });
              Get.back();
              Get.snackbar('Sticker Publicado',
                  'Compartelo para que tengas mas likes y lo vea mas gente!');
              Get.find<BottomController>().index.value = 0;
            },
            icon: Icon(Icons.post_add),
            label: load
                ? const Text('Publicar')
                : SizedBox(
                    height: 35,
                    width: 35,
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )),
                  ))
      ],
    );
  }
}
