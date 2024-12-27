import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/route_middleware.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Mengecek status login Firebase Auth
    if (FirebaseAuth.instance.currentUser != null) {
      // Jika user sudah login, redirect ke halaman HOME
      return const RouteSettings(name: '/nav-bar');
    }
    // Jika belum login, tetap di halaman LOGIN
    return null;
  }
}