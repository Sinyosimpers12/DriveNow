import 'package:drive_now/app/data/kendaraan_model.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/pesanan_controller.dart';

class PesananView extends GetView<PesananController> {
  final KendaraanModel vehicle;

  const PesananView({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PesananController());
    controller.setSelectedVehicle(vehicle);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF707FDD),
        title: const Text('Sewa Motor', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image kendaraan
            Hero(
              tag: vehicle.name,
              child: Image.network(
                vehicle.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(vehicle.brand, style: const TextStyle(color: Colors.grey)),
                  Text(vehicle.cc, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),

                  const Text('Pilih Harga',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Obx(() => DropdownButton<String>(
                        value: controller.selectedPriceOption.value.isNotEmpty
                            ? controller.selectedPriceOption.value
                            : null,
                        hint: const Text("Pilih Durasi"),
                        items: [
                          DropdownMenuItem(
                            value: vehicle.price2,
                            child: Text("Per 12 Jam: Rp.${vehicle.price2}"),
                          ),
                          DropdownMenuItem(
                            value: vehicle.price,
                            child: Text("Per Hari: Rp.${vehicle.price}"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            if (value == vehicle.price2) {
                              controller.selectPrice(value, '12 Jam');
                            } else {
                              controller.selectPrice(value, 'Per Hari');
                            }
                          }
                        },
                      )),

                  const SizedBox(height: 16),

                  const Text('Fitur',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),

                  // Fitur dalam list vertikal
                  Column(
                    children: [
                       // Helm dengan increment dan decrement
                      Obx(() => _featureTile(
                        'Antar Kendaraan',
                        'assets/images/scooter.png',
                        controller.featuresSelected.contains('Antar Kendaraan'),
                        () => controller.toggleFeature('Antar Kendaraan'),
                        'Rp 15000',
                        'Layanan antar kendaraan ke lokasi Anda',
                      )),
                      // Helm dengan increment dan decrement
                      Obx(() => Visibility(
                        visible: vehicle.category == 'Motor',
                        child: _incrementDecrementTile(
                          'Helm',
                          'Rp. 5.000',
                          'assets/images/helmet.png',
                          controller.helmetCount.value,
                          () => controller.incrementFeature('Helm'),
                          () => controller.decrementFeature('Helm'),
                        ),
                      )),
                      Obx(() => Visibility(
                          visible: vehicle.category == 'Motor',
                          child: _incrementDecrementTile(
                            'Jas Hujan',
                            'Rp. 3.000',
                            'assets/images/raincoat.png',
                            controller.raincoatCount.value,
                            () => controller.incrementFeature('Jas Hujan'),
                            () => controller.decrementFeature('Jas Hujan'),
                          ),
                        )),                      
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Obx(() => Text(
                    "Total Harga: Rp.${controller.price}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: controller.processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF707FDD),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                child: const Text(
                  'Lanjut',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureTile(
    String title, 
    String imagePath, 
    bool isSelected, 
    Function onTap,
    String price, 
    String description, // Add the description parameter to the function
  ) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.indigo.shade400 : Colors.indigo.shade100,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isSelected
                  ? Colors.indigo.shade400
                  : Colors.indigo.shade100,
              child: Image.asset(
                imagePath,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _incrementDecrementTile(
      String title, String description, String imagePath, int count, Function onIncrement, Function onDecrement) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.indigo.shade100,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.indigo.shade100,
            child: Image.asset(
              imagePath,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => onDecrement(),
          ),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onIncrement(),
          ),
        ],
      ),
    );
  }
}
