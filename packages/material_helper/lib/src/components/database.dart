import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

export 'package:sqlite3/sqlite3.dart' show PreparedStatement, ResultSet;

extension on String {
  String overflow(int maxLength) {
    assert(maxLength > 3);
    maxLength -= 3;
    return length > maxLength ? "${substring(0, maxLength)}..." : this;
  }
}

class DatabaseValue {
  final bool isInitialized;

  DatabaseValue({this.isInitialized = false});

  DatabaseValue copyWith({bool? isInitialized}) =>
      DatabaseValue(isInitialized: isInitialized ?? this.isInitialized);
}

class Database {
  static Database? _instance;
  sqlite3.Database? _db;

  static DatabaseValue _value = DatabaseValue();
  static DatabaseValue get value => _value;

  Future<void> _load() async {
    _db = sqlite3.sqlite3.open(
      "${(await getApplicationDocumentsDirectory()).path}/database.db",
    );
  }

  Database._();

  void dispose() {
    _db?.dispose();
    _instance = null;
  }

  static Future<Database> get instance async {
    _instance ??= Database._();
    if (_instance!._db == null) await _instance!._load();
    _value = _value.copyWith(isInitialized: true);
    return _instance!;
  }

  Stream<double> backup(Database toDatabase, {int nPage = 5}) =>
      _db!.backup(toDatabase._db!, nPage: nPage);

  void execute(String sql, [List<Object?> parameters = const []]) =>
      _db!.execute(sql, parameters);

  sqlite3.PreparedStatement prepare(
    String sql, {
    bool persistent = false,
    bool vtab = true,
    bool checkNoTail = false,
  }) => _db!.prepare(
    sql,
    persistent: persistent,
    vtab: vtab,
    checkNoTail: checkNoTail,
  );

  List<sqlite3.PreparedStatement> prepareMultiple(
    String sql, {
    bool persistent = false,
    bool vtab = true,
  }) => _db!.prepareMultiple(sql, persistent: persistent, vtab: vtab);

  sqlite3.ResultSet select(String sql, [List<Object?> parameters = const []]) =>
      _db!.select(sql, parameters);
}

class KeyValueDatabase<K, V> {
  late String table;
  final Map<K, V> _data = {};

  Future<void> _checkTable() async {
    final matchingDatabases = (await Database.instance).select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    assert(
      matchingDatabases.length == 1,
      "Table must already exist before using KeyValueDatabase",
    );

    final structure = (await Database.instance).select(
      "PRAGMA table_info($table)",
    );
    final databaseKeys = structure.map((e) => e["name"] as String).toList();
    assert(
      databaseKeys.contains("key") && databaseKeys.contains("value"),
      "Table must have key and value columns",
    );
    assert(
      databaseKeys.length == 2,
      "Table must only have key and value columns and no others",
    );
  }

  Future<void> _loadData() async {
    final result = (await Database.instance).select("SELECT * FROM $table");
    for (final row in result) {
      print(row);
      assert(
        row["key"] is K,
        "Malformed key data in database:\n${row["key"].toString().overflow(21)} (type ${row["key"].runtimeType}) can't be cast onto $K",
      );
      assert(
        row["value"] is V,
        "Malformed value data in database:\n${row["value"].toString().overflow(21)} (type ${row["value"].runtimeType}) can't be cast onto $V",
      );
      _data[row["key"] as K] = row["value"] as V;
    }
  }

  Future<void> _storeData() async {
    for (final entry in _data.entries) {
      (await Database.instance).execute(
        "INSERT OR REPLACE INTO $table VALUES (?, ?)",
        [entry.key, entry.value],
      );
    }
  }

  KeyValueDatabase(this.table) {
    _checkTable();
    _loadData();
  }

  Future<V?> operator [](K key) async {
    await _loadData();
    return _data[key];
  }

  void operator []=(K key, V value) async {
    await awaitableSetter(key, value);
  }

  Future<void> awaitableSetter(K key, V value) async {
    _data[key] = value;
    await _storeData();
  }
}
