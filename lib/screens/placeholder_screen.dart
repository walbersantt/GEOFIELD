import 'package:material_ui/material_ui.dart';
import '../theme/app_colors.dart';

/// Tela provisÃ³ria, usada enquanto uma aba ainda nÃ£o foi construÃ­da.
/// Quando a tela real ficar pronta, Ã© sÃ³ trocÃ¡-la no MainShell.
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta tela serÃ¡ construÃ­da nas prÃ³ximas etapas.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
