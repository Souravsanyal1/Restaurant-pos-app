import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background rich gradient with ambient glow
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF0F172A), const Color(0xFF020617), const Color(0xFF1A1F30)]
                    : [AppColors.background, const Color(0xFFFFF4F0), const Color(0xFFFFECE5)],
              ),
            ),
          ),
          // Glow spheres
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: isDark ? 0.08 : 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: isDark ? 0.06 : 0.1),
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.appName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.loginSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Main Glassmorphism Form Card
                    GlassCard(
                      padding: const EdgeInsets.all(28),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SELECT YOUR ROLE (রোল সিলেক্ট করুন)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Premium Interactive Role Grid
                          _buildRoleGrid(),
                          const SizedBox(height: 24),

                          const Text(
                            'EMAIL ADDRESS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'e.g. staff@tastepoint.com',
                              prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                              fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'PASSWORD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: controller.passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                              fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                              filled: true,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Login Trigger Button
                          Obx(() => CustomButton(
                                text: 'Sign In to Dashboard',
                                isLoading: controller.isLoading.value,
                                width: double.infinity,
                                onPressed: () => controller.login(),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Version Footer
                    Center(
                      child: Text(
                        'TastePoint Restaurant Management Suite v1.1.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white30 : Colors.black38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleGrid() {
    return Obx(() {
      final activeRole = controller.selectedRole.value;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.15,
        ),
        itemCount: controller.roles.length,
        itemBuilder: (context, index) {
          final role = controller.roles[index];
          final isSelected = activeRole == role;
          
          IconData roleIcon;
          String bngLabel;
          switch (role) {
            case AppStrings.roleSuperAdmin:
              roleIcon = Icons.admin_panel_settings_rounded;
              bngLabel = 'সুপার এডমিন';
              break;
            case AppStrings.roleOwner:
              roleIcon = Icons.storefront_rounded;
              bngLabel = 'মালিক';
              break;
            case AppStrings.roleManager:
              roleIcon = Icons.supervisor_account_rounded;
              bngLabel = 'ম্যানেজার';
              break;
            case AppStrings.roleCashier:
              roleIcon = Icons.point_of_sale_rounded;
              bngLabel = 'ক্যাশিয়ার';
              break;
            case AppStrings.roleKitchen:
              roleIcon = Icons.kitchen_rounded;
              bngLabel = 'বাবুর্চি';
              break;
            case AppStrings.roleWaiter:
              roleIcon = Icons.room_service_rounded;
              bngLabel = 'ওয়েটার';
              break;
            default:
              roleIcon = Icons.person_rounded;
              bngLabel = 'স্টাফ';
          }

          return InkWell(
            onTap: () => controller.selectedRole.value = role,
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primary.withValues(alpha: 0.15),
            highlightColor: AppColors.primary.withValues(alpha: 0.05),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF0F172A).withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.6)),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E293B)
                          : AppColors.outlineVariant.withValues(alpha: 0.5)),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    roleIcon,
                    size: 24,
                    color: isSelected ? AppColors.primary : Colors.grey,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    role.replaceAll(' Restaurant', '').replaceAll(' Staff', ''),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    bngLabel,
                    style: TextStyle(
                      fontSize: 8,
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
