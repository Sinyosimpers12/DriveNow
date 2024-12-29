import 'package:drive_now/app/modules/profil/controllers/profil_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

class PersyaratanView extends StatelessWidget {
  const PersyaratanView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfilController controller = Get.put(ProfilController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Persyaratan',
          style: GoogleFonts.poppins( // Apply Poppins font
            color: Colors.white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          color: Colors.white,
        ),
        elevation: 0,
        backgroundColor: Color(0xFF707FDD),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Upload Foto SIM',
                style: GoogleFonts.poppins( // Apply Poppins font
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF707FDD),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pastikan foto SIM terlihat jelas dan tidak buram',
                style: GoogleFonts.poppins( // Apply Poppins font
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Obx(() {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: controller.homeController.userData.value!.sim == ''
                        ? Container(
                            height: 200,
                            width: 320,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icons/sim_placeholder.png',
                                  height: 150,
                                  width: 240,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Belum ada foto SIM',
                                  style: GoogleFonts.poppins( // Apply Poppins font
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Image.network(
                            controller.homeController.userData.value!.sim,
                            height: 200,
                            width: 320,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                width: 320,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Gagal memuat gambar',
                                      style: GoogleFonts.poppins(
                                        color: Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => controller.changeSimImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white,),
                    label: Text(
                      'Kamera',
                      style: GoogleFonts.poppins( // Apply Poppins font
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF707FDD),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => controller.changeSimImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library, color: Colors.white,),
                    label: Text(
                      'Galeri',
                      style: GoogleFonts.poppins( // Apply Poppins font
                        fontSize: 16,
                        color: Colors.white
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF707FDD),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
