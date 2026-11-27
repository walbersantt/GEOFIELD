import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../data/repositories/point_repository.dart';
import '../../data/repositories/survey_repository.dart';
import '../../models/point.dart';
import '../../models/survey.dart';
import '../measure/measure_calculations.dart';
import '../notes/notes_screen.dart';
import '../photo/photo_screen.dart';

// Tokens de DESIGN.md; valores que só existem no print 7 estão marcados
// no ponto de uso.
const Color _colorBackground = Color(0xFFF7F7F2);
const Color _colorCard = Color(0xFFEDF1EA);
const Color _colorSurface = Color(0xFFFFFFFF);
const Color _colorBorder = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorText = Color(0xFF1F2723);
const Color _colorSecondary = Color(0xFF68716C);
const Color _colorOnPrimary = Color(0xFFFFFFFF);

/// Tela "Detalhes do levantamento" do print 7, agora com nome, data e pontos
/// vindos do Drift. Mapa e exportação seguem sem implementação.
class SurveyDetailsScreen extends StatefulWidget {
  const SurveyDetailsScreen({super.key, this.surveyId, this.surveyName});

  /// Id do levantamento usado para buscar os dados locais.
  final String? surveyId;

  /// Nome opcional recebido pela lista para exibição imediata. O nome gravado
  /// no Drift tem precedência quando disponível.
  final String? surveyName;

  @override
  State<SurveyDetailsScreen> createState() => _SurveyDetailsScreenState();
}

class _SurveyDetailsScreenState extends State<SurveyDetailsScreen> {
  final SurveyRepository _surveyRepository = SurveyRepository(appDatabase);
  final PointRepository _pointRepository = PointRepository(appDatabase);

  Survey? _survey;
  List<SurveyPoint> _points = const <SurveyPoint>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurvey();
  }

  Future<void> _loadSurvey() async {
    final String? id = widget.surveyId;
    if (id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final Survey? survey = await _surveyRepository.getSurveyById(id);
    final List<SurveyPoint> points =
        await _pointRepository.watchPointsBySurvey(id).first;
    if (!mounted) return;
    setState(() {
      _survey = survey;
      _points = points;
      _isLoading = false;
    });
  }

  String get _surveyName =>
      _survey?.name ??
      widget.surveyName ??
      'Levantamento não identificado';

  String get _pointsLabel {
    final int count = _points.length;
    return count == 1 ? '1 ponto coletado' : '$count pontos coletados';
  }

  /// Formatação manual para não adicionar dependências. Padrão dd/MM/yyyy
  /// definido na descrição da tela.
  String _formatDate(DateTime date) {
    final DateTime local = date.toLocal();
    final String day = local.day.toString().padLeft(2, '0');
    final String month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  /// Os cálculos usam longitude como x e latitude como y. Não há conversão
  /// para metros; por isso o valor é exibido sem unidade inventada.
  List<Offset> get _offsets => _points
      .map((point) => Offset(point.longitude, point.latitude))
      .toList(growable: false);

  String _formatNumber(double value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Em breve',
          style: TextStyle(
            color: _colorOnPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 20 / 14,
          ),
        ),
        backgroundColor: _colorText,
      ),
    );
  }

  void _openNotes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotesScreen(surveyId: widget.surveyId),
      ),
    );
  }

  void _openPhotos(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PhotoScreen(surveyId: widget.surveyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double area = polygonArea(_offsets);
    final double perimeter = polygonPerimeter(_offsets);

    return Scaffold(
      backgroundColor: _colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // 16 px de margem lateral vem do print 7.
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const _DetailsHeader(),
                    const SizedBox(height: 24),
                    if (_isLoading)
                      // Texto estático: um indicador circular animado dentro
                      // da pilha de telas impediria pumpAndSettle nos testes.
                      const Center(
                        child: Text(
                          'Carregando levantamento...',
                          style: TextStyle(
                            color: _colorSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 20 / 14,
                          ),
                        ),
                      )
                    else ...[
                      _SurveySummaryCard(
                        name: _surveyName,
                        dateLabel: _survey == null
                            ? 'Data não informada'
                            : _formatDate(_survey!.createdAt),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _pointsLabel,
                        style: const TextStyle(
                          color: _colorText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _MeasurementCard(
                        areaLabel: _formatNumber(area),
                        perimeterLabel: _formatNumber(perimeter),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pontos registrados',
                        style: TextStyle(
                          color: _colorText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_points.isEmpty)
                        const _EmptyPoints()
                      else
                        for (int index = 0; index < _points.length; index++) ...[
                          _PointCard(index: index, point: _points[index]),
                          const SizedBox(height: 12),
                        ],
                    ],
                  ],
                ),
              ),
            ),
            _DetailsFooter(
              onMapTap: () => _showSoon(context),
              onPhotosTap: () => _openPhotos(context),
              onNotesTap: () => _openNotes(context),
              onExportTap: () => _showSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader();

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
            icon: const Icon(Icons.chevron_left, color: _colorText, size: 24),
          ),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhes do levantamento',
                style: TextStyle(
                  color: _colorText,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
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
      ],
    );
  }
}

