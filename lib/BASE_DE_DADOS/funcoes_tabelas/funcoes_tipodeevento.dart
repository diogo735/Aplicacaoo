import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_TipodeEvento{
static Future<void> create_TipodeEVENTO_Table(Database db) async {//CRIA A TABELA DE EVENTOS
    await db.execute(
        'CREATE TABLE tipo_evento(id INTEGER PRIMARY KEY, nome_tipo TEXT)');
  }

  static Future<void> insertipodeevento(Database db) async {//INSERE OS EVENTOS
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Conferencia'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Seminários'
      },
    );

    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Espétaculo'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Convenção'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Feira ou Festival'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Concerto'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Sessão'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Jantar'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Workshop'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Festa'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Corrida'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Torneio'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Jogo'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Caminhada'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Percurso'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'Atração'
      },
    );
    await db.insert(
      'tipo_evento',
      {
        'nome_tipo': 'outro'
      },
    );
 
  }

 Future<List<Map<String, dynamic>>> consultatipodeevento() async {//FAZ A CONSULTO DOS EVENTOS DA TABELA
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM tipo_evento');
  }
 
// Função para obter o nome do tipo de evento com base no ID do banco de dados
static Future<String> obterTipoEventoDoBancoDeDados(int id) async {
  
  Database db = await DatabaseHelper.basededados;

  final List<Map<String, dynamic>> maps = await db.query(
    'tipo_evento',
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return maps.first['nome_tipo'];
  } else {
    return 'Desconhecido';
  }
}
}