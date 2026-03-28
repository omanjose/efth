import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await init();
    return _db!;
  }

  static Future<Database> init() async {
    final path = join(await getDatabasesPath(), 'favourites.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, v) {
        db.execute('''
CREATE TABLE fav(
key TEXT PRIMARY KEY,
id INTEGER,
title TEXT,
language TEXT,
lyrics TEXT,
audio TEXT
)
''');
      },
    );
  }
}
