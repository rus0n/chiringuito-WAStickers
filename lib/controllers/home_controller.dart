import 'package:chiringuito/db/firestore.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeController extends GetxController {
  RxList<int> seleccionado = RxList();
  RxList<String> favoritos = RxList();

  RxList<Sticker> stickers = RxList();

  final BannerAd myBanner = BannerAd(
    adUnitId: //'ca-app-pub-3940256099942544/6300978111',
        'ca-app-pub-6592025069346248/2775240563',
    size: AdSize.banner,
    request: const AdRequest(),
    listener: const BannerAdListener(),
  );

  void onInit() {
    stickers.bindStream(stickerStream());
    myBanner.load();
    super.onInit();
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
