import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/dev_flags.dart';
import '../../config/supabase_config.dart';
import '../../data/app_database.dart';
import '../../data/sync_service.dart';
import '../../services/auth_service.dart';
import '../main_shell.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Decide entre login e navegação principal a partir do estado do Supabase.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final AuthService _authService;
  late final SyncService _syncService;
  StreamSubscription<AuthStatus>? _subscription;

  /// `null` enquanto a primeira resolução do estado não acontece.
  AuthStatus? _status;
  bool _handlingWebCallback = false;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _syncService = SyncService(database: appDatabase, authService: _authService);
    unawaited(_syncService.start());
    _subscription = _authService.onAuthStateChange.listen((status) {
      debugPrint('AuthGate: onAuthStateChange status=$status');
      if (!mounted) return;
      setState(() => _status = status);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_resolveInitialAuth());
    });
  }

  Future<void> _resolveInitialAuth() async {
    await _handleWebAuthCallback();
    if (!mounted) return;
    setState(() => _status = _authService.currentStatus);
  }

  Future<void> _handleWebAuthCallback() async {
    if (!kIsWeb || !SupabaseConfig.isReady) return;
    final Uri uri = Uri.base;
    final bool hasAuthParams = uri.queryParameters.containsKey('code') ||
        uri.queryParameters.containsKey('error') ||
        uri.queryParameters.containsKey('error_description') ||
        uri.fragment.contains('access_token=') ||
        uri.fragment.contains('refresh_token=') ||
        uri.fragment.contains('error=');
    debugPrint(
      'AuthGate web callback: uri=$uri hasAuthParams=$hasAuthParams '
      'currentStatus=${_authService.currentStatus}',
    );
    if (!hasAuthParams) return;
    if (_authService.currentStatus == AuthStatus.authenticated) {
      debugPrint('AuthGate web callback: sessão já autenticada, pulando troca.');
      return;
    }

    if (mounted) setState(() => _handlingWebCallback = true);
    try {
      final response =
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
      debugPrint(
        'AuthGate web callback: getSessionFromUrl ok '
        'user=${response.session.user.id} expiresAt=${response.session.expiresAt}',
      );
    } catch (e, st) {
      debugPrint('AuthGate web callback: getSessionFromUrl erro: $e');
      debugPrint('$st');
    } finally {
      if (mounted) setState(() => _handlingWebCallback = false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    unawaited(_syncService.dispose());
    unawaited(_authService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bypass de desenvolvimento (kDevBypassAuth); remover/desligar quando o
    // Supabase estiver configurado.
    if (kDevBypassAuth) {
      return const MainShell();
    }

    final AuthStatus? status = _status;
    if (status == null || _handlingWebCallback) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F7F2),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF18583D)),
        ),
      );
    }

    switch (status) {
      case AuthStatus.authenticated:
        return const MainShell();
      case AuthStatus.unauthenticated:
        return LoginScreen(
          authService: _authService,
          onRegisterTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RegisterScreen(authService: _authService),
              ),
            );
          },
          onForgotPasswordTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ForgotPasswordScreen(authService: _authService),
              ),
            );
          },
        );
    }
  }
}
