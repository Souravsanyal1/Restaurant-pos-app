import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'reports_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/order_model.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

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
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.analytics_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Reports & Analytics'),
            ],
          ),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : AppColors.background.withValues(alpha: 0.3),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Section
              Text(
                'Sales Summary (আজকের বিক্রয় বিবরণী)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  if (isMobile) {
                    final cardWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: Obx(() => _buildSummaryCard(
                            title: 'Gross Revenue',
                            value: '৳${controller.totalRevenue.toStringAsFixed(0)}',
                            gradient: AppColors.secondaryGradient,
                            icon: Icons.monetization_on_rounded,
                          )),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: Obx(() => _buildSummaryCard(
                            title: 'Discounts Given',
                            value: '৳${controller.totalDiscounts.toStringAsFixed(0)}',
                            gradient: AppColors.primaryGradient,
                            icon: Icons.percent_rounded,
                          )),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => _buildSummaryCard(
                            title: 'Completed Orders',
                            value: '${controller.completedOrdersCount}',
                            gradient: AppColors.tertiaryGradient,
                            icon: Icons.shopping_bag_rounded,
                          )),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildSummaryCard(
                          title: 'Gross Revenue',
                          value: '৳${controller.totalRevenue.toStringAsFixed(0)}',
                          gradient: AppColors.secondaryGradient,
                          icon: Icons.monetization_on_rounded,
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => _buildSummaryCard(
                          title: 'Discounts Given',
                          value: '৳${controller.totalDiscounts.toStringAsFixed(0)}',
                          gradient: AppColors.primaryGradient,
                          icon: Icons.percent_rounded,
                        )),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => _buildSummaryCard(
                          title: 'Completed Orders',
                          value: '${controller.completedOrdersCount}',
                          gradient: AppColors.tertiaryGradient,
                          icon: Icons.shopping_bag_rounded,
                        )),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Order logs list
              Text(
                'Recent Transactions Log (সাম্প্রতিক ট্রানজ্যাকশন)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              Obx(() {
                final orders = controller.dbService.orders;
                if (orders.isEmpty) {
                  return GlassCard(
                    padding: const EdgeInsets.all(32),
                    color: isDark ? const Color(0xFF151D30) : Colors.white,
                    child: const Center(
                      child: Text(
                        'No transactions recorded yet.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildTransactionRow(context, order);
                  },
                );
              }),
              const SizedBox(height: 32),

              // Export Section
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                color: isDark ? const Color(0xFF151D30) : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.file_download_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Export Data Sheets',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Compile reports and download spreadsheets/documents.',
                                style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        if (isMobile) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomButton(
                                text: 'Export PDF Report',
                                icon: Icons.picture_as_pdf_rounded,
                                color: AppColors.primary,
                                onPressed: () => controller.exportPDF(),
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                text: 'Export Excel Sheet',
                                icon: Icons.table_chart_rounded,
                                color: AppColors.secondary,
                                onPressed: () => controller.exportExcel(),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Export PDF Report',
                                icon: Icons.picture_as_pdf_rounded,
                                color: AppColors.primary,
                                onPressed: () => controller.exportPDF(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Export Excel Sheet',
                                icon: Icons.table_chart_rounded,
                                color: AppColors.secondary,
                                onPressed: () => controller.exportExcel(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required List<Color> gradient,
    required IconData icon,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 20,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9, 
                      fontWeight: FontWeight.w800, 
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.6)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w900, 
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, OrderModel order) {
    Color statusColor;
    switch (order.orderStatus) {
      case OrderStatus.pending:
        statusColor = const Color(0xFFE11D48); // Red
        break;
      case OrderStatus.preparing:
        statusColor = const Color(0xFFD97706); // Amber
        break;
      case OrderStatus.ready:
        statusColor = const Color(0xFF4F46E5); // Indigo
        break;
      case OrderStatus.delivered:
        statusColor = const Color(0xFF0D9488); // Teal
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 16,
        color: isDark ? const Color(0xFF151D30) : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Icon indicator
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      order.orderType == OrderType.dineIn 
                          ? Icons.table_restaurant_rounded 
                          : Icons.takeout_dining_rounded,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.tableName != null ? 'Order #${order.orderNumber} (${order.tableName})' : 'Order #${order.orderNumber} (Takeout)',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.time.hour.toString().padLeft(2, '0')}:${order.time.minute.toString().padLeft(2, '0')} • Waiter: ${order.waiterName ?? 'Self'} • ${order.items.length} items',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Status & Price stacked vertically to save horizontal space
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '৳${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.orderStatus.name.toUpperCase(),
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
