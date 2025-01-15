import 'package:drive_now/app/modules/riwayat/controllers/riwayat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

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
    final deliveryPersonPhotoUrl = order['fotourl'];
    final deliveryPersonName = order['namaKaryawan'];
    final deliveryPersonPhone = order['noHp'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Pesanan',
              style: GoogleFonts.poppins( // Apply Poppins font
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'No. Pesanan: $noPesanan',
              style: GoogleFonts.poppins( // Apply Poppins font
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
              color: controller.getStatusColor(pesananStatus).withOpacity(0.1),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                pesananStatus,
                style: GoogleFonts.poppins( // Apply Poppins font
                  color: controller.getStatusColor(pesananStatus),
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
                              style: GoogleFonts.poppins( // Apply Poppins font
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              motorData['model']!,
                              style: GoogleFonts.poppins( // Apply Poppins font
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (pesananStatus == 'Menunggu Konfirmasi')
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Bisa Refund',
                          style: GoogleFonts.poppins(), // Apply Poppins font
                        ),
                      ],
                    ),
                  if (pesananStatus == 'Menunggu Konfirmasi')
                    Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Tidak bisa reschedule',
                          style: GoogleFonts.poppins(), // Apply Poppins font
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  
                  // Data Penyewa
                  Text(
                    'Data Penyewa',
                    style: GoogleFonts.poppins( // Apply Poppins font
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            penyewaData['name']!,
                            style: GoogleFonts.poppins( // Apply Poppins font
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${penyewaData['email']} • ${penyewaData['noHp']}',
                            style: GoogleFonts.poppins(), // Apply Poppins font
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lokasi Pengambilan dan Pengembalian
                  _buildLocationSection('Lokasi Pengambilan',  lokasiPengambilan),
                  _buildLocationSection('Lokasi Pengembalian', lokasiPengembalian),
                  
                  // Durasi Sewa
                  _buildDurationSection(controller.formatTanggalDetail(waktuPengambilan), controller.formatTanggalDetail(waktuPengembalian)),

                   const SizedBox(height: 16),

                  // Data Karyawan Pengantar
                  lokasiPengambilan != 'Rental Bandung Instarent'
                    ? _buildDeliveryPersonSection(deliveryPersonPhotoUrl, deliveryPersonName, deliveryPersonPhone)
                    : const SizedBox.shrink(),
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
            const SizedBox(height: 8),
            const SizedBox(height: 8),
              if (pesananStatus == 'Menunggu Konfirmasi') // Logika untuk menampilkan tombol hanya jika status sesuai
                OutlinedButton(
                  onPressed: () async {
                    bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Pembatalan'),
                        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Tidak'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Ya'),
                          ),
                        ],
                      ),
                    );

                    if (confirm) {
                      await controller.batalkanPesanan(order['idPesanan']);
                      Get.back(); // Kembali ke halaman sebelumnya setelah pembatalan
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Batalkan Pesanan',
                    style: GoogleFonts.poppins( // Apply Poppins font
                      color: Colors.red,
                      fontSize: 16,
                    ),
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
              style: GoogleFonts.poppins( // Apply Poppins font
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(location, style: GoogleFonts.poppins()), // Apply Poppins font
        const SizedBox(height: 16),
      ],
    );
  }

  // Durasi Sewa
  Widget _buildDurationSection(String waktuPengambilan, String waktuPengembalian) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Durasi Sewa',
              style: GoogleFonts.poppins( // Apply Poppins font
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' *',
              style: GoogleFonts.poppins(color: Colors.red),
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
                  Text('Pengambilan:',style: GoogleFonts.poppins()),
                  Text(
                    waktuPengambilan,
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengembalian:', style: GoogleFonts.poppins(),),
                  Text(
                    waktuPengembalian,
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

   Widget _buildDeliveryPersonSection(String? photoUrl, String? name, String? phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Karyawan Pengantar',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null ? const Icon(Icons.person, size: 25) : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? 'Nama tidak tersedia',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                Text(
                  phone ?? 'No HP tidak tersedia',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}