import 'package:drive_now/app/data/kendaraan_model.dart';
import 'package:drive_now/app/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final uploads = <KendaraanModel>[].obs;
  final filteredUploads = <KendaraanModel>[].obs;
  final unavailableUploads = <KendaraanModel>[].obs; // Kendaraan yang tidak tersedia
  final selectedCategory = Rxn<String>();
  final selectedBrand = Rxn<String>();
  final brands = <String>[].obs;
  final userData = Rxn<UserModel>();
  int rentalDays = 0;

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child("Kendaraan");
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference databaseRefUser = FirebaseDatabase.instance.ref().child("users");

  Rx<DateTime?> selectedBookingDateTime = Rx<DateTime?>(DateTime.now());
  Rx<DateTime?> returnDateTime = Rx<DateTime?>(DateTime.now().add(const Duration(days: 1)));
  final selectedRentalType = Rx<String>('Harian');
  
  @override
  void onInit() {
    super.onInit();
    fetchUploads();
    fetchUserData();
    final user = auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      databaseRefUser.child(uid).onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          userData.value = UserModel.fromJson(data); 
        } else {
          userData.value = null;
        }
      });
    }

    ever(selectedBookingDateTime, (_) => fetchUploads());
    ever(returnDateTime, (_) => fetchUploads());
  }

  Future<void> fetchUserData() async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null) {
        Get.snackbar('Error', 'Tidak ada pengguna yang login.');
        return;
      }

      final snapshot = await databaseRefUser.child(uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        userData.value = UserModel.fromJson(data); // Menyimpan data pengguna
      } else {
        Get.snackbar('Error', 'Data pengguna tidak ditemukan.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data pengguna: $e');
    }
  }

  Future<void> fetchUploads() async {
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        List<KendaraanModel> allVehicles = data.entries.map((entry) {
          final kendaraan = KendaraanModel.fromJson(Map<String, dynamic>.from(entry.value));
          kendaraan.key = entry.key;
          return kendaraan;
        }).toList();

        List<KendaraanModel> availableVehicles = [];
        List<KendaraanModel> unavailableVehicles = [];

        for (var vehicle in allVehicles) {
          bool available = await isVehicleAvailable(
            vehicle.key!, 
            selectedBookingDateTime.value!, 
            returnDateTime.value!
          );

          if (available) {
            availableVehicles.add(vehicle);
          } else {
            unavailableVehicles.add(vehicle);
          }
        }

        uploads.assignAll(availableVehicles);
        filteredUploads.assignAll(availableVehicles);
        unavailableUploads.assignAll(unavailableVehicles);  // Kendaraan tidak tersedia

        // Update daftar merek yang tersedia
        brands.assignAll(uploads.map((v) => v.brand).toSet().toList());
      } else {
        uploads.clear();
        filteredUploads.clear();
        unavailableUploads.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> isVehicleAvailable(String vehicleKey, DateTime startDate, DateTime endDate) async {
    final snapshot = await FirebaseDatabase.instance.ref('pesanan').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (var entry in data.entries) {
        final pesanan = Map<String, dynamic>.from(entry.value);

        // Ambil status pemesanan
        String? statusPemesanan = pesanan['statusPemesanan'];

        if (statusPemesanan != null) {
          DateTime bookingDate = DateTime.parse(pesanan['booking']);
          DateTime returnDate = DateTime.parse(pesanan['return']);

          if (pesanan['vehicle']['key'] == vehicleKey) {
            // Kendaraan tidak tersedia jika status "Menunggu Konfirmasi" atau "Berlangsung"
            if (statusPemesanan == "Menunggu Konfirmasi" || statusPemesanan == "Berlangsung" || statusPemesanan == "Diantar" || statusPemesanan == "Menunggu Kendaraan Diambil") {
              // Cek apakah rentang tanggal bentrok
              if (!(returnDate.isBefore(startDate) || bookingDate.isAfter(endDate))) {
                return false; // Tidak valid jika overlap
              }
            }
          }
        }
      }
    }
    return true; // Kendaraan tersedia
  }

  void filterByName(String query) {
    if (query.isEmpty) {
      filteredUploads.assignAll(uploads);
    } else {
      filteredUploads.assignAll(
        uploads.where((vehicle) => vehicle.name.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

  void filterVehicles({String? category, String? brand}) {
    List<KendaraanModel> filteredList = uploads;

    if (category != null && category.isNotEmpty) {
      filteredList = filteredList.where((upload) => upload.category.toLowerCase() == category.toLowerCase()).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      filteredList = filteredList.where((upload) => upload.brand.toLowerCase() == brand.toLowerCase()).toList();
    }

    filteredUploads.assignAll(filteredList);

    // Jika tidak ada kategori dan merek yang dipilih, reset filter
    if (category == null && brand == null) {
      resetFilter();
    }
  }

  // Reset filter
  void resetFilter() {
    selectedCategory.value = null;
    selectedBrand.value = null;
    filteredUploads.assignAll(uploads);
    update();
  }

  Future<void> pickDateRangeWithTime(BuildContext context) async {
    DateTime now = DateTime.now();

    if (selectedRentalType.value == 'Harian') {
      // Jika tipe sewa harian, gunakan DateRangePicker
      DateTimeRange? selectedDateRange = await showDateRangePicker(
        context: context,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      );

      if (selectedDateRange != null) {
        // Pastikan tanggal mulai dan tanggal akhir tidak sama
        if (selectedDateRange.start.isAtSameMomentAs(selectedDateRange.end)) {
          Get.snackbar('Error', 'Tanggal mulai dan tanggal akhir tidak boleh sama');
          return;
        }

        // Pilih waktu pengambilan
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (selectedTime != null) {
          selectedBookingDateTime.value = DateTime(
            selectedDateRange.start.year,
            selectedDateRange.start.month,
            selectedDateRange.start.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          // Untuk penyewaan harian, pengembalian tetap di waktu yang sama
          returnDateTime.value = DateTime(
            selectedDateRange.end.year,
            selectedDateRange.end.month,
            selectedDateRange.end.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        }
        rentalDays = calculateRentalDays(selectedDateRange.start, selectedDateRange.end);
        print('Jumlah hari yang dipilih untuk sewa: $rentalDays hari');
      }
    } else if (selectedRentalType.value == '12 Jam') {
      // Jika tipe sewa per 12 jam, pilih tanggal menggunakan DatePicker biasa
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 365)),
      );

      if (selectedDate != null) {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (selectedTime != null) {
          selectedBookingDateTime.value = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          // Untuk penyewaan per 12 jam, tambah 12 jam pada tanggal pengembalian
          returnDateTime.value = selectedBookingDateTime.value?.add(const Duration(hours: 12));
        }
      }
    }
  }



  String getFormattedDateTime() {
    if (selectedBookingDateTime.value != null) {
      return DateFormat("d MMMM yyyy (HH:mm)", "id_ID").format(selectedBookingDateTime.value!);
    } else {
      return "Belum dipilih";
    }
  }

  Future<File> compressImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      final directory = await getApplicationDocumentsDirectory();
      final outputPath = '${directory.path}/compressed_image.jpg';

      // Melakukan kompresi gambar
      var result = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 800, // Tentukan lebar minimal gambar
        minHeight: 600, // Tentukan tinggi minimal gambar
        quality: 80, // Kualitas kompresi 0-100
      );

      // Menyimpan gambar terkompresi ke file lokal
      final compressedFile = await File(outputPath).writeAsBytes(result);

      return compressedFile;
    } else {
      throw Exception("Failed to load image");
    }
  }

  int calculateRentalDays(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    return difference;
  }
}