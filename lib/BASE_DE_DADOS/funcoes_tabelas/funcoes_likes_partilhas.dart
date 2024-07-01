import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Likes_das_Partilhas {
  static Future<void> createPartilhasLikesTable(Database db) async {
    await db.execute('CREATE TABLE likes_das_partilhas('
        'id INTEGER PRIMARY KEY, '
        'id_usuario INTEGER, '
        'partilha_id INTEGER,'
        'FOREIGN KEY (id_usuario) REFERENCES usuario(id), '
        'FOREIGN KEY (partilha_id) REFERENCES partilha(id)'
        ')');
  }

  static Future<void> insertLikesPartilhas(Database db) async {
    await db.insert(
      'likes_das_partilhas',
      {
        'id_usuario': 3,
        'partilha_id ': 1,
      },
    );
    await db.insert(
      'likes_das_partilhas',
      {
        'id_usuario': 2,
        'partilha_id ': 1,
      },
    );
  }

 static Future<void> insertLike(Map<String, dynamic> like) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert('likes_das_partilhas', like);
  }

  static Future<void> deleteLikesByCentroId(int centroId) async {
    Database db = await DatabaseHelper.basededados;
    await db.delete('likes_das_partilhas',
        where: 'partilha_id IN (SELECT id FROM partilha WHERE centro_id = ?)',
        whereArgs: [centroId]);
  }

  Future<List<Map<String, dynamic>>> consultaLikesPartilhas() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM likes_das_partilhas');
  }

  Future<int> countLikesPorPartilha(int partilhaId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> likes = await db.rawQuery(
        'SELECT COUNT(*) FROM likes_das_partilhas WHERE partilha_id = ?',
        [partilhaId]);
    int? numLikes = Sqflite.firstIntValue(likes);
    return numLikes ?? 0;
  }

   static Future<void> userDaLike(int idUsuario, int idPartilha) async {
    try {
      Database db = await DatabaseHelper.basededados;
      await db.insert(
        'likes_das_partilhas',
        {
          'id_usuario': idUsuario,
          'partilha_id': idPartilha,
        },
      );
    } catch (e) {
      print('Erro ao inserir like na tabela: $e');
    }
  }

    static Future<void> userRemoveLike(int idUsuario, int idPartilha) async {
    try {
      Database db = await DatabaseHelper.basededados;
      await db.delete(
        'likes_das_partilhas',
        where: 'id_usuario = ? AND partilha_id = ?',
        whereArgs: [idUsuario, idPartilha],
      );
    } catch (e) {
      print('Erro ao remover like da tabela: $e');
    }
  }

   static Future<bool> verificarUserDeuLike(int idUsuario, int idPartilha) async {
    try {
      Database db = await DatabaseHelper.basededados;
      List<Map<String, dynamic>> result = await db.query(
        'likes_das_partilhas',
        where: 'id_usuario = ? AND partilha_id = ?',
        whereArgs: [idUsuario, idPartilha],
      );
      return result.isNotEmpty;
    } catch (e) {
      print('Erro ao verificar se o usuário deu like: $e');
      return false;
    }
  }
}
