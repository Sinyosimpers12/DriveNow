import 'package:drive_now/app/modules/login/views/lupa_password_view.dart';
import 'package:drive_now/app/modules/register/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Color(0xFF707FDD),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Masuk',
                      style: GoogleFonts.poppins( // Apply Poppins font
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Masukan email dan password untuk melanjutkan',
                      style: GoogleFonts.poppins( // Apply Poppins font
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(), // Apply Poppins font
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF707FDD)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() => TextField(
                        controller: controller.passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: GoogleFonts.poppins(), // Apply Poppins font
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF707FDD)),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        obscureText: !controller.isPasswordVisible.value,
                      )),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.to(LupaPasswordView()); 
                      },
                      child: Text(
                        'Lupa password?',
                        style: GoogleFonts.poppins(color: Colors.blue), // Apply Poppins font
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: controller.login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF707FDD),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        )
                    ),
                    child: Center(
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.poppins( // Apply Poppins font
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Atau lanjut dengan:',
                          style: GoogleFonts.poppins(), // Apply Poppins font
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: controller.loginWithGoogleAndSaveData,
                    child: Center(
                      child: Image.asset(
                        "assets/icons/search.png",
                        width: 48,
                        height: 48,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Get.off(RegisterView());
                      },
                      child: Text.rich(
                        TextSpan(
                          text: 'Belum punya akun? ',
                          style: GoogleFonts.poppins(), // Apply Poppins font
                          children: [
                            TextSpan(
                              text: 'Register disini',
                              style: GoogleFonts.poppins( // Apply Poppins font
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}