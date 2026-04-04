import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────

class AppColors {
  // Primary: vibrant cherry-red matching the app logo
  static const primary = Color(0xFFE2293F); 
  static const primaryDark = Color(0xFFEF5366); // slightly lighter on dark bg

  // Backgrounds
  static const bgLight1 = Color(0xFFFEF3F4);
  static const bgLight2 = Color(0xFFFCE1E5);
  static const bgDark1 = Color(0xFF14080A);
  static const bgDark2 = Color(0xFF241014);

  // Text
  static const textLight = Color(0xFF2E1518);
  static const textDark = Color(0xFFF7E6E8);
  static const subtitleLight = Color(0xFF906065);
  static const subtitleDark = Color(0xFFB38085);
}

// ─── Glass Card ───────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final double? width;
  final double? height;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.blurSigma = 14,
    this.width,
    this.height,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.88));

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: border, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : AppColors.primary.withValues(alpha: 0.09),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Glass Background ─────────────────────────────────────────────────────────

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [AppColors.bgDark1, AppColors.bgDark2, Color(0xFF1C0D16)]
              : const [AppColors.bgLight1, AppColors.bgLight2, Color(0xFFFDE8F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}

// ─── Decorative Blob ─────────────────────────────────────────────────────────

class GlassBlob extends StatelessWidget {
  final double size;
  final double opacity;
  const GlassBlob({super.key, required this.size, this.opacity = 0.12});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: isDark ? opacity * 0.6 : opacity),
      ),
    );
  }
}

// ─── Gradient Button ─────────────────────────────────────────────────────────

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDisabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled
                ? [Colors.grey.shade400, Colors.grey.shade400]
                : [primary, Color.lerp(primary, const Color(0xFFFF6976), 0.5)!],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  )
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

// ─── App Theme ────────────────────────────────────────────────────────────────

class AppTheme {
  static const _primary = AppColors.primary;
  static const _primaryDark = AppColors.primaryDark;

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        primary: _primary,
        brightness: Brightness.light,
        surface: AppColors.bgLight1,
        onSurface: AppColors.textLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight1,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3B7BC), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF3B7BC), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.subtitleLight),
        prefixIconColor: AppColors.subtitleLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: _primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 12,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
              color: s.contains(WidgetState.selected) ? _primary : AppColors.subtitleLight,
            )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? _primary : AppColors.subtitleLight,
            )),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? _primary : Colors.grey.shade400),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? _primary.withValues(alpha: 0.28)
            : Colors.grey.shade300),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryDark,
        primary: _primaryDark,
        brightness: Brightness.dark,
        surface: AppColors.bgDark1,
        onSurface: AppColors.textDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark1,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryDark, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.subtitleDark),
        prefixIconColor: AppColors.subtitleDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: _primaryDark.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 12,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
              color: s.contains(WidgetState.selected) ? _primaryDark : AppColors.subtitleDark,
            )),
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? _primaryDark : AppColors.subtitleDark,
            )),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? _primaryDark : Colors.grey.shade600),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? _primaryDark.withValues(alpha: 0.30)
            : Colors.grey.shade800),
      ),
    );
  }
}
