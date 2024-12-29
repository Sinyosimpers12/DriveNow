import 'package:drive_now/app/modules/profil/controllers/profil_controller.dart';
import 'package:drive_now/app/modules/profil/views/edit_profile_view.dart';
import 'package:drive_now/app/modules/profil/views/persyaratan_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

class ProfilView extends StatelessWidget {
  final ProfilController controller = Get.put(ProfilController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            color: Color(0xFF707FDD),
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() {
                  return CircleAvatar(
                    backgroundImage: (controller.homeController.userData.value?.photoUrl != null &&
                            controller.homeController.userData.value!.photoUrl.isNotEmpty)
                        ? NetworkImage(controller.homeController.userData.value!.photoUrl)
                        : const AssetImage('assets/icons/user_default.png'),
                    radius: 50.0,
                  );
                }),
                SizedBox(height: 10),
                Obx(() {
                  return Text(
                    controller.homeController.userData.value!.name,
                    style: GoogleFonts.poppins( // Apply Poppins font
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
                Obx(() {
                  return Text(
                    controller.homeController.userData.value!.noHp.isEmpty
                        ? 'Ayo lengkapi data kamu.'
                        : controller.homeController.userData.value!.noHp,
                    style: GoogleFonts.poppins( // Apply Poppins font
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text(
                    'Edit Profil',
                    style: GoogleFonts.poppins(), // Apply Poppins font
                  ),
                  onTap: () {
                    Get.to(() => EditProfileView());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text(
                    'Persyaratan',
                    style: GoogleFonts.poppins(), // Apply Poppins font
                  ),
                  onTap: () {
                    Get.to(() => PersyaratanView());
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Keluar',
                    style: GoogleFonts.poppins( // Apply Poppins font
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    controller.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}