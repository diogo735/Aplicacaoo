import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Topicos{
static Future<void> createTopicosTable(Database db) async {//CRIA A TABELA DE EVENTOS
    await db.execute(
        'CREATE TABLE topicos(id INTEGER PRIMARY KEY, nome_topico TEXT,area_id INTEGER,topico_imagem TEXT)');
  }

  static Future<void> insertTopicos(Database db) async {//INSERE OS EVENTOS
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Futebol',
        'topico_imagem': 'assets/images/icons_dos_topicos/bola.png',
        'area_id':2,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Ténis',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_tenis.png',
        'area_id':2,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Ciclismo',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_ciclismo.png',
        'area_id':2,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Nutricção',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_nutricao.png',
        'area_id':1,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Festival',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_festival.png',
        'area_id':3,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Cursos',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_cursos.png',
        'area_id':4,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Feiras',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_feiras.png',
        'area_id':5,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Mobilidade',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_mobilidade.png',
        'area_id':6,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Feiras',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_feira_turismo.png',
        'area_id':7,
      },
    );
    await db.insert(
      'topicos',
      {
        'nome_topico': 'Padle',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_padel.png',
        'area_id':2,
      },
    );
     await db.insert(
      'topicos',
      {
        'nome_topico': 'Ginásios',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_ginasio.png',
        'area_id':2,
      },
    );
     await db.insert(
      'topicos',
      {
        'nome_topico': 'Fitness',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_fitness.png',
        'area_id':2,
      },
    );
     await db.insert(
      'topicos',
      {
        'nome_topico': 'Basketball',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_basket.png',
        'area_id':2,
      },
    );
     await db.insert(
      'topicos',
      {
        'nome_topico': 'Voleibol',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_voleibol.png',
        'area_id':2,
      },
    );
     await db.insert(
      'topicos',
      {
        'nome_topico': 'Atletismo',
        'topico_imagem': 'assets/images/icons_dos_topicos/topico_atletismo.png',
        'area_id':2,
      },
    );

  
  }

 Future<List<Map<String, dynamic>>> consultaTopicos() async {//FAZ A CONSULTO DOS EVENTOS DA TABELA
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM topicos');
  }
 
 static Future<String> getCaminhoImagemDoTopico(int topicoId) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'topicos',
      columns: ['topico_imagem'],
      where: 'id = ?',
      whereArgs: [topicoId],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['topico_imagem'];
    } else {
      return ''; // retorna uma string vazia
    }
  }

  static Future<String?> obternomedoTopico(int topicoId) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'topicos',
      columns: ['nome_topico'],
      where: 'id = ?',
      whereArgs: [topicoId],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['nome_topico'];
    } else {
      return null; // Retorna null 
    }
  }

Future<List<Map<String, dynamic>>> consultaTopicosPorArea(int areaId) async {
  Database db = await DatabaseHelper.basededados;
  List<Map<String, dynamic>> topicos = await db.query(
    'topicos',
    where: 'area_id = ?',
    whereArgs: [areaId],
  );
  return topicos;
}

}