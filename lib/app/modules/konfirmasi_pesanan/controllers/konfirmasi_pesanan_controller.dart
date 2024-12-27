
import 'package:drive_now/app/modules/pesanan/controllers/pesanan_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class KonfirmasiPesananController extends GetxController {
  
  final pesananArguments = Get.arguments;
  final PesananController pesananController = Get.find();
  var helmCount = 0.obs;
  var raincoatCount = 0.obs;
  var totalPrice = 0.obs;
  var price = ''.obs; 
  var priceVehicle = 0.obs; 
  final formKey = GlobalKey<FormState>();


  var selectedFeatures = <String>[].obs;
  var selectedPriceOption = ''.obs; 
  Rx<DateTime?> selectedBookingDateTime = Rx<DateTime?>(null);
  Rx<DateTime?> returnDateTime = Rx<DateTime?>(null);

  final TextEditingController addressController = TextEditingController();
  bool get requiresAddress => selectedFeatures.contains('Antar Kendaraan');

  Map<String, String> featuresWithImages = {};

  LatLng location = LatLng(-6.972759930242774, 107.63675284440431);
  
  // Harga untuk setiap item
  final Map<String, int> itemPrices = {
    'helm': 5000,
    'raincoat': 3000,
    'antarKendaraan': 15000,
  };

  var items = <Map<String, dynamic>>[].obs;
  

  @override
  void onInit() {
    super.onInit();
    selectedPriceOption.value = pesananController.selectedDuration.value;
    initializeData();
  }

  void initializeData() {
    totalPrice.value = pesananArguments['price'];
    price.value = pesananArguments['priceVehicle'];
    selectedFeatures.assignAll(pesananArguments['features']);
    helmCount.value = pesananArguments['helmets'];
    raincoatCount.value = pesananArguments['raincoats'];

    priceVehicle.value = int.tryParse(price.value) ?? 0;

    featuresWithImages = {
      'Helm (${helmCount.value})': 'assets/images/helmet.png',
      'Jas Hujan (${raincoatCount.value})': 'assets/images/raincoat.png',
      'Antar Kendaraan': 'assets/images/scooter.png',
    };

    addItemsBasedOnFeatures();
  }

  void addItemsBasedOnFeatures() {
    items.clear();

    if (helmCount.value > 0) {
      items.add({
        "name": "Helm $helmCount",
        "price": helmCount.value * itemPrices['helm']!,
      });
    }

    if (raincoatCount.value > 0) {
      items.add({
        "name": "Jas Hujan $raincoatCount",
        "price": raincoatCount.value * itemPrices['raincoat']!,
      });
    }

    if (selectedFeatures.contains('Antar Kendaraan')) {
      items.add({
        "name": "Antar Kendaraan",
        "price": itemPrices['antarKendaraan']!,
      });
    }

     items.add({
          "name": "Sewa Kendaraan ${selectedPriceOption.value}",
          "price":  priceVehicle.toInt(),
        });
    updateTotalPrice();
  }

  void updateTotalPrice() {
    int total = items.fold(0, (sum, item) => sum + item['price'] as int);
    print("Total Price: $total");
  }
  

  String getFormattedDateTime() {
    if (selectedBookingDateTime.value != null) {
      return DateFormat("d MMMM yyyy (HH:mm)", "id_ID").format(selectedBookingDateTime.value!);
    } else {
      return "Belum dipilih";
    }
  }

  void calculateReturnDateTime() {
    if (selectedBookingDateTime.value != null) {
      if (selectedPriceOption.value == '12 Jam') {
        returnDateTime.value = selectedBookingDateTime.value!.add(Duration(hours: 12));
      } else if (selectedPriceOption.value == 'Per Hari') {
        returnDateTime.value = selectedBookingDateTime.value!.add(Duration(days: 1));
      }
    }
  }

  Future<void> pickDateTime(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        selectedBookingDateTime.value = combinedDateTime;
        calculateReturnDateTime();
      }
    }
  }

  Future<void> openMapsNavigation(double lat, double lng) async {
    
    final Uri googleUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving'
    );
    try {
      if (await canLaunchUrl(googleUrl)) {
        await launchUrl(googleUrl);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  void confirmOrder() {
    if (returnDateTime.value == null) {
      Get.snackbar(
        "Kesalahan",
        "Harap pilih tanggal dan waktu pengembalian.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Only validate form if address is required
    if (requiresAddress) {
      if (formKey.currentState == null || !formKey.currentState!.validate()) {
        Get.snackbar(
          "Kesalahan",
          "Harap isi alamat pengantaran.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Proceed with order
    Get.toNamed('/pembayaran', arguments: {
      'totalPrice': items.fold(0, (sum, item) => sum + item['price'] as int),
      'priceVehicle': selectedPriceOption,
      'features': selectedFeatures,
      'helmets': helmCount.value,
      'raincoats': raincoatCount.value,
      'bookingDate': selectedBookingDateTime.value,
      'returnDate': returnDateTime.value,
      'items': items,
      'selectedBookingDateTime': selectedBookingDateTime,
      'address': addressController.text,
    });
  }
}