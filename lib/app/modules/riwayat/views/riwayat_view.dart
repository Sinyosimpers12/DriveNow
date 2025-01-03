import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RiwayatController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Riwayat',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Color(0xFF707FDD),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Options
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Obx() digunakan untuk merender ulang saat selectedFilter berubah
                Obx(() {
                  return DropdownButton<String>(
                    value: controller.selectedFilter.value,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedFilter.value = newValue;
                        controller.applyFilter();
                      }
                    },
                    items: <String>[
                      'Semua Tanggal',
                      '30 Hari Terakhir',
                      '90 Hari Terakhir',
                      'Pilih Tanggal Sendiri'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(),
                        ),
                      );
                    }).toList(),
                  );
                }),
                Obx(() {
                  if (controller.selectedFilter.value == 'Pilih Tanggal Sendiri') {
                    return IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => controller.selectDateRange(context),
                    );
                  } else {
                    return Container(); // You can return an empty container or another widget if needed
                  }
                }),
              ],
            ),
          ),
          // Display Orders
          Expanded(
            child: Obx(() {
              if (controller.filteredOrders.isEmpty) {
                return Center(
                  child: Text(
                    "Belum ada riwayat pesanan",
                    style: GoogleFonts.poppins(),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.filteredOrders[index];
                  final vehicleName = order['vehicle']['name'] ?? 'Kendaraan Tidak Diketahui';
                  final vehicleType = order['vehicle']['category'] ?? 'Tipe Tidak Diketahui';
                  final price = order['totalHarga']?.toString() ?? '0';
                  final status = order['statusPemesanan'] ?? 'Tidak Diketahui';
                  final rawDate = order['tanggalPesanan'] ?? '';
                  final bookingDate = controller.formatTanggal(rawDate);

                  return GestureDetector(
                    onTap: () {
                      // Menangani tap pada card dan mengirim data order
                      controller.onOrderTap(order); // Kirim data order
                    },
                    child: Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Pesanan: ${order['idPesanan'] ?? 'Tidak Ada ID'}',
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                    ),
                                    Text(
                                      bookingDate,
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      vehicleName,
                                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp. $price',
                                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text(
                                  vehicleType,
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Add padding for spacing
                            decoration: BoxDecoration(
                              color: controller.getStatusColor(status).withOpacity(0.1), // Background color with some opacity
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12), // Rounded bottom-left corner
                                bottomRight: Radius.circular(12), // Rounded bottom-right corner
                              ),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: controller.getStatusColor(status), // Ensure text color matches the status
                              ),

                            ),
                          )
                        ],
                      )
                      
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}