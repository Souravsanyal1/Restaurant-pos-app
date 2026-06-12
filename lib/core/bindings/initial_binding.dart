import 'package:get/get.dart';
import '../services/db_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<DbService>(DbService(), permanent: true);
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
  }
}
