import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/glass_card.dart';
import '../../core/services/notification_service.dart';


class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = context.width < 700;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.dashboard_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Obx(() => Text(controller.dbService.restaurantName.value)),
          ],
        ),
        actions: [
          if (!isMobile) ...[
            _buildDateBadge(isDark),
            _buildRoleBadge(),
          ],
          IconButton(
            onPressed: () async {
              try {
                final ns = Get.find<NotificationService>();
                await ns.requestWebPermission();
                ns.showNotification(
                  'Notifications Active (নোটিফিকেশন সক্রিয়)',
                  'You will now receive real-time order and stock alerts on this device.',
                );
              } catch (e) {
                // Ignored
              }
            },
            icon: const Icon(Icons.notifications_active_rounded),
            tooltip: 'Enable Notifications',
          ),
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${controller.authService.currentUserEmail.value.split('@').first.capitalizeFirst ?? 'Staff'} 👋',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is the status of your restaurant for today.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                // Quick refresh indicator
                Icon(
                  Icons.online_prediction_rounded,
                  color: Colors.green.shade500,
                  size: 28,
                ),
              ],
            ),
            if (isMobile) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDateBadge(isDark),
                  _buildRoleBadge(),
                ],
              ),
            ],
            const SizedBox(height: 32),

            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = context.width < 600;
                final crossAxisCount = context.width >= 1024 ? 4 : 2;
                final childAspectRatio = isMobile ? 1.45 : 2.1;
                final spacing = isMobile ? 12.0 : 16.0;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildStatCard(
                      context: context,
                      title: "Today's Sales",
                      valueWidget: Obx(() => Text(
                            '৳${controller.totalSalesToday.value.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: isMobile ? 18 : 24, 
                              color: Colors.white,
                            ),
                          )),
                      icon: Icons.monetization_on_rounded,
                      gradient: AppColors.secondaryGradient,
                    ),
                    _buildStatCard(
                      context: context,
                      title: "Total Orders",
                      valueWidget: Obx(() => Text(
                            '${controller.ordersCountToday.value}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: isMobile ? 18 : 24, 
                              color: Colors.white,
                            ),
                          )),
                      icon: Icons.shopping_bag_rounded,
                      gradient: AppColors.primaryGradient,
                    ),
                    _buildStatCard(
                      context: context,
                      title: "Occupied Tables",
                      valueWidget: Obx(() => Text(
                            '${controller.activeTablesCount.value} / ${controller.dbService.tables.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: isMobile ? 18 : 24, 
                              color: Colors.white,
                            ),
                          )),
                      icon: Icons.table_bar_rounded,
                      gradient: AppColors.tertiaryGradient,
                    ),
                    _buildStatCard(
                      context: context,
                      title: "Low Stock Alerts",
                      valueWidget: Obx(() => Text(
                            '${controller.lowStockAlertsCount.value}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900, 
                              fontSize: isMobile ? 18 : 24, 
                              color: Colors.white,
                            ),
                          )),
                      icon: Icons.warning_rounded,
                      gradient: AppColors.errorGradient,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Modules Access Panel Header
            Text(
              'App Quick Access (কুইক লিংক)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid for modular navigation
            Obx(() {
              final role = controller.authService.currentUserRole.value;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final cols = context.width >= 1024 ? 3 : (context.width >= 600 ? 2 : 1);
                  final tiles = <Widget>[];

                  // POS module
                  if (role == AppStrings.roleSuperAdmin ||
                      role == AppStrings.roleOwner ||
                      role == AppStrings.roleManager ||
                      role == AppStrings.roleCashier) {
                    tiles.add(_buildModuleTile(
                      title: AppStrings.posTitle,
                      subtitle: 'Direct billing, cart, and invoice printing.',
                      icon: Icons.point_of_sale_rounded,
                      gradient: AppColors.primaryGradient,
                      bngText: 'বিলিং অ্যান্ড পিওএস',
                      onTap: () => controller.goToPOS(),
                    ));
                  }

                  // Kitchen module
                  if (role == AppStrings.roleSuperAdmin ||
                      role == AppStrings.roleOwner ||
                      role == AppStrings.roleManager ||
                      role == AppStrings.roleKitchen) {
                    tiles.add(_buildModuleTile(
                      title: AppStrings.kdsTitle,
                      subtitle: 'Real-time kitchen order Kanban monitor.',
                      icon: Icons.kitchen_rounded,
                      gradient: AppColors.secondaryGradient,
                      bngText: 'রান্নাঘর মনিটর',
                      onTap: () => controller.goToKitchen(),
                    ));
                  }

                  // Tables module
                  if (role == AppStrings.roleSuperAdmin ||
                      role == AppStrings.roleOwner ||
                      role == AppStrings.roleManager ||
                      role == AppStrings.roleCashier ||
                      role == AppStrings.roleWaiter) {
                    tiles.add(_buildModuleTile(
                      title: AppStrings.tableTitle,
                      subtitle: 'Check availability and reserve dining tables.',
                      icon: Icons.table_restaurant_rounded,
                      gradient: AppColors.tertiaryGradient,
                      bngText: 'টেবিল ম্যানেজমেন্ট',
                      onTap: () => controller.goToTables(),
                    ));
                  }

                  // Inventory module
                  if (role == AppStrings.roleSuperAdmin ||
                      role == AppStrings.roleOwner ||
                      role == AppStrings.roleManager) {
                    tiles.add(_buildModuleTile(
                      title: AppStrings.inventoryTitle,
                      subtitle: 'Stock level logs and replenishment entries.',
                      icon: Icons.inventory_2_rounded,
                      gradient: AppColors.goldGradient,
                      bngText: 'ইনভেন্টরি ও স্টক',
                      onTap: () => controller.goToInventory(),
                    ));
                  }

                  // Reports module
                  if (role == AppStrings.roleSuperAdmin ||
                      role == AppStrings.roleOwner) {
                    tiles.add(_buildModuleTile(
                      title: AppStrings.reportsTitle,
                      subtitle: 'View sales performance logs and export logs.',
                      icon: Icons.analytics_rounded,
                      gradient: AppColors.indigoGradient,
                      bngText: 'রিপোর্ট ও অ্যানালিটিক্স',
                      onTap: () => controller.goToReports(),
                    ));
                  }

                  // Settings module
                  if (role == AppStrings.roleSuperAdmin ||
                      role == AppStrings.roleOwner) {
                    tiles.add(_buildModuleTile(
                      title: 'System Settings',
                      subtitle: 'Configure VAT, service charges, and discount coupons.',
                      icon: Icons.settings_rounded,
                      gradient: AppColors.primaryGradient,
                      bngText: 'সিস্টেম সেটিংস',
                      onTap: () => controller.goToSettings(),
                    ));
                  }

                  if (tiles.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No authorized features found for your role.'),
                      ),
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: tiles.length,
                    itemBuilder: (context, index) => tiles[index],
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required Widget valueWidget,
    required IconData icon,
    required List<Color> gradient,
  }) {
    final isMobile = context.width < 600;
    final paddingHorizontal = isMobile ? 12.0 : 20.0;
    final paddingVertical = isMobile ? 12.0 : 16.0;
    final iconPadding = isMobile ? 8.0 : 12.0;
    final iconSize = isMobile ? 22.0 : 28.0;
    final spacing = isMobile ? 10.0 : 16.0;

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: isMobile ? 8 : 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  valueWidget,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required String bngText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.grey),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
            Text(
              bngText,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            DateFormat('dd MMM, yyyy').format(DateTime.now()),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shield_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            controller.authService.currentUserRole.value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }}
