import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/product_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/coupon_model.dart';
import '../constants/app_strings.dart';
import 'notification_service.dart';

class DbService extends GetxService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = GetStorage();

  // Observable Data Streams
  final categories = <String>[].obs;
  final products = <ProductModel>[].obs;
  final tables = <TableModel>[].obs;
  final orders = <OrderModel>[].obs;
  final coupons = <CouponModel>[].obs;
  
  final waiters = <String>[].obs;
  final chefs = <String>[].obs;

  // User Credentials for all roles (kept local for performance, synced to Firestore)
  final userCredentials = <String, Map<String, String>>{}.obs;

  // Restaurant Settings
  final restaurantName = 'TastePoint Restaurant'.obs;
  final vatRate = 0.10.obs;
  final serviceCharge = 20.0.obs;
  final shopAddress = 'Dhaka, Bangladesh'.obs;
  final shopPhone = '+8801700000000'.obs;
  final shopEmail = 'contact@tastepoint.com'.obs;

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListeners();
  }

  void _initFirestoreListeners() {
    // 1. Listen to Categories
    _firestore.collection('categories').snapshots().listen((snapshot) {
      categories.assignAll(snapshot.docs.map((doc) => doc.id).toList());
      if (categories.isEmpty) _loadDefaultCategories();
    });

    // 2. Listen to Products
    _firestore.collection('products').snapshots().listen((snapshot) {
      products.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList());
    });

    // 3. Listen to Tables
    _firestore.collection('tables').snapshots().listen((snapshot) {
      tables.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TableModel.fromMap(data);
      }).toList());
    });

    // 4. Listen to Orders (Today's orders)
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    _firestore.collection('orders')
        .where('time', isGreaterThanOrEqualTo: startOfDay)
        .orderBy('time', descending: true)
        .snapshots().listen((snapshot) {
      orders.assignAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return OrderModel.fromMap(data);
      }).toList());
    });

    // 5. Listen to Settings
    _firestore.collection('settings').doc('restaurant_config').snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        restaurantName.value = data['name'] ?? 'TastePoint';
        vatRate.value = data['vatRate'] ?? 0.10;
        serviceCharge.value = data['serviceCharge'] ?? 20.0;
        shopAddress.value = data['address'] ?? '';
        shopPhone.value = data['phone'] ?? '';
        shopEmail.value = data['email'] ?? '';
      } else {
        _uploadDefaultSettings();
      }
    });

    // 6. Listen to Coupons
    _firestore.collection('coupons').snapshots().listen((snapshot) {
      coupons.assignAll(snapshot.docs.map((doc) => CouponModel.fromMap(doc.data())).toList());
    });

    // 7. Listen to Waiters
    _firestore.collection('waiters').snapshots().listen((snapshot) {
      waiters.assignAll(snapshot.docs.map((doc) => doc.id).toList());
      if (waiters.isEmpty) _loadDefaultWaiters();
    });

    // 8. Listen to Chefs
    _firestore.collection('chefs').snapshots().listen((snapshot) {
      chefs.assignAll(snapshot.docs.map((doc) => doc.id).toList());
      if (chefs.isEmpty) _loadDefaultChefs();
    });
  }

  Future<void> addWaiter(String name) async {
    await _firestore.collection('waiters').doc(name.trim()).set({'active': true});
  }

  Future<void> deleteWaiter(String name) async {
    await _firestore.collection('waiters').doc(name).delete();
  }

  Future<void> addChef(String name) async {
    await _firestore.collection('chefs').doc(name.trim()).set({'active': true});
  }

  Future<void> deleteChef(String name) async {
    await _firestore.collection('chefs').doc(name).delete();
  }

  Future<void> _loadDefaultWaiters() async {
    final defaults = ['Kamal', 'Jamal', 'Rahim', 'Bashar'];
    for (var name in defaults) {
      await _firestore.collection('waiters').doc(name).set({'active': true});
    }
  }

  Future<void> _loadDefaultChefs() async {
    final defaults = ['Chef Zakir', 'Chef Sumon', 'Chef Kabir'];
    for (var name in defaults) {
      await _firestore.collection('chefs').doc(name).set({'active': true});
    }
  }

  // Cloud Write Operations
  Future<void> saveSettings() async {
    await _firestore.collection('settings').doc('restaurant_config').set({
      'name': restaurantName.value,
      'vatRate': vatRate.value,
      'serviceCharge': serviceCharge.value,
      'address': shopAddress.value,
      'phone': shopPhone.value,
      'email': shopEmail.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  void updateSettings({
    required String name,
    required double vat,
    required double serviceFee,
    required String address,
    required String phone,
    required String email,
  }) {
    restaurantName.value = name;
    vatRate.value = vat;
    serviceCharge.value = serviceFee;
    shopAddress.value = address;
    shopPhone.value = phone;
    shopEmail.value = email;
    saveSettings();
  }

  Future<void> addOrder(OrderModel order) async {
    final orderData = order.toMap();
    // Use server timestamp for accuracy
    orderData['time'] = FieldValue.serverTimestamp();
    await _firestore.collection('orders').add(orderData);

    // Deduct stock for each item
    for (var item in order.items) {
      _firestore.collection('products').doc(item.product.id).update({
        'stock': FieldValue.increment(-item.quantity)
      });
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'orderStatus': status.toString().split('.').last,
    });
  }

  Future<void> assignChefToOrder(String orderId, String chefName) async {
    await _firestore.collection('orders').doc(orderId).update({
      'chefName': chefName,
      'orderStatus': 'preparing',
    });
  }

  Future<void> updateTableStatus(String tableId, TableStatus status) async {
    await _firestore.collection('tables').doc(tableId).update({
      'status': status.toString().split('.').last,
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  Future<void> addCoupon(CouponModel coupon) async {
    await _firestore.collection('coupons').doc(coupon.code.toUpperCase()).set(coupon.toMap());
  }

  Future<void> deleteCoupon(String code) async {
    await _firestore.collection('coupons').doc(code.toUpperCase()).delete();
  }

  Future<void> addStock(String productId, int quantity) async {
    await _firestore.collection('products').doc(productId).update({
      'stock': FieldValue.increment(quantity),
    });
  }

  Future<void> addTable(TableModel table) async {
    await _firestore.collection('tables').add(table.toMap());
  }

  Future<void> toggleCouponStatus(String code) async {
    final doc = await _firestore.collection('coupons').doc(code.toUpperCase()).get();
    if (doc.exists) {
      final current = doc.data()?['isActive'] ?? true;
      await _firestore.collection('coupons').doc(code.toUpperCase()).update({
        'isActive': !current,
      });
    }
  }

  // --- Initial Setup & Migration Helpers ---
  
  Future<void> _loadDefaultCategories() async {
    final defaults = ['All', 'Biryani & Tehari', 'Naan & Kabab', 'Borhani & Drinks', 'Desserts'];
    for (var cat in defaults) {
      await _firestore.collection('categories').doc(cat).set({'active': true});
    }
  }

  Future<void> _uploadDefaultSettings() async {
    await saveSettings();
  }

  // One-time tool to move mock products to cloud
  Future<void> migrateMockDataToFirebase() async {
    // This is useful for first-run
    final mockProducts = [
      {'name': 'Mutton Kacchi Biryani', 'price': 250.0, 'category': 'Biryani & Tehari', 'stock': 30, 'sku': 'BD-KCH-01'},
      {'name': 'Beef Tehari Premium', 'price': 160.0, 'category': 'Biryani & Tehari', 'stock': 50, 'sku': 'BD-THR-02'},
      {'name': 'Beef Sheek Kabab', 'price': 140.0, 'category': 'Naan & Kabab', 'stock': 40, 'sku': 'BD-SHK-03'},
      {'name': 'Butter Naan', 'price': 40.0, 'category': 'Naan & Kabab', 'stock': 100, 'sku': 'BD-NAN-04'},
      {'name': 'Special Borhani Glass', 'price': 60.0, 'category': 'Borhani & Drinks', 'stock': 80, 'sku': 'BD-BRH-05'},
    ];

    for (var p in mockProducts) {
      await _firestore.collection('products').add(p);
    }

    final mockTables = ['Table 1', 'Table 2', 'Table 3', 'Table 4', 'Table 5'];
    for (var t in mockTables) {
      await _firestore.collection('tables').add({
        'name': t,
        'capacity': 4,
        'status': 'available'
      });
    }
  }

  void updateCredentials(String role, String email, String password) {
    // Handled by AuthService in Firebase Auth
    userCredentials[role] = {'email': email.trim(), 'password': password.trim()};
    userCredentials.refresh();
  }
}
