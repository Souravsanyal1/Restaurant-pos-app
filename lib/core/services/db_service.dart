import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/product_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/coupon_model.dart';
import '../constants/app_strings.dart';
import 'notification_service.dart';

class DbService extends GetxService {
  final categories = <String>[].obs;
  final products = <ProductModel>[].obs;
  final tables = <TableModel>[].obs;
  final orders = <OrderModel>[].obs;
  
  // Waiters and Chefs lists
  final waiters = <String>[].obs;
  final chefs = <String>[].obs;

  // User Credentials for all roles
  final userCredentials = <String, Map<String, String>>{}.obs;

  // Restaurant Settings
  final restaurantName = 'TastePoint Restaurant'.obs;
  final vatRate = 0.10.obs; // 10% VAT
  final serviceCharge = 20.0.obs; // Default BDT service charge (e.g. ৳20)

  // QR Payment Settings
  final showQrPayment = true.obs;
  final qrPaymentGateway = 'bKash Merchant'.obs;
  final qrPaymentNumber = '+8801700000000'.obs;
  final qrImageUrl = ''.obs;
  
  // Coupon System
  final coupons = <CouponModel>[].obs;

  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadCredentials();
    _loadSettings();
    _loadMockData();
  }

  void _loadSettings() {
    restaurantName.value = _storage.read<String>('restaurant_name') ?? 'TastePoint Restaurant';
    vatRate.value = _storage.read<double>('vat_rate') ?? 0.10;
    serviceCharge.value = _storage.read<double>('service_charge') ?? 20.0;
    showQrPayment.value = _storage.read<bool>('show_qr_payment') ?? true;
    qrPaymentGateway.value = _storage.read<String>('qr_payment_gateway') ?? 'bKash Merchant';
    qrPaymentNumber.value = _storage.read<String>('qr_payment_number') ?? '+8801700000000';
    qrImageUrl.value = _storage.read<String>('qr_image_url') ?? '';
  }

  void _saveSettings() {
    _storage.write('restaurant_name', restaurantName.value);
    _storage.write('vat_rate', vatRate.value);
    _storage.write('service_charge', serviceCharge.value);
    _storage.write('show_qr_payment', showQrPayment.value);
    _storage.write('qr_payment_gateway', qrPaymentGateway.value);
    _storage.write('qr_payment_number', qrPaymentNumber.value);
    _storage.write('qr_image_url', qrImageUrl.value);
  }

  void _loadCredentials() {
    final stored = _storage.read<Map<String, dynamic>>('user_credentials');
    if (stored != null) {
      final Map<String, Map<String, String>> loaded = {};
      stored.forEach((key, value) {
        if (value is Map) {
          loaded[key] = Map<String, String>.from(value);
        }
      });
      userCredentials.assignAll(loaded);
    } else {
      userCredentials.assignAll({
        AppStrings.roleSuperAdmin: {
          'email': 'admin@tastepoint.com',
          'password': 'admin123',
        },
        AppStrings.roleOwner: {
          'email': 'owner@tastepoint.com',
          'password': 'owner123',
        },
        AppStrings.roleManager: {
          'email': 'manager@tastepoint.com',
          'password': 'manager123',
        },
        AppStrings.roleCashier: {
          'email': 'cashier@tastepoint.com',
          'password': 'cashier123',
        },
        AppStrings.roleKitchen: {
          'email': 'kitchen@tastepoint.com',
          'password': 'kitchen123',
        },
        AppStrings.roleWaiter: {
          'email': 'waiter@tastepoint.com',
          'password': 'waiter123',
        },
      });
      _saveCredentials();
    }
  }

  void _saveCredentials() {
    _storage.write('user_credentials', userCredentials);
  }

  void _loadMockData() {

    // Waiters
    waiters.assignAll([
      'Kamal',
      'Jamal',
      'Rahim',
      'Bashar',
    ]);

    // Chefs
    chefs.assignAll([
      'Chef Zakir',
      'Chef Sumon',
      'Chef Kabir',
    ]);

    // Categories
    categories.assignAll([
      'All',
      'Biryani & Tehari',
      'Naan & Kabab',
      'Borhani & Drinks',
      'Desserts',
    ]);

    // Products (Bangladeshi Menu with BDT prices)
    products.assignAll([
      ProductModel(
        id: '1',
        name: 'Mutton Kacchi Biryani',
        price: 250.0,
        discount: 10.0,
        vat: 0.10, // 10% VAT
        sku: 'BD-KCH-01',
        category: 'Biryani & Tehari',
        stock: 30,
        imageUrl: 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=400',
      ),
      ProductModel(
        id: '2',
        name: 'Beef Tehari Premium',
        price: 160.0,
        discount: 0.0,
        vat: 0.10,
        sku: 'BD-THR-02',
        category: 'Biryani & Tehari',
        stock: 4, // Low stock alert
        imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400',
      ),
      ProductModel(
        id: '3',
        name: 'Beef Sheek Kabab',
        price: 140.0,
        discount: 0.0,
        vat: 0.10,
        sku: 'BD-SHK-03',
        category: 'Naan & Kabab',
        stock: 25,
        imageUrl: 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400',
      ),
      ProductModel(
        id: '4',
        name: 'Butter Naan',
        price: 40.0,
        discount: 0.0,
        vat: 0.10,
        sku: 'BD-NAN-04',
        category: 'Naan & Kabab',
        stock: 100,
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=400',
      ),
      ProductModel(
        id: '5',
        name: 'Special Borhani Glass',
        price: 60.0,
        discount: 0.0,
        vat: 0.05,
        sku: 'BD-BRH-05',
        category: 'Borhani & Drinks',
        stock: 50,
        imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400',
      ),
      ProductModel(
        id: '6',
        name: 'Royal Falooda Bowl',
        price: 120.0,
        discount: 5.0,
        vat: 0.05,
        sku: 'BD-FLD-06',
        category: 'Desserts',
        stock: 15,
        imageUrl: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=400',
      ),
      ProductModel(
        id: '7',
        name: 'Sweet Lassi',
        price: 80.0,
        discount: 0.0,
        vat: 0.05,
        sku: 'BD-LSI-07',
        category: 'Borhani & Drinks',
        stock: 35,
        imageUrl: 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400',
      ),
    ]);

    // Tables
    tables.assignAll([
      TableModel(id: 'T1', name: 'Table 1', capacity: 2, status: TableStatus.available),
      TableModel(id: 'T2', name: 'Table 2', capacity: 4, status: TableStatus.occupied),
      TableModel(id: 'T3', name: 'Table 3', capacity: 4, status: TableStatus.available),
      TableModel(id: 'T4', name: 'Table 4', capacity: 6, status: TableStatus.reserved),
      TableModel(id: 'T5', name: 'Table 5', capacity: 2, status: TableStatus.available),
      TableModel(id: 'T6', name: 'Table 6', capacity: 8, status: TableStatus.occupied),
    ]);

    // Prepopulate some Mock Orders (with waiter and chef names)
    orders.assignAll([
      OrderModel(
        id: 'ORD-1001',
        orderNumber: '1001',
        tableName: 'Table 2',
        waiterName: 'Kamal',
        chefName: 'Chef Zakir',
        items: [
          OrderItem(product: products[0], quantity: 2), // Mutton Kacchi
          OrderItem(product: products[4], quantity: 2), // Borhani
        ],
        orderType: OrderType.dineIn,
        paymentMethod: PaymentMethod.cash,
        orderStatus: OrderStatus.preparing,
        time: DateTime.now().subtract(const Duration(minutes: 15)),
        discount: 20.0,
        serviceCharge: 15.0,
      ),
      OrderModel(
        id: 'ORD-1002',
        orderNumber: '1002',
        tableName: null,
        waiterName: 'Jamal',
        chefName: null,
        items: [
          OrderItem(product: products[2], quantity: 2), // Beef Sheek
          OrderItem(product: products[3], quantity: 2), // Butter Naan
        ],
        orderType: OrderType.takeAway,
        paymentMethod: PaymentMethod.mobileBanking,
        orderStatus: OrderStatus.pending,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        discount: 0.0,
        serviceCharge: 0.0,
      ),
    ]);

    // Coupons
    coupons.assignAll([
      CouponModel(code: 'TASTE10', isPercentage: true, value: 10.0, minOrderAmount: 200.0),
      CouponModel(code: 'SAVE50', isPercentage: false, value: 50.0, minOrderAmount: 300.0),
      CouponModel(code: 'FREE20', isPercentage: false, value: 20.0, minOrderAmount: 100.0),
    ]);
  }

  // Settings & Coupon Operations
  void updateSettings({
    required String name,
    required double vat,
    required double serviceFee,
    required bool showQr,
    required String qrGateway,
    required String qrNumber,
    required String qrImage,
  }) {
    restaurantName.value = name;
    vatRate.value = vat;
    serviceCharge.value = serviceFee;
    showQrPayment.value = showQr;
    qrPaymentGateway.value = qrGateway;
    qrPaymentNumber.value = qrNumber;
    qrImageUrl.value = qrImage;
    _saveSettings();
  }

  void addCoupon(CouponModel coupon) {
    final index = coupons.indexWhere((c) => c.code.toUpperCase() == coupon.code.toUpperCase());
    if (index != -1) {
      coupons[index] = coupon;
    } else {
      coupons.add(coupon);
    }
    coupons.refresh();
  }

  void toggleCouponStatus(String code) {
    final index = coupons.indexWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    if (index != -1) {
      coupons[index].isActive = !coupons[index].isActive;
      coupons.refresh();
    }
  }

  void deleteCoupon(String code) {
    coupons.removeWhere((c) => c.code.toUpperCase() == code.toUpperCase());
    coupons.refresh();
  }

  void updateCredentials(String role, String email, String password) {
    userCredentials[role] = {
      'email': email.trim(),
      'password': password.trim(),
    };
    userCredentials.refresh();
    _saveCredentials();
  }

  // Database Operations
  void addProduct(ProductModel product) {
    products.add(product);
    products.refresh();
  }

  void addTable(TableModel table) {
    tables.add(table);
    tables.refresh();
  }

  void addOrder(OrderModel order) {
    orders.insert(0, order);
    
    // Trigger notification
    try {
      final notificationService = Get.find<NotificationService>();
      notificationService.showNotification(
        'New Order Placed (নতুন অর্ডার)',
        'Order #${order.orderNumber} placed for ${order.tableName ?? "Takeaway"}. Total: ৳${order.totalAmount.toStringAsFixed(0)}',
      );
    } catch (e) {
      // Ignored
    }

    // Deduct stocks
    for (var item in order.items) {
      deductStock(item.product.id, item.quantity);
    }
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = orders[index];
      order.orderStatus = status;
      orders[index] = order;
      orders.refresh();

      // Trigger notification if order is ready
      if (status == OrderStatus.ready) {
        try {
          final notificationService = Get.find<NotificationService>();
          notificationService.showNotification(
            'Order Ready (অর্ডার রেডি)',
            'Order #${order.orderNumber} for ${order.tableName ?? "Takeaway"} is ready to be served!',
          );
        } catch (e) {
          // Ignored
        }
      }
    }
  }

  void assignChefToOrder(String orderId, String chefName) {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = orders[index];
      order.chefName = chefName;
      order.orderStatus = OrderStatus.preparing; // Update to preparing when Chef assigns
      orders[index] = order;
      orders.refresh();
    }
  }

  void updateTableStatus(String tableId, TableStatus status) {
    final index = tables.indexWhere((t) => t.id == tableId);
    if (index != -1) {
      final table = tables[index];
      table.status = status;
      tables[index] = table;
      tables.refresh();
    }
  }

  void addStock(String productId, int quantity) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = products[index];
      product.stock += quantity;
      products[index] = product;
      products.refresh();
    }
  }

  void deductStock(String productId, int quantity) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final product = products[index];
      product.stock = (product.stock - quantity).clamp(0, 9999);
      products[index] = product;
      products.refresh();

      // Trigger low stock warning
      if (product.stock <= 5) {
        try {
          final notificationService = Get.find<NotificationService>();
          notificationService.showNotification(
            'Low Stock Alert (স্টক ফুরিয়ে যাচ্ছে)',
            '${product.name} is running out of stock! Only ${product.stock} items left.',
          );
        } catch (e) {
          // Ignored
        }
      }
    }
  }
}
