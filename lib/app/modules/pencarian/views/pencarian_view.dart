import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pencarian_controller.dart';

class PencarianView extends GetView<PencarianController> {
  const PencarianView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PencarianController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pencarian Kendaraan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF707FDD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) {
                controller.filterByName(query);
              },
              decoration: InputDecoration(
                labelText: "Cari berdasarkan nama",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.filteredData.isEmpty) {
                  return const Center(child: Text("Tidak ada kendaraan ditemukan"));
                }

                List<dynamic> availableVehicles = [];
                List<dynamic> unavailableVehicles = [];

                for (var vehicle in controller.filteredData) {
                  if (vehicle.status == "Tersedia") {
                    availableVehicles.add(vehicle);
                  } else {
                    unavailableVehicles.add(vehicle);
                  }
                }

              List<dynamic> sortedVehicles = availableVehicles..addAll(unavailableVehicles);
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 12,
                    childAspectRatio: 3,
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
      ),
    );
  }

  Widget buildVehicleCard(dynamic vehicle) {
    bool isAvailable = vehicle.status == "Tersedia";

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isAvailable
            ? () {
                Get.toNamed('/pesanan', arguments: vehicle);
              }
            : null,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Hero(
                tag: vehicle.name,
                child: Image.network(
                  vehicle.imageUrl ?? '',
                  width: 120,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 80),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      vehicle.name ?? 'Nama tidak tersedia',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.category == 'Mobil'
                          ? vehicle.model ?? 'Model tidak tersedia'
                          : '${vehicle.cc ?? '0'}cc',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp. ${vehicle.price2} ~ Rp. ${vehicle.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF707FDD),
                      ),
                    ),
                    if (!isAvailable)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        color: Colors.black.withOpacity(0.5),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(4),
                        child: const Text(
                          'Tidak Tersedia',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}