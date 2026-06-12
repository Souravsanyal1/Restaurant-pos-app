import 'package:get/get.dart';
import '../constants/app_strings.dart';
import 'db_service.dart';

class AuthService extends GetxService {
  final isLoggedIn = false.obs;
  final currentUserRole = AppStrings.roleCashier.obs; // Default role for convenience
  final currentUserEmail = ''.obs;

  final dbService = Get.find<DbService>();

  bool login(String email, String password, String role) {
    final creds = dbService.userCredentials[role];
    if (creds != null) {
      if (creds['email'] == email.trim() && creds['password'] == password.trim()) {
        isLoggedIn.value = true;
        currentUserRole.value = role;
        currentUserEmail.value = email.trim();
        return true;
      }
    }
    return false;
  }

  void logout() {
    isLoggedIn.value = false;
    currentUserRole.value = AppStrings.roleCashier;
    currentUserEmail.value = '';
  }
}
