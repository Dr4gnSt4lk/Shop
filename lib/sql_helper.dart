import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper{
  static Future<void> createTables(sql.Database database) async{
    await database.execute("""CREATE TABLE products(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      description TEXT,
      price INTEGER,
      discount INTEGER,
      inStock TEXT,
      tags TEXT,
      rating REAL,
      image BLOB
    )"""

    );
  }


static Future<sql.Database> db() async {

  return sql.openDatabase(
    'shop.db',
    version: 1,
    onCreate: (sql.Database database, int version) async {
      print("Создание таблицы товаров");
      await createTables(database);
    },
  );
}

static Future<int> createItem(String title, String? description, int? price, int? discount, String? inStock, String? tags, double? rating, Uint8List? image) async {
  final db = await SQLHelper.db();

  final data = {
    'title': title,
    'description': description,
    'price': price,
    'discount': discount,
    'inStock': inStock,
    'tags': tags,
    'rating': rating,
    'image': image
  };

  final id = await db.insert('products', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  return id;
}
static Future<List<Map<String, dynamic>>> getItems() async{
  final db = await SQLHelper.db();
  return db.query('products', orderBy: "id");
}

static Future<List<Map<String, dynamic>>> getItem(int id) async{
  final db = await SQLHelper.db();
  return db.query('products', where: "id = ?", whereArgs: [id], limit: 1);
}

static Future<int> updateItem(int id, String title, String? description, int? price, int? discount, String? inStock, String? tags, double? rating, Uint8List? image) async {
  final db = await SQLHelper.db();

  final data = {
    'title': title,
    'description': description,
    'price': price,
    'discount': discount,
    'inStock': inStock,
    'tags': tags,
    'rating': rating,
    'image': image
  };

  final result = await db.update('products', data, where: "id = ?", whereArgs: [id]);
  return result;
}


static Future<void> deleteItem(int id) async {
  final db = await SQLHelper.db();
  try{
    await db.delete("products", where: "id = ?", whereArgs: [id]);
  }
  catch(err){
    debugPrint("Не получилось удалить товар: $err");
  }
}

static Future<List<Map<String, dynamic>>> searchByName(String title) async {
    final db = await SQLHelper.db();
    return await db.query('products', where: 'title LIKE ?', whereArgs: ['%$title%']);
  }
}