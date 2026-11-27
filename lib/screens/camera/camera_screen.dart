import 'package:material_ui/material_ui.dart';

// Tokens de DESIGN.md. #234B3A e #F7F7F2 vieram do print 5 e já estão
// registrados nas constantes do projeto; os demais vêm de DESIGN.md.
const Color _colorBackground = Color(0xFF234B3A);
const Color _colorOnBackground = Color(0xFFF7F7F2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorSnackBar = Color(0xFF1F2723);

/// Tela "Fotografar" do print 5: câmera simulada, sem plugin de câmera e sem
/// persistência. Os botões apenas avisam que os recursos virão depois.
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  void _showSoon(BuildContext context) {
    // Mesmo padrão de SnackBar do MeasureScreen.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Em breve',
          style: TextStyle(
            color: _colorOnBackground,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
        backgroundColor: _colorSnackBar,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _CameraHeader(
                title: 'Fotografar',
                subtitle: 'Aponte para o local desejado',
                onBack: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),
              const _CameraPreview(),
              const SizedBox(height: 16),
              Center(
                child: _CreamButton(
                  label: 'Capturar',
                  onPressed: () => _showSoon(context),
                  fullWidth: false,
                ),
              ),
              const SizedBox(height: 24),
              const _PhotoSection(),
              const SizedBox(height: 24),
              _CreamButton(
                label: 'Ver todas as fotos',
                onPressed: () => _showSoon(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraHeader extends StatelessWidget {
  const _CameraHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.chevron_left,
              color: _colorOnBackground,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _colorOnBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _colorOnBackground.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        // Proporção 3:4 indicada no print 5 para o visor.
        aspectRatio: 3 / 4,
        child: Container(
          // Cinza escuro do placeholder: valor permitido pelo print 5.
          color: Colors.black45,
          alignment: Alignment.center,
          child: Text(
            'Visualização da câmera',
            style: TextStyle(
              color: _colorOnBackground.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Fotos deste levantamento',
          style: TextStyle(
            color: _colorOnBackground,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '3 fotos • última adicionada agora',
          style: TextStyle(
            color: _colorOnBackground.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _PhotoThumbnail(),
                SizedBox(width: 12),
                _PhotoThumbnail(),
                SizedBox(width: 12),
                _PhotoThumbnail(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        // Placeholder de imagem: mesmo cinza escuro do visor.
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Botão creme em pílula, com texto verde escuro. Hover/focus/disabled não
/// foram definidos no Figma; se onPressed for null no futuro, o Material 3
/// aplica a opacidade padrão de disabled.
class _CreamButton extends StatelessWidget {
  const _CreamButton({
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: fullWidth ? double.infinity : null,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _colorOnBackground,
          foregroundColor: _colorPrimary,
          minimumSize: Size(fullWidth ? double.infinity : 0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
