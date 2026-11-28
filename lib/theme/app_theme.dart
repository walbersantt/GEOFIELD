import 'package:material_ui/material_ui.dart';
import 'app_colors.dart';

/// Define o "tema": a aparÃªncia padrÃ£o dos componentes do app.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: AppColors.textPrimary,
        surface: AppColors.backgroundAlt,
        onSurface: AppColors.textPrimary,
      ),

      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),

      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // NOVO: barra de navegaÃ§Ã£o inferior.
      // indicatorColor Ã© a "pÃ­lula" que destaca a aba selecionada.
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.backgroundAlt,
        indicatorColor: AppColors.softGreen,
        elevation: 0,
      ),
    );
  }
}
