// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../routes/app_routes.dart';
import 'pos_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../core/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js' as js;

class PosView extends GetView<PosController> {
  const PosView({super.key});

  // Category to emoji helper mapping
  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'All':
        return '🍽️';
      case 'Biryani & Tehari':
        return '🍛';
      case 'Naan & Kabab':
        return '🫓';
      case 'Borhani & Drinks':
        return '🥤';
      case 'Desserts':
        return '🍨';
      default:
        return '🥘';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktopOrTablet = context.width >= 900;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background rich gradient with ambient glow spheres
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0F172A),
                        const Color(0xFF020617),
                        const Color(0xFF1E1B4B),
                      ]
                    : [
                        AppColors.background,
                        const Color(0xFFFFF7F5),
                        const Color(0xFFFFEFEA),
                      ],
              ),
            ),
          ),
          // Glow spheres for depth
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(
                  alpha: isDark ? 0.08 : 0.12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 200,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(
                  alpha: isDark ? 0.05 : 0.08,
                ),
              ),
            ),
          ),

          // Main Layout Content
          SafeArea(
            child: Column(
              children: [
                // Frosted Glass AppBar
                _buildFrostedAppBar(context),

                // Content splits
                Expanded(
                  child: isDesktopOrTablet
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Menu selection (Left + Center)
                            Expanded(flex: 3, child: _buildMenuPanel(context)),
                            VerticalDivider(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : AppColors.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                              width: 1,
                            ),
                            // Current order cart (Right)
                            SizedBox(
                              width: 420,
                              child: _buildCartPanel(context),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(child: _buildMenuPanel(context)),
                            _buildMobileCartSummary(context),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0x7F0F172A)
            : Colors.white.withValues(alpha: 0.75),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? const Color(0xFF1E293B)
                : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Get.offAllNamed(AppRoutes.dashboard);
              }
            },
            tooltip: 'Back to Dashboard',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.point_of_sale_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Bangladeshi POS Billing',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => controller.clearCart(),
            icon: const Icon(
              Icons.delete_sweep_rounded,
              color: AppColors.error,
            ),
            tooltip: 'Clear Cart (স্লিপ খালি করুন)',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        // Search Box & Category Filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Hero(
            tag: 'posSearch',
            child: Material(
              color: Colors.transparent,
              child: TextField(
                controller: controller.searchController,
                onChanged: (val) => controller.searchQuery.value = val,
                onSubmitted: (val) => controller.handleBarcodeSubmit(val),
                decoration: InputDecoration(
                  hintText: 'Search delicious foods or SKU (খাবার খুঁজুন)...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _showBarcodeScannerDialog(context),
                      tooltip: 'Simulate Barcode Scanner',
                    ),
                  ),
                  fillColor: isDark
                      ? const Color(0xFF151D30).withValues(alpha: 0.75)
                      : Colors.white.withValues(alpha: 0.85),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : AppColors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Category selector chips
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: controller.dbService.categories.length,
            itemBuilder: (context, index) {
              final category = controller.dbService.categories[index];
              final emoji = _getCategoryEmoji(category);

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Obx(() {
                  final isSelected =
                      controller.selectedCategory.value == category;
                  return InkWell(
                    onTap: () => controller.selectedCategory.value = category,
                    borderRadius: BorderRadius.circular(100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: AppColors.primaryGradient,
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark
                                  ? const Color(
                                      0xFF151D30,
                                    ).withValues(alpha: 0.6)
                                  : Colors.white.withValues(alpha: 0.8)),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (isDark
                                    ? const Color(0xFF334155)
                                    : AppColors.outlineVariant.withValues(
                                        alpha: 0.8,
                                      )),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white70
                                        : AppColors.onSurface),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),

        // Product Grid
        Expanded(
          child: Obx(() {
            final products = controller.filteredProducts;
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.no_meals_rounded,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'খাবার খুঁজে পাওয়া যায়নি।',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Try adjusting your search criteria.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.width >= 1200
                    ? 3
                    : (context.width >= 600 ? 2 : 2),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return _buildProductCard(context, p);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => controller.addToCart(product),
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section with Tags
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : AppColors.surfaceContainer,
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  // Dark Vignette gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Dynamic Stock Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.stock <= 5
                            ? AppColors.error.withValues(alpha: 0.9)
                            : const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.9), // Emerald green
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        product.stock <= 5
                            ? 'Low Stock: ${product.stock}'
                            : 'Stock: ${product.stock}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  // Discount Ribbon (SAVE Badge)
                  if (product.discount > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'SAVE ৳${product.discount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                  // SKU tag at bottom left
                  Positioned(
                    bottom: 8,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.sku,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Product Info section
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pricing Layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '৳${(product.price - product.discount).toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          if (product.discount > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '৳${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Floating circular Add icon button
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartPanel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      height: isMobile ? MediaQuery.of(context).size.height * 0.85 : null,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D30) : const Color(0xFFFBF9F3),
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(30))
            : BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Serrated top margin design for realistic receipt feel
          _buildReceiptTeethBar(isDark),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Receipt Header details
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.dbService.restaurantName.value
                                .toUpperCase(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Dhaka, Bangladesh | Order Slip (অর্ডার স্লিপ)',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildDottedDivider(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cart Items Scroll
                  Obx(() {
                    if (controller.cartItems.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'কার্ট খালি। খাবার সিলেক্ট করুন।',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        return _buildCartRow(item);
                      },
                    );
                  }),

                  const SizedBox(height: 8),
                  _buildDottedDivider(),
                  const SizedBox(height: 16),

                  // Waiter / Table configs
                  _buildCartConfigOptions(context, isDark),

                  const SizedBox(height: 12),
                  _buildDottedDivider(),
                  const SizedBox(height: 16),

                  // Coupon Section
                  _buildCouponSection(context, isDark),

                  const SizedBox(height: 12),
                  _buildDottedDivider(),
                  const SizedBox(height: 16),

                  // Cost breakdowns
                  _buildCartCalculationRow(),
                  const SizedBox(height: 20),

                  // Simulated Payment QR Code (Wow Aesthetic Feature)
                  _buildPaymentQRSection(isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Pay Button block
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'অর্ডার প্লেস করুন (৳)',
                icon: Icons.check_circle_outline_rounded,
                width: double.infinity,
                onPressed: () {
                  final order = controller.checkout();
                  if (order != null) {
                    _showPrintSimulatorDialog(context, order);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptTeethBar(bool isDark) {
    return SizedBox(
      height: 8,
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDottedDivider() {
    return Row(
      children: List.generate(
        35,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 1.5,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildCartRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '৳${(item.product.price - item.product.discount).toStringAsFixed(0)} each',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Pill shaped custom counter
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => controller.updateQuantity(item.product, -1),
                  icon: const Icon(
                    Icons.remove_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => controller.updateQuantity(item.product, 1),
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '৳${item.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildCartConfigOptions(BuildContext context, bool isDark) {
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 11,
      color: Colors.grey.shade500,
      letterSpacing: 0.3,
    );

    return Column(
      children: [
        // Waiter selector row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('WAITER (ওয়েটার)', style: labelStyle),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text(
                      'Select Waiter',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: controller.selectedWaiterName.value,
                    items: controller.dbService.waiters.map((w) {
                      return DropdownMenuItem<String>(
                        value: w,
                        child: Text(
                          w,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      controller.selectedWaiterName.value = val;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Order Type Selection Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TYPE (অর্ডার টাইপ)', style: labelStyle),
            Obx(
              () => SegmentedButton<OrderType>(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: OrderType.dineIn,
                    label: Text(
                      'Dine-In',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: OrderType.takeAway,
                    label: Text(
                      'Takeout',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
                selected: {controller.selectedOrderType.value},
                onSelectionChanged: (selection) {
                  controller.selectedOrderType.value = selection.first;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Payment Method Selection Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PAYMENT (পেমেন্ট)', style: labelStyle),
            Obx(
              () => SegmentedButton<PaymentMethod>(
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: PaymentMethod.cash,
                    label: Text(
                      'Cash',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: PaymentMethod.mobileBanking,
                    label: Text(
                      'bKash',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ButtonSegment(
                    value: PaymentMethod.card,
                    label: Text(
                      'Card',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                selected: {controller.selectedPaymentMethod.value},
                onSelectionChanged: (selection) {
                  controller.selectedPaymentMethod.value = selection.first;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Table selector row
        Obx(() {
          if (controller.selectedOrderType.value == OrderType.dineIn) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TABLE (খাবার টেবিল)', style: labelStyle),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text(
                        'Select Table',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: controller.selectedTableName.value,
                      items: controller.dbService.tables.map((t) {
                        return DropdownMenuItem<String>(
                          value: t.name,
                          child: Text(
                            t.name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedTableName.value = val;
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildCartCalculationRow() {
    return Obx(() {
      final vatPercent = (controller.dbService.vatRate.value * 100)
          .toStringAsFixed(0);
      return Column(
        children: [
          _buildCalcLine(
            'Subtotal (সাবটোটাল)',
            '৳${controller.cartSubtotal.toStringAsFixed(0)}',
          ),
          _buildCalcLine(
            'VAT (ভ্যাট $vatPercent%)',
            '৳${controller.cartVat.toStringAsFixed(0)}',
          ),
          _buildCalcLine(
            'Service Charge (সার্ভিস চার্জ)',
            '৳${controller.cartServiceCharge.toStringAsFixed(0)}',
          ),
          if (controller.couponDiscount > 0)
            _buildCalcLine(
              'Coupon Discount (কুপন ছাড়)',
              '-৳${controller.couponDiscount.toStringAsFixed(0)}',
              isBold: false,
              isDiscount: true,
            ),
          const Divider(height: 20),
          _buildCalcLine(
            'Total Payable (সর্বমোট)',
            '৳${controller.cartTotal.toStringAsFixed(0)}',
            isBold: true,
          ),
        ],
      );
    });
  }

  Widget _buildCouponSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.confirmation_num_rounded,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'APPLY COUPON (ডিসকাউন্ট কুপন)',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final hasCoupon = controller.appliedCoupon.value != null;
          final activeCoupons = controller.dbService.coupons
              .where((c) => c.isActive)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: controller.couponCodeController,
                        enabled: !hasCoupon,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter code (e.g. TASTE10)',
                          hintStyle: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          fillColor: isDark
                              ? const Color(0xFF0F172A)
                              : Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: hasCoupon
                        ? ElevatedButton.icon(
                            onPressed: () => controller.removeCoupon(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.clear_rounded, size: 14),
                            label: const Text(
                              'Remove',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => controller.applyCoupon(
                              controller.couponCodeController.text,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.check_rounded, size: 14),
                            label: const Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
              if (!hasCoupon && activeCoupons.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: activeCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = activeCoupons[index];
                      final isEligible =
                          controller.cartSubtotal >= coupon.minOrderAmount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          label: Text(
                            '${coupon.code} (${coupon.isPercentage ? "${coupon.value.toStringAsFixed(0)}%" : "৳${coupon.value.toStringAsFixed(0)}"}${!isEligible ? " - Min ৳${coupon.minOrderAmount.toStringAsFixed(0)}" : ""})',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isEligible
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                          backgroundColor: isEligible
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.grey.shade100,
                          side: BorderSide(
                            color: isEligible
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                          onPressed: isEligible
                              ? () {
                                  controller.couponCodeController.text =
                                      coupon.code;
                                  controller.applyCoupon(coupon.code);
                                }
                              : () {
                                  Get.snackbar(
                                    'Min Purchase Required',
                                    'This coupon requires a minimum subtotal of ৳${coupon.minOrderAmount.toStringAsFixed(0)}.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red.withValues(
                                      alpha: 0.1,
                                    ),
                                    colorText: Colors.red,
                                  );
                                },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCalcLine(
    String title,
    String val, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                fontSize: isBold ? 14 : 11,
                color: isBold
                    ? AppColors.primary
                    : (isDiscount
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade700),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            val,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
              fontSize: isBold ? 18 : 12,
              color: isBold
                  ? AppColors.primary
                  : (isDiscount ? const Color(0xFF10B981) : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentQRSection(bool isDark) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.location_on_rounded,
            size: 16,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.dbService.shopAddress.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              )),
          const SizedBox(height: 2),
          Obx(() => Text(
                'Phone: ${controller.dbService.shopPhone.value}',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildQRImageOrMock(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return _buildMockQRCode();
    }
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildMockQRCode(),
        ),
      ),
    );
  }

  Widget _buildMockQRCode() {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Stack(
        children: [
          // QR Markers
          Positioned(top: 0, left: 0, child: _qrMarker()),
          Positioned(top: 0, right: 0, child: _qrMarker()),
          Positioned(bottom: 0, left: 0, child: _qrMarker()),

          // Noise dots
          Positioned(
            top: 14,
            bottom: 14,
            left: 14,
            right: 14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (rIndex) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (cIndex) => Container(
                      width: 4,
                      height: 4,
                      color: (rIndex + cIndex * 3) % 2 == 0
                          ? Colors.black
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qrMarker() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3.5),
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(color: Colors.black),
    );
  }

  Widget _buildMobileCartSummary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${controller.cartItems.length} items added',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '৳${controller.cartTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomButton(
            text: 'View Slip & Pay',
            onPressed: () {
              Get.bottomSheet(
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: _buildCartPanel(context),
                ),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showBarcodeScannerDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final manualSkuController = TextEditingController();
    final products = controller.dbService.products;
    var selectedSku = (products.isNotEmpty ? products.first.sku : '').obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Barcode / SKU Scanner',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual camera scanner view finder mockup
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: 0.1,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const Positioned(
                      bottom: 8,
                      child: Text(
                        'Align scanner with item SKU barcode',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (products.isNotEmpty) ...[
                const Text(
                  'SIMULATE PRODUCT SCAN (খাবার সিলেক্ট করুন):',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 0.8,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSku.value.isEmpty
                            ? null
                            : selectedSku.value,
                        isExpanded: true,
                        items: products.map((p) {
                          return DropdownMenuItem<String>(
                            value: p.sku,
                            child: Text(
                              '${p.name} (${p.sku})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) selectedSku.value = val;
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Text(
                'MANUAL SKU / BARCODE ENTRY (কোড লিখুন Entry):',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: manualSkuController,
                decoration: const InputDecoration(
                  hintText: 'e.g. BD-KCH-01',
                  labelText: 'SKU Code',
                  prefixIcon: Icon(Icons.keyboard_rounded),
                ),
                onSubmitted: (val) {
                  final text = val.trim();
                  Get.back();
                  if (text.isNotEmpty) {
                    controller.scanAndAddProduct(text);
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final manualSku = manualSkuController.text.trim();
              final selectedSkuVal = selectedSku.value;
              Get.back();
              if (manualSku.isNotEmpty) {
                controller.scanAndAddProduct(manualSku);
              } else if (selectedSkuVal.isNotEmpty) {
                controller.scanAndAddProduct(selectedSkuVal);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Scan Item (স্ক্যান করুন)'),
          ),
        ],
      ),
    );
  }

  void _showPrintSimulatorDialog(BuildContext context, OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPrinting = true.obs;
    final progress = 0.0.obs;

    // Simulate thermal printing progress
    double current = 0.0;
    Timer.periodic(const Duration(milliseconds: 60), (t) {
      current += 0.05;
      if (current >= 1.0) {
        progress.value = 1.0;
        isPrinting.value = false;
        t.cancel();

        // Auto trigger physical print if on web
        if (kIsWeb) {
          _printReceiptWeb(order);
        }

        // Trigger OS notification
        try {
          final notificationService = Get.find<NotificationService>();
          notificationService.showNotification(
            'Receipt Printed (রশিদ প্রিন্ট)',
            'Invoice for Order #${order.orderNumber} printed successfully!',
          );
        } catch (e) {
          // Ignored
        }
      } else {
        progress.value = current;
      }
    });

    Get.dialog(
      Obx(
        () => PopScope(
          canPop: !isPrinting.value,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            contentPadding: EdgeInsets.zero,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Printer simulator icon and progress
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.print_rounded,
                            color: isPrinting.value
                                ? AppColors.primary
                                : Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isPrinting.value
                                ? 'Printing Receipt (প্রিন্ট হচ্ছে)...'
                                : 'Printing Complete (প্রিন্ট সম্পন্ন)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isPrinting.value
                                  ? AppColors.primary
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress.value,
                          backgroundColor: isDark
                              ? Colors.black26
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPrinting.value ? AppColors.primary : Colors.green,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mock Printer Slot
                Container(
                  width: 280,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A)
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Receipt sliding out
                Flexible(
                  child: SingleChildScrollView(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: progress.value,
                        child: Container(
                          width: 260,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF151D30)
                                : const Color(0xFFFFFDF9),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Serrated top teeth edge simulation
                              _buildDottedDivider(),
                              const SizedBox(height: 12),
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      controller.dbService.restaurantName.value
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Dhaka, Bangladesh',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const Text(
                                      '----------------------------------',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Order meta details
                              Text(
                                'ORDER #: ORD-${order.orderNumber}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'DATE: ${DateFormat("dd-MM-yyyy hh:mm a").format(order.time)}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                'TYPE: ${order.orderType == OrderType.dineIn ? "Dine-In (${order.tableName})" : "Takeaway"}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                'WAITER: ${order.waiterName ?? "None"}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                'PAYMENT: ${order.paymentMethod == PaymentMethod.mobileBanking ? "BKASH/MOBILE" : order.paymentMethod.toString().split('.').last.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const Text(
                                '----------------------------------',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),

                              // Items Table
                              const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ITEM DESCRIPTION',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    'TOTAL',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                '----------------------------------',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              ...order.items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.quantity}x ${item.product.name}',
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontFamily: 'monospace',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '৳${item.totalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Text(
                                '----------------------------------',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),

                              // Calculations
                              _buildReceiptCalculations(order),

                              const Text(
                                '----------------------------------',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontFamily: 'monospace',
                                ),
                              ),

                              // QR Code Payment removed as per request

                              // Barcode & Footer
                              Center(
                                child: Column(
                                  children: [
                                    // Simulated Barcode
                                    Container(
                                      height: 24,
                                      width: 140,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                          24,
                                          (index) => Container(
                                            width: (index % 3 == 0)
                                                ? 3.0
                                                : ((index % 5 == 0)
                                                      ? 1.5
                                                      : 0.8),
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.black,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 0.6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'THANK YOU! PLEASE COME AGAIN',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const Text(
                                      'TastePoint POS System',
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontStyle: FontStyle.italic,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildDottedDivider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Actions block (appears when printing finishes)
                if (!isPrinting.value) ...[
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back(); // close dialog
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.close_rounded, size: 16),
                            label: const Text(
                              'Close (বন্ধ করুন)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              if (kIsWeb) {
                                _printReceiptWeb(order);
                              } else {
                                Get.snackbar(
                                  'Physical Print (প্রিন্ট সম্পন্ন)',
                                  'Invoice sent to physical receipt printer.',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(
                                    0xFF0D9488,
                                  ).withValues(alpha: 0.1),
                                  colorText: const Color(0xFF0D9488),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.print_rounded, size: 16),
                            label: const Text(
                              'Print (প্রিন্ট)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildReceiptCalculations(OrderModel order) {
    return Column(
      children: [
        _buildReceiptCalcRow(
          'SUBTOTAL',
          '৳${order.subTotal.toStringAsFixed(0)}',
        ),
        if (order.discount > 0)
          _buildReceiptCalcRow(
            'DISCOUNT',
            '-৳${order.discount.toStringAsFixed(0)}',
          ),
        if (order.serviceCharge > 0)
          _buildReceiptCalcRow(
            'SERVICE CHARGE',
            '৳${order.serviceCharge.toStringAsFixed(0)}',
          ),
        const Text(
          '----------------------------------',
          style: TextStyle(fontSize: 8, fontFamily: 'monospace'),
        ),
        _buildReceiptCalcRow(
          'TOTAL PAYABLE',
          '৳${order.totalAmount.toStringAsFixed(0)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildReceiptCalcRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 8,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  void _printReceiptWeb(OrderModel order) {
    if (!kIsWeb) return;

    final restaurantName = controller.dbService.restaurantName.value
        .toUpperCase();
    final dateStr = DateFormat("dd-MM-yyyy hh:mm a").format(order.time);
    final orderNumStr = order.orderNumber;
    final orderTypeStr = order.orderType == OrderType.dineIn ? "DINE-IN" : "TAKEAWAY";
    final tableInfoStr = order.orderType == OrderType.dineIn ? " (${order.tableName})" : "";
    final waiterNameStr = order.waiterName ?? "NONE";
    final paymentMethodStr = order.paymentMethod
        .toString()
        .split('.')
        .last
        .toUpperCase();
    final subtotalStr = order.subTotal.toStringAsFixed(0);
    final totalStr = order.totalAmount.toStringAsFixed(0);

    final itemsHtml = order.items
        .map(
          (item) =>
              '''
      <div class="flex-row item-row">
        <span>${item.quantity}x ${item.product.name}</span>
        <span>৳${item.totalPrice.toStringAsFixed(0)}</span>
      </div>
    ''',
        )
        .join('\n');

    final discountHtml = order.discount > 0
        ? '<div class="flex-row"><span>DISCOUNT</span><span>-৳${order.discount.toStringAsFixed(0)}</span></div>'
        : '';

    final serviceChargeHtml = order.serviceCharge > 0
        ? '<div class="flex-row"><span>SERVICE CHARGE</span><span>৳${order.serviceCharge.toStringAsFixed(0)}</span></div>'
        : '';

    // Shop Details Section
    final address = controller.dbService.shopAddress.value;
    final phone = controller.dbService.shopPhone.value;

    final htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
  <title>Receipt Print</title>
  <style>
    body {
      margin: 0;
      padding: 10px;
      width: 76mm;
      font-family: 'Courier New', Courier, monospace;
      font-size: 11px;
      color: #000;
      background-color: #fff;
    }
    .center {
      text-align: center;
    }
    .bold {
      font-weight: bold;
    }
    .right {
      text-align: right;
    }
    .flex-row {
      display: flex;
      justify-content: space-between;
    }
    .divider {
      border-top: 1px dashed #000;
      margin: 6px 0;
    }
    .item-row {
      margin: 3px 0;
    }
    .shop-details {
      margin-top: 8px;
      text-align: center;
      font-size: 10px;
    }
    @media print {
      body {
        width: 76mm;
      }
      @page {
        margin: 0;
      }
    }
  </style>
</head>
<body>
  <div class="center bold" style="font-size: 13px; margin-bottom: 2px;">$restaurantName</div>
  <div class="center" style="font-size: 10px; margin-bottom: 4px;">$address</div>
  <div class="center" style="font-size: 10px; margin-bottom: 4px;">Phone: $phone</div>
  <div class="divider"></div>
  
  <div class="flex-row"><span class="bold">ORDER #:</span><span>#$orderNumStr</span></div>
  <div class="flex-row"><span>DATE:</span><span>$dateStr</span></div>
  <div class="flex-row"><span>TYPE:</span><span>$orderTypeStr$tableInfoStr</span></div>
  <div class="flex-row"><span>WAITER:</span><span>$waiterNameStr</span></div>
  <div class="flex-row"><span>PAYMENT:</span><span>$paymentMethodStr</span></div>
  <div class="divider"></div>
  
  <div class="flex-row bold">
    <span>ITEM DESCRIPTION</span>
    <span>TOTAL</span>
  </div>
  <div class="divider"></div>
  
  $itemsHtml
  <div class="divider"></div>
  
  <div class="flex-row"><span>SUBTOTAL</span><span>৳$subtotalStr</span></div>
  $discountHtml
  $serviceChargeHtml
  <div class="divider"></div>
  <div class="flex-row bold" style="font-size: 12px;"><span>TOTAL PAYABLE</span><span>৳$totalStr</span></div>
  <div class="divider"></div>
  
  <div class="center bold" style="margin-top: 8px; font-size: 9px;">THANK YOU! PLEASE COME AGAIN</div>
  <div class="center" style="font-size: 8px; font-style: italic; margin-top: 2px;">TastePoint POS System</div>
</body>
</html>
''';

    try {
      js.context.callMethod('printReceiptHtml', [htmlContent]);
    } catch (_) {
      // If index.html wasn't refreshed, dynamically register the print helper on the window object
      js.context.callMethod('eval', [
        '''
        window.printReceiptHtml = function(htmlContent) {
          var iframe = document.getElementById('receipt-print-iframe');
          if (!iframe) {
            iframe = document.createElement('iframe');
            iframe.id = 'receipt-print-iframe';
            iframe.style.position = 'fixed';
            iframe.style.right = '0';
            iframe.style.bottom = '0';
            iframe.style.width = '0';
            iframe.style.height = '0';
            iframe.style.border = 'none';
            document.body.appendChild(iframe);
          }
          var doc = iframe.contentDocument || iframe.contentWindow.document;
          doc.open();
          doc.write(htmlContent);
          doc.close();
          setTimeout(function() {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
          }, 500);
        };
        ''',
      ]);
      // Retry call
      js.context.callMethod('printReceiptHtml', [htmlContent]);
    }
  }
}
