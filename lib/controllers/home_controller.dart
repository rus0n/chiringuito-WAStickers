import 'dart:convert';

import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../main.dart';

class HomeController extends GetxController {
  RxList<int> seleccionado = RxList();
  RxList<dynamic> favoritos = RxList();

  RxList<Sticker> stickers = RxList();

  var gs = GetStorage();

  final BannerAd myBanner = BannerAd(
    adUnitId: //'ca-app-pub-3940256099942544/6300978111',
        'ca-app-pub-6592025069346248/2775240563',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  Future<void> onInit() async {
    gs.writeIfNull('favoritos', jsonEncode(['']));
    favoritos.value = jsonDecode(gs.read('favoritos'));
    stickers.bindStream(stickerStream());
    myBanner.load();

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
