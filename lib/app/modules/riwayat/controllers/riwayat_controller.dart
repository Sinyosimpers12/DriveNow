import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:drive_now/app/modules/nav_bar/views/nav_bar_view.dart';
import 'package:drive_now/app/modules/riwayat/views/detail_pesanan.dart';

class RiwayatController extends GetxController {
  final databaseRef = FirebaseDatabase.instance.ref('pesanan');

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin; // Declare it here

  RxList<Map<String, dynamic>> userOrders = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredOrders = <Map<String, dynamic>>[].obs;
  RxString selectedFilter = 'Semua Tanggal'.obs;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void onInit() {
    super.onInit();
    flutterLocalNotificationsPlugin = Get.put(FlutterLocalNotificationsPlugin()); // Initialize here
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
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void fetchUserOrders() {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      databaseRef.orderByChild('dataUser/uid').equalTo(uid).onValue.listen((event) {
        final data = event.snapshot.value;

        if (data != null) {
          Map<String, dynamic> ordersData = Map<String, dynamic>.from(data as Map);

          userOrders.clear();

          ordersData.forEach((key, value) {
            final order = Map<String, dynamic>.from(value);

            // Cek jika status berubah (periksa semua status)
            final previousOrder = userOrders.firstWhereOrNull((o) => o['id'] == order['id']);
            if (previousOrder != null &&
                previousOrder['statusPemesanan'] != order['statusPemesanan']) {
              _showLocalNotification();
            }

            userOrders.add(order);
          });

          sortOrdersByDate();
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
      return dateB.compareTo(dateA);
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
    Get.offAll(NavBarView());
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

  Future<void> _showLocalNotification() async {
    String title = 'Status Pesanan Diperbarui';
    String body = 'Status pesanan Anda diperbarui.';

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'your_channel_id',
      'Status Pesanan',
      channelDescription: 'Notifikasi perubahan status pesanan',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}