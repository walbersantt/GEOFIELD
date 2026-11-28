import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

/// URL de retorno usada tanto no OAuth do Google quanto no link de recuperação.
///
/// No mobile, usa o deep link do app. No web, usa a origem atual do navegador
/// (ex.: http://localhost:8080), que deve estar cadastrada no Supabase em
/// Authentication -> URL Configuration -> Redirect URLs.
String get kAuthRedirectTo =>
    kIsWeb ? Uri.base.origin : 'geofield://login-callback';

/// Estado de autenticação simplificado para a camada de UI.
enum AuthStatus { authenticated, unauthenticated }

/// Falha já traduzida para pt-BR, pronta para ser exibida ao usuário.
class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthFailure(message: $message, code: $code)';
}

/// Encapsula todas as operações de autenticação do Supabase.
///
/// A UI nunca recebe mensagens técnicas do Supabase: [AuthException] é
/// convertido em [AuthFailure] com texto em pt-BR.
class AuthService {
  AuthService();

  final StreamController<AuthStatus> _statusController =
      StreamController<AuthStatus>.broadcast();

  StreamSubscription<AuthState>? _authSubscription;

  AuthStatus _lastStatus = AuthStatus.unauthenticated;

  GoTrueClient get _auth => SupabaseConfig.client.auth;

  /// Liga ao stream na primeira leitura, para que o construtor não exija
  /// Supabase inicializado (necessário para widget tests determinísticos).
  void _ensureSubscribed() {
    if (_authSubscription != null) return;
    _lastStatus = _statusFromUser(_safeCurrentUser());
    try {
      _authSubscription = _auth.onAuthStateChange.listen(
        (state) => _emit(_statusFromUser(state.session?.user)),
        onError: (Object error, StackTrace stackTrace) {
          // Erros do stream não são propagados à UI; o último estado válido
          // permanece disponível em [currentStatus].
        },
      );
    } on StateError {
      // Supabase ainda não foi inicializado nesta sessão.
      _lastStatus = AuthStatus.unauthenticated;
    }
  }

  User? _safeCurrentUser() {
    try {
      return _auth.currentUser;
    } on StateError {
      return null;
    }
  }

  /// Último estado conhecido, usado para montar a primeira frame da UI.
  AuthStatus get currentStatus {
    _ensureSubscribed();
    return _lastStatus;
  }

  /// Mudanças de estado já convertidas para [AuthStatus].
  Stream<AuthStatus> get onAuthStateChange {
    _ensureSubscribed();
    return _statusController.stream;
  }

  /// Usuário atual do Supabase, quando autenticado.
  User? get currentUser => _safeCurrentUser();

  /// Atalho para o id do usuário usado pelas camadas de dados/sincronização.
  String? get currentUserId => currentUser?.id;

  bool get isAuthenticated => currentUser != null;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) {
    return _runAuth(
      () => _auth.signInWithPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? nome,
  }) {
    final String? trimmedNome = nome?.trim();
    return _runAuth(
      () => _auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: kAuthRedirectTo,
        data: trimmedNome == null || trimmedNome.isEmpty
            ? null
            : {'nome': trimmedNome},
      ),
    );
  }

  /// Abre o navegador para o login com Google.
  ///
  /// O resultado bem-sucedido é observado por [onAuthStateChange], conforme
  /// contrato do `signInWithOAuth` do supabase_flutter.
  Future<bool> signInWithGoogle() {
    return signInWithOAuth(
      provider: OAuthProvider.google,
      redirectTo: kAuthRedirectTo,
    );
  }

  Future<bool> signInWithOAuth({
    OAuthProvider provider = OAuthProvider.google,
    String? redirectTo,
  }) async {
    final String resolvedRedirectTo = redirectTo ?? kAuthRedirectTo;
    try {
      final bool launched = await _auth.signInWithOAuth(
        provider,
        redirectTo: resolvedRedirectTo,
      );
      if (!launched) {
        throw const AuthFailure(
          'Não foi possível abrir o navegador para entrar com Google.',
        );
      }
      return launched;
    } on AuthException catch (error) {
      throw AuthFailure(
        _translateAuthException(error),
        code: error.code ?? error.statusCode,
      );
    } on AuthFailure {
      rethrow;
    } on StateError catch (error) {
      throw AuthFailure(error.message);
    } catch (_) {
      throw const AuthFailure(
        'Não foi possível iniciar a entrada com Google. Tente novamente.',
      );
    }
  }

  Future<void> resetPasswordForEmail({
    required String email,
    String? redirectTo,
  }) {
    final String resolvedRedirectTo = redirectTo ?? kAuthRedirectTo;
    return _runAuth(
      () => _auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: resolvedRedirectTo,
      ),
    );
  }

  Future<void> signOut() => _runAuth(() => _auth.signOut());

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    if (!_statusController.isClosed) {
      await _statusController.close();
    }
  }

  AuthStatus _statusFromUser(User? user) {
    return user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
  }

  void _emit(AuthStatus status) {
    _lastStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  Future<T> _runAuth<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on AuthException catch (error) {
      throw AuthFailure(
        _translateAuthException(error),
        code: error.code ?? error.statusCode,
      );
    } on StateError catch (error) {
      throw AuthFailure(error.message);
    } catch (_) {
      throw const AuthFailure(
        'Não foi possível concluir a operação. Verifique sua conexão e tente novamente.',
      );
    }
  }

  String _translateAuthException(AuthException error) {
    final String code = (error.code ?? '').toLowerCase();
    final String message = error.message.toLowerCase();

    if (error is AuthSessionMissingException) {
      return 'Você já está desconectado.';
    }
    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (code == 'email_not_confirmed' ||
        message.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (code == 'user_already_registered' ||
        message.contains('user already registered')) {
      return 'Já existe uma conta com este e-mail.';
    }
    if (error is AuthWeakPasswordException ||
        code == 'weak_password' ||
        message.contains('weak password')) {
      return 'A senha é muito fraca. Use uma senha mais forte.';
    }
    if (code == 'email_address_invalid' || message.contains('invalid email')) {
      return 'Informe um e-mail válido.';
    }
    if (code == 'too_many_requests' ||
        message.contains('too many requests')) {
      return 'Muitas tentativas. Aguarde um momento e tente novamente.';
    }
    if (code == 'signup_disabled' ||
        message.contains('signups not allowed')) {
      return 'O cadastro está temporariamente indisponível.';
    }
    if (code == 'otp_expired' || message.contains('expired')) {
      return 'O link expirou. Solicite um novo e-mail de recuperação.';
    }
    if (error.statusCode == '422') {
      return 'Verifique os dados informados e tente novamente.';
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
  }
}
