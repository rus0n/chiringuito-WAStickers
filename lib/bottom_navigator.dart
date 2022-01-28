import 'package:chiringuito/controllers/bottom_navigator_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavigator extends StatelessWidget {
  const BottomNavigator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var b = Get.put(BottomController());
    return Obx(() => Scaffold(
          body: b.bodyWidget.elementAt(b.index.value),
          bottomNavigationBar: BottomNavigationBar(
            items: b.bttomItems,
            currentIndex: b.index.value,
            onTap: (value) => b.index.value = value,
          ),
        ));
  }
}
