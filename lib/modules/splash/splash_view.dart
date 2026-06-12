import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure controller is initialized
    Get.find<SplashController>();

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
                    ? [const Color(0xFF0F172A), const Color(0xFF020617), const Color(0xFF1E1E38)]
                    : [AppColors.background, const Color(0xFFFFF1ED), const Color(0xFFFFE3DC)],
              ),
            ),
          ),
          // Glow spheres
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: isDark ? 0.08 : 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: isDark ? 0.05 : 0.12),
              ),
            ),
          ),
          
          // Main content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  borderRadius: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing icon badge
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Brand Name
                      const Text(
                        'TastePoint POS',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Premium Dining POS System',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white60 : AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 36),
                      // Loader with gradient styling
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Connecting securely...',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
