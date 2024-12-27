import 'package:drive_now/app/data/kendaraan_model.dart';
import 'package:drive_now/app/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  final isLoading = true.obs;
  final uploads = <KendaraanModel>[].obs;
  final filteredUploads = <KendaraanModel>[].obs;
  final selectedCategory = Rxn<String>();
  final selectedBrand = Rxn<String>();
  final brands = <String>[].obs;
  final userData = Rxn<UserModel>();

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child("Kendaraan");
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference databaseRefUser = FirebaseDatabase.instance.ref().child("users");

  @override
  void onInit() {
    super.onInit();
    fetchUploads();
    fetchUserData();
    final user = auth.currentUser;
    if (user != null) {
      final uid = user.uid;
      // Menambahkan listener untuk data pengguna
      databaseRefUser.child(uid).onValue.listen((event) {
        if (event.snapshot.exists) {
          // Jika data pengguna ada, perbarui data di aplikasi
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          userData.value = UserModel.fromJson(data);  // Menetapkan nilai untuk userData
        } else {
          // Jika data pengguna tidak ada, set userData menjadi null
          userData.value = null;
        }
      });
    }
    databaseRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        uploads.assignAll(
          data.entries.map((entry) {
            final kendaraan = KendaraanModel.fromJson(Map<String, dynamic>.from(entry.value));
            kendaraan.key = entry.key;
            return kendaraan;
          }).toList(),
        );
        filteredUploads.assignAll(uploads);
      } else {
        uploads.clear();
        filteredUploads.clear();
      }
    });
  }

  Future<void> fetchUploads() async {
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        uploads.assignAll(
          data.entries.map((entry) {
            final kendaraan = KendaraanModel.fromJson(Map<String, dynamic>.from(entry.value));
            kendaraan.key = entry.key;
            
            compressImage(kendaraan.imageUrl).then((compressedImage) {
            }).catchError((e) {
              print("Gagal mengompres gambar: $e");
            });
          
            return kendaraan;
          }).toList(),
        );
        filteredUploads.assignAll(uploads);
        brands.assignAll(uploads.map((v) => v.brand).toSet().toList());
      } else {
        uploads.clear();
        filteredUploads.clear();
      }
    } finally {
      isLoading.value = false;
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
        userData.value = UserModel.fromJson(data); // Hanya satu objek pengguna
      } else {
        Get.snackbar('Error', 'Data pengguna tidak ditemukan.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil data pengguna: $e');
    }
  }

  // Reset filter
  void resetFilter() {
    selectedCategory.value = null;
    selectedBrand.value = null;
    filteredUploads.assignAll(uploads);
    update();
  }

  // Filter berdasarkan nama
  void filterByName(String query) {
    if (query.isEmpty) {
      filteredUploads.assignAll(uploads);
    } else {
      filteredUploads.assignAll(
        uploads.where((vehicle) => vehicle.name.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

  // Filter berdasarkan kategori dan merek secara bersamaan
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
}