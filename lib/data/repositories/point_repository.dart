import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/point.dart';
import '../../services/auth_service.dart';
import '../app_database.dart';
import '../sync_service.dart';

/// CRUD local dos pontos de um levantamento sobre o Drift.
///
/// Sem login real, `userId` fica null no banco local. Isso é aceito pelo Drift,
/// mas a sincronização com o Supabase exige `AuthService.currentUserId`.
class PointRepository {
  PointRepository(
    this._db, {
    AuthService? authService,
    Uuid? uuid,
    SyncService? syncService,
  })  : _authService = authService ?? AuthService(),
        _uuid = uuid ?? const Uuid(),
        _syncService = syncService ?? SyncService.instance;

  final AppDatabase _db;
  final AuthService _authService;
  final Uuid _uuid;
  final SyncService? _syncService;

  /// Pontos ativos de um levantamento, na ordem em que foram capturados.
  Stream<List<SurveyPoint>> watchPointsBySurvey(String surveyId) {
    final query = _db.select(_db.points)
      ..where(
        (row) => row.surveyId.equals(surveyId) & row.deleted.equals(false),
      )
      ..orderBy([
        (row) => OrderingTerm.asc(row.capturedAt),
        (row) => OrderingTerm.asc(row.createdAt),
      ]);
    return query.watch();
  }

  /// Insere um ponto. `source` deve ser `manual` ou `automatic`.
  Future<SurveyPoint> addPoint({
    required String surveyId,
    required double lat,
    required double lng,
    required double accuracy,
    required String source,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final SurveyPoint point = SurveyPoint(
      id: _uuid.v4(),
      userId: _authService.currentUserId,
      surveyId: surveyId,
      latitude: lat,
      longitude: lng,
      accuracy: accuracy,
      source: source,
      capturedAt: now,
      createdAt: now,
      updatedAt: now,
      deleted: false,
    );
    await _db.into(_db.points).insert(point.toCompanion());
    await _syncService?.pushPoint(point);
    return point;
  }

  /// Exclusão lógica: nunca remove a linha do banco.
  Future<void> softDeletePoint(String id) async {
    await (_db.update(_db.points)..where((row) => row.id.equals(id))).write(
      PointsCompanion(
        deleted: const Value(true),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    final point = await (_db.select(_db.points)..where((r) => r.id.equals(id)))
        .getSingleOrNull();
    if (point != null) await _syncService?.pushPoint(point);
  }
}
