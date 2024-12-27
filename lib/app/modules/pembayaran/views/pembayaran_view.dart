import 'package:drive_now/app/modules/pembayaran/controllers/pembayaran_controller.dart';
import 'package:drive_now/app/modules/pesanan/controllers/pesanan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PembayaranView extends GetView<PembayaranController> {
  
  final PesananController pesananController = Get.find();
  PembayaranView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchBankData(); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sewa Motor', style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
          color: Colors.white,
        ),
        
        backgroundColor: Color(0xFF707FDD),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Info Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pesananController.selectedVehicle.value.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            pesananController.selectedVehicle.value.brand,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  controller.homeController.userData.value!.name,
                                  style: TextStyle(color: Colors.grey[600]),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  controller.pesananData['address']?.isNotEmpty ?? false
                                      ? controller.pesananData['address']!
                                      : 'Rental Bandung IntaRent',
                                  style: TextStyle(color: Colors.grey[600]),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                    Image.network(
                      pesananController.selectedVehicle.value.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),

              // Payment Methods Section
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metode Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      'Transfer Bank',
                      controller,
                    ),
                    if (controller.selectedPaymentMethod.value == 'Transfer Bank') ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...controller.bankList.map((bank) => ListTile(
                                  title: Text(bank['name']),
                                  subtitle: Text('No. Rekening: ${bank['accountNumber']}\nBank: ${bank['bank']}'),
                                  contentPadding: EdgeInsets.zero,
                                )),
                            Text('*Harap membayar sesuai total harga yang tertera',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                            SizedBox(height: 10)
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: controller.uploadGambar,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Pilih dari Galeri'),
                          ),
                          ElevatedButton.icon(
                            onPressed: controller.uploadGambarKamera,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Ambil Foto'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() {
                        if (controller.paymentProof.value != null) {
                          return Column(
                            children: [
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.file(
                                  controller.paymentProof.value!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: controller.hapusGambar,
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text(
                                  'Hapus Bukti Pembayaran',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Belum ada bukti pembayaran',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10,)
                          ]
                        );
                      }),
                    ],
                    _buildPaymentOption(
                      'Tunai',
                      controller,
                      isCash: true,
                    ),
                    if (controller.selectedPaymentMethod.value == 'Tunai')
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 8),
                        child:  Text('*Harap menyiapkan uang saat mengambil kendaraan sesuai total harga yang tertera',
                            style: TextStyle(fontStyle: FontStyle.italic))
                      ),
                  ],
                ),
              ),

              // Items Ordered Section
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tanggal dan Waktu Booking',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0), 
                      child: Text(
                        controller.getFormattedDateTime(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 7),
                    
                    const Text(
                      'Items yang Dipesan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.pesananData['items'].length,
                      itemBuilder: (context, index) {
                        final item = controller.pesananData['items'][index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['name'], style: const TextStyle(fontSize: 16)),
                              Text(
                                'Rp.${item['price']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Harga: Rp.${controller.pesananData['totalPrice']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: controller.submitPayment,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF707FDD),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                ),
              child: const Text('Bayar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    String name,
    PembayaranController controller, {
    bool isCash = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: isCash
            ? const Icon(Icons.payments)
            : const Icon(Icons.account_balance),
        title: Text(name),
        trailing: Radio<String>(
          value: name,
          groupValue: controller.selectedPaymentMethod.value,
          onChanged: (value) => controller.selectPaymentMethod(value.toString()),
        ),
        onTap: () => controller.selectPaymentMethod(name),
      ),
    );
  }
}