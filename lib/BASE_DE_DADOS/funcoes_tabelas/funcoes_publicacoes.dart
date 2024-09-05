import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Publicacoes {
  static Future<void> criarTabela_Publicacoes(Database db) async {
    await db.execute('CREATE TABLE publicacao('
        'id INTEGER PRIMARY KEY,'
        'nome TEXT,' //
        'local TEXT,'//
        'area_id INTEGER,'//
        'descricao_local TEXT,'//
        'topico_id INTEGER,'//
        'pagina_web TEXT,'//
        'data_publicacao TEXT,'//
        'telemovel TEXT,'//
        'email TEXT,'//
        'centro_id INTEGRER,'//
        'user_id INTEGER,'//
        'estado_publicacao TEXT,'//
        'FOREIGN KEY (user_id) REFERENCES usuario(id),'
        'FOREIGN KEY (centro_id) REFERENCES centros(id), '
        'FOREIGN KEY (topico_id) REFERENCES topicos(id),'
        'FOREIGN KEY (area_id) REFERENCES areas(id) )');
  }

  static Future<void> insertPublicacao(Map<String, dynamic> publicacao) async {
    Database db = await DatabaseHelper.basededados;

    await db.insert(
      'publicacao',
      publicacao,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  static Future<List<Map<String, dynamic>>> consultarPublicacoesPorAutor(int userId) async {
  Database db = await DatabaseHelper.basededados;

  // Busca todas as publicações criadas por um determinado usuário
  return await db.query(
    'publicacao', // Nome da tabela
    where: 'user_id = ?', // Condição para obter as publicações do autor
    whereArgs: [userId], // Substitui o '?' pelo valor de userId
  );
}


  Future<List<Map<String, dynamic>>> consultaPublicacoes() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM publicacao');
  }

  Future<List<Map<String, dynamic>>> consultaPublicacoesPorCentroId(int centroId) async {
  Database db = await DatabaseHelper.basededados;
  return await db.query(
    'publicacao',
    where: 'centro_id = ? AND estado_publicacao != ?', 
    whereArgs: [centroId, 'Por validar'], 
  );
}



  static Future<String> consultaNomeLocalPorId(int idLocal) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'publicacao',
      columns: ['nome'],
      where: 'id = ?',
      whereArgs: [idLocal],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['nome'];
    } else {
      return '';
    }
  }

  static Future<List<Map<String, dynamic>>> consultaDetalhesPublicacaoPorId(
      int idLocal) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'publicacao',
      where: 'id = ?',
      whereArgs: [idLocal],
    );
  }

  static Future<Map<String, dynamic>?> detalhes_por_id(int idLocal) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'publicacao',
      where: 'id = ?',
      whereArgs: [idLocal],
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<List<Map<String, dynamic>>> consultarPublicacoesPorIdTopico(
      int idTopico) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'publicacao',
      where: 'topico_id = ? AND estado_publicacao != ?',
      whereArgs: [idTopico, 'Por validar'],
    );
  }

  static Future<List<Map<String, dynamic>>> buscarPublicacoesPorNome(
      String nomePesquisa) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'publicacao',
      where: 'nome LIKE ?',
      whereArgs: ['%$nomePesquisa%'],
    );
  }

  static Future<Map<String, double>?> obter_cordenadada_pub(int idLocal) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> resultado = await db.query(
      'publicacao',
      columns: ['latitude', 'longitude'],
      where: 'id = ?',
      whereArgs: [idLocal],
    );

    if (resultado.isNotEmpty) {
      double? latitude = double.tryParse(resultado.first['latitude']);
      double? longitude = double.tryParse(resultado.first['longitude']);

      if (latitude != null && longitude != null) {
        return {'latitude': latitude, 'longitude': longitude};
      }
    }
    return null;
  }
    static Future<void> deletePublicacoesByCentroId(int centroId) async {
    
    Database db = await DatabaseHelper.basededados;

    // Excluir todas as publicações que possuem o centroId especificado
    await db.delete(
      'publicacao', // Nome da tabela
      where: 'centro_id = ?', // Condição para exclusão
      whereArgs: [centroId], // Substitui o '?' pelo valor do centroId
    );

   // print("Publicações com centro_id = $centroId deletadas com sucesso.");
  }
    static Future<int> contarPUBAtivosPorUsuario(int userId) async {
    Database db = await DatabaseHelper.basededados;

    // Faz a contagem de eventos cujo estado seja diferente de "Por validar" e que foram criados pelo usuário
    int? count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM publicacao WHERE user_id = ? AND estado_publicacao != ?',
      [userId, 'Por validar'],
    ));

    // Retorna o valor da contagem ou 0 se for null
    return count ?? 0;
  }

}

