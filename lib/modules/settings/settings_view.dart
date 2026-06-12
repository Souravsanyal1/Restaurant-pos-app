import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/custom_button.dart';
import '../../routes/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/constants/app_strings.dart';
import 'settings_controller.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/order_model.dart';



class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

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
              Icon(Icons.settings_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('System Settings (সেটিংস)'),
            ],
          ),
        ),
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : AppColors.background.withValues(alpha: 0.3),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 0: Executive Owner Hub (Pro Settings)
              Obx(() {
                final role = Get.find<AuthService>().currentUserRole.value;
                if (role == AppStrings.roleOwner || role == AppStrings.roleSuperAdmin) {
                  return _buildOwnerExecutiveHub(context, isDark);
                }
                return const SizedBox.shrink();
              }),

              // Section 1: Business Settings
              Text(
                'Business Settings (সাধারণ সেটিংস)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              _buildBusinessSettingsCard(context, isDark),
              
              const SizedBox(height: 32),

              // Section 2: Create Coupon
              Text(
                'Create Coupon (ডিসকাউন্ট কুপন তৈরি)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              _buildCreateCouponCard(context, isDark),

              const SizedBox(height: 32),

              // Section 3: Coupon List
              Text(
                'Active Coupons List (চলতি কুপন সমূহ)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: isDark ? Colors.white : AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 14),
              _buildCouponList(context, isDark),
              
              // Section 4: User Accounts & Passwords (Super Admin / Restaurant Owner)
              Obx(() {
                final role = Get.find<AuthService>().currentUserRole.value;
                if (role == AppStrings.roleSuperAdmin || role == AppStrings.roleOwner) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'User Accounts & Security (ইউজার অ্যাকাউন্ট সেটিংস)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: isDark ? Colors.white : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildUserCredentialsCard(context, isDark),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessSettingsCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: isDark ? const Color(0xFF151D30) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Restaurant Name (রেস্টুরেন্ট নাম)',
              hintText: 'e.g. TastePoint Restaurant',
              prefixIcon: Icon(Icons.storefront_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.vatController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'VAT Percentage (ভ্যাট %)',
                    hintText: '10',
                    prefixIcon: Icon(Icons.receipt_long_rounded),
                    suffixText: '%',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller.serviceChargeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Service Charge (সার্ভিস চার্জ)',
                    hintText: '20',
                    prefixIcon: Icon(Icons.room_service_rounded),
                    suffixText: '৳',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Mobile Payment QR Code (কিউআর পেমেন্ট সেটিংস)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Display QR Payment on POS Receipt (স্লিপে পেমেন্ট কিউআর কোড দেখান)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                value: controller.showQrPayment.value,
                onChanged: (val) => controller.showQrPayment.value = val,
                activeThumbColor: AppColors.secondary,
              )),
          Obx(() {
            if (!controller.showQrPayment.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.qrGatewayController,
                        decoration: const InputDecoration(
                          labelText: 'Gateway Name (পেমেন্ট গেটওয়ে)',
                          hintText: 'e.g. bKash Merchant, Nagad Personal',
                          prefixIcon: Icon(Icons.payment_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: controller.qrNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Account Number (মোবাইল নম্বর)',
                          hintText: 'e.g. +8801700000000',
                          prefixIcon: Icon(Icons.phone_android_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller.qrImageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Custom QR Code Image URL (ঐচ্ছিক ছবির লিংক)',
                    hintText: 'e.g. https://example.com/my-qr.png',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Save Settings (সেটিংস সংরক্ষণ করুন)',
            icon: Icons.save_rounded,
            width: double.infinity,
            onPressed: () => controller.saveSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCouponCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: isDark ? const Color(0xFF151D30) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller.couponCodeController,
            decoration: const InputDecoration(
              labelText: 'Coupon Code (কুপন কোড)',
              hintText: 'e.g. TASTE20',
              prefixIcon: Icon(Icons.confirmation_num_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.couponValueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Discount Value (ছাড়ের পরিমাণ)',
                    hintText: '10 or 50',
                    prefixIcon: Icon(Icons.discount_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller.couponMinOrderController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Min Order Subtotal (সর্বনিম্ন অর্ডার)',
                    hintText: '200',
                    prefixIcon: Icon(Icons.shopping_bag_rounded),
                    suffixText: '৳',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'COUPON TYPE (ছাড়ের ধরণ):',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('PERCENTAGE OFF (%)')),
                      selected: controller.couponIsPercentage.value,
                      onSelected: (val) => controller.couponIsPercentage.value = true,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: controller.couponIsPercentage.value ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('FLAT BDT OFF (৳)')),
                      selected: !controller.couponIsPercentage.value,
                      onSelected: (val) => controller.couponIsPercentage.value = false,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: !controller.couponIsPercentage.value ? Colors.white : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Create Coupon (কুপন কোড তৈরি করুন)',
            icon: Icons.add_circle_rounded,
            width: double.infinity,
            onPressed: () => controller.createCoupon(),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponList(BuildContext context, bool isDark) {
    return Obx(() {
      final coupons = controller.dbService.coupons;
      if (coupons.isEmpty) {
        return GlassCard(
          padding: const EdgeInsets.all(32),
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          child: const Center(
            child: Text(
              'No coupons created yet.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          final coupon = coupons[index];
          final discountTypeLabel = coupon.isPercentage ? '%' : '৳';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: isDark ? const Color(0xFF151D30) : Colors.white,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.confirmation_num_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.code,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Discount: ${coupon.value.toStringAsFixed(0)}$discountTypeLabel • Min Order: ৳${coupon.minOrderAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: coupon.code));
                      Get.snackbar(
                        'Copied (কপি হয়েছে)',
                        'Coupon code "${coupon.code}" copied to clipboard.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        colorText: const Color(0xFF0D9488),
                      );
                    },
                    tooltip: 'Copy Coupon Code',
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: coupon.isActive,
                    onChanged: (val) => controller.toggleCoupon(coupon.code),
                    activeThumbColor: AppColors.secondary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    onPressed: () => controller.deleteCoupon(coupon.code),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildUserCredentialsCard(BuildContext context, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      color: isDark ? const Color(0xFF151D30) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SELECT ROLE TO CONFIGURE (রোল সিলেক্ট করুন):',
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
                    value: controller.selectedRoleToManage.value,
                    isExpanded: true,
                    items: controller.rolesList.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedRoleToManage.value = val;
                    },
                  ),
                ),
              )),
          const SizedBox(height: 16),
          TextField(
            controller: controller.roleEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Staff Email Address (ইমেইল ঠিকানা)',
              hintText: 'e.g. cashier@tastepoint.com',
              prefixIcon: Icon(Icons.email_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller.rolePasswordController,
            decoration: const InputDecoration(
              labelText: 'Account Password (পাসওয়ার্ড)',
              hintText: 'Minimum 6 characters',
              prefixIcon: Icon(Icons.lock_rounded),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Save User Account (ইউজার সেটিংস সেভ করুন)',
            icon: Icons.security_rounded,
            width: double.infinity,
            onPressed: () => controller.saveRoleCredentials(),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerExecutiveHub(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final isMobile = context.width < 700;
    
    // Calculate total sales dynamically from dbService
    final totalSalesToday = controller.dbService.orders.fold(0.0, (sum, order) {
      if (order.orderStatus == OrderStatus.delivered) {
        return sum + order.totalAmount;
      }
      return sum;
    });
    
    final salesProgress = (totalSalesToday / 10000.0).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.insights_rounded, color: AppColors.secondary, size: 22),
            const SizedBox(width: 8),
            Text(
              'EXECUTIVE OWNER HUB (ম্যানেজমেন্ট অ্যানালিটিক্স)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'PRO',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        
        // Sales Target & Progress Card
        GlassCard(
          padding: const EdgeInsets.all(20),
          color: isDark ? const Color(0xFF151D30) : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DAILY SALES TARGET',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '৳${totalSalesToday.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                          const Text(
                            ' / ৳10,000',
                            style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(salesProgress * 100).toStringAsFixed(0)}% REACHED',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: salesProgress,
                  minHeight: 8,
                  backgroundColor: isDark ? Colors.black26 : Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Split panel layout
        if (isMobile) ...[
          _buildQuickControls(isDark),
          const SizedBox(height: 16),
          _buildLiveFeeds(isDark),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildQuickControls(isDark)),
              const SizedBox(width: 16),
              Expanded(child: _buildLiveFeeds(isDark)),
            ],
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildQuickControls(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF151D30) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QUICK OVERVIEW CONTROLS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          
          // QR Toggle
          Obx(() => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Receipt QR Code Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            subtitle: const Text('Toggle payment instructions on invoice', style: TextStyle(fontSize: 10, color: Colors.grey)),
            value: controller.showQrPayment.value,
            onChanged: (val) {
              controller.showQrPayment.value = val;
              // Save to DB
              controller.dbService.showQrPayment.value = val;
              // Save to persistence
              GetStorage().write('showQrPayment', val);
              Get.snackbar(
                'Visibility Updated', 
                'QR visibility inside receipt updated successfully!',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                colorText: AppColors.secondary,
              );
            },
            activeThumbColor: AppColors.secondary,
          )),
          
          const Divider(),
          const SizedBox(height: 8),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'CSV Export',
                      'Mock Excel spreadsheet generated successfully.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      colorText: Colors.green,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 14),
                  label: const Text('Export Data', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Database Cleaned',
                      'Database optimization completed.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      colorText: AppColors.primary,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.restart_alt_rounded, size: 14),
                  label: const Text('Clean DB', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLiveFeeds(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF151D30) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIVE NOTIFICATION ALERTS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          
          _buildAlertItem(
            icon: Icons.done_all_rounded,
            color: Colors.green,
            message: 'All kitchen display orders prepared',
            time: 'Just now',
          ),
          const SizedBox(height: 8),
          _buildAlertItem(
            icon: Icons.warning_rounded,
            color: Colors.amber,
            message: 'Low stock warnings resolved',
            time: '5 mins ago',
          ),
          const SizedBox(height: 8),
          _buildAlertItem(
            icon: Icons.payments_rounded,
            color: Colors.blue,
            message: 'Daily payment methods synchronized',
            time: '1 hour ago',
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required Color color,
    required String message,
    required String time,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          time,
          style: const TextStyle(fontSize: 9, color: Colors.grey),
        ),
      ],
    );
  }
}
