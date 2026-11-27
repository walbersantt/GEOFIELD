import 'package:material_ui/material_ui.dart';

import '../camera/camera_screen.dart';
import 'gps_quality_screen.dart';
import '../notes/notes_screen.dart';

// Tokens de DESIGN.md; valores que só existem no print 3 estão marcados
// no ponto de uso.
const Color _colorBackground = Color(0xFF234B3A);
const Color _colorSurface = Color(0xFFF7F7F2);
const Color _colorBorder = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorText = Color(0xFF1F2723);
const Color _colorSecondary = Color(0xFF68716C);
const Color _colorWarningBackground = Color(0xFFFFF2E0);
const Color _colorWarningIcon = Color(0xFFF48B39);

/// Área do polígono por Shoelace/Gauss. 1 unidade = 1 metro (simulação).
/// Pública para ser verificada em test/measure_calculations_test.dart.
double polygonArea(List<Offset> points) {
  if (points.length < 3) return 0;
  double sum = 0;
  for (int i = 0; i < points.length; i++) {
    final Offset current = points[i];
    final Offset next = points[(i + 1) % points.length];
    sum += current.dx * next.dy - next.dx * current.dy;
  }
  return (sum / 2).abs();
}

/// Perímetro: soma das distâncias euclidianas. Com 2 pontos, é a distância
/// entre eles (não vai e volta). Com 3 ou mais, o polígono é fechado.
/// Pública para ser verificada em test/measure_calculations_test.dart.
double polygonPerimeter(List<Offset> points) {
  if (points.length < 2) return 0;
  if (points.length == 2) return (points[1] - points[0]).distance;
  double total = 0;
  for (int i = 0; i < points.length; i++) {
    total += (points[(i + 1) % points.length] - points[i]).distance;
  }
  return total;
}

