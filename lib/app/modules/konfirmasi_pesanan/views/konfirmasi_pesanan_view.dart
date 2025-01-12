import 'package:drive_now/app/modules/pesanan/controllers/pesanan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';


import '../controllers/konfirmasi_pesanan_controller.dart';

class KonfirmasiPesananView extends StatelessWidget {
  final KonfirmasiPesananController controller = Get.put(KonfirmasiPesananController());
  final PesananController pesananController = Get.find();

  KonfirmasiPesananView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF707FDD),
        title: Text('Sewa Motor', style: GoogleFonts.poppins(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Details Section
              Row(
                children: [
                  Image.network(
                    pesananController.selectedVehicle.value.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesananController.selectedVehicle.value.name,
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pesananController.selectedVehicle.value.brand,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fitur",
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600), textAlign: TextAlign.start,
                    ),
                    if(controller.selectedFeatures.isEmpty)
                      Text('-'),
                    const SizedBox(height: 8,),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: controller.selectedFeatures.map((feature) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.indigo.shade100, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Mengatur tinggi menyesuaikan isi.
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.indigo.shade100,
                                child: Image.asset(
                                  controller.featuresWithImages[feature] ?? "",
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                feature.isEmpty ? '-' : feature,
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
                
              }),

              const SizedBox(height: 16),

              // Date and Time Selection
              Text(
                "Tanggal dan Waktu Booking",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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

              const SizedBox(height: 16),
              
              if (controller.selectedFeatures.contains('Antar Kendaraan'))
                MapsUser(controller: controller)
              else
                MapsOwner(controller: controller),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade200,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Obx(() => Text(
                    "Total Harga: Rp.${controller.totalPrice}",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ))),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: controller.confirmOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF707FDD),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Konfirmasi',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapsOwner extends StatelessWidget {
  const MapsOwner({
    super.key,
    required this.controller,
  });

  final KonfirmasiPesananController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Lokasi Penyewaan',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: controller.location,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                controller.openMapsNavigation(controller.location.latitude, controller.location.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: controller.location,
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        controller.openMapsNavigation(controller.location.latitude, controller.location.longitude);
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Ketuk peta atau pin lokasi merah untuk menavigasi ke lokasi langsung di aplikasi peta Anda.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class MapsUser extends StatefulWidget {
  const MapsUser({super.key, required this.controller});

  final KonfirmasiPesananController controller;

  @override
  _MapsUserState createState() => _MapsUserState();
}

class _MapsUserState extends State<MapsUser> {
  String currentAddress = 'Alamat belum diperbarui';
  Position? currentPosition;
  bool isLoading = false;

  Future<void> _fetchLocation() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Mendapatkan lokasi terkini
      Position position = await _getCurrentLocation();
      setState(() {
        currentPosition = position;
      });

      // Mendapatkan alamat dari koordinat
      await _getAddressFromLatLng(position);
    } catch (e) {
      setState(() {
        currentAddress = 'Gagal mendapatkan lokasi: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Layanan lokasi tidak aktif.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Izin lokasi ditolak.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Izin lokasi ditolak secara permanen.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          currentAddress =
              "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.country}";
          widget.controller.addressController.text = currentAddress;
        });
      }
    } catch (e) {
      setState(() {
        currentAddress = 'Gagal mendapatkan alamat: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Lokasi Pengantaran Kendaraan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: widget.controller.formKey,
              child: TextFormField(
                controller: widget.controller.addressController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Alamat Lengkap', labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan alamat lengkap anda', hintStyle: GoogleFonts.poppins(),
                  
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _fetchLocation,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF707FDD),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text('Gunakan Lokasi Anda Saat Ini', style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}