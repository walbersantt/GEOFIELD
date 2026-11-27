import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../services/auth_service.dart';
import '../camera/camera_screen.dart';
import '../measure/measure_screen.dart';
import '../notes/notes_screen.dart';
import '../surveys/survey_details_screen.dart';

// Tokens extraídos de DESIGN.md. Valores que só existem no print 2 estão
// marcados em comentário no ponto de uso.
const Color _colorBackground = Color(0xFFF7F7F2);
const Color _colorCard = Color(0xFFEDF1EA);
const Color _colorBorder = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorText = Color(0xFF1F2723);
const Color _colorSecondary = Color(0xFF68716C);
const Color _colorOnPrimary = Color(0xFFFFFFFF);

/// Aba Início da MainShell, conforme o print 2 do MVP.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A MainShell não recebe o AuthService do AuthGate. Esta instância é usada
  // apenas para a leitura síncrona de currentUser; ela não assina o stream de
  // autenticação (quem faz isso é o AuthGate) e é descartada junto com a tela.
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    unawaited(_authService.dispose());
    super.dispose();
  }

  /// Nome real do usuário, com fallback neutro. Nenhum dado é inventado.
  String _resolveUserName() {
    try {
      final user = _authService.currentUser;
      final Object? nome = user?.userMetadata?['nome'];
      if (nome is String && nome.trim().isNotEmpty) return nome.trim();
      final String? email = user?.email;
      if (email != null && email.isNotEmpty) return email;
    } catch (_) {
      // Leitura local indisponível: mantém o fallback.
    }
    return 'você';
  }

  void _showSoon() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
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
    final String userName = _resolveUserName();
    final String initial = userName.substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: _colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $userName',
                          style: const TextStyle(
                            color: _colorText,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'O que você quer fazer hoje?',
                          style: TextStyle(
                            color: _colorSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 40 px vem do print; a composição branco sobre #18583D é a
                  // primeira opção dada na descrição.
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: _colorPrimary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: _colorOnPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SurveyStatusCard(
                label: 'Levantamento em andamento',
                // CRUD de levantamentos ainda não implementado: sem dado fictício.
                value: 'Nenhum levantamento em andamento',
                onTap: _showSoon,
              ),
              const SizedBox(height: 16),
              const _SectionHeader(title: 'Acesso rápido'),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Acesso provisório até existir roteamento definitivo.
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.location_on,
                      title: 'Medir terreno',
                      subtitle: 'Pontos, área e perímetro',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MeasureScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.edit_note,
                      title: 'Registrar anotações',
                      subtitle: 'Observações do campo',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const NotesScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.photo_camera,
                      title: 'Fotografar',
                      subtitle: 'Registrar evidências',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CameraScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _QuickAccessCard(
                      icon: Icons.description,
                      title: 'Compilar planilha',
                      subtitle: 'Organizar e exportar dados',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SurveyStatusCard(
                label: 'Último levantamento',
                // Mock do print 7 até existir o CRUD de levantamentos.
                value: 'Sítio Boa Vista',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SurveyDetailsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: _colorText,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SurveyStatusCard extends StatelessWidget {
  const _SurveyStatusCard({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _colorCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: _colorSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 16 px semibold em #1F2723 vem do print 2: DESIGN.md só
                    // registra 15 px semibold e 16 px regular nessa cor.
                    Text(
                      value,
                      style: const TextStyle(
                        color: _colorText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Círculo de 32 px e ícone de 20 px estão na escala do DESIGN.md.
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: _colorBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: _colorPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // A altura mínima de 94 px é a do card de ação rápida em DESIGN.md.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 94),
      child: Material(
        color: _colorBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          // Destinos ainda não existem: feedback em vez de navegação inválida.
          // "Medir terreno" já recebe um onTap próprio na Home.
          onTap:
              onTap ??
              () {
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
              },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _colorBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _colorBorder, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: _colorPrimary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _colorText,
                          fontSize: 14,
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
                          height: 16 / 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