/// Ponto simulado. Não vem de GPS e não é persistido nesta etapa.
class _MeasurePoint {
  const _MeasurePoint(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;

  /// Usa longitude como x e latitude como y apenas para o cálculo local.
  Offset get offset => Offset(longitude, latitude);

  String get coordinates =>
      '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
}

/// Simulação explícita até a integração com flutter_offline_background_location.
/// Não são dados reais de campo e não são gravados no Drift.
const List<_MeasurePoint> _kSimulatedPoints = [
  _MeasurePoint('P01', -8.1800, -34.9200),
  _MeasurePoint('P02', -8.1810, -34.9210),
  _MeasurePoint('P03', -8.1820, -34.9200),
  _MeasurePoint('P04', -8.1830, -34.9220),
];

/// Tela "Medir terreno" do print 3: mapa placeholder e cálculos sobre pontos
/// simulados. Sem GPS real, sem flutter_map e sem persistência.
class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key});

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  final List<_MeasurePoint> _points = List<_MeasurePoint>.from(_kSimulatedPoints);

  List<Offset> get _offsets =>
      _points.map((point) => point.offset).toList(growable: false);

  void _collectPoint() {
    // Simulação determinística: incremento fixo sobre o último ponto.
    // Substituir por leitura de GPS quando o CRUD e o Drift existirem.
    final _MeasurePoint last = _points.last;
    final String name = 'P${(_points.length + 1).toString().padLeft(2, '0')}';
    setState(() {
      _points.add(
        _MeasurePoint(
          name,
          last.latitude + 0.0001,
          last.longitude + 0.0001,
        ),
      );
    });
  }

  void _openNotes() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotesScreen()),
    );
  }

  void _openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CameraScreen()),
    );
  }

  void _openGpsQuality() {
    // Finalizar passa pela checagem de precisão antes de qualquer persistência.
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const GpsQualityScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double area = polygonArea(_offsets);
    final double perimeter = polygonPerimeter(_offsets);

    return Scaffold(
      backgroundColor: _colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          // 16 px de margem lateral vem do print 3.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _MeasureHeader(pointCount: _points.length),
              const SizedBox(height: 16),
              const _GpsWarningBanner(),
              const SizedBox(height: 16),
              _MapPlaceholder(points: _points),
              const SizedBox(height: 16),
              _ResultsCard(area: area, perimeter: perimeter),
              const SizedBox(height: 16),
              _ActionButtonRow(
                firstLabel: '+ Coletar ponto',
                firstIcon: Icons.add,
                onFirst: _collectPoint,
                secondLabel: 'Finalizar',
                onSecond: _openGpsQuality,
              ),
              const SizedBox(height: 12),
              _ActionButtonRow(
                firstLabel: 'Registrar anotações',
                onFirst: _openNotes,
                secondLabel: 'Fotografar',
                onSecond: _openCamera,
              ),
              const SizedBox(height: 24),
              _PointList(points: _points),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasureHeader extends StatelessWidget {
  const _MeasureHeader({required this.pointCount});

  final int pointCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.chevron_left, color: _colorSurface, size: 24),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medir terreno',
                style: TextStyle(
                  color: _colorSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Levantamento • Terreno — Piedade',
                style: TextStyle(
                  color: _colorSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: const BoxDecoration(
            color: _colorSurface,
            borderRadius: BorderRadius.all(Radius.circular(13)),
          ),
          child: Text(
            '$pointCount pontos',
            style: const TextStyle(
              color: _colorPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GpsWarningBanner extends StatelessWidget {
  const _GpsWarningBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _colorWarningBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: _colorWarningIcon,
            size: 20,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Coordenadas de GPS de smartphone não são topograficamente precisas. '
              'A precisão depende do dispositivo, do ambiente e do sinal GNSS.',
              style: TextStyle(
                color: _colorText,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.points});

  final List<_MeasurePoint> points;

  static const double _height = 320;
  // Posições proporcionais ilustrativas do print 3, não coordenadas reais.
  static const List<double> _xFractions = [0.20, 0.70, 0.80, 0.30];
  static const List<double> _yFractions = [0.30, 0.50, 0.20, 0.70];

  @override
  Widget build(BuildContext context) {
    return Container(
      // ~320 px vem do print 3.
      height: _height,
      decoration: BoxDecoration(
        color: _colorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorBorder, width: 1),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          return Stack(
            children: [
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorBorder,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GPS ativo',
                    style: TextStyle(color: _colorSecondary, fontSize: 11),
                  ),
                ),
              ),
              for (int i = 0; i < points.length; i++)
                Positioned(
                  left: width * _xFractions[i % _xFractions.length] -
                      6 +
                      (i ~/ _xFractions.length) * 12,
                  top: _height * _yFractions[i % _yFractions.length] -
                      6 +
                      (i ~/ _yFractions.length) * 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        points[i].name,
                        style: const TextStyle(
                          color: _colorSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: _colorPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.area, required this.perimeter});

  final double area;
  final double perimeter;

  // Com coordenadas em graus tratadas como 1 unidade = 1 metro, os valores
  // simulados são pequenos; preservar casas decimais permite ver a mudança.
  String _formatArea(double value) {
    if (value <= 0) return '—';
    return value < 1
        ? '${value.toStringAsFixed(6)} m²'
        : '${value.toStringAsFixed(0)} m²';
  }

  String _formatPerimeter(double value) {
    if (value <= 0) return '—';
    return value < 1
        ? '${value.toStringAsFixed(6)} m'
        : '${value.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Área estimada',
                  style: TextStyle(
                    color: _colorSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatArea(area),
                  style: const TextStyle(
                    color: _colorText,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perímetro',
                  style: TextStyle(
                    color: _colorSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatPerimeter(perimeter),
                  style: const TextStyle(
                    color: _colorSecondary,
                    fontSize: 14,
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

class _ActionButtonRow extends StatelessWidget {
  const _ActionButtonRow({
    required this.firstLabel,
    required this.onFirst,
    required this.secondLabel,
    required this.onSecond,
    this.firstIcon,
  });

  final String firstLabel;
  final VoidCallback onFirst;
  final String secondLabel;
  final VoidCallback onSecond;
  final IconData? firstIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: firstLabel,
            icon: firstIcon,
            onPressed: onFirst,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(label: secondLabel, onPressed: onSecond),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Hover/focus não definidos no Figma. Se onPressed for null em algum
    // estado futuro, o Material 3 aplica a opacidade padrão de disabled.
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _colorSurface,
          foregroundColor: _colorPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _PointList extends StatelessWidget {
  const _PointList({required this.points});

  final List<_MeasurePoint> points;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pontos coletados',
          style: TextStyle(
            color: _colorSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (final _MeasurePoint point in points)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  point.name,
                  style: const TextStyle(
                    color: _colorSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '• ${point.coordinates}',
                    style: TextStyle(
                      color: _colorSurface.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
