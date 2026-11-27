import 'package:material_ui/material_ui.dart';

import '../../data/app_database.dart';
import '../../data/repositories/survey_repository.dart';

// Tokens de DESIGN.md; valores que só existem no print 4 estão marcados
// no ponto de uso.
const Color _colorBackground = Color(0xFFF7F7F2);
const Color _colorCard = Color(0xFFEDF1EA);
const Color _colorBorder = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorText = Color(0xFF1F2723);
const Color _colorSecondary = Color(0xFF68716C);
const Color _colorOnPrimary = Color(0xFFFFFFFF);

/// Anotação simulada. Substituir pelo modelo do Drift quando o CRUD existir.
class _Note {
  const _Note(this.title, this.body, this.time);

  final String title;
  final String body;
  final String time;
}

/// Simulação explícita até a persistência ser implementada. A tabela de
/// anotações ainda não existe no Drift; quando existir, esta lista será
/// substituída pelo repositório correspondente, filtrado por surveyId.
const List<_Note> _kSimulatedNotes = [
  _Note(
    'P04 — acesso lateral',
    'Terreno com acesso estreito. Verificar medidas antes de finalizar o levantamento.',
    '14:18',
  ),
  _Note(
    'P03 — marco encontrado',
    'Marco físico identificado próximo ao limite do terreno.',
    '14:32',
  ),
];

/// Tela "Registrar anotações" do print 4: sem persistência e sem câmera real.
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, this.surveyId});

  /// Id do levantamento ao qual as anotações serão vinculadas.
  final String? surveyId;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final SurveyRepository _surveyRepository = SurveyRepository(appDatabase);
  final TextEditingController _controller = TextEditingController();
  final List<_Note> _notes = List<_Note>.from(_kSimulatedNotes);

  // Texto do print 4, mantido quando a tela é aberta sem levantamento vinculado.
  // Com surveyId, o nome real vem do Drift; se não for encontrado, o texto é
  // neutro para não inventar dados.
  String _surveySubtitle = 'Terreno — Piedade';

  @override
  void initState() {
    super.initState();
    _loadSurveyName();
  }

  Future<void> _loadSurveyName() async {
    final String? id = widget.surveyId;
    if (id == null) return;
    final survey = await _surveyRepository.getSurveyById(id);
    if (!mounted || survey == null) return;
    setState(() => _surveySubtitle = survey.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _currentTime() {
    final DateTime now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _addNote() {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      _showMessage('Descreva a anotação antes de adicionar.');
      return;
    }
    setState(() {
      // Título neutro: o print não define como o título é gerado e nenhum
      // ponto está selecionado nesta etapa.
      _notes.add(_Note('Anotação', text, _currentTime()));
      _controller.clear();
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // 16 px de margem lateral vem do print 4.
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _NotesHeader(subtitle: _surveySubtitle),
                    const SizedBox(height: 24),
                    const Text(
                      'Anotações do campo',
                      style: TextStyle(
                        color: _colorText,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registre observações vinculadas ao levantamento.',
                      style: TextStyle(
                        color: _colorSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _NewNoteCard(controller: _controller),
                    const SizedBox(height: 32),
                    for (final _Note note in _notes) ...[
                      _NoteCard(note: note),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
            _NotesFooter(count: _notes.length, onAdd: _addNote),
          ],
        ),
      ),
    );
  }
}

class _NotesHeader extends StatelessWidget {
  const _NotesHeader({required this.subtitle});

  final String subtitle;

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registrar anotações',
                style: TextStyle(
                  color: _colorText,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
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

class _NewNoteCard extends StatelessWidget {
  const _NewNoteCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nova anotação',
            style: TextStyle(
              color: _colorText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 5,
            style: const TextStyle(
              color: _colorText,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
            ),
            decoration: const InputDecoration(
              hintText:
                  'Descreva uma ocorrência, medida ou observação importante do local...',
              hintStyle: TextStyle(
                color: _colorSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              // Botão de ação local ainda não tem destino: sem navegação.
              onPressed: () {},
              icon: const Icon(
                Icons.photo_library_outlined,
                color: _colorText,
                size: 16,
              ),
              label: const Text(
                'Adicionar foto',
                style: TextStyle(
                  color: _colorText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: _colorBackground,
                foregroundColor: _colorText,
                side: const BorderSide(color: _colorBorder, width: 1),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerRight,
            // 14:32 vem do print 4.
            child: Text(
              '14:32',
              style: TextStyle(
                color: _colorSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final _Note note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                    color: _colorText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 8),
                // 13 px vem do print; DESIGN.md não registra 13 px regular.
                Text(
                  note.body,
                  style: const TextStyle(
                    color: _colorSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            note.time,
            style: const TextStyle(
              color: _colorSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesFooter extends StatelessWidget {
  const _NotesFooter({required this.count, required this.onAdd});

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(color: _colorBackground),
      child: Column(
        children: [
          // Hover/focus não definidos no Figma; disabled usaria a opacidade
          // padrão do Material 3 se onPressed fosse null.
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova anotação'),
            style: FilledButton.styleFrom(
              backgroundColor: _colorPrimary,
              foregroundColor: _colorOnPrimary,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count anotações salvas',
            style: const TextStyle(
              color: _colorSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
