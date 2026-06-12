import 'package:get/get.dart';
import '../../core/services/db_service.dart';
import '../../data/models/table_model.dart';

class TablesController extends GetxController {
  final dbService = Get.find<DbService>();

  void toggleTableStatus(String id, TableStatus current) {
    TableStatus next;
    switch (current) {
      case TableStatus.available:
        next = TableStatus.reserved;
        break;
      case TableStatus.reserved:
        next = TableStatus.occupied;
        break;
      case TableStatus.occupied:
        next = TableStatus.available;
        break;
    }
    dbService.updateTableStatus(id, next);
  }

  void addNewTable(String name, int capacity) {
    if (name.trim().isEmpty) {
      Get.snackbar('Input Error', 'Please enter a table name.');
      return;
    }
    final id = 'T${dbService.tables.length + 1}';
    dbService.addTable(TableModel(
      id: id,
      name: name,
      capacity: capacity,
      status: TableStatus.available,
    ));
    Get.back(); // close modal dialog
    Get.snackbar('Table Added', 'Table "$name" has been added successfully.');
  }
}
