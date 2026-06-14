import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_strings.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final selectedRole = AppStrings.roleCashier.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  final authService = Get.find<AuthService>();

  final roles = [
    AppStrings.roleSuperAdmin,
    AppStrings.roleOwner,
    AppStrings.roleManager,
    AppStrings.roleCashier,
    AppStrings.roleKitchen,
    AppStrings.roleWaiter,
  ];

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void login() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter email address',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red);
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red);
      return;
    }

    isLoading.value = true;
    
    try {
      final success = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole.value,
      );

      if (success) {
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      Get.snackbar('Login Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 4));
    } finally {
      isLoading.value = false;
    }
  }
}
