  // ignore_for_file: camel_case_types
  import 'package:sqflite/sqflite.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
  import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mensagens_do_forum.dart';


  class Funcoes_Foruns{
  static Future<void> createForumTable(Database db ) async {
      await db.execute(
          'CREATE TABLE forum(id INTEGER PRIMARY KEY, area_id INTEGRER, centro_id INTEGER, nome TEXT, estado TEXT, FOREIGN KEY (area_id) REFERENCES areas(id), FOREIGN KEY (centro_id) REFERENCES centros(id))');
    }

  Future<List<Map<String, dynamic>>> consultaForum() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM forum');
    }
    
Future<int?> consultaForumPorAreaECentro(int areaId, int centroId) async {
  Database db = await DatabaseHelper.basededados;

  // Executa a consulta para encontrar um fórum com base em area_id e centro_id
  List<Map<String, dynamic>> result = await db.query(
    'forum',
    where: 'area_id = ? AND centro_id = ?',
    whereArgs: [areaId, centroId],
    limit: 1,
  );

  if (result.isNotEmpty) {
    print('Consulta por área e centro: Fórum encontrado com ID ${result.first['id']}');
    return result.first['id'] as int;
  } else {
    print('Consulta por área e centro: Nenhum fórum encontrado para area_id $areaId e centro_id $centroId');
    return null;
  }
}

static Future<void> insertForum(Database db, Map<String, dynamic> forumData) async {
  await db.insert(
    'forum',
    {
      'id': forumData['id'],
      'area_id': forumData['area_id'],
      'centro_id': forumData['centro_id'],
      'nome': forumData['nome'],
      'estado': forumData['estado'],
    },
    conflictAlgorithm: ConflictAlgorithm.replace, // Para substituir caso o ID já exista
  );
  print("Fórum inserido: ${forumData['nome']} (ID: ${forumData['id']})");
}
static Future<void> apagarTodosForuns() async {
  Database db = await DatabaseHelper.basededados;
  
  // Apaga todos os fóruns da tabela 'forum'
  await db.delete('forum');
  
  print("Todos os fóruns foram apagados.");
}

Future<List<int>> consultaIdsDosForuns() async {
  Database db = await DatabaseHelper.basededados;
  
  // Executa uma query para buscar apenas os IDs dos fóruns
  List<Map<String, dynamic>> result = await db.query(
    'forum',
    columns: ['id'], // Busca apenas a coluna de ID
  );

  // Converte o resultado da query em uma lista de inteiros (IDs)
  List<int> forumIds = result.map((forum) => forum['id'] as int).toList();

  print('IDs dos fóruns encontrados: $forumIds');
  return forumIds;
}



  }