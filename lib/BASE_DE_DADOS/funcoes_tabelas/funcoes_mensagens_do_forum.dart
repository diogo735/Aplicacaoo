// ignore_for_file: camel_case_types

import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Mensagens_foruns {
  static Future<void> createMensagemForumTable(Database db) async {
    await db.execute('CREATE TABLE mensagem_forum('
        'id INTEGER PRIMARY KEY,'
        'forum_id INTEGRER,'
        'user_id INTEGRER,'
        'texto_mensagem TEXT,'
        'dia INTEGRER,'
        'mes INTEGRER,'
        'hora INTEGRER,'
        'minutos INTEGRER,'
        'FOREIGN KEY (user_id) REFERENCES user(id), '
        'FOREIGN KEY (forum_id) REFERENCES forum(id) '
        ')');
  }

  static Future<void> insertMensagemForum(Database db) async {
    await db.insert(
      'mensagem_forum',
      {
        'forum_id': 2,
        'user_id': 2,
        'texto_mensagem':
            'O desempenho deste jogador está simplesmente incrível. Ele está dominando o campo!',
        'dia ': 15,
        'mes ': 4,
        'hora ': 16,
        'minutos ': 17
      },
    );
    await db.insert(
      'mensagem_forum',
      {
        'forum_id': 2,
        'user_id': 2,
        'texto_mensagem':
            'Essa partida está repleta de reviravoltas. Não consigo prever o que vai acontecer a seguir!',
        'dia ': 15,
        'mes ': 4,
        'hora ': 10,
        'minutos ': 1
      },
    );
    await db.insert(
      'mensagem_forum',
      {
        'forum_id': 2,
        'user_id': 2,
        'texto_mensagem':
            'É impressionante ver como a equipe está se recuperando após um início difícil',
        'dia ': 15,
        'mes ': 4,
        'hora ': 9,
        'minutos ': 9
      },
    );
    await db.insert(
      'mensagem_forum',
      {
        'forum_id': 2,
        'user_id': 2,
        'texto_mensagem':
            'Essa partida está repleta de reviravoltas. Não consigo prever o que vai acontecer a seguir!',
        'dia ': 1,
        'mes ': 5,
        'hora ': 1,
        'minutos ': 9
      },
    );
    await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem':
        'Essa partida está repleta de reviravoltas. Não consigo prever o que vai acontecer a seguir!',
    'dia': 1,
    'mes': 5,
    'hora': 1,
    'minutos': 9,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem':
        'O jogador marcou um gol espetacular! O estádio está em polvorosa!',
    'dia': 1,
    'mes': 5,
    'hora': 1,
    'minutos': 10,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem': 'Estou assistindo ao jogo com amigos. Que emoção!',
    'dia': 4,
    'mes': 5,
    'hora': 1,
    'minutos': 11,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem':
        'Está sendo uma partida muito disputada. Ambos os times estão jogando muito bem!',
    'dia': 5,
    'mes': 5,
    'hora': 1,
    'minutos': 12,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem': 'Golaço! O jogador acertou um chute de longa distância!',
    'dia': 5,
    'mes': 5,
    'hora': 1,
    'minutos': 13,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem':
        'A defesa do time visitante está fazendo um ótimo trabalho para evitar gols!',
    'dia': 5,
    'mes': 5,
    'hora': 1,
    'minutos': 14,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem': 'Estou torcendo muito pelo meu time favorito!',
    'dia': 5,
    'mes': 5,
    'hora': 1,
    'minutos': 15,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem': 'Esse jogo está eletrizante! Não consigo desgrudar os olhos da tela!',
    'dia': 5,
    'mes': 5,
    'hora': 1,
    'minutos': 16,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem': 'O time da casa está atacando com tudo em busca do gol!',
    'dia': 9,
    'mes': 5,
    'hora': 1,
    'minutos': 17,
  },
);

await db.insert(
  'mensagem_forum',
  {
    'forum_id': 2,
    'user_id': 2,
    'texto_mensagem': 'Foi marcada uma falta perigosa perto da área!',
    'dia': 9,
    'mes': 5,
    'hora': 1,
    'minutos': 18,
  },
);

  }

  Future<List<Map<String, dynamic>>> consultaMensagemForumPorForumId(int forumId) async {
  Database db = await DatabaseHelper.basededados;
  return await db.rawQuery('SELECT * FROM mensagem_forum WHERE forum_id = ?', [forumId]);
}

Future<void> inserirMensagemNoBancoDeDados({
  required int forumId,
  required int userId,
  required String textoMensagem,
  required int hora,
  required int minutos,
  required int dia,
  required int mes,
}) async {
  // Implemente a lógica para inserir a mensagem no banco de dados aqui
  
  Database db = await DatabaseHelper.basededados;
  await db.insert(
    'mensagem_forum',
    {
      'forum_id': forumId,
      'user_id': userId,
      'texto_mensagem': textoMensagem,
      'dia ': dia,
      'mes ': mes,
      'hora ': hora,
      'minutos ': minutos,
    },
  );
}


}
