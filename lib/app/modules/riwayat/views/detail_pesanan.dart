import 'package:drive_now/app/modules/riwayat/controllers/riwayat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailPesananView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RiwayatController controller = Get.find();
    final Map order = Get.arguments;

    // Mengambil data dari order map yang dikirimkan
    final motorData = order['vehicle'];
    final penyewaData = order['dataUser'];
    final pesananStatus = order['statusPemesanan'];
    final noPesanan = order['idPesanan'];
    final lokasiPengambilan = order['pesananAlamat'];
    final lokasiPengembalian = 'Rental Bandung Instarent';
    final waktuPengambilan = order['booking'];
    final waktuPengembalian = order['return'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Pesanan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'No. Pesanan: $noPesanan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF707FDD),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Pesanan
            Container(
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                pesananStatus,
                style: const TextStyle(
                  color: Color(0xFF707FDD),
                  fontWeight: FontWeight.w500,
                  
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Detail Kendaraan
                  Row(
                    children: [
                      Image.network(
                        motorData['image_url']!,
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              motorData['name']!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              motorData['model']!,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Bisa Refund'),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Tidak bisa reschedule'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Data Penyewa
                  const Text(
                    'Data Penyewa',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            penyewaData['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${penyewaData['email']} • ${penyewaData['noHp']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lokasi Pengambilan dan Pengembalian
                  _buildLocationSection('Lokasi Pengambilan',  lokasiPengambilan),
                  _buildLocationSection('Lokasi Pengembalian', lokasiPengembalian),

                  const SizedBox(height: 16),
                  
                  // Durasi Sewa
                  _buildDurationSection(controller.formatTanggalDetail(waktuPengambilan) , controller.formatTanggalDetail(waktuPengembalian) ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                // Fungsi untuk menghubungi kantor sewa
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF707FDD),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hubungi Kantor Sewa',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                // Fungsi untuk membatalkan pesanan
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Batalkan Pesanan',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lokasi Pengambilan dan Pengembalian
  Widget _buildLocationSection(String title, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(location),
        const SizedBox(height: 16),
      ],
    );
  }

  // Durasi Sewa
  Widget _buildDurationSection(String waktuPengambilan, String waktuPengembalian) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Durasi Sewa',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengambilan:'),
                  Text(
                    waktuPengambilan,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pengembalian:'),
                  Text(
                    waktuPengembalian,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}