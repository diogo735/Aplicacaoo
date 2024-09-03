import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Areas{
static Future<void> createAreasTable(Database db) async {//CRIA A TABELA DE EVENTOS
    await db.execute(
        'CREATE TABLE areas(id INTEGER PRIMARY KEY, nome_area TEXT)');
  }

  // Função para inserir uma área específica
   static Future<void> insertArea(Map<String, dynamic> area) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert(
      'areas',
      area,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

 Future<List<Map<String, dynamic>>> consultaAreas() async {//FAZ A CONSULTO DOS EVENTOS DA TABELA
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM areas');
  }
 
Future<String?> getNomeAreaPorId(int id) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> result = await db.query(
      'areas',
      columns: ['nome_area'],
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return result.first['nome_area'];
    } else {
      return null; 
    }
  }

  static Future<int?> getIdAreaPorNome(String nomeArea) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> result = await db.query(
      'areas',
      columns: ['id'],
      where: 'nome_area = ?',
      whereArgs: [nomeArea],
    );
    if (result.isNotEmpty) {
      return result.first['id'] as int?;
    } else {
      return null;
    }
  }
  static Future<void> clearTable() async {
    Database db = await DatabaseHelper.basededados;
    await db.delete('areas');
  }
}