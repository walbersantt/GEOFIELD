import 'package:material_ui/material_ui.dart';

// Tokens de DESIGN.md. #E8F2EB e os textos vieram da descrição do print 7;
// nenhum valor visual foi inventado.
const Color _colorBackground = Color(0xFFF7F7F2);
const Color _colorWarning = Color(0xFFFFF2E0);
const Color _colorWarningIcon = Color(0xFFF48B39);
const Color _colorImprove = Color(0xFFE8F2EB);
const Color _colorCoordinates = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorText = Color(0xFF1F2723);
const Color _colorSecondary = Color(0xFF68716C);
const Color _colorOnPrimary = Color(0xFFFFFFFF);
const Color _colorSnackBar = Color(0xFF1F2723);
const Color _colorOnSnackBar = Color(0xFFF7F7F2);

/// Tela "Qualidade do GPS" do print 7: checagem de precisão antes de salvar.
/// Valores simulados, sem leitura real de GPS e sem persistência.
class GpsQualityScreen extends StatelessWidget {
  const GpsQualityScreen({super.key});

  void _showSoon(BuildContext context) {
    // Mesmo padrão de SnackBar das telas anteriores.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Em breve',
          style: TextStyle(
            color: _colorOnSnackBar,
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
      appBar: AppBar(
        backgroundColor: _colorBackground,
        elevation: 0,
        title: const Text(
          'Qualidade do GPS',
          style: TextStyle(
            color: _colorText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const _QualityHeader(),
              const SizedBox(height: 20),
              const _AccuracyCard(),
              const SizedBox(height: 24),
              const _ExplanationSection(),
              const SizedBox(height: 16),
              const _ImproveLocationCard(),
              const SizedBox(height: 24),
              const _CoordinatesSection(),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: () => _showSoon(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _colorPrimary,
                    foregroundColor: _colorOnPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Tentar novamente'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => _showSoon(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _colorPrimary,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: _colorPrimary, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Salvar ponto mesmo assim'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityHeader extends StatelessWidget {
  const _QualityHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'LEVANTAMENTO • TERRENO PIEDADE',
          style: TextStyle(
            color: _colorSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Verifique seu ponto',
          style: TextStyle(
            color: _colorText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Confira a precisão estimada antes de salvar a coordenada.',
          style: TextStyle(
            color: _colorSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 18 / 13,
          ),
        ),
      ],
    );
  }
}

class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorWarning,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: _colorWarningIcon,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.priority_high,
              color: _colorOnPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Precisão moderada',
                  style: TextStyle(
                    color: _colorText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '± 4 m',
                  style: TextStyle(
                    color: _colorText,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Precisão estimada pelo celular',
                  style: TextStyle(
                    color: _colorSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationSection extends StatelessWidget {
  const _ExplanationSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'O que isso significa?',
          style: TextStyle(
            color: _colorText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'A localização pode variar. Para um registro mais confiável, '
          'aguarde alguns instantes em um local aberto e tente novamente.',
          style: TextStyle(
            color: _colorSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
          ),
        ),
        SizedBox(height: 8),
        // Aviso obrigatório conforme AGENTS.md §7.
        Text(
          'Coordenadas de GPS de smartphone não são topograficamente precisas; '
          'a precisão depende do dispositivo, do ambiente e do sinal GNSS.',
          style: TextStyle(
            color: _colorSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w400,
            height: 14 / 11,
          ),
        ),
      ],
    );
  }
}

class _ImproveLocationCard extends StatelessWidget {
  const _ImproveLocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // #E8F2EB vem do print 7 e não está em DESIGN.md.
        color: _colorImprove,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(Icons.sync, color: _colorPrimary, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tentar melhorar a localização',
                  style: TextStyle(
                    color: _colorPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'O GPS pode levar alguns segundos para estabilizar.',
                  style: TextStyle(
                    color: _colorSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinatesSection extends StatelessWidget {
  const _CoordinatesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Text(
          'COORDENADAS CAPTURADAS',
          style: TextStyle(
            color: _colorSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        _CoordinatesCard(),
      ],
    );
  }
}

class _CoordinatesCard extends StatelessWidget {
  const _CoordinatesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorCoordinates,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: const [
          _CoordinateRow(label: 'Latitude', value: '-8.1874°'),
          SizedBox(height: 12),
          _CoordinateRow(label: 'Longitude', value: '-34.9221°'),
          SizedBox(height: 12),
          Text(
            'Exemplo ilustrativo • valores simulados',
            style: TextStyle(
              color: _colorSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinateRow extends StatelessWidget {
  const _CoordinateRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _colorSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _colorText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
