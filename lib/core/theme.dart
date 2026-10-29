import 'package:flutter/material.dart';
import 'package:visitor_management/domain/entities/visitor_status.dart';

class AppTheme {
  AppTheme._();

  static const Color blue = Color(0xFF3B82F6);      
  static const Color green = Color(0xFF22C55E);     
  static const Color purple = Color(0xFF8B5CF6);    
  static const Color orange = Color(0xFFF97316);    
  static const Color red = Color(0xFFEF4444);       

  static const Color _bg = Color(0xFF0A1020);           
  static const Color _surface = Color(0xFF0F1A2E);      
  static const Color _surfaceHigh = Color(0xFF14233D);  
  static const Color _outline = Color(0xFF1E2D4A);      
  static const Color _textPrimary = Color(0xFFE6EDF7);
  static const Color _textSecondary = Color(0xFF8FA3BF);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static Color statusColor(String status) {
    switch (status) {
      case VisitorStatus.checkedIn:
        return green;
      case VisitorStatus.checkedOut:
        return orange;
      case VisitorStatus.registered:
      default:
        return blue;
    }
  }

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final base = ColorScheme.fromSeed(seedColor: blue, brightness: brightness);

    final scheme = isDark
        ? base.copyWith(
            primary: blue,
            onPrimary: Colors.white,
            secondary: green,
            onSecondary: Colors.white,
            tertiary: purple,
            onTertiary: Colors.white,
            error: red,
            onError: Colors.white,
            surface: _bg,
            onSurface: _textPrimary,
            onSurfaceVariant: _textSecondary,
            surfaceContainerLowest: _bg,
            surfaceContainerLow: _surface,
            surfaceContainer: _surface,
            surfaceContainerHigh: _surfaceHigh,
            surfaceContainerHighest: _surfaceHigh,
            outline: _textSecondary,
            outlineVariant: _outline,
          )
        : base.copyWith(
            primary: blue,
            onPrimary: Colors.white,
            secondary: green,
            tertiary: purple,
            error: red,
          );

    final radius = BorderRadius.circular(12);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,

      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isDark ? _surface : null,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? _surfaceHigh : scheme.surfaceContainerHighest,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark ? _surfaceHigh : null,
        selectedColor: scheme.primary,
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        side: BorderSide(color: scheme.outlineVariant),
        shape: const StadiumBorder(),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? _surface : null,
        surfaceTintColor: Colors.transparent,
        indicatorColor: blue.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? blue
                  : scheme.onSurfaceVariant,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11,
              color: states.contains(WidgetState.selected)
                  ? blue
                  : scheme.onSurfaceVariant,
            )),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : _textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? blue : _outline),
      ),

      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),

      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? _surface : null,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}