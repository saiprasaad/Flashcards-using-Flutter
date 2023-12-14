import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String _databaseName = 'decks.db';
  static const int _databaseVersion = 1;
  bool exists = false;

  DBHelper._();
  static final DBHelper _singleton = DBHelper._();
  factory DBHelper() => _singleton;
  Database? _database;
  get db async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);
    print(dbPath);
    // await deleteDatabase(dbPath);
    var db = await openDatabase(dbPath,
        version: _databaseVersion, // used for migrations

        // called when the database is first created
        onCreate: (Database db, int version) async {
      // create the customer table
      await db.execute('''
          CREATE TABLE decks(
            id INTEGER PRIMARY KEY,
            title TEXT
          )
        ''');

      // create the purchase_order table (can't use "order" as it's a keyword)
      await db.execute('''
          CREATE TABLE cards(
            id INTEGER PRIMARY KEY,
            question TEXT,
            answer TEXT,
            decksId  INTEGER,
            FOREIGN KEY (decksId) REFERENCES decks(id)
          )
        ''');
    });
    return db;
  }

  Future<bool> checkIfDBExists() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);
    return await databaseExists(dbPath);
  }

  // fetch records from a table with an optional "where" clause
  Future<List<Map<String, dynamic>>> query(String table,
      {String? where}) async {
    final db = await this.db;
    return where == null ? db.query(table) : db.query(table, where: where);
  }

  // insert a record into a table
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    int id = await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // update a record in a table
  Future<void> update(String table, Map<String, dynamic> data) async {
    final db = await this.db;
    await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  // delete a record from a table
  Future<void> deleteFlashCardByDeckId(String table, int deckId) async {
    final db = await this.db;
    await db.delete(
      table,
      where: 'decksId = ?',
      whereArgs: [deckId],
    );
  }

    Future<void> delete(String table, int id) async {
    final db = await this.db;
    await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<int, int>> getCountOfCards() async {
    final db = await this.db;
    var result = await db.rawQuery(
        "SELECT decksId, COUNT(id) as cardCount FROM cards GROUP BY decksId");
    Map<int, int> countsMap = {
      for (var e in result) e['decksId']: e['cardCount']
    };
    return countsMap;
  }
}
