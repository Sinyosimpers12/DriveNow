import 'package:drive_now/app/modules/profil/controllers/profil_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class EditProfileView extends GetView<ProfilController> {
  const EditProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(ProfilController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF8C9EFF),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage: (controller.homeController.userData.value?.photoUrl != null &&
                controller.homeController.userData.value!.photoUrl.isNotEmpty)
                  ? NetworkImage(controller.homeController.userData.value!.photoUrl)
                  : const AssetImage('assets/icons/user_default.png'),
                    ),
              SizedBox(height: 40),
              _buildTextField(
                label: 'Nama Lengkap',
                controller: controller.nameController,
                initialValue: controller.homeController.userData.value!.name,
              ),
              SizedBox(height: 20),
              _buildTextField(
                label: 'Email',
                controller: controller.emailController,
                initialValue: controller.homeController.userData.value!.email,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              SizedBox(height: 20),
              _buildTextField(
                label: 'No HP',
                controller: controller.phoneController,
                initialValue: controller.homeController.userData.value!.noHp,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8C9EFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false, // Add a readOnly parameter
  }) {
    controller.text = initialValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color :readOnly ? Colors.black.withOpacity(0.25): Colors.black
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:Color(0xFFEEEEEE), // Darker shade for read-only field
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly, // Set readOnly property to true for email
            style: TextStyle(
              color: readOnly ? Colors.black.withOpacity(0.25): Colors.black, // Text color remains black
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              hintText: readOnly ? 'Email tidak dapat diedit' : '', // Optional hint when read-only
              hintStyle: TextStyle(color: readOnly ? Colors.black.withOpacity(0.5):  Colors.grey), // Optional hint text style
            ),
          ),
        ),
      ],
    );
  }

}
