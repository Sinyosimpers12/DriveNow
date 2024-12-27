import 'package:drive_now/app/data/kendaraan_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

class PencarianController extends GetxController {
  final isLoading = true.obs;
  final uploads = <KendaraanModel>[].obs;
  final filteredData = <KendaraanModel>[].obs;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child("Kendaraan");

  @override
  void onInit() {
    super.onInit();
    fetchData();
    databaseRef.onValue.listen((event) {
      if (event.snapshot.exists) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        uploads.assignAll(
          data.values.map((e) => KendaraanModel.fromJson(Map<String, dynamic>.from(e))).toList(),
        );
        filteredData.assignAll(uploads);
      } else {
        uploads.clear();
        filteredData.clear();
      }
    });
  }

  Future<void> fetchData() async {
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        uploads.assignAll(
          data.values.map((e) => KendaraanModel.fromJson(Map<String, dynamic>.from(e))).toList(),
        );
        filteredData.assignAll(uploads);
      } else {
        uploads.clear();
        filteredData.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }


  void filterByName(String query) {
    if (query.isEmpty) {
      filteredData.assignAll(uploads);
    } else {
      filteredData.assignAll(
        uploads.where((vehicle) => vehicle.name.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }
}
