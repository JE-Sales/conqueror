import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import "package:conqueror/history/scan_ds.dart";

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'scan_history.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE scans(id INTEGER PRIMARY KEY AUTOINCREMENT, thumbnailPath TEXT, textResult TEXT, dateTime TEXT)',
        );
      },
    );
  }

  Future<int> insertScan(Scan scan) async {
    final db = await database;
    return await db.insert('scans', scan.toMap());
  }

  Future<List<Scan>> getScans() async {
    final db = await database;
    final maps = await db.query('scans', orderBy: 'dateTime DESC');

    return List.generate(maps.length, (i) {
      return Scan(
        id: maps[i]['id'] as int,
        thumbnailPath: maps[i]['thumbnailPath'] as String,
        textResult: maps[i]['textResult'] as String,
        dateTime: maps[i]['dateTime'] as String,
      );
    });
  }

  Future<int> deleteScan(int id) async {
    final db = await database;
    return await db.delete(
      'scans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
