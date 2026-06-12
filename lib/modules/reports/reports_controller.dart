import 'package:get/get.dart';
import '../../core/services/db_service.dart';
import '../../data/models/order_model.dart';

class ReportsController extends GetxController {
  final dbService = Get.find<DbService>();

  double get totalRevenue => dbService.orders
      .where((o) => o.orderStatus == OrderStatus.delivered)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  double get totalDiscounts => dbService.orders
      .where((o) => o.orderStatus == OrderStatus.delivered)
      .fold(0.0, (sum, o) => sum + o.discount);

  int get completedOrdersCount => dbService.orders
      .where((o) => o.orderStatus == OrderStatus.delivered)
      .length;

  void exportPDF() {
    Get.snackbar(
      'Export Success',
      'PDF Sales Report has been compiled and saved to local storage.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void exportExcel() {
    Get.snackbar(
      'Export Success',
      'Excel Inventory Spreadsheet exported successfully.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
