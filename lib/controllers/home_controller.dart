import 'dart:convert';
import 'dart:io';

import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:new_version/new_version.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import '../main.dart';

class HomeController extends GetxController {
  RxList<String> seleccionado = RxList();
  RxList<dynamic> favoritos = RxList();

  RxList<Sticker> destacadoStickers = RxList();
  RxList<Sticker> recienteStickers = RxList();

  var gs = GetStorage();

  Rxn<UserCredential> user = Rxn();

  var ads = <String, BannerAd>{}.obs;
  var ads1 = <String, BannerAd>{}.obs;

  Future<void> onInit() async {
    gs.writeIfNull('favoritos', jsonEncode(['']));
    favoritos.value = jsonDecode(gs.read('favoritos'));
    destacadoStickers.bindStream(stickerDestacadosStream());
    recienteStickers.bindStream(stickerRecienteStream());

    once(destacadoStickers, (_) => loadAds(0));
    once(recienteStickers, (_) => loadAds(1));

    // Notificaciones
    late AndroidNotificationChannel channel;

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name,
                  channelDescription: channel.description, icon: 'splash'),
            ),
            payload: notification.android!.channelId! == '1' &&
                    notification.android!.channelId != null
                ? 'dialog'
                : 'payload');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Get.dialog(SimpleDialog(
        title: Text(message.notification!.title!),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message.notification!.body!),
          )
        ],
      ));
    });
    user.value = await FirebaseAuth.instance.signInAnonymously();
    final newVersion = NewVersion(androidId: 'com.ruson.chiringuito');
    final status = await newVersion.getVersionStatus();

    if (status != null && status.canUpdate) {
      newVersion.showUpdateDialog(
        context: Get.context!,
        versionStatus: status,
        dialogText: 'Actualizacion disponible',
        updateButtonText: 'Actualizar',
        dismissButtonText: 'Más tarde',
      );
    }
    print(user.value!.user!.uid);
    super.onInit();
  }

  addFavoritos(String id) {
    favoritos.add(id);
    gs.write('favoritos', jsonEncode(favoritos));
  }

  //Cargamos anuncios y ordenamos
  loadAds(int index) {
    if (index == 1) {
      for (var i = 0; i < (recienteStickers.length); i++) {
        if (i % 4 == 0) {
          ads1['myBanner$i'] = BannerAd(
            adUnitId: 'ca-app-pub-6592025069346248/3345291016',
            size: AdSize.banner,
            request: AdRequest(
              keywords: [
                'eventos deportivos',
                'ver futbol',
                'futbol tv',
                'nba',
                'nba hoy',
                'liga smartbank',
                'liga santander',
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
            listener: BannerAdListener(
                onAdClosed: (ad) => ad.dispose(),
                onAdFailedToLoad: (ad, error) => print(error.message),
                onAdLoaded: (ad) {
                  print('Cargado');
                }),
          );

          ads1['myBanner$i']!.load();
        }
      }
    } else {
      for (var i = 0; i < (destacadoStickers.length); i++) {
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
            listener: BannerAdListener(
                onAdClosed: (ad) => ad.dispose(),
                onAdFailedToLoad: (ad, error) => print(error.message),
                onAdLoaded: (ad) {
                  print('Cargado');
                }),
          );

          ads['myBanner$i']!.load();
        }
      }
    }
  }

  Future<void> compartir() async {
    final file =
        File('${(await getTemporaryDirectory()).path}/splashscreen.png');
    if (!await file.exists()) {
      final byteData = await rootBundle.load('images/splashscreen.png');

      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }

    await Share.shareFiles([file.path],
        text:
            'Descargate ya la nueva aplicacion para tener los mejores packs de stickers del chiringuito https://play.google.com/store/apps/details?id=com.ruson.chiringuito',
        subject: 'Chiringuito Stickers');
  }

  Future<void> likesAdd(Sticker _sticker) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference _likesReference = Db().stickers().doc(_sticker.id);

      DocumentSnapshot _snapshot = await transaction.get(_likesReference);

      int newFollowerCount = _snapshot.get('likes') + 1;

      // Perform an update on the document
      transaction.update(_likesReference, {'likes': newFollowerCount});

      addFavoritos(_sticker.id);

      // Return the new count
      //return newFollowerCount;
    });
  }

  Stream<List<Sticker>> stickerDestacadosStream() {
    return Db()
        .stickers()
        .orderBy('likes', descending: true)
        .snapshots()
        .map((event) {
      if (event.docs.isNotEmpty) {
        return event.docs.map((e) => Sticker.fromFireStore(e)).toList();
      } else {
        return [];
      }
    });
  }

  Stream<List<Sticker>> stickerRecienteStream() {
    return Db()
        .stickers()
        .orderBy('creado', descending: true)
        .snapshots()
        .map((event) {
      if (event.docs.isNotEmpty) {
        return event.docs.map((e) => Sticker.fromFireStore(e)).toList();
      } else {
        return [];
      }
    });
  }
}
