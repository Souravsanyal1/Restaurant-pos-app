import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderSide? border;
  final Gradient? gradient;
  final List<BoxShadow>? customShadows;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
    this.border,
    this.gradient,
    this.customShadows,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium default glass shadow
    final defaultShadows = [
      BoxShadow(
        color: isDark 
            ? Colors.black.withValues(alpha: 0.3) 
            : AppColors.primary.withValues(alpha: 0.05),
        blurRadius: elevation != null ? elevation! * 6 : 12,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: isDark 
            ? Colors.black.withValues(alpha: 0.15) 
            : Colors.grey.withValues(alpha: 0.02),
        blurRadius: 2,
        spreadRadius: -1,
        offset: const Offset(0, 1),
      ),
    ];

    // Transparent white-ish border highlights for light mode, dark border highlights for dark mode
    final defaultBorderColor = isDark 
        ? const Color(0xFF1E293B).withValues(alpha: 0.7)
        : AppColors.outlineVariant.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: color ?? (isDark 
            ? const Color(0xFF151D30).withValues(alpha: 0.85) 
            : Colors.white.withValues(alpha: 0.9)),
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border != null 
            ? Border.fromBorderSide(border!) 
            : Border.all(color: defaultBorderColor, width: 1.2),
        boxShadow: customShadows ?? defaultShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
