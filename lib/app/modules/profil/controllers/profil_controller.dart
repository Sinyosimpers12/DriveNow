import 'dart:convert';
import 'dart:io';
import 'package:drive_now/app/modules/home/controllers/home_controller.dart';
import 'package:drive_now/app/modules/profil/views/profil_view.dart';
import 'package:image/image.dart' as img;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

class ProfilController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  final HomeController homeController = Get.put(HomeController());

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  final String cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dw2qgzbpm/image/upload';
  final String cloudinaryPreset = 'simUrl';

  RxString cloudinaryPublicId = ''.obs; // Store Cloudinary public ID

  Future<void> updateProfile() async {
    try {
      // Get the current logged-in user
      User? user = auth.currentUser;

      if (user != null) {
        // Get user UID
        String uid = user.uid;

        // Get the user's input data
        String name = nameController.text.trim();
        String phone = phoneController.text.trim();

        // Prepare updated data map
        Map<String, dynamic> updatedData = {};

        // Add fields if there are any updates
        if (name.isNotEmpty) {
          updatedData['name'] = name;
        }
        if (phone.isNotEmpty) {
          updatedData['noHp'] = phone;
        }

        // Update user data in Realtime Database
        await database.ref('users/$uid').update(updatedData);

        // Show success message
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Show error message if update fails
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void saveProfile() {
    updateProfile();
    Get.off(ProfilView());
  }

  Future<File> compressImage(File imageFile) async {
    // Membaca file gambar
    final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    if (image == null) {
      throw Exception("Failed to decode image");
    }

    // Mengubah ukuran gambar untuk kompresi (misalnya, mengubah ukuran menjadi 800x600)
    img.Image resizedImage = img.copyResize(image, width: 800);


    final compressedImageFile = File('${imageFile.parent.path}/compressed_image.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));

    return compressedImageFile;
  }

  Future<void> pickAndUploadImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);

        // Kompres gambar sebelum upload
        File compressedImage = await compressImage(imageFile);

        String newImageUrl = await uploadToCloudinary(compressedImage);

        await updateSimImage(newImageUrl);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick or upload image: ${e.toString()}');
    }
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = cloudinaryPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        cloudinaryPublicId.value = data['public_id'];
        return data['secure_url'];
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      throw Exception('Cloudinary upload error: $e');
    }
  }

  Future<void> updateSimImage(String newImageUrl) async {
    try {
      User? user = auth.currentUser;

      if (user != null) {
        String uid = user.uid;

        await database.ref('users/$uid').update({
          'sim': newImageUrl,
        });


        Get.snackbar(
          'Success',
          'SIM image updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'User is not logged in',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update SIM image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Function to change SIM image (pick and upload)
  Future<void> changeSimImage(ImageSource source) async {
    try {
      await pickAndUploadImage(source); 
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to change SIM image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Logout function
  Future<void> logout() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
      Get.snackbar('Logout', 'Anda telah berhasil logout.');
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: ${e.toString()}');
    }
  }
}