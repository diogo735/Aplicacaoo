// ignore_for_file: camel_case_types

import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Foruns{
static Future<void> createForumTable(Database db) async {
    await db.execute(
        'CREATE TABLE forum(id INTEGER PRIMARY KEY, area_id INTEGRER, FOREIGN KEY (area_id) REFERENCES areas(id))');
  }

  static Future<void> insertForum(Database db) async {
     await db.insert(
    'forum',
    {
      'area_id': 1,
      
    },
  );
   await db.insert(
    'forum',
    {
      'area_id': 2,
    },
  );
  await db.insert(
    'forum',
    {
      'area_id': 3,
    },
  );
  await db.insert(
    'forum',
    {
      'area_id': 4,
    },
  );
  await db.insert(
    'forum',
    {
      'area_id': 5,
    },
  );
  await db.insert(
    'forum',
    {
      'area_id': 6,
    },
  );
  await db.insert(
    'forum',
    {
      'area_id': 7,
    },
  );
  
  }

 Future<List<Map<String, dynamic>>> consultaForum() async {
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM forum');
  }
  
 Future<int?> consultaForumPorArea(int areaId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> result = await db.query(
      'forum',
      where: 'area_id = ?',
      whereArgs: [areaId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return null;
    }
  }

}