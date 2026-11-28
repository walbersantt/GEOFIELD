import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncable/syncable.dart';

import '../config/supabase_config.dart';
import '../data/app_database.dart';
import '../models/point.dart';
import '../models/survey.dart';
import '../services/auth_service.dart';

/// Coordena a sincronização local (Drift) <-> Supabase.
///
/// Usa o `syncable` para filas em tempo real e complementa com um pull inicial
/// ao autenticar, garantindo que dados remotos existentes cheguem ao dispositivo.
class SyncService {
  SyncService({
    required AppDatabase database,
    required this._authService,
    this._supabaseClient,
  }) : _db = database;

  static SyncService? instance;

  final AppDatabase _db;
  final AuthService _authService;
  final SupabaseClient? _supabaseClient;

  SyncManager<AppDatabase>? _manager;
  StreamSubscription<AuthStatus>? _authSub;
  bool _started = false;
  bool _pulling = false;

  SupabaseClient get _client => _supabaseClient ?? SupabaseConfig.client;

  bool get _canSync {
    if (_supabaseClient != null) return true;
    return SupabaseConfig.isReady;
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    instance ??= this;

    if (!_canSync) return;

    try {
      _manager = SyncManager<AppDatabase>(
        localDatabase: _db,
        supabaseClient: _client,
      );
      _manager!
        ..registerSyncable<Survey>(
          backendTable: 'surveys',
          fromJson: Survey.fromJson,
          companionConstructor: SurveysCompanion.new,
        )
        ..registerSyncable<SurveyPoint>(
          backendTable: 'points',
          fromJson: SurveyPoint.fromJson,
          companionConstructor: PointsCompanion.new,
        );

      await _applyAuthState(_authService.currentStatus);

      _authSub = _authService.onAuthStateChange.listen((status) {
        unawaited(_applyAuthState(status));
      });
    } catch (e) {
      debugPrint('SyncService.start falhou: $e');
    }
  }

  Future<void> _applyAuthState(AuthStatus status) async {
    final manager = _manager;
    if (manager == null || !_canSync) return;

    if (status == AuthStatus.authenticated) {
      final String? userId = _authService.currentUserId;
      if (userId == null || userId.isEmpty) return;

      try {
        manager.setUserId(userId);
        await manager.fillMissingUserIdForLocalTables();
        await _pullRemote();
        manager.enableSync();
      } catch (e) {
        debugPrint('SyncService auth sync falhou: $e');
      }
      return;
    }

    try {
      manager.disableSync();
      manager.setUserId('');
    } catch (e) {
      debugPrint('SyncService disable falhou: $e');
    }
  }

  /// Pull inicial/refresh: baixa dados remotos do usuário e aplica no Drift.
  /// Conflito: versão com `updated_at` mais recente vence.
  Future<void> _pullRemote() async {
    if (_pulling || !_canSync) return;
    final String? userId = _authService.currentUserId;
    if (userId == null || userId.isEmpty) return;

    _pulling = true;
    try {
      final surveysData = await _client
          .from('surveys')
          .select()
          .eq('user_id', userId);
      final pointsData = await _client
          .from('points')
          .select()
          .eq('user_id', userId);

      await _db.transaction(() async {
        await _upsertSurveys(List<Map<String, dynamic>>.from(surveysData));
        await _upsertPoints(List<Map<String, dynamic>>.from(pointsData));
      });
    } catch (e) {
      debugPrint('SyncService.pullRemote falhou: $e');
    } finally {
      _pulling = false;
    }
  }

  Future<void> _upsertSurveys(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      final Survey remote = Survey.fromJson(row);
      final Survey? local = await (_db.select(_db.surveys)
            ..where((t) => t.id.equals(remote.id)))
          .getSingleOrNull();
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await _db.into(_db.surveys).insertOnConflictUpdate(remote.toCompanion());
      }
    }
  }

  Future<void> _upsertPoints(List<Map<String, dynamic>> rows) async {
    for (final row in rows) {
      final SurveyPoint remote = SurveyPoint.fromJson(row);
      final SurveyPoint? local = await (_db.select(_db.points)
            ..where((t) => t.id.equals(remote.id)))
          .getSingleOrNull();
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await _db.into(_db.points).insertOnConflictUpdate(remote.toCompanion());
      }
    }
  }

  /// Push direto (fallback/garantia) de um levantamento.
  Future<void> pushSurvey(Survey survey) async {
    if (!_canSync) return;
    final String? userId = _authService.currentUserId ?? survey.userId;
    if (userId == null) return;
    try {
      final data = survey.toJson()..['user_id'] = userId;
      await _client.from('surveys').upsert(data);
    } catch (e) {
      debugPrint('SyncService.pushSurvey falhou: $e');
    }
  }

  Future<void> pushPoint(SurveyPoint point) async {
    if (!_canSync) return;
    final String? userId = _authService.currentUserId ?? point.userId;
    if (userId == null) return;
    try {
      final data = point.toJson()..['user_id'] = userId;
      await _client.from('points').upsert(data);
    } catch (e) {
      debugPrint('SyncService.pushPoint falhou: $e');
    }
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    _manager?.dispose();
    if (identical(instance, this)) instance = null;
  }
}
