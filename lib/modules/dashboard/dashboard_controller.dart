import 'package:get/get.dart';
import '../../core/services/db_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/order_model.dart';
import '../../data/models/table_model.dart';
import '../../routes/app_routes.dart';

class DashboardController extends GetxController {
  final dbService = Get.find<DbService>();
  final authService = Get.find<AuthService>();

  // Reactive Stats
  final totalSalesToday = 0.0.obs;
  final ordersCountToday = 0.obs;
  final activeTablesCount = 0.obs;
  final lowStockAlertsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Bind reactive computations
    ever(dbService.orders, (_) => _calculateStats());
    ever(dbService.tables, (_) => _calculateStats());
    ever(dbService.products, (_) => _calculateStats());
    
    _calculateStats();
  }

  void _calculateStats() {
    // Today's Sales
    double total = 0;
    int count = 0;
    for (var order in dbService.orders) {
      if (order.orderStatus == OrderStatus.delivered) {
        total += order.totalAmount;
      }
      count++;
    }
    totalSalesToday.value = total;
    ordersCountToday.value = count;

    // Active (Occupied) Tables
    activeTablesCount.value = dbService.tables.where((t) => t.status == TableStatus.occupied).length;

    // Low Stock Alert Count (e.g. stock <= 5)
    lowStockAlertsCount.value = dbService.products.where((p) => p.stock <= 5).length;
  }

  void logout() {
    authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  // Navigation helpers
  void goToPOS() => Get.toNamed(AppRoutes.pos);
  void goToKitchen() => Get.toNamed(AppRoutes.kitchen);
  void goToInventory() => Get.toNamed(AppRoutes.inventory);
  void goToTables() => Get.toNamed(AppRoutes.tables);
  void goToReports() => Get.toNamed(AppRoutes.reports);
  void goToSettings() => Get.toNamed(AppRoutes.settings);
}
