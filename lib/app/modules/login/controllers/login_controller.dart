import 'dart:convert';
import 'package:drive_now/app/modules/nav_bar/views/nav_bar_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class LoginController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("users");

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// Login dengan Google
  Future<void> loginWithGoogleAndSaveData() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar('Info', 'Login dibatalkan oleh pengguna.');
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);

      User? user = userCredential.user;
      if (user == null) {
        Get.snackbar('Error', 'Gagal mendapatkan data pengguna.');
        return;
      }

      bool userExists = await _checkIfUserExists(user.uid);

      String cloudinaryUrl;
      if (userExists) {
        cloudinaryUrl = await _getExistingPhotoUrl(user.uid);
      } else {
        String? photoUrl = user.photoURL;
        cloudinaryUrl = await _uploadImageToCloudinary(photoUrl);

        await _saveUserDataToRealtimeDatabase(user, cloudinaryUrl);
      }

      Get.snackbar('Login Berhasil', 'Selamat datang, ${user.displayName ?? "User"}');
      Get.offAll(NavBarView());
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  /// Login dengan Email dan Password
  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email dan password tidak boleh kosong.');
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Get.offAll(NavBarView());
      Get.snackbar('Success', 'Selamat datang, $email');
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'Pengguna dengan email tersebut tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password yang Anda masukkan salah.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      } else {
        errorMessage = 'Terjadi kesalahan saat login. Silakan coba lagi.';
      }

      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  Future<bool> _checkIfUserExists(String uid) async {
    DataSnapshot snapshot = await dbRef.child(uid).get();
    return snapshot.exists;
  }

  Future<String> _getExistingPhotoUrl(String uid) async {
    DataSnapshot snapshot = await dbRef.child(uid).child("photo_url").get();
    if (snapshot.exists && snapshot.value != null) {
      return snapshot.value as String;
    }
    throw Exception("Foto tidak ditemukan untuk pengguna ini.");
  }

  Future<String> _uploadImageToCloudinary(String? imageUrl) async {
    if (imageUrl == null) throw Exception('Foto profil tidak ditemukan.');

    const String cloudName = 'dw2qgzbpm';
    const String uploadPreset = 'profilPictures';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final response = await http.post(
      uri,
      body: {
        'file': imageUrl,
        'upload_preset': uploadPreset,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'];
    } else {
      throw Exception('Gagal mengunggah foto ke Cloudinary');
    }
  }

  Future<void> _saveUserDataToRealtimeDatabase(User user, String photoUrl) async {
    DatabaseReference userRef = dbRef.child(user.uid);
    await userRef.set({
      "uid": user.uid,
      "name": user.displayName ?? "No Name",
      "email": user.email ?? "No Email",
      "photo_url": photoUrl,
      'sim': '',
      "created_at": DateTime.now().toIso8601String(),
    });
  }
}