class _SurveySummaryCard extends StatelessWidget {
  const _SurveySummaryCard({required this.name, required this.dateLabel});

  final String name;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: _colorText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: _colorPrimary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        // O modelo Survey não possui localização. Texto neutro
                        // definido na descrição para manter a linha do print.
                        'Localização não informada',
                        // 13 px vem do print; DESIGN.md não traz 13 px regular.
                        style: TextStyle(
                          color: _colorSecondary,
                          fontSize: 13,
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
          Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: _colorPrimary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: const TextStyle(
                  color: _colorSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.areaLabel,
    required this.perimeterLabel,
  });

  final String areaLabel;
  final String perimeterLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Área calculada',
                  style: TextStyle(
                    color: _colorSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  areaLabel,
                  style: const TextStyle(
                    color: _colorText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: _colorBorder),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Perímetro calculado',
                  style: TextStyle(
                    color: _colorSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  perimeterLabel,
                  style: const TextStyle(
                    color: _colorText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _EmptyPoints extends StatelessWidget {
  const _EmptyPoints();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorBorder, width: 1),
      ),
      child: const Text(
        'Nenhum ponto registrado neste levantamento.',
        style: TextStyle(
          color: _colorSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 20 / 13,
        ),
      ),
    );
  }
}

class _PointCard extends StatelessWidget {
  const _PointCard({required this.index, required this.point});

  final int index;
  final SurveyPoint point;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _colorSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorBorder, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: _colorPrimary, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P${(index + 1).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    color: _colorText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat ${point.latitude.toStringAsFixed(6)} • '
                  'Lon ${point.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(
                    color: _colorSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_outline,
            color: _colorPrimary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _DetailsFooter extends StatelessWidget {
  const _DetailsFooter({
    required this.onMapTap,
    required this.onPhotosTap,
    required this.onNotesTap,
    required this.onExportTap,
  });

  final VoidCallback onMapTap;
  final VoidCallback onPhotosTap;
  final VoidCallback onNotesTap;
  final VoidCallback onExportTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(color: _colorBackground),
      child: Column(
        children: [
          // Hover/focus não definidos no Figma. Com onPressed sempre válido,
          // não há estado disabled; se houvesse, seria a opacidade do Material 3.
          _DetailButton(
            label: 'Ver pontos no mapa',
            icon: Icons.map,
            filled: true,
            onPressed: onMapTap,
          ),
          const SizedBox(height: 12),
          _DetailButton(
            label: 'Ver imagens registradas',
            icon: Icons.photo_library,
            onPressed: onPhotosTap,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailButton(
                  label: 'Consultar anotações',
                  icon: Icons.description,
                  onPressed: onNotesTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailButton(
                  label: 'Exportar CSV',
                  icon: Icons.download,
                  onPressed: onExportTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailButton extends StatelessWidget {
  const _DetailButton({
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
    final TextStyle textStyle = TextStyle(
      color: filled ? _colorOnPrimary : _colorPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    return SizedBox(
      height: filled ? 56 : 48,
      child: filled
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label, style: textStyle),
              style: FilledButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: _colorOnPrimary,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label, style: textStyle),
              style: OutlinedButton.styleFrom(
                backgroundColor: _colorBackground,
                foregroundColor: _colorPrimary,
                side: const BorderSide(color: _colorBorder, width: 1),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
    );
  }
}
