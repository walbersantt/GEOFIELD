import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../data/repositories/point_repository.dart';
import '../../data/repositories/survey_repository.dart';
import '../../models/point.dart';
import '../../models/survey.dart';
import '../camera/camera_screen.dart';
import '../notes/notes_screen.dart';
import 'gps_quality_screen.dart';
import 'measure_calculations.dart';

// Mantém o teste existente importando apenas measure_screen.dart.
export 'measure_calculations.dart';

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

/// Coordenada inicial e incremento ainda simulados até a captura GPS real.
/// Os pontos passam a ser gravados no Drift, mas a origem das coordenadas
/// continua determinística nesta etapa.
const double _kInitialLatitude = -8.1800;
const double _kInitialLongitude = -34.9200;
const double _kCoordinateStep = 0.0001;

/// Preenche o campo obrigatório `accuracy` do modelo. Não representa a
/// precisão real do GPS; o aviso no topo da tela continua obrigatório.
const double _kSimulatedAccuracy = 0.0;

String _pointName(int index) =>
    'P${(index + 1).toString().padLeft(2, '0')}';

/// Usa longitude como x e latitude como y apenas para o cálculo local.
Offset _pointOffset(SurveyPoint point) =>
    Offset(point.longitude, point.latitude);

String _pointCoordinates(SurveyPoint point) =>
    '${point.latitude.toStringAsFixed(2)}, ${point.longitude.toStringAsFixed(2)}';

/// Tela "Medir terreno" do print 3: mapa placeholder e cálculos sobre pontos
/// gravados no Drift. Ainda sem GPS real e sem flutter_map; as coordenadas
/// continuam simuladas até a captura real existir.
class MeasureScreen extends StatefulWidget {
  const MeasureScreen({super.key, this.initialSurveyId});

  /// Quando informado, carrega este levantamento em vez do mais recente.
  final String? initialSurveyId;

  @override
  State<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends State<MeasureScreen> {
  final SurveyRepository _surveyRepository = SurveyRepository(appDatabase);
  final PointRepository _pointRepository = PointRepository(appDatabase);

  String? _surveyId;
  List<SurveyPoint> _points = const <SurveyPoint>[];

  @override
  void initState() {
    super.initState();
    _loadInitialSurvey();
  }

  List<Offset> get _offsets =>
      _points.map(_pointOffset).toList(growable: false);

  /// Com `initialSurveyId`, prioriza o levantamento pedido. Se o id não for
  /// encontrado, mantém o comportamento antigo de usar o mais recente.
  Future<void> _loadInitialSurvey() async {
    final String? requestedId = widget.initialSurveyId;
    if (requestedId == null) {
      await _loadExistingSurvey();
      return;
    }

    final Survey? requested = await _surveyRepository.getSurveyById(requestedId);
    if (!mounted) return;
    if (requested == null) {
      await _loadExistingSurvey();
      return;
    }

    setState(() => _surveyId = requested.id);
    await _loadPoints(requested.id);
  }

  /// Carrega pontos de um levantamento já existente, sem criar dados novos.
  Future<void> _loadExistingSurvey() async {
    final Survey? latest = await _surveyRepository.getLatestSurvey();
    if (latest == null || !mounted) return;
    setState(() => _surveyId = latest.id);
    await _loadPoints(latest.id);
  }

  /// Recarrega a lista a partir do Drift para recalcular área e perímetro.
  Future<void> _loadPoints(String surveyId) async {
    final List<SurveyPoint> points =
        await _pointRepository.watchPointsBySurvey(surveyId).first;
    if (!mounted) return;
    setState(() => _points = points);
  }

  /// Reaproveita o último levantamento local ou cria um quando ainda não há.
  Future<String> _resolveSurveyId() async {
    final String? existingId = _surveyId;
    if (existingId != null) return existingId;

    final Survey? latest = await _surveyRepository.getLatestSurvey();
    if (latest != null) {
      _surveyId = latest.id;
      return latest.id;
    }

    await _surveyRepository.createSurvey(
      name: 'Levantamento em campo',
      description: '',
    );
    final Survey? created = await _surveyRepository.getLatestSurvey();
    if (created == null) {
      throw StateError('Não foi possível criar o levantamento local.');
    }
    _surveyId = created.id;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Novo levantamento criado. Você pode editá-lo na aba Levantamentos.',
            style: TextStyle(
              color: _colorSurface,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
            ),
          ),
          backgroundColor: _colorText,
        ),
      );
    }
    return created.id;
  }

  Future<void> _collectPoint() async {
    final String surveyId = await _resolveSurveyId();
    final SurveyPoint? last = _points.isEmpty ? null : _points.last;
    final double lat =
        last == null ? _kInitialLatitude : last.latitude + _kCoordinateStep;
    final double lng =
        last == null ? _kInitialLongitude : last.longitude + _kCoordinateStep;

    await _pointRepository.addPoint(
      surveyId: surveyId,
      lat: lat,
      lng: lng,
      accuracy: _kSimulatedAccuracy,
      source: 'manual',
    );
    await _loadPoints(surveyId);
  }

  void _openNotes() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotesScreen(surveyId: _surveyId),
      ),
    );
  }

  void _openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CameraScreen(surveyId: _surveyId),
      ),
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

  final List<SurveyPoint> points;

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
                        _pointName(i),
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

  final List<SurveyPoint> points;

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
        for (int i = 0; i < points.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  _pointName(i),
                  style: const TextStyle(
                    color: _colorSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '• ${_pointCoordinates(points[i])}',
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
