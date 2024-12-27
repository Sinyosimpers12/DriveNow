import 'dart:convert';
import 'package:drive_now/app/data/kendaraan_model.dart';
import 'package:drive_now/app/modules/home/controllers/home_controller.dart';
import 'package:drive_now/app/modules/nav_bar/views/nav_bar_view.dart';
import 'package:drive_now/app/modules/pesanan/controllers/pesanan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class PembayaranController extends GetxController {
  var selectedPaymentMethod = ''.obs;
  var isPaymentSubmitted = false.obs;
  RxList<Map<String, dynamic>> bankList = <Map<String, dynamic>>[].obs;
  final databaseRef = FirebaseDatabase.instance.ref();

  final PesananController pesananController = Get.find();

  final pesananData = Get.arguments;

  final ImagePicker picker = ImagePicker();

  Rx<File?> paymentProof = Rx<File?>(null);

  final HomeController homeController = Get.find();

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  @override
  void onInit() {
    super.onInit();
    fetchBankData();
  }

  void fetchBankData() async {
    try {
      DatabaseEvent event = await databaseRef.child('pembayaran').once();
      final data = event.snapshot.value as Map;

      bankList.value = data.entries.map((entry) {
        return {
          'id': entry.key,
          'name': entry.value['name'],
          'accountNumber': entry.value['account_number'],
          'bank': entry.value['bank'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching bank data: $e');
    }
  }

  String getFormattedDateTime() {
    DateTime? selectedDateTime = pesananData['selectedBookingDateTime']?.value;
    if (selectedDateTime != null) {
      return DateFormat("d MMMM yyyy (HH:mm)", "id_ID").format(selectedDateTime);
    } else {
      return "Belum dipilih";
    }
  }

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> uploadGambar() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Mengompres kualitas gambar
      );

      if (image != null) {
        paymentProof.value = File(image.path);
        Get.snackbar(
          'Sukses',
          'Bukti pembayaran berhasil diunggah',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunggah gambar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> uploadGambarKamera() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        paymentProof.value = File(image.path);
        Get.snackbar(
          'Sukses',
          'Bukti pembayaran berhasil diunggah',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunggah gambar: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void hapusGambar() {
    paymentProof.value = null;
    Get.snackbar(
      'Sukses',
      'Bukti pembayaran berhasil dihapus',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<String> uploadImageToCloudinary(File imageFile) async {
    const String cloudName = 'dw2qgzbpm';
    const String uploadPreset = 'buktiBayar';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return data['secure_url'];
    } else {
      throw Exception('Gagal mengunggah gambar ke Cloudinary');
    }
  }

  Future<void> submitPayment() async {
    if (selectedPaymentMethod.value == 'Transfer Bank' && paymentProof.value == null) {
      Get.snackbar(
        'Error',
        'Mohon unggah bukti pembayaran',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('pesanan');
      String? keyV = pesananController.selectedVehicle.value.key;

      // Validasi metode pembayaran
      if (selectedPaymentMethod.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Silakan pilih metode pembayaran terlebih dahulu.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      DatabaseEvent vehicleEvent = await FirebaseDatabase.instance
          .ref('Kendaraan')
          .child(keyV!)
          .once();

      String key = databaseRef.push().key!;

      if (vehicleEvent.snapshot.exists) {
        final vehicleData = Map<String, dynamic>.from(vehicleEvent.snapshot.value as Map);

        KendaraanModel selectedVehicle = KendaraanModel.fromJson(vehicleData);

        String? cloudinaryUrl;
        if (paymentProof.value != null) {
          cloudinaryUrl = await uploadImageToCloudinary(paymentProof.value!);
        }

        Map<String, dynamic> data = {
          'idPesanan': key,
          'dataUser': homeController.userData.value!.toJson(),
          'vehicle': selectedVehicle.toJson(),
          'totalHarga': pesananData['totalPrice'],
          'metodePembayaran': selectedPaymentMethod.value,
          'statusPembayaran': selectedPaymentMethod.value == 'Tunai' ? 'Belum Lunas' : 'Lunas',
          'buktiPembayaran': cloudinaryUrl ?? 'Tidak Ada',
          'tanggalPesanan': DateTime.now().toIso8601String(),
          'pesananAlamat': pesananData['address'] == '' 
              ? 'Rental Bandung Intarent' 
              : pesananData['address'],          
          'statusPemesanan': 'Menunggu Konfirmasi',
          'fitur': pesananData['items'],
          'booking' : pesananData['bookingDate'].toString(),
          'return' : pesananData['returnDate'].toString(),

        };

        await databaseRef.child(key).set(data);

        isPaymentSubmitted.value = true;
        Get.snackbar(
          'Sukses',
          'Pembayaran berhasil dikonfirmasi!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAll(NavBarView());
      } else {
        Get.snackbar(
          'Error',
          'Data kendaraan tidak ditemukan untuk key: $keyV',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

  }
}