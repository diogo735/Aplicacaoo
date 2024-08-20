import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:sqflite/sqflite.dart';

class Funcoes_TopicosFavoritos {
  static Future<void> createTopicosFavoritosUserTable(Database db) async {
    await db.execute(
      'CREATE TABLE topicos_favoritos_user('
        'id INTEGER PRIMARY KEY,'
        'usuario_id INTEGER,'
        'topico_id INTEGER,'
        'FOREIGN KEY (usuario_id) REFERENCES usuario(id),'
        'FOREIGN KEY (topico_id) REFERENCES topicos(id))');
  }
 static Future<void> insertTopicoFavorito(Map<String, dynamic> data) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert(
      'topicos_favoritos_user',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<List<Map<String, dynamic>>> consultaTopicosFavoritos() async {
    // FAZ A CONSULTA DOS TÓPICOS FAVORITOS DA TABELA
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM topicos_favoritos_user');
  }


  

  static Future<List<int>> obeter_topicos_favoritos_do_userid(int usuarioId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'topicos_favoritos_user',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      columns: ['topico_id'],
    );
    return results.map<int>((row) => row['topico_id'] as int).toList();
  }
  static Future<void> clearTable() async {
    Database db = await DatabaseHelper.basededados;
    await db.delete('topicos_favoritos_user');
  }

    static Future<void> removeTopicoFavorito(int usuarioId, int topicoId) async {
    // Abre a base de dados
    Database db = await DatabaseHelper.basededados;

    // Executa a exclusão com base no usuário e no tópico
    await db.delete(
      'topicos_favoritos_user',  // Nome da tabela onde os tópicos favoritos estão armazenados
      where: 'usuario_id = ? AND topico_id = ?',  // Condição para a exclusão
      whereArgs: [usuarioId, topicoId],  // Argumentos para a condição
    );
  }
}
