import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/db_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/coupon_model.dart';
import '../../core/constants/app_strings.dart';

class SettingsController extends GetxController {
  final dbService = Get.find<DbService>();

  // Settings fields
  final nameController = TextEditingController();
  final vatController = TextEditingController();
  final serviceChargeController = TextEditingController();

  // QR Settings fields
  final showQrPayment = true.obs;
  final qrGatewayController = TextEditingController();
  final qrNumberController = TextEditingController();
  final qrImageUrlController = TextEditingController();

  // Coupon fields
  final couponCodeController = TextEditingController();
  final couponValueController = TextEditingController();
  final couponMinOrderController = TextEditingController();
  final couponIsPercentage = true.obs;

  // User Management fields (Super Admin only)
  final selectedRoleToManage = AppStrings.roleSuperAdmin.obs;
  final roleEmailController = TextEditingController();
  final rolePasswordController = TextEditingController();

  final rolesList = [
    AppStrings.roleSuperAdmin,
    AppStrings.roleOwner,
    AppStrings.roleManager,
    AppStrings.roleCashier,
    AppStrings.roleKitchen,
    AppStrings.roleWaiter,
  ];

  @override
  void onInit() {
    super.onInit();
    // Load current DB service settings
    nameController.text = dbService.restaurantName.value;
    vatController.text = (dbService.vatRate.value * 100).toStringAsFixed(0);
    serviceChargeController.text = dbService.serviceCharge.value.toStringAsFixed(0);

    // QR Code Payment settings
    showQrPayment.value = dbService.showQrPayment.value;
    qrGatewayController.text = dbService.qrPaymentGateway.value;
    qrNumberController.text = dbService.qrPaymentNumber.value;
    qrImageUrlController.text = dbService.qrImageUrl.value;

    // Load initial values for role credentials
    _loadRoleCredentials(selectedRoleToManage.value);

    // Auto-update when role selection changes
    ever(selectedRoleToManage, (role) {
      _loadRoleCredentials(role);
    });
  }

  void _loadRoleCredentials(String role) {
    final creds = dbService.userCredentials[role];
    if (creds != null) {
      roleEmailController.text = creds['email'] ?? '';
      rolePasswordController.text = creds['password'] ?? '';
    }
  }

  void saveSettings() {
    final name = nameController.text.trim();
    final vatVal = double.tryParse(vatController.text.trim()) ?? 0.0;
    final chargeVal = double.tryParse(serviceChargeController.text.trim()) ?? 0.0;

    if (name.isEmpty) {
      Get.snackbar('Error', 'Restaurant name cannot be empty.');
      return;
    }

    dbService.updateSettings(
      name: name,
      vat: vatVal / 100.0,
      serviceFee: chargeVal,
      showQr: showQrPayment.value,
      qrGateway: qrGatewayController.text.trim(),
      qrNumber: qrNumberController.text.trim(),
      qrImage: qrImageUrlController.text.trim(),
    );

    Get.snackbar(
      'Success',
      'Settings updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
      colorText: const Color(0xFF0D9488),
    );
  }

  void saveRoleCredentials() {
    final role = selectedRoleToManage.value;
    final email = roleEmailController.text.trim();
    final password = rolePasswordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Error', 'Email cannot be empty.');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar('Error', 'Invalid email address format.');
      return;
    }

    if (password.isEmpty) {
      Get.snackbar('Error', 'Password cannot be empty.');
      return;
    }
    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters.');
      return;
    }

    dbService.updateCredentials(role, email, password);

    // Update active user session email if their own role was changed
    final authService = Get.find<AuthService>();
    if (authService.currentUserRole.value == role) {
      authService.currentUserEmail.value = email;
    }

    Get.snackbar(
      'Success',
      'Credentials for "$role" updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
      colorText: const Color(0xFF0D9488),
    );
  }

  void createCoupon() {
    final code = couponCodeController.text.trim().toUpperCase();
    final value = double.tryParse(couponValueController.text.trim()) ?? 0.0;
    final minOrder = double.tryParse(couponMinOrderController.text.trim()) ?? 0.0;

    if (code.isEmpty) {
      Get.snackbar('Error', 'Coupon code cannot be empty.');
      return;
    }

    if (value <= 0) {
      Get.snackbar('Error', 'Discount value must be greater than 0.');
      return;
    }

    // Percentage limit checks
    if (couponIsPercentage.value && value > 100) {
      Get.snackbar('Error', 'Percentage discount cannot exceed 100%.');
      return;
    }

    final newCoupon = CouponModel(
      code: code,
      isPercentage: couponIsPercentage.value,
      value: value,
      minOrderAmount: minOrder,
      isActive: true,
    );

    dbService.addCoupon(newCoupon);

    // Reset controllers
    couponCodeController.clear();
    couponValueController.clear();
    couponMinOrderController.clear();
    couponIsPercentage.value = true;

    Get.snackbar(
      'Success',
      'Coupon "$code" created successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
      colorText: const Color(0xFF0D9488),
    );
  }

  void toggleCoupon(String code) {
    dbService.toggleCouponStatus(code);
  }

  void deleteCoupon(String code) {
    dbService.deleteCoupon(code);
  }

  @override
  void onClose() {
    nameController.dispose();
    vatController.dispose();
    serviceChargeController.dispose();
    qrGatewayController.dispose();
    qrNumberController.dispose();
    qrImageUrlController.dispose();
    couponCodeController.dispose();
    couponValueController.dispose();
    couponMinOrderController.dispose();
    roleEmailController.dispose();
    rolePasswordController.dispose();
    super.onClose();
  }
}
