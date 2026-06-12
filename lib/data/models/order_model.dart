import 'product_model.dart';

enum OrderType {
  dineIn,
  takeAway,
  delivery,
}

enum PaymentMethod {
  cash,
  card,
  mobileBanking,
  due,
}

enum OrderStatus {
  pending,
  preparing,
  ready,
  delivered,
}

class OrderItem {
  final ProductModel product;
  final int quantity;

  OrderItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.finalPrice * quantity;
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String? tableName;
  final String? waiterName;
  String? chefName;
  final List<OrderItem> items;
  final OrderType orderType;
  final PaymentMethod paymentMethod;
  OrderStatus orderStatus;
  final DateTime time;
  final double discount;
  final double serviceCharge;

  OrderModel({
    required this.id,
    required this.orderNumber,
    this.tableName,
    this.waiterName,
    this.chefName,
    required this.items,
    required this.orderType,
    required this.paymentMethod,
    required this.orderStatus,
    required this.time,
    required this.discount,
    required this.serviceCharge,
  });

  double get subTotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  double get totalAmount {
    return subTotal - discount + serviceCharge;
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? tableName,
    String? waiterName,
    String? chefName,
    List<OrderItem>? items,
    OrderType? orderType,
    PaymentMethod? paymentMethod,
    OrderStatus? orderStatus,
    DateTime? time,
    double? discount,
    double? serviceCharge,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      tableName: tableName ?? this.tableName,
      waiterName: waiterName ?? this.waiterName,
      chefName: chefName ?? this.chefName,
      items: items ?? this.items,
      orderType: orderType ?? this.orderType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderStatus: orderStatus ?? this.orderStatus,
      time: time ?? this.time,
      discount: discount ?? this.discount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
    );
  }
}
