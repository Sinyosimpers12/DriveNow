import 'package:drive_now/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);

  // Inisialisasi FlutterLocalNotificationsPlugin
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/logo');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  // Inisialisasi plugin
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}