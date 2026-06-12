import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/auth_service.dart';
import 'app_routes.dart';

class RoleMiddleware extends GetMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware({required this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // 1. Check if user is logged in
    if (!authService.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // 2. Check if user's role is allowed
    final userRole = authService.currentUserRole.value;
    if (!allowedRoles.contains(userRole)) {
      // Access Denied: Show warning and redirect to dashboard
      Get.snackbar(
        'Access Denied (অ্যাক্সেস অস্বীকৃত)',
        'Your role ($userRole) is not authorized to access this module.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withValues(alpha: 0.15),
        colorText: Colors.red,
        icon: const Icon(Icons.security_rounded, color: Colors.red),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return const RouteSettings(name: AppRoutes.dashboard);
    }

    return null;
  }
}

class LoginMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn.value) {
      return const RouteSettings(name: AppRoutes.dashboard);
    }
    return null;
  }
}
