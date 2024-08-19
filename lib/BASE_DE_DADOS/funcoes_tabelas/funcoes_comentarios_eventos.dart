import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Comentarios_Eventos {
  static Future<void> criarTabela_Eventos_Comentarios(Database db) async {
    await db.execute('CREATE TABLE comentario_evento('
        'id INTEGER PRIMARY KEY,'
        'user_id INTEGER,'
        'data_comentario TEXT,'
        'classificacao INTEGER,'
        'texto_comentario TEXT,'
        'evento_id INTEGER,'
        'FOREIGN KEY (user_id) REFERENCES usuario(id),'
        'FOREIGN KEY (evento_id) REFERENCES evento(id) )');
  }

  static Future<void> inserirComentarios(Database db) async {
    // Exemplo de inserção de um comentário para um evento
    await db.insert(
      'comentario_evento',
      {
        'classificacao': 4,
        'texto_comentario': 'Ótimo evento, muito bem organizado!',
        'data_comentario': '05/07/2023',
        'evento_id': 1,
        'user_id': 1,
      },
    );
  }
  
   static Future<void> deletarComentarioPorId(int idComentario) async {
    Database db = await DatabaseHelper.basededados;

    await db.delete(
      'comentario_evento',
      where: 'id = ?',
      whereArgs: [idComentario],
    );
  }
static Future<void> insertComentarioEvento(Map<String, dynamic> comentario) async {
    Database db = await DatabaseHelper.basededados; 
    await db.insert('comentario_evento', comentario);
  }


  Future<List<Map<String, dynamic>>> consultaComentarios() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM comentario_evento');
  }

 static Future<void> deleteAllcomentarios() async {
    Database db = await DatabaseHelper.basededados; 
    await db.delete('comentario_evento');  
  }
   static Future<List<Map<String, dynamic>>> consultaComentariosPorEvento(int idEvento) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'comentario_evento',
      where: 'evento_id = ?',
      whereArgs: [idEvento],
    );
  }

  Future<Map<String, dynamic>?> consultaComentarioPorId(int idComentario) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> resultados = await db.query(
      'comentario_evento',
      where: 'id = ?',
      whereArgs: [idComentario],
    );
    if (resultados.isNotEmpty) {
      return resultados.first;
    } else {
      return null;
    }
  }

  static Future<void> inserir_comentario_feito_pelo_user(
      int idUser,
      int classificacao,
      String texto,
      String data,
      int idEvento,
    ) async {
      Database db = await DatabaseHelper.basededados;
      await db.insert(
        'comentario_evento',
        {
          'user_id': idUser,
          'classificacao': classificacao,
          'texto_comentario': texto,
          'data_comentario': data,
          'evento_id': idEvento,
        },
      );
    }
}
