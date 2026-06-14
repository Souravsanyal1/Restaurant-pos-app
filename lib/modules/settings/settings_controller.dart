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

  // Shop Details fields
  final shopAddressController = TextEditingController();
  final shopPhoneController = TextEditingController();
  final shopEmailController = TextEditingController();

  // Coupon fields
  final couponCodeController = TextEditingController();
  final couponValueController = TextEditingController();
  final couponMinOrderController = TextEditingController();
  final couponIsPercentage = true.obs;

  // User Management fields (Super Admin only)
  final selectedRoleToManage = AppStrings.roleSuperAdmin.obs;
  final roleEmailController = TextEditingController();
  final rolePasswordController = TextEditingController();

  // Staff Management fields
  final staffNameController = TextEditingController();
  final isAddingWaiter = true.obs; // Toggle between Waiter and Chef

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
    // Load current db service settings
    nameController.text = dbService.restaurantName.value;
    vatController.text = (dbService.vatRate.value * 100).toStringAsFixed(0);
    serviceChargeController.text = dbService.serviceCharge.value.toStringAsFixed(0);

    // Shop details settings
    shopAddressController.text = dbService.shopAddress.value;
    shopPhoneController.text = dbService.shopPhone.value;
    shopEmailController.text = dbService.shopEmail.value;

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
      address: shopAddressController.text.trim(),
      phone: shopPhoneController.text.trim(),
      email: shopEmailController.text.trim(),
    );

    Get.snackbar(
      'Success',
      'Settings updated successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
      colorText: const Color(0xFF0D9488),
    );
  }

  void saveRoleCredentials() async {
    final role = selectedRoleToManage.value;
    final email = roleEmailController.text.trim();
    final password = rolePasswordController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Error', 'Email cannot be empty.');
      return;
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
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

    // Show loading overlay
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final authService = Get.find<AuthService>();
      await authService.registerOrUpdateStaff(email, password, role);

      // Update local storage too for UI consistency if needed
      dbService.updateCredentials(role, email, password);

      Get.back(); // Dismiss loading
      Get.snackbar(
        'Success',
        'Firebase account for "$role" synchronized successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
        colorText: const Color(0xFF0D9488),
      );
    } catch (e) {
      Get.back(); // Dismiss loading
      Get.snackbar(
        'Sync Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        duration: const Duration(seconds: 5),
      );
    }
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

  void toggleCoupon(String code) async {
    await dbService.toggleCouponStatus(code);
  }

  void deleteCoupon(String code) {
    dbService.deleteCoupon(code);
  }

  void migrateData() async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      await dbService.migrateMockDataToFirebase();
      Get.back();
      Get.snackbar('Success', 'Menu migrated to Firebase successfully!');
    } catch (e) {
      Get.back();
      Get.snackbar('Error', e.toString());
    }
  }

  void addStaff() async {
    final name = staffNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Name cannot be empty.');
      return;
    }

    if (isAddingWaiter.value) {
      await dbService.addWaiter(name);
    } else {
      await dbService.addChef(name);
    }

    staffNameController.clear();
    Get.snackbar('Success', '$name added successfully!');
  }

  void removeWaiter(String name) async {
    await dbService.deleteWaiter(name);
  }

  void removeChef(String name) async {
    await dbService.deleteChef(name);
  }

  @override
  void onClose() {
    nameController.dispose();
    vatController.dispose();
    serviceChargeController.dispose();
    shopAddressController.dispose();
    shopPhoneController.dispose();
    shopEmailController.dispose();
    couponCodeController.dispose();
    couponValueController.dispose();
    couponMinOrderController.dispose();
    roleEmailController.dispose();
    rolePasswordController.dispose();
    staffNameController.dispose();
    super.onClose();
  }
}
