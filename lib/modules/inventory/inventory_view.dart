import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'inventory_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../widgets/glass_card.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAllNamed(AppRoutes.dashboard);
            }
          },
          tooltip: 'Back to Dashboard',
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Inventory Stock Logs'),
            ],
          ),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : AppColors.background.withValues(alpha: 0.3),
        child: Obx(() {
          final products = controller.dbService.products;
          if (products.isEmpty) {
            return const Center(child: Text('No food products found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return _buildInventoryCard(context, p);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        label: const Text('Add Product (খাবার যোগ করুন)', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, ProductModel product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color statusColor = const Color(0xFF0D9488); // Teal
    String statusText = 'In Stock';
    if (product.stock == 0) {
      statusColor = const Color(0xFFE11D48); // Rose red
      statusText = 'Out of Stock';
    } else if (product.stock <= 5) {
      statusColor = const Color(0xFFD97706); // Amber
      statusText = 'Low Stock';
    }

    // Determine stock fill progress percentage (based on standard max capacity of 100 units)
    final double maxCapacity = 100.0;
    final double progress = (product.stock / maxCapacity).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        child: Row(
          children: [
            // Thumbnail image with border glow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  product.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainer,
                    child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Horizontal progress bar indicating stock fullness
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stock Capacity',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Restock controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${product.stock}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: product.stock <= 5 ? AppColors.error : (isDark ? Colors.white : AppColors.onSurface),
                  ),
                ),
                Text(
                  'UNITS',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _showRestockDialog(context, product),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: AppColors.primary),
                        Text(
                          'RESTOCK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRestockDialog(BuildContext context, ProductModel product) {
    controller.stockInputController.clear();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Restock ${product.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current stock: ${product.stock} units',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.stockInputController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter quantity to add',
                labelText: 'Add Quantity',
                prefixIcon: Icon(Icons.add_circle_outline_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => controller.restock(product.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var selectedCat = 'Biryani & Tehari'.obs;

    final presets = [
      {'name': 'Biryani', 'url': 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=400'},
      {'name': 'Tehari', 'url': 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=400'},
      {'name': 'Kabab', 'url': 'https://images.unsplash.com/photo-1603360946369-dc9bb6258143?w=400'},
      {'name': 'Naan', 'url': 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?w=400'},
      {'name': 'Salad', 'url': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400'},
      {'name': 'Dessert', 'url': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=400'},
      {'name': 'Lassi', 'url': 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400'},
      {'name': 'Pizza', 'url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400'},
      {'name': 'Burger', 'url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400'},
      {'name': 'Chicken', 'url': 'https://images.unsplash.com/photo-1569058242253-92a9c755a0ec?w=400'},
      {'name': 'Coffee', 'url': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400'},
      {'name': 'Tea', 'url': 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400'},
    ];

    var selectedImgUrl = presets[0]['url']!.obs;
    final customUrlCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Food Product', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Beef Khichuri Premium',
                  labelText: 'Food Name',
                  prefixIcon: Icon(Icons.restaurant_menu_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: '220',
                        labelText: 'Price (৳)',
                        prefixIcon: Icon(Icons.monetization_on_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '30',
                        labelText: 'Initial Stock',
                        prefixIcon: Icon(Icons.inventory_2_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'CATEGORY (খাবারের ক্যাটাগরি):',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade400, width: 0.8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCat.value,
                        items: controller.dbService.categories
                            .where((cat) => cat != 'All')
                            .map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) selectedCat.value = val;
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
              const Text(
                'SELECT PHOTO (খাবারের ছবি নির্বাচন করুন):',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                      child: Image.network(
                        selectedImgUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.restaurant_menu_rounded, 
                          color: AppColors.primary, 
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 70,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: presets.map((item) {
                            final isSel = selectedImgUrl.value == item['url'];
                            return GestureDetector(
                              onTap: () {
                                selectedImgUrl.value = item['url']!;
                                customUrlCtrl.clear();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSel ? AppColors.primary : Colors.grey.shade300,
                                    width: isSel ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(item['url']!, fit: BoxFit.cover),
                                      Container(
                                        color: Colors.black.withValues(alpha: 0.3),
                                      ),
                                      Center(
                                        child: Text(
                                          item['name']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 12),
              TextField(
                controller: customUrlCtrl,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/food.jpg',
                  labelText: 'Custom Image URL (ঐচ্ছিক)',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                onChanged: (val) {
                  if (val.trim().isNotEmpty) {
                    selectedImgUrl.value = val.trim();
                  } else {
                    selectedImgUrl.value = presets[0]['url']!;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              final stock = int.tryParse(stockCtrl.text.trim()) ?? 0;
              controller.addNewProduct(
                name: nameCtrl.text.trim(),
                price: price,
                category: selectedCat.value,
                initialStock: stock,
                imageUrl: selectedImgUrl.value,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Add Food'),
          ),
        ],
      ),
    );
  }
}
