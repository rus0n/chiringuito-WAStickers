import 'package:chiringuito/screens/add.dart';
import 'package:chiringuito/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomController extends GetxController {
  var index = 0.obs;

  final bodyWidget = [Home(), Add()];

  final bttomItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home'),
    BottomNavigationBarItem(
        icon: Icon(Icons.add_outlined),
        activeIcon: Icon(Icons.add),
        label: 'Añadir'),
  ];
}
