import 'package:drive_now/app/data/kendaraan_model.dart';
import 'package:drive_now/app/modules/konfirmasi_pesanan/views/konfirmasi_pesanan_view.dart';
import 'package:get/get.dart';

class PesananController extends GetxController {
  var selectedVehicle = KendaraanModel(name: '', price2: '', price: '', imageUrl: '', category: '', brand: '', cc: '', model: '', key: '', status: '').obs;
  var price = 0.obs;
  var selectedPriceOption = "".obs;
  var selectedDuration = "".obs;
  var featuresSelected = <String>[].obs;

  var helmetCount = 0.obs;
  var raincoatCount = 0.obs;

  void setSelectedVehicle(KendaraanModel vehicle) {
    selectedVehicle.value = vehicle;
    price.value = 0;
    selectedPriceOption.value = "";
    helmetCount.value = 0;
    raincoatCount.value = 0;
    featuresSelected.clear();  // Clear previous features when vehicle is changed
  }

  void selectPrice(String priceOption, String duration) {
    selectedPriceOption.value = priceOption;
    selectedDuration.value = duration;
    price.value = int.parse(priceOption);
    resetToggle();
  }

  void toggleFeature(String feature) {
    // Fitur selain helm dan raincoat
    if (feature != 'Helm' && feature != 'Jas Hujan') {
      if (featuresSelected.contains(feature)) {
        featuresSelected.remove(feature);
        price.value -= getFeaturePrice(feature);
      } else {
        featuresSelected.add(feature);
        price.value += getFeaturePrice(feature);
      }
    }
  }

  void incrementFeature(String feature) {
    if (feature == 'Helm') {
      helmetCount.value++;
      price.value += 5000;
      _updateFeatureInSelected('Helm', helmetCount.value);
    } else if (feature == 'Jas Hujan') {
      raincoatCount.value++;
      price.value += 3000;
      _updateFeatureInSelected('Jas Hujan', raincoatCount.value);
    }
  }

  void decrementFeature(String feature) {
    if (feature == 'Helm' && helmetCount.value > 0) {
      helmetCount.value--;
      price.value -= 5000;
      if (helmetCount.value > 0) {
        _updateFeatureInSelected('Helm', helmetCount.value);
      } else {
        _removeFeatureFromSelected('Helm');
      }
    } else if (feature == 'Jas Hujan' && raincoatCount.value > 0) {
      raincoatCount.value--;
      price.value -= 3000;
      if (raincoatCount.value > 0) {
        _updateFeatureInSelected('Jas Hujan', raincoatCount.value);
      } else {
        _removeFeatureFromSelected('Jas Hujan');
      }
    }
  }

  void resetToggle() {
    featuresSelected.clear();
    helmetCount.value = 0;
    raincoatCount.value = 0;
    price.value = selectedPriceOption.value.isNotEmpty
        ? int.parse(selectedPriceOption.value)
        : 0;
  }

  Future<void> processOrder() async {
    if (selectedDuration.value.isEmpty) {
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
      'priceVehicle': selectedPriceOption.contains('12 Jam')
          ? selectedVehicle.value.price
          : selectedVehicle.value.price2,
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
        return 15000; // Harga fitur "Antar Kendaraan"
      default:
        return 0; // Jika fitur tidak dikenal
    }
  }

  void _updateFeatureInSelected(String feature, int count) {
    String featureWithCount = '$feature ($count)';
    // Hapus jika sudah ada, untuk menghindari duplikasi
    featuresSelected.removeWhere((f) => f.startsWith(feature));
    // Tambahkan fitur dengan jumlah baru
    featuresSelected.add(featureWithCount);
  }

  void _removeFeatureFromSelected(String feature) {
    featuresSelected.removeWhere((f) => f.startsWith(feature));
  }
}
