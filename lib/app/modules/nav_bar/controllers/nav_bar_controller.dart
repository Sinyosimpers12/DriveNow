import 'package:drive_now/app/modules/home/views/home_view.dart';
import 'package:drive_now/app/modules/profil/views/profil_view.dart';
import 'package:drive_now/app/modules/riwayat/views/riwayat_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavBarController extends GetxController {
  var selectedIndex = 0.obs;
  final List<Widget> pages = [
    HomeView(),
    RiwayatView(),
    ProfilView(),
  ];

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}