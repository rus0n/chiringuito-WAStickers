import 'dart:convert';
import 'dart:io';

import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

import '../main.dart';

class HomeController extends GetxController {
  RxList<int> seleccionado = RxList();
  RxList<dynamic> favoritos = RxList();

  RxList<Sticker> stickers = RxList();

  var gs = GetStorage();

  var load = false.obs;

  final BannerAd myBanner = BannerAd(
    adUnitId: //'ca-app-pub-3940256099942544/6300978111',
        'ca-app-pub-6592025069346248/2775240563',
    size: AdSize.banner,
    request: const AdRequest(keywords: [
      'futbol',
      'chiringuito de jugones',
      'alfredo duro',
      'cristobal soria',
      'deporte',
      'pedrerol',
      'twitter'
    ]),
    listener: BannerAdListener(
      onAdFailedToLoad: (ad, error) => print(error.message),
    ),
  );

  Future<void> onInit() async {
    gs.writeIfNull('favoritos', jsonEncode(['']));
    favoritos.value = jsonDecode(gs.read('favoritos'));
    stickers.bindStream(stickerStream());

    await myBanner.load();

    load.value = true;

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
    super.onInit();
  }

  addFavoritos(String id) {
    favoritos.add(id);
    gs.write('favoritos', jsonEncode(favoritos));
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

  Stream<List<Sticker>> stickerStream() {
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
}
