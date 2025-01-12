class KendaraanModel {
  final String name;
  final String category;
  final String brand;
  final String imageUrl;
  final String platnomor;
  final String price;
  final String price2;
  final String cc;
  final String model;
  final String status;
  String? key;

  KendaraanModel({
    required this.name,
    required this.category,
    required this.brand,
    required this.imageUrl,
    required this.platnomor,
    required this.price,
    required this.cc,
    required this.model,
    required this.status,
    required this.price2,
    this.key,
  });

  factory KendaraanModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return KendaraanModel(
      name: json['name'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String,
      imageUrl: json['image_url'] as String? ?? 
        'https://2.bp.blogspot.com/-o2aCi7-VNfY/XwU9ciw4vVI/AAAAAAAAmDI/AnceEf0nEQ4EYBoORMDHWXoVMWaMnqcxQCK4BGAYYCw/s1600/84629060_791682118006722_5456952411683872835_n.jpg',
      platnomor: json['platnomor'].toString(),
      price: json['price'].toString(),
      price2: json['price2'].toString(),
      cc: json['cc'].toString(),
      model: json['model'] as String,
      status: json['status'] as String,
      key: key ?? json['key'], // Memprioritaskan parameter `key`
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key, 
      'name': name,
      'category': category,
      'brand': brand,
      'image_url': imageUrl,
      'platnomor': platnomor,
      'price': price,
      'price2': price2,
      'cc': cc,
      'model': model,
      'status': status,
    };
  }
}