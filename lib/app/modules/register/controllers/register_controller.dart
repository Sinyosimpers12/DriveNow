import 'package:drive_now/app/modules/login/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('users');

  // Controller untuk input
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Fungsi untuk registrasi pengguna
  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validasi input
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi.');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Password dan konfirmasi password tidak cocok.');
      return;
    }

    try {
      // Mendaftarkan pengguna ke Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Menyimpan data pengguna ke Firebase Realtime Database
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _databaseRef.child(uid).set({
          'name': name,
          'email': email,
          'noHp': phone,
          'uid': uid,
          'photo_url': '',
          'sim': '',
          'createdAt': DateTime.now().toIso8601String(),
        });

        Get.snackbar('Success', 'Registrasi berhasil!');
        Get.offAll(LoginView());
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      // Handle error dari Firebase
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email sudah digunakan oleh akun lain.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password terlalu lemah.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email tidak valid.';
      } else {
        errorMessage = 'Registrasi gagal. Silakan coba lagi.';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

