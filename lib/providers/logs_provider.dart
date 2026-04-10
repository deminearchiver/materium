import 'package:drift/drift.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:materium/database/database.dart';
import 'package:materium/flutter.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

enum LogLevels { debug, info, warning, error }

class LogsProvider {
  LogsProvider._();

  AppDatabase get _database => AppDatabase.instance;

  Future<Log> add(String message, {LogLevels level = LogLevels.info}) async {
    final createdAt = DateTime.now();
    final data = await _database
        .into(_database.logs)
        .insertReturning(
          LogsCompanion.insert(
            level: level,
            message: message,
            createdAt: Value(createdAt),
          ),
        );
    if (kDebugMode) {
      debugPrint("${data.createdAt}: ${data.level.name}: ${data.message}");
    }
    return data;
  }

  MultiSelectable<Log> select({
    DateTime? before,
    DateTime? after,
    OrderingMode orderingMode = OrderingMode.desc,
  }) {
    final query = _database.select(_database.logs);
    if (before != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(before));
    }
    if (after != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(after));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: orderingMode),
    ]);
    return query;
  }

  Future<int> clear({DateTime? before, DateTime? after}) async {
    final query = _database.delete(_database.logs);
    if (before != null) {
      query.where((t) => t.createdAt.isSmallerOrEqualValue(before));
    }
    if (after != null) {
      query.where((t) => t.createdAt.isBiggerOrEqualValue(after));
    }
    final amount = await query.go();
    if (amount > 0) {
      await add(
        plural(
          "clearedNLogsBeforeXAfterY",
          amount,
          namedArgs: {"before": before.toString(), "after": after.toString()},
          name: "n",
        ),
      );
    }
    return amount;
  }

  Future<int> clearDefault() =>
      clear(before: DateTime.now().subtract(const Duration(days: 7)));

  static LogsProvider? _instance;

  static LogsProvider get instance {
    assert(_instance != null);
    return _instance!;
  }

  static Future<void> ensureInitialized({bool runDefaultClear = true}) async {
    if (_instance != null) return;

    final instance = LogsProvider._();

    if (runDefaultClear) {
      await instance.clearDefault();
    }

    try {
      final legacyDatabaseExists = await sqflite.databaseExists(
        _legacyDatabasePath,
      );
      if (legacyDatabaseExists) {
        await instance.add("Legacy database found, trying to purge.");

        // We clear the database before deletion just in case
        final legacyDatabase = await _openLegacyDatabase();
        await legacyDatabase.delete(_legacyDatabaseTable);
        await legacyDatabase.close();
        await instance.add("Legacy database was successfully cleared.");

        // Delete the legacy database
        await sqflite.databaseFactory.deleteDatabase(_legacyDatabasePath);
        await instance.add("Legacy database was successfully deleted.");
      } else {
        await instance.add("Legacy database not found.");
      }
    } on Object catch (e) {
      await instance.add(
        "Legacy database purge failed. $e",
        level: LogLevels.warning,
      );
    }

    _instance = instance;
  }

  static const String _legacyDatabasePath = "logs.db";
  static const String _legacyDatabaseTable = "logs";
  static const String _legacyDatabaseIdColumn = "_id";
  static const String _legacyDatabaseLevelColumn = "level";
  static const String _legacyDatabaseMessageColumn = "message";
  static const String _legacyDatabaseTimestampColumn = "timestamp";

  static Future<sqflite.Database> _openLegacyDatabase() => sqflite.openDatabase(
    _legacyDatabasePath,
    version: 1,
    onCreate: (db, version) async {
      await db.execute(
        "create table if not exists $_legacyDatabaseTable ("
        "  $_legacyDatabaseIdColumn integer primary key autoincrement,"
        "  $_legacyDatabaseLevelColumn integer not null,"
        "  $_legacyDatabaseMessageColumn text not null,"
        "  $_legacyDatabaseTimestampColumn integer not null"
        ")",
      );
    },
  );
}
