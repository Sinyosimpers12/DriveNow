import 'package:drive_now/app/modules/pembayaran/controllers/pembayaran_controller.dart';
import 'package:drive_now/app/modules/pesanan/controllers/pesanan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PembayaranView extends GetView<PembayaranController> {
  
  final PesananController pesananController = Get.find();
  PembayaranView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchBankData(); 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Sewa Motor', style: GoogleFonts.poppins(color: Colors.white),),
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
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            pesananController.selectedVehicle.value.brand,
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  controller.homeController.userData.value!.name,
                                  style: GoogleFonts.poppins(color: Colors.grey[600]),
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
                                  style: GoogleFonts.poppins(color: Colors.grey[600]),
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
                    Text(
                      'Metode Pembayaran',
                      style: GoogleFonts.poppins(
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
                                  subtitle: Text('No. Rekening: ${bank['accountNumber']}\nBank: ${bank['bank']}', style: GoogleFonts.poppins(),),
                                  contentPadding: EdgeInsets.zero,
                                  
                                )),
                            Text('*Harap membayar sesuai total harga yang tertera',
                            style: GoogleFonts.poppins(fontStyle: FontStyle.italic)),
                            SizedBox(height: 10)
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF707FDD)),
                            onPressed: controller.uploadGambar,
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            label: Text('Pilih dari Galeri', style: GoogleFonts.poppins(color: Colors.white)),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF707FDD)),
                            onPressed: controller.uploadGambarKamera,
                            icon: Icon(Icons.camera_alt, color: Colors.white),
                            label: Text('Ambil Foto', style: GoogleFonts.poppins(color: Colors.white)),
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
                                label: Text(
                                  'Hapus Bukti Pembayaran',
                                  style: GoogleFonts.poppins(color: Colors.red),
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
                              child: Center(
                                child: Text(
                                  'Belum ada bukti pembayaran',
                                  style: GoogleFonts.poppins(color: Colors.grey),
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
                            style: GoogleFonts.poppins(fontStyle: FontStyle.italic))
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
                    Text(
                      'Tanggal dan Waktu Booking',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold,),
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
                    Obx(() {
                    return Text(
                        controller.homeController.selectedRentalType.value == 'Harian'
                            ? 'Durasi Sewa: ${controller.homeController.rentalDays} Hari'
                            : 'Durasi Sewa: ${controller.homeController.selectedRentalType.value}',
                        style: GoogleFonts.poppins(fontSize: 16),
                      );
                    }),
                    const SizedBox(height: 7),
                      
                    Text(
                      'Item yang Dipesan',
                      style: GoogleFonts.poppins(
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
                              Text(item['name'], style: GoogleFonts.poppins(fontSize: 16)),
                              Text(
                                'Rp.${item['price']}',
                                style: GoogleFonts.poppins(fontSize: 16),
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
        color: Colors.grey.shade200,
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Harga: Rp.${controller.pesananData['totalPrice']}',
                  style: GoogleFonts.poppins(
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
              child: Text('Bayar', style: GoogleFonts.poppins(color: Colors.white)),
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
        title: Text(name, style: GoogleFonts.poppins(),),
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