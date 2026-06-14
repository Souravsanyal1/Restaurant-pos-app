import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:lordicon/lordicon.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              width: 350.w.clamp(200.0, 400.0),
              height: 350.w.clamp(200.0, 400.0),
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
              width: 350.w.clamp(200.0, 400.0),
              height: 350.w.clamp(200.0, 400.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: isDark ? 0.06 : 0.1),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w.clamp(16.0, 32.0),
                  vertical: 40.h.clamp(20.0, 60.0),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420), // Fixed width for desktop
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Brand Badge with Lordicon
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.1),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: _AnimatedLordIcon(
                              iconId: 'qhgfqwtg', // Chef Hat
                              fallbackIcon: Icons.restaurant_menu,
                              size: 60.w.clamp(40.0, 80.0),
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h.clamp(16.0, 32.0)),
                        Text(
                          AppStrings.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: AppColors.primary,
                            fontSize: 32.sp.clamp(24.0, 36.0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          AppStrings.loginSubtitle,
                          style: TextStyle(
                            fontSize: 14.sp.clamp(12.0, 16.0),
                            color: isDark ? Colors.white70 : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h.clamp(24.0, 40.0)),

                        // Main Glassmorphism Form Card
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: GlassCard(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w.clamp(16.0, 28.0),
                              vertical: 28.w.clamp(20.0, 32.0),
                            ),
                            borderRadius: 28,
                            blur: 15,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 3,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        'SELECT YOUR ROLE (রোল সিলেক্ট করুন)',
                                        style: TextStyle(
                                          fontSize: 11.sp.clamp(9.0, 13.0),
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h.clamp(8.0, 16.0)),
                                // Premium Interactive Role Grid
                                _buildRoleGrid(),
                                SizedBox(height: 24.h.clamp(16.0, 32.0)),

                                Text(
                                  'EMAIL ADDRESS',
                                  style: TextStyle(
                                    fontSize: 12.sp.clamp(10.0, 13.0),
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white54 : AppColors.onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                TextField(
                                  controller: controller.emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(fontSize: 15.sp.clamp(13.0, 17.0)),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Email here',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: _AnimatedLordIcon(
                                        iconId: 'rhvddzym', // Email
                                        fallbackIcon: Icons.email_outlined,
                                        size: 22,
                                        color: isDark ? Colors.white70 : AppColors.primary,
                                        trigger: false,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h.clamp(16.0, 32.0)),

                                Text(
                                  'PASSWORD',
                                  style: TextStyle(
                                    fontSize: 12.sp.clamp(10.0, 13.0),
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white54 : AppColors.onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Obx(() => TextField(
                                      controller: controller.passwordController,
                                      obscureText: !controller.isPasswordVisible.value,
                                      style: TextStyle(fontSize: 15.sp.clamp(13.0, 17.0)),
                                      decoration: InputDecoration(
                                        hintText: 'Enter Password here',
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: _AnimatedLordIcon(
                                            iconId: 'onmxiidj', // Lock
                                            fallbackIcon: Icons.lock_outline,
                                            size: 22,
                                            color: isDark ? Colors.white70 : AppColors.primary,
                                            trigger: false,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                                            color: isDark ? Colors.white38 : Colors.grey,
                                          ),
                                          onPressed: () => controller.isPasswordVisible.toggle(),
                                        ),
                                      ),
                                    )),
                                SizedBox(height: 32.h),

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
                        ),
                        SizedBox(height: 32.h),
                        // Version Footer
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'TastePoint Restaurant Management Suite',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.sp.clamp(9.0, 13.0),
                                color: isDark ? Colors.white30 : Colors.black38,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'v1.1.0',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.sp.clamp(8.0, 12.0),
                                color: isDark ? Colors.white24 : Colors.black26,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                          ),
                        ),
                      ],
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

  Widget _buildRoleGrid() {
    return Obx(() {
      final activeRole = controller.selectedRole.value;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: controller.roles.length,
        itemBuilder: (context, index) {
          final role = controller.roles[index];
          final isSelected = activeRole == role;
          
          String iconId;
          String bngLabel;
          IconData fallbackIcon;

          switch (role) {
            case AppStrings.roleSuperAdmin:
              iconId = 'hwuyidju'; // Settings/Admin
              bngLabel = 'সুপার এডমিন';
              fallbackIcon = Icons.admin_panel_settings_outlined;
              break;
            case AppStrings.roleOwner:
              iconId = 'vunioisq'; // Store
              bngLabel = 'মালিক';
              fallbackIcon = Icons.storefront_outlined;
              break;
            case AppStrings.roleManager:
              iconId = 'uoeisycx'; // Users
              bngLabel = 'ম্যানেজার';
              fallbackIcon = Icons.badge_outlined;
              break;
            case AppStrings.roleCashier:
              iconId = 'lpzyuabd'; // Wallet/Cash
              bngLabel = 'ক্যাশিয়ার';
              fallbackIcon = Icons.point_of_sale_outlined;
              break;
            case AppStrings.roleKitchen:
              iconId = 'qhgfqwtg'; // Pot/Cooking
              bngLabel = 'বাবুর্চি';
              fallbackIcon = Icons.soup_kitchen_outlined;
              break;
            case AppStrings.roleWaiter:
              iconId = 'yvbeeyid'; // Bell/Serving
              bngLabel = 'ওয়েটার';
              fallbackIcon = Icons.delivery_dining_outlined;
              break;
            default:
              iconId = 'ljvkvght'; // User
              bngLabel = 'স্টাফ';
              fallbackIcon = Icons.person_outline;
          }

          return GestureDetector(
            onTap: () => controller.selectedRole.value = role,
            child: AnimatedScale(
              scale: isSelected ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : (Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF0F172A).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.4)),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : AppColors.outlineVariant.withValues(alpha: 0.5)),
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.0),
                      blurRadius: isSelected ? 15.0 : 0.0,
                      spreadRadius: 0.0,
                      offset: isSelected ? const Offset(0, 4) : Offset.zero,
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedLordIcon(
                        iconId: iconId,
                        fallbackIcon: fallbackIcon,
                        size: 28,
                        color: isSelected ? AppColors.primary : Colors.grey,
                        trigger: isSelected,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          role.replaceAll(' Restaurant', '').replaceAll(' Staff', ''),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.sp.clamp(8.0, 12.0),
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? Colors.white60 : Colors.black87),
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          bngLabel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.sp.clamp(6.0, 10.0),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primary.withValues(alpha: 0.8) : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class _AnimatedLordIcon extends StatefulWidget {
  final String iconId;
  final double size;
  final Color color;
  final bool trigger;
  final IconData fallbackIcon;

  const _AnimatedLordIcon({
    required this.iconId,
    required this.size,
    required this.color,
    required this.fallbackIcon,
    this.trigger = false,
  });

  @override
  State<_AnimatedLordIcon> createState() => _AnimatedLordIconState();
}

class _AnimatedLordIconState extends State<_AnimatedLordIcon> {
  IconController? _controller;
  bool _useFallback = kIsWeb; // Default to fallback on Web for stability

  @override
  void initState() {
    super.initState();
    if (!_useFallback) {
      _controller = IconController.network('https://cdn.lordicon.com/${widget.iconId}.json');
      _controller?.addStatusListener((status) {
        if (status == ControllerStatus.ready && widget.trigger) {
          _controller?.playFromBeginning();
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedLordIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_useFallback && widget.trigger && !oldWidget.trigger) {
      _controller?.playFromBeginning();
    }
  }

  @override
  void dispose() {
    if (!_useFallback) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_useFallback) {
      return Icon(
        widget.fallbackIcon,
        size: widget.size,
        color: widget.color,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            widget.color ?? Colors.black,
            BlendMode.srcIn,
          ),
          child: _controller == null
              ? Icon(widget.fallbackIcon, size: widget.size, color: widget.color)
              : IconViewer(
                  controller: _controller!,
                  width: widget.size,
                  height: widget.size,
                ),
        ),
      ),
    );
  }
}
