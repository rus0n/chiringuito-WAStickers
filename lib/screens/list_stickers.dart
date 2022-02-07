import 'package:chiringuito/controllers/home_controller.dart';
import 'package:chiringuito/models/stickers_model.dart';
import 'package:chiringuito/screens/comments.dart';
import 'package:chiringuito/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ListSticker extends StatelessWidget {
  const ListSticker({Key? key, required this.stickers, required this.ads})
      : super(key: key);
  final List<Sticker> stickers;
  final Map<String, BannerAd> ads;
  @override
  Widget build(BuildContext context) {
    var h = Get.find<HomeController>();

    Widget bannerAdWidget(BannerAd _bannerAd) {
      return StatefulBuilder(
        builder: (context, setState) => Container(
          child: AdWidget(ad: _bannerAd),
          width: _bannerAd.size.width.toDouble(),
          height: 100.0,
          alignment: Alignment.center,
        ),
      );
    }

    return Obx(() => stickers.isEmpty
        ? ShimmerList()
        : SizedBox(
            height: Get.size.height,
            width: Get.size.width,
            child: ListView.separated(
                cacheExtent: 300,
                padding: EdgeInsets.all(8),
                itemBuilder: (_, index) {
                  Sticker _sticker = stickers.elementAt(index);
                  return InkWell(
                      onTap: () {
                        if (h.seleccionado.length <= 30) {
                          bool _select = false;
                          h.seleccionado.forEach((element) {
                            if (element == _sticker.id) {
                              _select = true;
                            }
                          });
                          print(_select);
                          if (_select && h.seleccionado.isNotEmpty ||
                              h.seleccionado.length == 30) {
                            h.seleccionado.remove(_sticker.id);
                          } else {
                            h.seleccionado.add(_sticker.id);
                          }

                          print(h.seleccionado);
                        }
                      },
                      child: Card(
                        elevation: 3,
                        clipBehavior: Clip.antiAlias,
                        color: (h.seleccionado.contains(_sticker.id) &&
                                h.seleccionado.isNotEmpty)
                            ? Colors.lightBlueAccent
                            : null,
                        child: SizedBox(
                          height: 170,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: (Get.size.width / 3.6),
                                    bottom: 8,
                                    top: 8),
                                child: Image.network(
                                  _sticker.imageUrl!,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Text('No se puede actualizar'),
                                  ),
                                  loadingBuilder: (_, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        onPressed: () => h.likesAdd(_sticker),
                                        icon: h.favoritos.contains(_sticker.id)
                                            ? Icon(Icons.favorite,
                                                color: Colors.blueAccent)
                                            : Icon(Icons.favorite_border)),
                                    Text('${_sticker.likes}'),
                                    IconButton(
                                        onPressed: () => Get.to(() => Comments(
                                              id: _sticker.id,
                                            )),
                                        icon: Icon(Icons.add_comment_outlined)),
                                    Text('${_sticker.comments}')
                                  ],
                                ),
                              ),
                              SizedBox(height: 10)
                            ],
                          ),
                        ),
                      ));
                },
                separatorBuilder: (_, index) {
                  if ((index % 4 == 0)) {
                    return bannerAdWidget(ads['myBanner$index']!);
                  }
                  return Container();
                },
                itemCount: stickers.length),
          ));
  }
}
