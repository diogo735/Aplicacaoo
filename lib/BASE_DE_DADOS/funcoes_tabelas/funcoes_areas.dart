import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Areas{
static Future<void> createAreasTable(Database db) async {//CRIA A TABELA DE EVENTOS
    await db.execute(
        'CREATE TABLE areas(id INTEGER PRIMARY KEY, nome_area TEXT)');
  }

  static Future<void> insertAreas(Database db) async {//INSERE OS EVENTOS
    await db.insert(
      'areas',
      {
        'nome_area': 'Saúde'
      },
    );
  await db.insert(
      'areas',
      {
        'nome_area': 'Desporto'
      },
    );
    await db.insert(
      'areas',
      {
        'nome_area': 'Gastronomia'
      },
    );
    await db.insert(
      'areas',
      {
        'nome_area': 'Formação'
      },
    );
    await db.insert(
      'areas',
      {
        'nome_area': 'Alojamento'
      },
    );
    await db.insert(
      'areas',
      {
        'nome_area': 'Transportes'
      },
    );
    await db.insert(
      'areas',
      {
        'nome_area': 'Lazer'
      },
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
}