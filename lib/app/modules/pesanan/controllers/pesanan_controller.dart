import 'package:drive_now/app/data/kendaraan_model.dart';
import 'package:drive_now/app/modules/home/controllers/home_controller.dart';
import 'package:drive_now/app/modules/konfirmasi_pesanan/views/konfirmasi_pesanan_view.dart';
import 'package:get/get.dart';

class PesananController extends GetxController {
  final HomeController homeController = Get.find();
  final selectedVehicle = KendaraanModel(
    name: '',
    price2: '',
    price: '',
    imageUrl: '',
    platnomor: '',
    category: '',
    brand: '',
    cc: '',
    model: '',
    key: '',
    status: '',
  ).obs;
  final price = 0.obs;
  final selectedPriceOption = "".obs;
  final featuresSelected = <String>[].obs;
  final helmetCount = 0.obs;
  final raincoatCount = 0.obs;
  final rentalType = '';

  @override
  void onInit() {
    super.onInit();
    selectPrice();
  }

  void setSelectedVehicle(KendaraanModel vehicle) {
    selectedVehicle.value = vehicle;
    resetOrderDetails();
    selectPrice();
    print(price);
  }

  void resetOrderDetails() {
    price.value = 0;
    selectedPriceOption.value = homeController.selectedRentalType.value;
    helmetCount.value = 0;
    raincoatCount.value = 0;
    featuresSelected.clear();
  }

  void selectPrice() {
    final rentalType = selectedPriceOption.value;
    if (selectedVehicle.value.price.isEmpty || selectedVehicle.value.price2.isEmpty) {
      price.value = 0;
      return;
    }

    if (rentalType == 'Harian') {
      price.value = int.parse(selectedVehicle.value.price) * homeController.rentalDays;
    } else {
      price.value = int.parse(selectedVehicle.value.price2);
    }
  }

  void toggleFeature(String feature) {
    if (feature == 'Helm' || feature == 'Jas Hujan') return;

    if (featuresSelected.contains(feature)) {
      featuresSelected.remove(feature);
      price.value -= getFeaturePrice(feature);
    } else {
      featuresSelected.add(feature);
      price.value += getFeaturePrice(feature);
    }
  }

  void incrementFeature(String feature) {
    final incrementAmount = feature == 'Helm' ? 5000 : feature == 'Jas Hujan' ? 3000 : 0;
    if (incrementAmount > 0) {
      if (feature == 'Helm') {
        helmetCount.value++;
      } else if (feature == 'Jas Hujan') {
        raincoatCount.value++;
      }
      price.value += incrementAmount;
      _updateFeatureInSelected(feature, feature == 'Helm' ? helmetCount.value : raincoatCount.value);
    }
  }

  void decrementFeature(String feature) {
    final decrementAmount = feature == 'Helm' ? 5000 : feature == 'Jas Hujan' ? 3000 : 0;
    if (decrementAmount > 0) {
      if (feature == 'Helm' && helmetCount.value > 0) {
        helmetCount.value--;
        _handleFeatureRemoval('Helm', helmetCount.value, decrementAmount);
      } else if (feature == 'Jas Hujan' && raincoatCount.value > 0) {
        raincoatCount.value--;
        _handleFeatureRemoval('Jas Hujan', raincoatCount.value, decrementAmount);
      }
    }
  }

  void _handleFeatureRemoval(String feature, int count, int decrementAmount) {
    price.value -= decrementAmount;
    if (count > 0) {
      _updateFeatureInSelected(feature, count);
    } else {
      _removeFeatureFromSelected(feature);
    }
  }

  Future<void> processOrder() async {
    if (homeController.selectedRentalType.value.isEmpty) {
      Get.snackbar(
        "Error",
        "Durasi sewa harus dipilih.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      Get.to(() => KonfirmasiPesananView(), arguments: {
        'price': price.value,
        'features': featuresSelected,
        'helmets': helmetCount.value,
        'raincoats': raincoatCount.value,
        'priceVehicle': selectedPriceOption.value.contains('12 Jam')
          ? selectedVehicle.value.price2
          : int.parse(selectedVehicle.value.price) * homeController.rentalDays,
      });
    } catch (e) {
      Get.snackbar(
        "Error",
        "Terjadi kesalahan saat memproses pemesanan.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  int getFeaturePrice(String feature) {
    switch (feature) {
      case 'Antar Kendaraan':
        return 15000;
      default:
        return 0;
    }
  }

  void _updateFeatureInSelected(String feature, int count) {
    final featureWithCount = '$feature ($count)';
    featuresSelected.removeWhere((f) => f.startsWith(feature));
    featuresSelected.add(featureWithCount);
  }

  void _removeFeatureFromSelected(String feature) {
    featuresSelected.removeWhere((f) => f.startsWith(feature));
  }
}