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


  Future<List<Map<String, dynamic>>> consultaAreasFavoritas() async {
    //FAZ A CONSULTO DOS EVENTOS DA TABELA
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM areas_favoritas');
  }

 static Future<void> insertAreaFavorita(Map<String, dynamic> data) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert(
      'areas_favoritas',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<void> clearTable() async {
    Database db = await DatabaseHelper.basededados;
    await db.delete('areas_favoritas');
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

  static Future<void> removeAreaFavorita(int usuarioId, int areaId) async {
    Database db = await DatabaseHelper.basededados;

    // Deleta a entrada que corresponde ao usuarioId e areaId fornecidos
    await db.delete(
      'areas_favoritas',
      where: 'usuario_id = ? AND area_id = ?',
      whereArgs: [usuarioId, areaId],
    );

    print('Área favorita removida com sucesso!');
  }
}
