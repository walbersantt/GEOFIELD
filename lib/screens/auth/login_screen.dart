import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../services/auth_service.dart';

// Cores, raios, alturas e espaçamentos vêm de DESIGN.md. Onde o print do
// Figma especifica um valor ausente no DESIGN.md, ele é marcado no código.
const Color _colorBackground = Color(0xFFF7F7F2);
const Color _colorField = Color(0xFFE2E7E2);
const Color _colorPrimary = Color(0xFF18583D);
const Color _colorTextPrimary = Color(0xFF1F2723);
const Color _colorTextSecondary = Color(0xFF68716C);
const Color _colorOnPrimary = Color(0xFFFFFFFF);

/// Tela de login descrita no print 1 do MVP.
///
/// A navegação para cadastro/recuperação é injetada por quem montar a tela;
/// o `AuthGate` já liga os callbacks às telas de Cadastro e Recuperação.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    this.onLoginSuccess,
    this.onRegisterTap,
    this.onForgotPasswordTap,
    this.onBackTap,
  });

  final AuthService authService;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onForgotPasswordTap;
  final VoidCallback? onBackTap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isGoogleLoading = false;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await widget.authService.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      widget.onLoginSuccess?.call();
    } on AuthFailure catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);
    try {
      await widget.authService.signInWithGoogle();
      // O sucesso chega via onAuthStateChange; não forçamos navegação aqui.
    } on AuthFailure catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  void _showError(String message) {
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
        backgroundColor: _colorTextPrimary,
      ),
    );
  }

  String? _validateEmail(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) return 'Informe seu e-mail.';
    final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(text)) return 'Informe um e-mail válido.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _BackButton(
                    onPressed:
                        widget.onBackTap ?? () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(height: 32),
                const _AuthBrandHeader(
                  title: 'Bem-vindo de volta',
                  subtitle: 'Entre para continuar seus levantamentos em campo.',
                ),
                const SizedBox(height: 24),
                _AuthTextField(
                  label: 'E-mail',
                  hint: 'seuemail@exemplo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
                _AuthTextField(
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onToggleObscure: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: _validatePassword,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: _AuthLinkButton(
                    label: 'Esqueci minha senha',
                    onPressed: widget.onForgotPasswordTap ?? () {},
                  ),
                ),
                const SizedBox(height: 24),
                _AuthPrimaryButton(
                  label: 'Entrar',
                  isLoading: _isLoading,
                  onPressed: (_isLoading || _isGoogleLoading)
                      ? () {}
                      : () {
                          unawaited(_submit());
                        },
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: (_isLoading || _isGoogleLoading)
                      ? null
                      : () {
                          unawaited(_submitGoogle());
                        },
                  icon: _isGoogleLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Entrar com Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: _colorTextPrimary,
                    side: const BorderSide(color: _colorPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 24 / 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _AuthFooterLink(
                  leadingText: 'Ainda não tem conta?',
                  linkText: 'Criar conta',
                  onLinkPressed: widget.onRegisterTap ?? () {},
                ),
                const SizedBox(height: 32),
                const Text(
                  'Agrimensura e geotecnologia',
                  textAlign: TextAlign.center,
                  // ~11 px conforme o print.
                  style: TextStyle(
                    color: _colorTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.chevron_left,
          color: _colorPrimary,
          size: 24,
        ),
      ),
    );
  }
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _colorOnPrimary,
                  shape: BoxShape.circle,
                ),
                // Substituto temporário do símbolo SVG do Figma, que não foi
                // exportado como asset local. Trocar pelo asset real quando
                // disponível; cor e medida vêm de DESIGN.md.
                child: const Icon(Icons.eco, color: _colorPrimary, size: 24),
              ),
              const SizedBox(height: 12),
              const Text(
                'GeoField',
                style: TextStyle(
                  color: _colorPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 34 / 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(
            color: _colorTextPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            height: 36 / 28,
          ),
        ),
        const SizedBox(height: 8),
        // ~15 px e line-height 1.4 vêm do print (DESIGN.md não traz esse par).
        Text(
          subtitle,
          style: const TextStyle(
            color: _colorTextSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _colorTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 16 / 12,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: _colorField,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  decoration: InputDecoration(
                    hintText: hint,
                    // Placeholder ~15 px conforme o print.
                    hintStyle: const TextStyle(
                      color: _colorTextSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  style: const TextStyle(
                    color: _colorTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
              if (onToggleObscure != null)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: onToggleObscure,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: _colorTextSecondary,
                      size: 24,
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

class _AuthLinkButton extends StatelessWidget {
  const _AuthLinkButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 48),
      ),
      child: Text(
        label,
        // ~13 px conforme o print.
        style: const TextStyle(
          color: _colorPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Estado disabled: com isLoading == true, onPressed é null e o Material 3
    // aplica a opacidade padrão do tema. Não há cor de hover/focus definida no
    // Figma, portanto nenhuma é sobrescrita aqui.
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _colorPrimary,
        foregroundColor: _colorOnPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 24 / 16,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: _colorOnPrimary),
            )
          : Text(label),
    );
  }
}

class _AuthFooterLink extends StatelessWidget {
  const _AuthFooterLink({
    required this.leadingText,
    required this.linkText,
    required this.onLinkPressed,
  });

  final String leadingText;
  final String linkText;
  final VoidCallback onLinkPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            leadingText,
            style: const TextStyle(
              color: _colorTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 20 / 14,
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: onLinkPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 48),
            ),
            child: Text(
              linkText,
              style: const TextStyle(
                color: _colorPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
