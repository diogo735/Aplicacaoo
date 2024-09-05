import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Comentarios_Publicacoes {
  static Future<void> criarTabela_Publicacoes_comentarios(Database db) async {
    await db.execute('CREATE TABLE comentario_publicacao('
        'id INTEGER PRIMARY KEY,'
        'user_id INTEGER,'
        'data_comentario TEXT,'
        'classificacao INTEGER,'
        'texto_comentario TEXT,'
        'publicacao_id INTEGER,'
        'FOREIGN KEY (user_id) REFERENCES usuario(id),'
        'FOREIGN KEY (publicacao_id) REFERENCES publicacao(id) )');
  }

 
 static Future<void> deletarComentarioPorId(int idComentario) async {
    Database db = await DatabaseHelper.basededados;

    await db.delete(
      'comentario_publicacao', // Nome da tabela de comentários
      where: 'id = ?',
      whereArgs: [idComentario],
    );

    print("Comentário $idComentario deletado com sucesso do banco local.");
  }
  
  Future<List<Map<String, dynamic>>> consultaComentarios() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM comentario_publicacao');
  }

static Future<void> deleteComentariosPorCentroId(int centroId) async {
    Database db = await DatabaseHelper.basededados;

    // 1. Buscar as publicações associadas ao centro
    List<Map<String, dynamic>> publicacoes = await db.query(
      'publicacao',
      where: 'centro_id = ?',
      whereArgs: [centroId],
      columns: ['id'], // Só precisamos do ID das publicações
    );

    // Se não houver publicações associadas ao centro, retorne
    if (publicacoes.isEmpty) {
      print("Nenhuma publicação encontrada para o centro com ID $centroId.");
      return;
    }

    // 2. Obter uma lista de IDs das publicações encontradas
    List<int> publicacaoIds = publicacoes.map((pub) => pub['id'] as int).toList();

    // 3. Excluir os comentários associados às publicações encontradas
    await db.delete(
      'comentario_publicacao',
      where: 'publicacao_id IN (${publicacaoIds.join(', ')})',
    );

    //print("Comentários excluídos para publicações do centro com ID $centroId.");
  }

Future<List<Map<String, dynamic>>> consultaComentariosPorPublicacao(int idPublicacao) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'comentario_publicacao',
      where: 'publicacao_id = ?',
      whereArgs: [idPublicacao],
    );
  }

  Future<Map<String, dynamic>?> consultaComentarioPorId(int idComentario) async {
  Database db = await DatabaseHelper.basededados;
  List<Map<String, dynamic>> resultados = await db.query(
    'comentario_publicacao',
    where: 'id = ?',
    whereArgs: [idComentario],
  );
  if (resultados.isNotEmpty) {
    return resultados.first;
  } else {
    return null;
  }
}

static Future<void> inserir_comentario_feito_pelo_user({
  required int idComentario,  // Agora aceita o ID do comentário explicitamente
  required int idUser,
  required int classificacao,
  required String texto,
  required String data,
  required int idPublicacao,
}) async {
  Database db = await DatabaseHelper.basededados;

  await db.insert(
    'comentario_publicacao',
    {
      'id': idComentario,  // Inserir o ID do comentário
      'user_id': idUser,
      'classificacao': classificacao,
      'texto_comentario': texto,
      'data_comentario': data,
      'publicacao_id': idPublicacao,
    },
    conflictAlgorithm: ConflictAlgorithm.replace, // Caso haja conflito de IDs, substituir
  );
}


  

}
