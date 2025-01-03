import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/login_controller.dart';

class LupaPasswordView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final LoginController controller = Get.find<LoginController>();

  LupaPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Lupa Password',
          style: GoogleFonts.poppins(color: Colors.white), // Apply Poppins font
        ),
        backgroundColor: Color(0xFF707FDD),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan email Anda untuk mengatur ulang password:',
                style: GoogleFonts.poppins(fontSize: 16), // Apply Poppins font
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF707FDD)),
                  ),
                ),
                style: GoogleFonts.poppins(), // Apply Poppins font
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String email = emailController.text.trim();
                  controller.forgotPassword(email); // Trigger the password reset
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF707FDD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Kirim Link Reset',
                    style: GoogleFonts.poppins(color: Colors.white), // Apply Poppins font
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
