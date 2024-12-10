import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storedge/models/history.dart';
import 'package:storedge/models/itemmodel.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  DatabaseHelper._internal();

  static Database? _database;

  // Constants for database configuration
  static const String _databaseName = 'database.db';
  static const int _version = 9;

  // Table and column names
  static const String _tableItems = 'Items';
  static const String _colId = 'id';
  static const String _colName = 'name';
  static const String _colDescription = 'description';
  static const String _colPrice = 'price';
  static const String _colCategory = 'category';
  static const String _colImage = 'image';
  static const String _colStock = 'stock';

  static const String _tableHistory = 'History';
  static const String _colIdHistory = 'id';
  static const String _colTypeHistory = 'type';
  static const String _colAmountHistory = 'amount';
  static const String _colDateHistory = 'date';
  static const String _colItemId = 'item_id';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return openDatabase(path, version: _version, onCreate: (db, version) {
      db.execute('''
          CREATE TABLE IF NOT EXISTS $_tableItems (
            $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colName TEXT NOT NULL,
            $_colDescription TEXT NOT NULL,
            $_colPrice REAL NOT NULL,
            $_colCategory TEXT NOT NULL,
            $_colImage TEXT NOT NULL,
            $_colStock INTEGER NOT NULL
          )
        ''');

      db.execute('''
          CREATE TABLE IF NOT EXISTS $_tableHistory (
            $_colIdHistory INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colTypeHistory INTEGER NOT NULL,
            $_colAmountHistory INTEGER NOT NULL,
            $_colDateHistory INTEGER NOT NULL,
            $_colItemId INTEGER NOT NULL
          )
        ''');
    }, onUpgrade: (db, newVersion, oldVersion) {
      db.execute('''
          CREATE TABLE IF NOT EXISTS $_tableItems (
            $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_colName TEXT NOT NULL,
            $_colDescription TEXT NOT NULL,
            $_colPrice REAL NOT NULL,
            $_colCategory TEXT NOT NULL,
            $_colImage TEXT NOT NULL,
            $_colStock INTEGER NOT NULL
          )
        ''');
    });
  }

  Future<List<ItemModel>> getAllItems() async {
    final db = await database;
    final result = await db.query(_tableItems);
    return result.map((json) => ItemModel.fromJson(json)).toList();
  }

  Future<ItemModel> getItemById(int id) async {
    final db = await database;
    final result = await db.query(
      _tableItems,
      where: '$_colId = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return ItemModel.fromJson(result.first);
    }
    throw Exception('Item with ID $id not found');
  }

  Future<void> insertItem(ItemModel item) async {
    final db = await database;
    await db.insert(_tableItems, item.toJson());
  }

  Future<int> updateItem(int id, ItemModel item) async {
    item.id = id;
    final db = await database;
    return db.update(
      _tableItems,
      item.toJson(),
      where: '$_colId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return db.delete(
      _tableItems,
      where: '$_colId = ?',
      whereArgs: [id],
    );
  }

  Future<List<History>> getHistory(int itemId) async {
    final db = await database;
    final result = await db.query(
      _tableHistory,
      where: '$_colItemId = ?',
      whereArgs: [itemId],
    );

    if (result.isEmpty) return [];
    return result.map((row) => History.fromJson(row)).toList();
  }

  Future<void> insertHistory(History history) async {
    final db = await database;
    await db.insert(_tableHistory, history.toJson());
  }

  Future<int> updateHistory(History history) async {
    final db = await database;
    return db.update(
      _tableHistory,
      history.toJson(),
      where: '$_colId = ?',
      whereArgs: [history.id],
    );
  }

  Future<int> deleteHistory(int id) async {
    final db = await database;
    return db.delete(
      _tableHistory,
      where: '$_colId = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
