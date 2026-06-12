import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/db_service.dart';
import '../../data/models/product_model.dart';

class InventoryController extends GetxController {
  final dbService = Get.find<DbService>();
  final stockInputController = TextEditingController();

  @override
  void onClose() {
    stockInputController.dispose();
    super.onClose();
  }

  void restock(String productId) {
    final qtyStr = stockInputController.text.trim();
    if (qtyStr.isEmpty) {
      Get.snackbar('Input Error', 'Please enter a valid stock quantity.');
      return;
    }

    final qty = int.tryParse(qtyStr);
    if (qty == null || qty <= 0) {
      Get.snackbar('Input Error', 'Quantity must be a positive integer.');
      return;
    }

    dbService.addStock(productId, qty);
    stockInputController.clear();
    Get.back(); // close modal
    Get.snackbar('Stock Updated', 'Stock restocked successfully.');
  }

  void addNewProduct({
    required String name,
    required double price,
    required String category,
    required int initialStock,
    required String imageUrl,
  }) {
    if (name.trim().isEmpty) {
      Get.snackbar('Input Error', 'Please enter a valid product name.');
      return;
    }
    if (price <= 0) {
      Get.snackbar('Input Error', 'Price must be greater than zero.');
      return;
    }
    if (initialStock < 0) {
      Get.snackbar('Input Error', 'Stock cannot be negative.');
      return;
    }

    final id = '${dbService.products.length + 1}';
    final cleanCategoryName = category.split(' ').first; // e.g. "Biryani" from "Biryani & Tehari"
    final cleanCategoryPrefix = cleanCategoryName.substring(0, cleanCategoryName.length.clamp(0, 3)).toUpperCase();
    final sku = 'BD-$cleanCategoryPrefix-${id.padLeft(2, '0')}';

    dbService.addProduct(ProductModel(
      id: id,
      name: name,
      price: price,
      discount: 0.0,
      vat: 0.10, // 10% standard BD VAT
      sku: sku,
      category: category,
      stock: initialStock,
      imageUrl: imageUrl.trim().isNotEmpty 
          ? imageUrl.trim() 
          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
    ));

    Get.back(); // close modal
    Get.snackbar('Product Added', 'Food product "$name" has been added successfully.');
  }
}
