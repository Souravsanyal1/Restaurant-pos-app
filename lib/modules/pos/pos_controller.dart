import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/db_service.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/table_model.dart';
import '../../data/models/coupon_model.dart';

class PosController extends GetxController {
  final dbService = Get.find<DbService>();

  final cartItems = <OrderItem>[].obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final discountInput = 0.0.obs;
  
  // Coupon state
  final appliedCoupon = Rxn<CouponModel>();
  final couponCodeController = TextEditingController();

  final selectedOrderType = OrderType.dineIn.obs;
  final selectedPaymentMethod = PaymentMethod.cash.obs;
  final selectedTableName = RxnString();
  
  // Waiter Selection
  final selectedWaiterName = RxnString();

  final searchController = TextEditingController();

  @override
  void onClose() {
    searchController.dispose();
    couponCodeController.dispose();
    super.onClose();
  }

  List<ProductModel> get filteredProducts {
    return dbService.products.where((product) {
      final matchesCategory = selectedCategory.value == 'All' || product.category == selectedCategory.value;
      final matchesSearch = product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          product.sku.toLowerCase().contains(searchQuery.value.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get cartSubtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get cartVat => cartSubtotal * dbService.vatRate.value;
  double get cartServiceCharge => dbService.serviceCharge.value;
  double get couponDiscount => appliedCoupon.value?.calculateDiscount(cartSubtotal) ?? 0.0;
  double get cartTotal => cartSubtotal + cartVat + cartServiceCharge - couponDiscount;

  void addToCart(ProductModel product) {
    if (product.stock <= 0) {
      Get.snackbar('Out of Stock', 'Product ${product.name} has no available stock.');
      return;
    }

    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final currentQty = cartItems[index].quantity;
      if (currentQty >= product.stock) {
        Get.snackbar('Stock Limit', 'Cannot add more. Available stock: ${product.stock}');
        return;
      }
      cartItems[index] = OrderItem(product: product, quantity: currentQty + 1);
    } else {
      cartItems.add(OrderItem(product: product, quantity: 1));
    }
    cartItems.refresh();
  }

  void removeFromCart(ProductModel product) {
    cartItems.removeWhere((item) => item.product.id == product.id);
    cartItems.refresh();
  }

  void updateQuantity(ProductModel product, int delta) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      final newQty = cartItems[index].quantity + delta;
      if (newQty <= 0) {
        removeFromCart(product);
      } else {
        if (delta > 0 && newQty > product.stock) {
          Get.snackbar('Stock Limit', 'Cannot add more. Available stock: ${product.stock}');
          return;
        }
        cartItems[index] = OrderItem(product: product, quantity: newQty);
      }
      cartItems.refresh();
    }
  }

  void clearCart() {
    cartItems.clear();
    discountInput.value = 0.0;
    appliedCoupon.value = null;
    couponCodeController.clear();
    selectedTableName.value = null;
    selectedWaiterName.value = null;
  }

  void applyCoupon(String code) {
    if (code.trim().isEmpty) {
      Get.snackbar('Enter Code', 'Please enter a coupon code.');
      return;
    }
    
    final coupon = dbService.coupons.firstWhereOrNull(
      (c) => c.code.toUpperCase() == code.trim().toUpperCase()
    );
    
    if (coupon == null) {
      Get.snackbar('Invalid Coupon', 'Coupon code "$code" does not exist.');
      return;
    }
    
    if (!coupon.isActive) {
      Get.snackbar('Expired', 'This coupon is no longer active.');
      return;
    }
    
    if (cartSubtotal < coupon.minOrderAmount) {
      Get.snackbar('Min Order Required', 'This coupon requires a minimum subtotal of ৳${coupon.minOrderAmount.toStringAsFixed(0)}.');
      return;
    }
    
    appliedCoupon.value = coupon;
    Get.snackbar('Coupon Applied', 'Successfully applied coupon: ${coupon.code}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
        colorText: const Color(0xFF0D9488));
  }

  void removeCoupon() {
    appliedCoupon.value = null;
    couponCodeController.clear();
    Get.snackbar('Coupon Removed', 'Coupon removed from order.');
  }

  OrderModel? checkout() {
    if (cartItems.isEmpty) {
      Get.snackbar('Empty Cart', 'Please add products to the cart first.');
      return null;
    }

    if (selectedWaiterName.value == null) {
      Get.snackbar('Waiter Missing', 'Please select an active Waiter before processing.');
      return null;
    }

    if (selectedOrderType.value == OrderType.dineIn && selectedTableName.value == null) {
      Get.snackbar('Table Missing', 'Please select a dining table for Dine-In orders.');
      return null;
    }

    // Generate unique order ID
    final nextNum = 1000 + dbService.orders.length + 1;
    final order = OrderModel(
      id: 'ORD-$nextNum',
      orderNumber: '$nextNum',
      tableName: selectedOrderType.value == OrderType.dineIn ? selectedTableName.value : null,
      waiterName: selectedWaiterName.value,
      chefName: null, // Chef will self-assign in KDS
      items: List.from(cartItems),
      orderType: selectedOrderType.value,
      paymentMethod: selectedPaymentMethod.value,
      orderStatus: OrderStatus.pending,
      time: DateTime.now(),
      discount: couponDiscount,
      serviceCharge: cartServiceCharge,
    );

    // Save order in DB
    dbService.addOrder(order);
    
    // Change table status to occupied if dine-in
    if (selectedOrderType.value == OrderType.dineIn && selectedTableName.value != null) {
      final table = dbService.tables.firstWhereOrNull((t) => t.name == selectedTableName.value);
      if (table != null) {
        dbService.updateTableStatus(table.id, TableStatus.occupied);
      }
    }

    clearCart();

    // Safely dismiss bottom sheet before showing success snackbar to avoid route conflicts
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    return order;
  }

  void handleBarcodeSubmit(String code) {
    if (code.trim().isEmpty) return;
    
    final product = dbService.products.firstWhereOrNull(
      (p) => p.sku.toLowerCase() == code.trim().toLowerCase()
    );
    
    if (product != null) {
      addToCart(product);
      searchController.clear();
      searchQuery.value = '';
      Get.snackbar('Scanned (স্ক্যান সফল)', '${product.name} added to cart.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
          colorText: const Color(0xFF0D9488));
    } else {
      // If no match, update the search query
      searchQuery.value = code;
    }
  }

  void scanAndAddProduct(String sku) {
    final product = dbService.products.firstWhereOrNull(
      (p) => p.sku.toLowerCase() == sku.trim().toLowerCase()
    );
    
    if (product != null) {
      addToCart(product);
      Get.snackbar('Scanned (স্ক্যান সফল)', '${product.name} added to cart.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
          colorText: const Color(0xFF0D9488));
    } else {
      Get.snackbar('Not Found', 'Product SKU "$sku" not found.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red);
    }
  }
}
