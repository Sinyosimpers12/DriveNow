import 'package:drive_now/app/modules/home/controllers/home_controller.dart';
import 'package:drive_now/app/modules/profil/controllers/profil_controller.dart';
import 'package:drive_now/app/modules/riwayat/controllers/riwayat_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/nav_bar_controller.dart';

class NavBarView extends StatelessWidget {
  final NavBarController controller = Get.put(NavBarController());
  final HomeController controllerHome = Get.put(HomeController());
  final RiwayatController controllerRiwayat = Get.put(RiwayatController());
  final ProfilController controllerProfil = Get.put(ProfilController());

  NavBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => controller.pages[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeTab,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF707FDD),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: 'home'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
