import 'package:drive_now/app/modules/riwayat/views/detail_pesanan.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class RiwayatController extends GetxController {
  final databaseRef = FirebaseDatabase.instance.ref('pesanan');

  RxList<Map<String, dynamic>> userOrders = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredOrders = <Map<String, dynamic>>[].obs;
  RxString selectedFilter = 'Semua Tanggal'.obs;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void onInit() {
    super.onInit();
    fetchUserOrders();
  }

  void onOrderTap(Map order) {
    Get.to(DetailPesananView(), arguments: order); 
  }

  String formatTanggal(String rawDate) {
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  String formatTanggalDetail(String rawDate) {
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Konfirmasi':
        return Colors.blue;
      case 'Berlangsung':
        return Color(0xFFFFA500);
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void fetchUserOrders() {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      // Listener untuk mendeteksi perubahan secara real-time
      databaseRef.orderByChild('dataUser/uid').equalTo(uid).onValue.listen((event) {
        final data = event.snapshot.value;

        if (data != null) {
          Map<String, dynamic> ordersData = Map<String, dynamic>.from(data as Map);

          // Kosongkan list sebelum diisi ulang
          userOrders.clear();

          ordersData.forEach((key, value) {
            userOrders.add(Map<String, dynamic>.from(value));
          });

          sortOrdersByDate(); // Sort ulang setiap ada perubahan
        }
      }, onError: (error) {
        print('Error fetching orders in real-time: $error');
      });
    }
  }


  void sortOrdersByDate() {
    userOrders.sort((a, b) {
      DateTime dateA = DateTime.parse(a['tanggalPesanan']);
      DateTime dateB = DateTime.parse(b['tanggalPesanan']);
      return dateB.compareTo(dateA); // Sort descending (latest first)
    });
    filteredOrders.value = userOrders;
  }

  void applyFilter() {
    switch (selectedFilter.value) {
      case '30 Hari Terakhir':
        DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
        filteredOrders.value = userOrders.where((order) {
          DateTime orderDate = DateTime.parse(order['tanggalPesanan']);
          return orderDate.isAfter(thirtyDaysAgo);
        }).toList();
        break;
      case '90 Hari Terakhir':
        DateTime ninetyDaysAgo = DateTime.now().subtract(Duration(days: 90));
        filteredOrders.value = userOrders.where((order) {
          DateTime orderDate = DateTime.parse(order['tanggalPesanan']);
          return orderDate.isAfter(ninetyDaysAgo);
        }).toList();
        break;
      case 'Pilih Tanggal Sendiri':
        if (startDate != null && endDate != null) {
          filteredOrders.value = userOrders.where((order) {
            DateTime orderDate = DateTime.parse(order['tanggalPesanan']);
            return orderDate.isAfter(startDate!) && orderDate.isBefore(endDate!);
          }).toList();
        }
        break;
      default:
        filteredOrders.value = userOrders;
    }
  }

  Future<void> batalkanPesanan(String idPesanan) async {
    try {
      await FirebaseDatabase.instance.ref('pesanan/$idPesanan').update({
        'statusPemesanan': 'Dibatalkan',
      });
      Get.snackbar(
        'Berhasil',
        'Pesanan berhasil dibatalkan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat membatalkan pesanan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
}


  Future<void> selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      startDate = picked.start;
      endDate = picked.end;
      applyFilter();
    }
  }
}
