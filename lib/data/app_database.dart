import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:syncable/syncable.dart';
import 'package:uuid/uuid.dart';

import '../models/point.dart';
import '../models/survey.dart';

part 'app_database.g.dart';

/// Banco local Drift. As tabelas seguem o contrato exigido por `syncable`:
/// `id`, `user_id`, `updated_at` e `deleted`.
@DriftDatabase(tables: [Surveys, Points])
class AppDatabase extends _$AppDatabase with SyncableDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'geofield',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 1;
}

@UseRowClass(Survey)
class Surveys extends Table implements SyncableTable {
  @override
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  @override
  TextColumn get userId => text().named('user_id').nullable()();

  @override
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(SurveyPoint)
class Points extends Table implements SyncableTable {
  @override
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  @override
  TextColumn get userId => text().named('user_id').nullable()();

  @override
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  TextColumn get surveyId => text().named('survey_id')();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  RealColumn get accuracy => real().nullable()();

  /// Valores usados: `manual` ou `automatic`.
  TextColumn get source => text()();

  DateTimeColumn get capturedAt => dateTime().named('captured_at')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Instância única do banco local, injetada nos repositórios das telas.
///
/// Mantida fora do ciclo de vida de um widget para que a navegação entre telas
/// preserve os mesmos dados offline.
final AppDatabase appDatabase = AppDatabase();
