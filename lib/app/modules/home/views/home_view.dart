import 'package:drive_now/app/modules/home/views/pencarian_view.dart';
import 'package:drive_now/app/modules/pesanan/views/pesanan_view.dart';
import 'package:drive_now/app/modules/profil/views/persyaratan_view.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Obx(() {
              return CircleAvatar(
                backgroundImage: (controller.userData.value?.photoUrl != null &&
                        controller.userData.value!.photoUrl.isNotEmpty)
                    ? NetworkImage(controller.userData.value!.photoUrl)
                    : const AssetImage('assets/icons/user_default.png'),
                radius: 18.0,
              );


            }),
            SizedBox(width: 10),
            Obx(() {
              final userName = controller.userData.value?.name ?? 'Pengguna';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo!',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    userName,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
                  ),
                ],
              );
            }),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Get.to(() => PencarianView());
            },
            tooltip: "Pencarian",
          ),
        ],
        backgroundColor: Color(0xFF707FDD),
      ),
      body: Column(
        children: [
          Obx(() {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  child: Text(
                    'Pilih Kendaraan sesuai kebutuhan di Instarent',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _button('Semua', ''),
                      _button('Mobil', 'Mobil'),
                      _button('Motor', 'Motor'),
                    ],
                  ),
                ),
                // Tampilkan filter brand berdasarkan kategori
                if (controller.selectedCategory.value != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.brands
                            .map((brand) => _button(brand, brand))
                            .toList(),
                      ),
                    ),
                  ),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Obx(() {
              return DropdownButton<String>(
                value: controller.selectedRentalType.value,
                hint: Text(
                  'Pilih Jenis Sewa',
                  style: GoogleFonts.poppins(color: Colors.black),
                ),
                isExpanded: true,
                items: [
                  DropdownMenuItem<String>(
                    value: 'Harian',
                    child: Text('Sewa Harian', style: GoogleFonts.poppins()),
                  ),
                  DropdownMenuItem<String>(
                    value: '12 Jam',
                    child: Text('Sewa 12 Jam', style: GoogleFonts.poppins()),
                  ),
                ],
                onChanged: (String? value) {
                  if (value != null) {
                    controller.selectedRentalType.value = value;
                  }
                },
              );
            }),
          ),


          Padding(
            padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await controller.pickDateRangeWithTime(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF707FDD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pilih Tanggal dan Waktu Sewa',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Obx(() {
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pengambilan:', style: GoogleFonts.poppins(),),
                            const SizedBox(height: 4.0),
                            Text(
                              controller.getFormattedDateTime(),
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Pengembalian:', style: GoogleFonts.poppins(),),
                            const SizedBox(height: 4.0),
                            Text(
                              controller.returnDateTime.value != null
                                  ? DateFormat("d MMMM yyyy (HH:mm)", "id_ID").format(controller.returnDateTime.value!)
                                  : 'Belum dipilih',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUploads.isEmpty) {
                return Center(child: Text("Tidak ada kendaraan ditemukan"));
              }

              // Pisahkan kendaraan yang tersedia dan tidak tersedia
              List<dynamic> availableVehicles = [];
              List<dynamic> unavailableVehicles = [];

              for (var vehicle in controller.filteredUploads) {
                if (vehicle.status == "Tersedia") {
                  availableVehicles.add(vehicle);
                } else {
                  unavailableVehicles.add(vehicle);
                }
              }

              List<dynamic> sortedVehicles = [];
              sortedVehicles.addAll(availableVehicles);
              sortedVehicles.addAll(controller.unavailableUploads);
              sortedVehicles.addAll(unavailableVehicles);

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: sortedVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = sortedVehicles[index];
                  return buildVehicleCard(vehicle);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _button(String label, String value) {
    return Obx(() {
      final isSelected = (controller.selectedCategory.value == value) ||
          (controller.selectedBrand.value == value) ||
          (value == '' && controller.selectedCategory.value == null && controller.selectedBrand.value == null);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Color(0xFF707FDD) : Colors.grey[300],
            foregroundColor: isSelected ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (value == '') {
              // Reset kategori dan merek jika tombol "Semua" ditekan
              controller.selectedCategory.value = null;
              controller.selectedBrand.value = null;
            } else if (value == 'Mobil' || value == 'Motor') {
              // Pilih kategori dan reset merek
              controller.selectedCategory.value = value;
              controller.selectedBrand.value = null;
            } else {
              // Pilih merek dan reset kategori
              controller.selectedBrand.value = value;
            }

            // Terapkan filter kendaraan berdasarkan kategori dan merek yang dipilih
            controller.filterVehicles(
              category: controller.selectedCategory.value,
              brand: controller.selectedBrand.value,

            );
          },
          child: Text(label, style: GoogleFonts.poppins(),),
        ),
      );
    });
  }


  Widget buildVehicleCard(dynamic vehicle) {
    bool isAvailable = vehicle.status == "Tersedia" && controller.uploads.contains(vehicle);

    return GestureDetector(
      onTap: isAvailable
          ? () {
              if (controller.userData.value?.sim == '' || controller.userData.value!.sim.isEmpty) {
                Get.snackbar(
                  'Info',
                  'Lengkapi data SIM Anda untuk melanjutkan.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                Get.to(() => PersyaratanView());
              } else {
                // Pindah ke halaman PesananView jika data SIM tersedia
                Get.to(() => PesananView(vehicle: vehicle));
              }
            }
          : null,
      child: Stack(
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Hero(
                        tag: vehicle.name,
                        child: Stack(
                          children: [
                            // Gambar kendaraan
                            Image.network(
                              vehicle.imageUrl ?? 'https://example.com/default_image.png',
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: Image.asset(
                                      'assets/icons/image_download.png',
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                return Center(child: Text('Gambar gagal dimuat', style: GoogleFonts.poppins(),));
                              },
                            ),
                            if (!isAvailable)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                alignment: Alignment.center,
                                child: Text(
                                  'Tidak Tersedia',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Nama kendaraan
                      Text(
                        vehicle.name,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      // Model atau cc kendaraan
                      Text(
                        vehicle.category == 'Mobil' ? vehicle.model : '${vehicle.cc}cc',
                        style: GoogleFonts.poppins(),
                      ),
                      SizedBox(height: 4),
                      // Harga kendaraan
                      Text(
                        'Rp. ${vehicle.price2} ~ Rp. ${vehicle.price}',
                        style: GoogleFonts.poppins(
                          color: Color(0xFF707FDD),
                          fontWeight: FontWeight.w600,
                          fontSize: 13
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}