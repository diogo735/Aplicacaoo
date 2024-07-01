import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
// ignore: camel_case_types
class Funcoes_Grupos{

static Future<void> createGrupoTable(Database db) async {
    await db.execute(
        'CREATE TABLE grupo('
        'id INTEGER PRIMARY KEY,'
        'admintrador_id INTEGRER,'
        'nome TEXT,'
        'numero_participantes INTEGER,'
        'caminho_imagem TEXT,'
        'foto_de_capa TEXT,'
        'area_id INTEGRER,'
        'topico_id INTEGRER,'
        'dia_criacao INTEGRER,'
        'mes_criacao INTEGRER,'
        'ano_criacao INTEGRER,'
        'descricao_grupo TEXT,'
        'privacidade_grupo INTEGRER,'
        'FOREIGN KEY (area_id) REFERENCES areas(id),'
        'FOREIGN KEY (admintrador_id) REFERENCES usuario(id),'
        'FOREIGN KEY (topico_id) REFERENCES topicos(id)'
        ')'
        );
  }

static Future<void> insertGrupos(Database db) async {
   await db.insert(
    'grupo',
    {
      'nome': 'Ténis-Softinsa',
      'numero_participantes': 5,
      'caminho_imagem': 'assets/images/grupo_tenis.jpg',
      'foto_de_capa':'assets/images/imagens_grupos/tenis_1.png',
      'topico_id':2,
      'dia_criacao':1,
      'area_id':2,
      'mes_criacao':1,
      'ano_criacao': 2024,
      'admintrador_id':2,
      'privacidade_grupo':0,
      'descricao_grupo':'Ei, pessoal! Somos um grupo de colegas de trabalho apaixonados por tênis. Nos reunimos regularmente para jogar, relaxar e nos divertir fora do ambiente de trabalho.',
    },
  );/*
  await db.insert(
    'grupo',
    {
      'nome': 'Padel-Softinsa',
      'numero_participantes': 15,
      'caminho_imagem': 'assets/images/grupo_padel.png',
      'topico_id':1,
      'dia_criacao':15,
      'mes_criacao':5,
      'ano_criacao': 2020
    },
  );
  await db.insert(
    'grupo',
    {
      'nome': 'Grupo do Fut',
      'numero_participantes': 25,
      'caminho_imagem': 'assets/images/grupodofut.jpg',
      'topico_id':1,
      'dia_criacao':15,
      'mes_criacao':6,
      'ano_criacao': 2024
    },
  );
  await db.insert(
    'grupo',
    {
      'nome': 'Futebol 2',
      'numero_participantes': 35,
      'caminho_imagem': 'assets/images/futebol2.jpeg',
      'topico_id':1,
      'dia_criacao':25,
      'mes_criacao':11,
      'ano_criacao': 2024
    },
  );
 
  await db.insert(
    'grupo',
    {
      'nome': 'Amigos do pedal',
      'numero_participantes': 17,
      'caminho_imagem': 'assets/images/grupo_ciclismo.jpeg',
      'topico_id':3,
      'dia_criacao':3,
      'mes_criacao':3,
      'ano_criacao': 2023
    },
  );
*/

}

 static Future<Map<String, dynamic>?> obterGrupoPorId(int grupoId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'grupo',
      where: 'id = ?',
      whereArgs: [grupoId],
      columns: ['id','nome', 'numero_participantes', 'caminho_imagem','topico_id'],
    );
    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> consultaGrupos() async {
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM grupo');
  }

  static Future<Map<String, dynamic>?> detalhes_do_grupo(int grupoId) async {
  Database db = await DatabaseHelper.basededados;
  List<Map<String, dynamic>> results = await db.query(
    'grupo',
    where: 'id = ?',
    whereArgs: [grupoId],
  );
  if (results.isNotEmpty) {
    return results.first; 
  } else {
    return null;
  }
}
  static Future<int?> obterAdministradorId(int grupoId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'grupo',
      where: 'id = ?',
      whereArgs: [grupoId],
      columns: ['admintrador_id'],
    );
    if (results.isNotEmpty) {
      return results.first['admintrador_id'] as int?;
    } else {
      return null;
    }
  }

static Future<bool> atualizarNomeDoGrupo(int idGrupo, String novoNome) async {
  try {
    Database db = await DatabaseHelper.basededados;
    await db.update(
      'grupo',
      {'nome': novoNome},
      where: 'id = ?',
      whereArgs: [idGrupo],
    );
    
    return true; 
  } catch (error) {
   
    return false; 
  }
}


static Future<bool> atualizarDescricaoDoGrupo(int idGrupo, String novadescricao) async {
  try {
    Database db = await DatabaseHelper.basededados;
    await db.update(
      'grupo',
      {'descricao_grupo': novadescricao},
      where: 'id = ?',
      whereArgs: [idGrupo],
    );
    
    return true; 
  } catch (error) {
    
    return false; 
  }
}

 static Future<bool> atualizarPrivacidadeDoGrupo(int idGrupo, int novoValor) async {
    try {
      Database db = await DatabaseHelper.basededados;
      await db.update(
        'grupo',
        {'privacidade_grupo': novoValor},
        where: 'id = ?',
        whereArgs: [idGrupo],
      );
      return true; 
    } catch (error) {
      return false; 
    }
  }

Future<List<Map<String, dynamic>>> obterGruposPorArea(int idArea) async {
  Database db = await DatabaseHelper.basededados;
  List<Map<String, dynamic>> results = await db.query(
    'grupo',
    where: 'area_id = ?', 
    whereArgs: [idArea],
  );
  return results;
}


}
