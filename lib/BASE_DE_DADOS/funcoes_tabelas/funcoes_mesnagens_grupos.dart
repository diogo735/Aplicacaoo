// ignore_for_file: camel_case_types

import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Mensagens_Grupos {
  static Future<void> createMensagemGrupoTable(Database db) async {
    await db.execute('CREATE TABLE mensagem_dos_grupos('
        'id INTEGER PRIMARY KEY,'
        'grupo_id INTEGRER,'
        'user_id INTEGRER,'
        'texto_mensagem TEXT,'
        'dia INTEGRER,'
        'mes INTEGRER,'
        'hora INTEGRER,'
        'ano INTEGRER,'
        'segundos INTEGRER,'
        'minutos INTEGRER,'
        'FOREIGN KEY (user_id) REFERENCES user(id), '
        'FOREIGN KEY (grupo_id) REFERENCES grupo(id) '
        ')');
  }

  static Future<void> insertMensagemGrupo(Database db) async {

    
 await db.insert(
  'mensagem_dos_grupos',
  {
    'grupo_id': 1,
    'user_id': 1,
    'texto_mensagem': 'O saque é uma das jogadas mais importantes no tênis.',
    'dia': 15,
    'mes': 4,
    'ano': 2024,
    'hora': 16,
    'minutos': 17,
    'segundos': 0,
  },
);

await db.insert(
  'mensagem_dos_grupos',
  {
    'grupo_id': 1,
    'user_id': 2,
    'texto_mensagem': 'O backhand de duas mãos é mais comum entre os jogadores profissionais.',
    'dia': 16,
    'mes': 4,
    'ano': 2024,
    'hora': 17,
    'minutos': 18,
    'segundos': 0,
  },
);

await db.insert(
  'mensagem_dos_grupos',
  {
    'grupo_id': 1,
    'user_id': 3,
    'texto_mensagem': 'O tênis é um esporte muito exigente fisicamente.',
    'dia': 17,
    'mes': 4,
    'ano': 2024,
    'hora': 18,
    'minutos': 19,
    'segundos': 0,
  },
);

await db.insert(
  'mensagem_dos_grupos',
  {
    'grupo_id': 1,
    'user_id': 4,
    'texto_mensagem': 'A preparação mental é crucial para o sucesso no esporte.',
    'dia': 18,
    'mes': 4,
    'ano': 2024,
    'hora': 19,
    'minutos': 20,
    'segundos': 0,
  },
);

await db.insert(
  'mensagem_dos_grupos',
  {
    'grupo_id': 1,
    'user_id': 5,
    'texto_mensagem': 'A velocidade e a precisão são fundamentais no tênis.',
    'dia': 19,
    'mes': 4,
    'ano': 2024,
    'hora': 20,
    'minutos': 21,
    'segundos': 0,
  },
);


   

  }

  Future<List<Map<String, dynamic>>> consultaMensagemGrupoPorID(int grupoid) async {
  Database db = await DatabaseHelper.basededados;
  return await db.rawQuery('SELECT * FROM mensagem_dos_grupos WHERE grupo_id = ?', [grupoid]);
}

Future<void> inserirMensagemNoBancoDeDados({
  required int grupoId,
  required int userId,
  required String textoMensagem,
  required int hora,
  required int minutos,
  required int ano,
  required int segundos,
  required int dia,
  required int mes,
}) async {
  
  Database db = await DatabaseHelper.basededados;
  await db.insert(
      'mensagem_dos_grupos',
      {
        'grupo_id': grupoId,
        'user_id': userId,
        'texto_mensagem':
            textoMensagem,
        'dia ': dia,
        'mes ': mes,
        'segundos':segundos,
        'hora ': hora,
        'ano':ano,
        'minutos ': minutos
      },
    );
}

static Future<List<Map<String, dynamic>>> obterMensagensPorGrupoID(int grupoId) async {
  Database db = await DatabaseHelper.basededados;
  return await db.query(
    'mensagem_dos_grupos',
    where: 'grupo_id = ?',
    whereArgs: [grupoId],
  );
}


}
