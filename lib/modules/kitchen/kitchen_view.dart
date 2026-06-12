import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'kitchen_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../widgets/glass_card.dart';

class KitchenView extends GetView<KitchenController> {
  const KitchenView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.soup_kitchen_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Kitchen Display System (KDS)',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : AppColors.background.withValues(alpha: 0.3),
        child: Obx(() {
          final isMobile = context.width < 720;
          if (isMobile) {
            return Column(
              children: [
                // Premium Status Tabs Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: isDark ? const Color(0xFF151D30) : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatusTab(
                          context: context,
                          index: 0,
                          label: 'Pending',
                          bngLabel: 'অর্ডার স্লিপ',
                          count: controller.pendingOrders.length,
                          color: const Color(0xFFEA580C),
                          gradient: AppColors.primaryGradient,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusTab(
                          context: context,
                          index: 1,
                          label: 'Preparing',
                          bngLabel: 'রান্না হচ্ছে',
                          count: controller.preparingOrders.length,
                          color: const Color(0xFFD97706),
                          gradient: AppColors.goldGradient,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatusTab(
                          context: context,
                          index: 2,
                          label: 'Ready',
                          bngLabel: 'প্রস্তুত',
                          count: controller.readyOrders.length,
                          color: const Color(0xFF0D9488),
                          gradient: AppColors.secondaryGradient,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                Expanded(
                  child: IndexedStack(
                    index: controller.selectedStatusIndex.value,
                    children: [
                      _buildKdsColumn(
                        context: context,
                        title: 'Pending (অর্ডার স্লিপ)',
                        orders: controller.pendingOrders,
                        headerColor: const Color(0xFFEA580C),
                        buttonColor: AppColors.primary,
                        buttonText: 'Start Preparing',
                        gradient: AppColors.primaryGradient,
                        hideHeader: true,
                      ),
                      _buildKdsColumn(
                        context: context,
                        title: 'Preparing (রান্না হচ্ছে)',
                        orders: controller.preparingOrders,
                        headerColor: const Color(0xFFD97706),
                        buttonColor: const Color(0xFFD97706),
                        buttonText: 'Mark Ready',
                        gradient: AppColors.goldGradient,
                        hideHeader: true,
                      ),
                      _buildKdsColumn(
                        context: context,
                        title: 'Ready (পরিবেশনের জন্য প্রস্তুত)',
                        orders: controller.readyOrders,
                        headerColor: const Color(0xFF0D9488),
                        buttonColor: const Color(0xFF0D9488),
                        buttonText: 'Mark Served',
                        gradient: AppColors.secondaryGradient,
                        hideHeader: true,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pending Column
                Expanded(
                  child: _buildKdsColumn(
                    context: context,
                    title: 'Pending (অর্ডার স্লিপ)',
                    orders: controller.pendingOrders,
                    headerColor: const Color(0xFFEA580C),
                    buttonColor: AppColors.primary,
                    buttonText: 'Start Preparing',
                    gradient: AppColors.primaryGradient,
                  ),
                ),
                VerticalDivider(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
                // Preparing Column
                Expanded(
                  child: _buildKdsColumn(
                    context: context,
                    title: 'Preparing (রান্না হচ্ছে)',
                    orders: controller.preparingOrders,
                    headerColor: const Color(0xFFD97706),
                    buttonColor: const Color(0xFFD97706),
                    buttonText: 'Mark Ready',
                    gradient: AppColors.goldGradient,
                  ),
                ),
                VerticalDivider(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
                // Ready Column
                Expanded(
                  child: _buildKdsColumn(
                    context: context,
                    title: 'Ready (পরিবেশনের জন্য প্রস্তুত)',
                    orders: controller.readyOrders,
                    headerColor: const Color(0xFF0D9488),
                    buttonColor: const Color(0xFF0D9488),
                    buttonText: 'Mark Served',
                    gradient: AppColors.secondaryGradient,
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildKdsColumn({
    required BuildContext context,
    required String title,
    required List<OrderModel> orders,
    required Color headerColor,
    required Color buttonColor,
    required String buttonText,
    required List<Color> gradient,
    bool hideHeader = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hideHeader) ...[
        // Column Header with a clean gradient indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151D30) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: isDark ? Colors.white : AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${orders.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
        
        // Orders Ticket List
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 48, color: headerColor.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(
                        'কোন অর্ডার নেই',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildKdsCard(context, order, buttonColor, buttonText);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildKdsCard(BuildContext context, OrderModel order, Color buttonColor, String buttonText) {
    final difference = DateTime.now().difference(order.time).inMinutes;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Time warning colors
    Color timeColor = Colors.grey.shade500;
    List<BoxShadow>? urgencyShadow;
    if (difference >= 10) {
      timeColor = AppColors.error;
      urgencyShadow = [
        BoxShadow(
          color: AppColors.error.withValues(alpha: 0.15),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else if (difference >= 5) {
      timeColor = const Color(0xFFD97706);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        customShadows: urgencyShadow,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: difference >= 10 
                    ? AppColors.error 
                    : (difference >= 5 ? const Color(0xFFD97706) : Colors.grey.shade300),
                width: 5,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              // Header Info
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  Text(
                    order.tableName != null ? 'Table: ${order.tableName}' : 'Takeout #${order.orderNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: timeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_filled_rounded, size: 11, color: timeColor),
                        const SizedBox(width: 4),
                        Text(
                          '${difference}m ago',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: timeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Staff Details Area (Stacked vertically on mobile to prevent overflow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 13, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Waiter: ${order.waiterName ?? 'Self'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.soup_kitchen_rounded, size: 13, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: order.chefName != null
                            ? Text(
                                'Chef: ${order.chefName}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : DropdownButtonHideUnderline(
                                child: SizedBox(
                                  height: 24,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    isDense: true,
                                    hint: const Text('Assign Chef', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    style: TextStyle(fontSize: 10, color: isDark ? Colors.white : AppColors.onSurface),
                                    items: controller.dbService.chefs.map((c) {
                                      return DropdownMenuItem<String>(
                                        value: c,
                                        child: Text(c, style: const TextStyle(fontSize: 9)),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.assignChef(order.id, val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 0.8),

              // Items Checklist Grid
              const Text(
                'ORDER ITEMS (খাবারের তালিকা):',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.3),
              ),
              const SizedBox(height: 6),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_box_outline_blank_rounded,
                                size: 16,
                                color: isDark ? Colors.white30 : Colors.black26,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'x${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.primary),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.cancelOrder(order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (order.chefName == null && order.orderStatus == OrderStatus.pending) {
                          Get.snackbar('Chef Required', 'Please assign a Chef to this order first.');
                          return;
                        }
                        controller.moveToNextStatus(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        buttonText, 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTab({
    required BuildContext context,
    required int index,
    required String label,
    required String bngLabel,
    required int count,
    required Color color,
    required List<Color> gradient,
  }) {
    final isSelected = controller.selectedStatusIndex.value == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => controller.selectedStatusIndex.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? color.withValues(alpha: 0.5) 
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    color: isSelected ? color : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              bngLabel,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color.withValues(alpha: 0.8) : (isDark ? Colors.white30 : Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
