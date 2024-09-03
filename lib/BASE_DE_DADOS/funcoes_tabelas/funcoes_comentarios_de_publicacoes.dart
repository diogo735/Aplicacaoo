import 'package:sqflite/sqflite.dart';
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

  static Future<void> insertComentarios(Database db) async {
   /*
    await db.insert(
      'comentario_publicacao',
      {
        'classificacao': 4,
        'texto_comentario':
            'Estádio com bom campo e iluminação, só o ruim q alguns lugares ficam muito longe do campo assim atrapalhando a visão do jogo, principalmente atrás dos gols!',
        'data_comentario':'02/07/2023',
        'publicacao_id': 1,
        'user_id':5,
        
      },
    );
    await db.insert(
      'comentario_publicacao',
      {
        'classificacao': 5,
        'texto_comentario':
            'Estádio com bom campo e iluminação, só o ruim q alguns lugares ficam muito longe do campo assim atrapalhando a visão do jogo, principalmente atrás dos gols!',
        'data_comentario':'02/07/2023',
        'publicacao_id': 1,
        'user_id':5,
        
      },
    );*/
    await db.insert(
  'comentario_publicacao',
  {
    'classificacao': 3,
    'texto_comentario':
        'O estádio é bom, mas a iluminação poderia ser melhor. Alguns lugares têm uma visão obstruída do campo.',
    'data_comentario':'03/07/2023',
    'publicacao_id': 1,
    'user_id':2,
  },
);

await db.insert(
  'comentario_publicacao',
  {
    'classificacao': 2,
    'texto_comentario':
        'Não gostei do estádio, muito desconfortável e a visão do jogo é péssima em vários lugares.',
    'data_comentario':'04/07/2023',
    'publicacao_id': 1,
    'user_id':3,
  },
);
/*
await db.insert(
  'comentario_publicacao',
  {
    'classificacao': 4,
    'texto_comentario':
        'Excelente estádio! Ótima visão de jogo e boa infraestrutura.',
    'data_comentario':'05/07/2023',
    'publicacao_id': 1,
    'user_id':4,
  },
);

await db.insert(
  'comentario_publicacao',
  {
    'classificacao': 1,
    'texto_comentario':
        'Estádio precisa de melhorias urgentes. Péssima experiência de assistir ao jogo aqui.',
    'data_comentario':'06/07/2023',
    'publicacao_id': 1,
    'user_id':5,
  },
);

await db.insert(
  'comentario_publicacao',
  {
    'classificacao': 5,
    'texto_comentario':
        'Melhor estádio que já visitei! Tudo perfeito, desde a visão até o conforto.',
    'data_comentario':'07/07/2023',
    'publicacao_id': 1,
    'user_id':1,
  },
);

   */

   
  }

  Future<List<Map<String, dynamic>>> consultaComentarios() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM comentario_publicacao');
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

static Future<void> inserir_comentario_feito_pelo_user(
    int idUser,
    int classificacao,
    String texto,
    String data,
    int idPublicacao,
  ) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert(
      'comentario_publicacao',
      {
        'user_id': idUser,
        'classificacao': classificacao,
        'texto_comentario': texto,
        'data_comentario': data,
        'publicacao_id': idPublicacao,
      },
    );
  }

}
