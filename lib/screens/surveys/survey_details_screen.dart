import 'package:material_ui/material_ui.dart';

// Tokens extraídos de DESIGN.md. O fundo do header (#E2E7E2) e os textos do
// print 7 vieram da descrição fornecida; nenhum valor foi inventado.
const Color _colorBackground = Color(0xFFF7F7F2);
const Color _colorAppBar = Color(0xFFFFFFFF);
const Color _colorHeader = Color(0xFFE2E7E2);
const Color _colorCard = Color(0xFFFFFFFF);
const Color _colorBorder = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorAction = Color(0xFF234B3A);
const Color _colorNoteBackground = Color(0xFFEDF3EE);
const Color _colorText = Color(0xFF1F2723);
const Color _colorSecondary = Color(0xFF68716C);
const Color _colorOnPrimary = Color(0xFFFFFFFF);
const Color _colorSnackBar = Color(0xFF1F2723);
const Color _colorOnSnackBar = Color(0xFFF7F7F2);

/// Ponto simulado do print 7. Substituir por SurveyPoint quando o Drift existir.
class _SurveyPoint {
  const _SurveyPoint(this.code, this.latitude, this.longitude);

  final String code;
  final String latitude;
  final String longitude;

  String get coordinates => 'Lat $latitude • Lon $longitude';
}

const List<_SurveyPoint> _kPoints = [
  _SurveyPoint('P01', '-8.118420', '-35.295180'),
  _SurveyPoint('P02', '-8.118610', '-35.294860'),
  _SurveyPoint('P03', '-8.118940', '-35.294920'),
  _SurveyPoint('P04', '-8.119120', '-35.295240'),
  _SurveyPoint('P05', '-8.118910', '-35.295570'),
  _SurveyPoint('P06', '-8.118590', '-35.295480'),
];

/// Tela "Detalhes do levantamento" do print 7.
///
/// Todos os dados abaixo são mock em memória: não há Drift, Supabase, mapa
/// real, galeria real nem exportação. Os botões apenas avisam "Em breve".
class SurveyDetailsScreen extends StatelessWidget {
  const SurveyDetailsScreen({super.key});

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
        backgroundColor: _colorAppBar,
        elevation: 0,
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            // 19 px semibold é o valor registrado em DESIGN.md para este texto.
            Text(
              'Detalhes do levantamento',
              style: TextStyle(
                color: _colorText,
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Levantamento finalizado',
              style: TextStyle(
                color: _colorSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const _SurveyHeaderCard(),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'Área calculada',
                      value: '1.240 m²',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Perímetro calculado',
                      value: '148 m',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _PointsSection(),
              const SizedBox(height: 24),
              _MapButton(onPressed: () => _showSoon(context)),
              const SizedBox(height: 12),
              _ImagesButton(onPressed: () => _showSoon(context)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SecondaryAction(
                      label: 'Consultar anotações',
                      icon: Icons.text_fields,
                      filled: true,
                      onPressed: () => _showSoon(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SecondaryAction(
                      label: 'Exportar CSV',
                      icon: Icons.download,
                      onPressed: () => _showSoon(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurveyHeaderCard extends StatelessWidget {
  const _SurveyHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorHeader,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sítio Boa Vista',
                  style: TextStyle(
                    color: _colorText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: _colorPrimary, size: 18),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Vitória de Santo Antão • PE',
                        style: TextStyle(
                          color: _colorSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '24 set',
            style: TextStyle(
              color: _colorSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 62),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _colorCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _colorBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _colorSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: _colorText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsSection extends StatelessWidget {
  const _PointsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '6 pontos coletados',
          style: TextStyle(
            color: _colorText,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _colorCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _colorBorder, width: 1),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _kPoints.length; i++) ...[
                _PointRow(point: _kPoints[i]),
                // DESIGN.md: a última linha da lista não tem borda inferior.
                if (i < _kPoints.length - 1)
                  const Divider(height: 1, thickness: 1, color: _colorBorder),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({required this.point});

  final _SurveyPoint point;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, color: _colorPrimary, size: 18),
          const SizedBox(width: 10),
          Text(
            point.code,
            style: const TextStyle(
              color: _colorText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 15 / 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              point.coordinates,
              style: const TextStyle(
                color: _colorSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 14 / 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Hover/focus/disabled não definidos no Figma; o Material 3 aplica a
    // opacidade padrão caso onPressed seja null no futuro.
    return SizedBox(
      height: 48,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.map, size: 18),
        label: const Text('Ver pontos no mapa'),
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
      ),
    );
  }
}

class _ImagesButton extends StatelessWidget {
  const _ImagesButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
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
        child: const Text('Ver imagens registradas'),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? _colorNoteBackground : null,
          foregroundColor: _colorAction,
          side: const BorderSide(color: _colorBorder, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
