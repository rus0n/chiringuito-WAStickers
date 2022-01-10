import 'package:chiringuito/screens/home.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:seo_renderer/seo_renderer.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //inicializamos dependencias

  await Firebase.initializeApp();
  //await FirebaseAppCheck.instance.activate(
  //    webRecaptchaSiteKey: "6Lc6DPcdAAAAANNKAykGIeGcl9MLsx0k50Vfbi-q");

  if (!kIsWeb) {
    MobileAds.instance.initialize();
    MobileAds.instance.updateRequestConfiguration((RequestConfiguration(
        testDeviceIds: ["2BFA3503083AEAC9D69808A74FE955AF"],
        tagForUnderAgeOfConsent: TagForChildDirectedTreatment.yes)));
    await GetStorage.init();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await configurarLocalTimeZone();
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('splash');
    final settings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(settings,
        onSelectNotification: (String? payload) async {
      if (payload != null && payload == 'dialog') {
        debugPrint('payload: ' + payload);

        Get.dialog(SimpleDialog(
          title: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('Nuevos stickers Disponibles'),
          ),
        ));
      }
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chiringuito WAStickers',
      navigatorObservers: [observer, routeObserver],
      theme: ThemeData(
        fontFamily: GoogleFonts.ptSans().fontFamily,
        primarySwatch: Colors.lightBlue,
      ),
      darkTheme: kIsWeb ? null : ThemeData.dark(),
      home: Home(),
    );
  }
}

Future<void> configurarLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}
