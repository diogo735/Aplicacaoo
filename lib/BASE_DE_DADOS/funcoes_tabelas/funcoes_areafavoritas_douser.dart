import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_AreasFavoritas {
  static Future<void> createAreasFavoritas_douserTable(Database db) async {
    await db.execute(
      'CREATE TABLE areas_favoritas('
        'id INTEGER PRIMARY KEY,'
        'usuario_id INTEGER,'
        'area_id INTEGER,'
        'FOREIGN KEY (usuario_id) REFERENCES usuario(id),'
        'FOREIGN KEY (area_id) REFERENCES areas(id))');
  }

  static Future<void> insertAreasFavoritas(Database db) async {
    //INSERE OS EVENTOS
    await db.insert(
      'areas_favoritas',
      {'usuario_id': 1, 'area_id ': 2},
    );
    await db.insert(
      'areas_favoritas',
      {'usuario_id': 1, 'area_id ': 3},
    );
    await db.insert(
      'areas_favoritas',
      {'usuario_id': 1, 'area_id ': 1},
    );
  }

  Future<List<Map<String, dynamic>>> consultaAreasFavoritas() async {
    //FAZ A CONSULTO DOS EVENTOS DA TABELA
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM areas_favoritas');
  }

  static Future<List<int>> obeter_areas_favoritas_do_userid(int usuarioId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'areas_favoritas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      columns: ['area_id'],
    );
    return results.map<int>((row) => row['area_id'] as int).toList();
  }
}
