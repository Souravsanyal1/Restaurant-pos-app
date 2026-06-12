import 'package:get/get.dart';
import '../../core/services/db_service.dart';
import '../../data/models/order_model.dart';

class KitchenController extends GetxController {
  final dbService = Get.find<DbService>();
  final selectedStatusIndex = 0.obs;

  List<OrderModel> get pendingOrders {
    return dbService.orders.where((o) => o.orderStatus == OrderStatus.pending).toList();
  }

  List<OrderModel> get preparingOrders {
    return dbService.orders.where((o) => o.orderStatus == OrderStatus.preparing).toList();
  }

  List<OrderModel> get readyOrders {
    return dbService.orders.where((o) => o.orderStatus == OrderStatus.ready).toList();
  }

  void moveToNextStatus(OrderModel order) {
    switch (order.orderStatus) {
      case OrderStatus.pending:
        // By default, move to preparing (or require Chef assignment first)
        dbService.updateOrderStatus(order.id, OrderStatus.preparing);
        break;
      case OrderStatus.preparing:
        dbService.updateOrderStatus(order.id, OrderStatus.ready);
        break;
      case OrderStatus.ready:
        dbService.updateOrderStatus(order.id, OrderStatus.delivered);
        break;
      case OrderStatus.delivered:
        break;
    }
  }

  void assignChef(String orderId, String chefName) {
    dbService.assignChefToOrder(orderId, chefName);
  }

  void cancelOrder(String orderId) {
    dbService.orders.removeWhere((o) => o.id == orderId);
    dbService.orders.refresh();
  }
}
