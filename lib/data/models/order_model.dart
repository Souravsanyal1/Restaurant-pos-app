import 'package:cloud_firestore/cloud_firestore.dart';
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

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'tableName': tableName,
      'waiterName': waiterName,
      'chefName': chefName,
      'items': items.map((x) => {
        'product': x.product.toMap(),
        'quantity': x.quantity,
      }).toList(),
      'orderType': orderType.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'orderStatus': orderStatus.toString().split('.').last,
      'time': time.millisecondsSinceEpoch,
      'discount': discount,
      'serviceCharge': serviceCharge,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      orderNumber: map['orderNumber'] ?? '',
      tableName: map['tableName'],
      waiterName: map['waiterName'],
      chefName: map['chefName'],
      items: (map['items'] as List?)?.map((x) {
        final productMap = Map<String, dynamic>.from(x['product']);
        // Product in order items needs its ID for references
        return OrderItem(
          product: ProductModel.fromMap(productMap),
          quantity: x['quantity'] ?? 1,
        );
      }).toList() ?? [],
      orderType: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == map['orderType'],
        orElse: () => OrderType.dineIn,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == map['paymentMethod'],
        orElse: () => PaymentMethod.cash,
      ),
      orderStatus: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['orderStatus'],
        orElse: () => OrderStatus.pending,
      ),
      time: map['time'] is Timestamp 
          ? (map['time'] as Timestamp).toDate() 
          : DateTime.fromMillisecondsSinceEpoch(map['time'] ?? 0),
      discount: (map['discount'] ?? 0).toDouble(),
      serviceCharge: (map['serviceCharge'] ?? 0).toDouble(),
    );
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
