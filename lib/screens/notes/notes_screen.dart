import 'package:material_ui/material_ui.dart';

// Tokens extraídos de DESIGN.md. Os textos simulados vêm da descrição do
// print 4; nenhum valor visual foi inventado.
const Color _colorAppBar = Color(0xFFFFFFFF);
const Color _colorBackground = Color(0xFFF7F7F2);
const Color _colorComposer = Color(0xFFF5F5ED);
const Color _colorCard = Color(0xFFFFFFFA);
const Color _colorBorder = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorAction = Color(0xFF234B3A);
const Color _colorText = Color(0xFF1F2723);
const Color _colorSecondary = Color(0xFF68716C);
const Color _colorOnPrimary = Color(0xFFFFFFFA);

/// Tela "Registrar anotações" do print 4.
///
/// Os registros exibidos são textos simulados vindos da descrição do print.
/// Não há Drift, Supabase nem qualquer persistência nesta etapa.
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorBackground,
      appBar: AppBar(
        backgroundColor: _colorAppBar,
        elevation: 0,
        // 64 px está na escala de alturas do DESIGN.md e acomoda as duas linhas.
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Registrar anotações',
              style: TextStyle(
                color: _colorText,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Levantamento • Terreno — Piedade',
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
          // 20 px é a margem horizontal do frame de detalhes no DESIGN.md.
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Anotações do campo',
                style: TextStyle(
                  color: _colorText,
                  fontSize: 24,
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
              const SizedBox(height: 24),
              _NewNoteCard(onPhotoTap: () => _showSoon(context)),
              const SizedBox(height: 24),
              const _NoteCard(
                time: '14:18',
                title: 'P04 — acesso lateral',
                body: 'Terreno com acesso estreito. Verificar medida antes de '
                    'finalizar o levantamento.',
              ),
              const SizedBox(height: 12),
              const _NoteCard(
                title: 'P03 — marco encontrado',
                body: 'Marco físico identificado próximo ao limite do terreno.',
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () => _showSoon(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nova anotação'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _colorPrimary,
                    foregroundColor: _colorOnPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '2 anotações salvas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _colorSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
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

/// Card creme com o campo de texto simulado e a ação de foto.
class _NewNoteCard extends StatelessWidget {
  const _NewNoteCard({required this.onPhotoTap});

  final VoidCallback onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // #F5F5ED é o fundo do cartão principal em DESIGN.md ("creme claro").
        color: _colorComposer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _colorBorder, width: 1),
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
          const SizedBox(height: 12),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Descreva uma ocorrência, medida ou observação '
                  'importante do local...',
              hintStyle: TextStyle(
                color: _colorSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
              ),
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onPhotoTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: _colorAction,
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              side: const BorderSide(color: _colorBorder, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Adicionar foto'),
          ),
          const SizedBox(height: 8),
          const Text(
            '14:32',
            textAlign: TextAlign.right,
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

/// Card de anotação simulada. O horário aparece acima do card quando informado.
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.title, required this.body, this.time});

  final String? time;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (time != null) ...[
          Text(
            time!,
            style: const TextStyle(
              color: _colorSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _colorCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _colorBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _colorText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  color: _colorSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
