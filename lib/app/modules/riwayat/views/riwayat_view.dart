import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RiwayatController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat', style: TextStyle(color: Colors.white)),
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
                        child: Text(value),
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
                return const Center(child: Text("Belum ada riwayat pesanan"));
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
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pesanan: ${order['idPesanan'] ?? 'Tidak Ada ID'}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  bookingDate,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  vehicleName,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Rp. $price',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Text(
                              vehicleType,
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Rp $price',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: controller.getStatusColor(status),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
