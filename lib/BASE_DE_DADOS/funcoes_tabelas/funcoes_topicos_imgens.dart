import 'package:sqflite/sqflite.dart';

import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Topicos_imagens{
static Future<void> createTopicosImagensTable(Database db) async {
    await db.execute(
        'CREATE TABLE topicos_imagens(id INTEGER PRIMARY KEY, topico_id INTEGER,topico_imagem TEXT,FOREIGN KEY (topico_id) REFERENCES topicos(id))');
  }

  static Future<void> insertTopicosImagens(Database db) async {
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 1,
        'topico_imagem':'assets/images/images_dos_topicos/fut_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 1,
        'topico_imagem':'assets/images/images_dos_topicos/fut_2.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 1,
        'topico_imagem':'assets/images/images_dos_topicos/fut_3.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 2,
        'topico_imagem':'assets/images/images_dos_topicos/tenis_3.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 2,
        'topico_imagem':'assets/images/images_dos_topicos/tenis_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 2,
        'topico_imagem':'assets/images/images_dos_topicos/tenis_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 3,
        'topico_imagem':'assets/images/images_dos_topicos/ciclismo_3.png',
      },
    );await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 3,
        'topico_imagem':'assets/images/images_dos_topicos/ciclismo_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 3,
        'topico_imagem':'assets/images/images_dos_topicos/ciclismo_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 4,
        'topico_imagem':'assets/images/images_dos_topicos/nutricao_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 4,
        'topico_imagem':'assets/images/images_dos_topicos/nutricao_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 4,
        'topico_imagem':'assets/images/images_dos_topicos/nutricao_3.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 5,
        'topico_imagem':'assets/images/images_dos_topicos/festival_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 5,
        'topico_imagem':'assets/images/images_dos_topicos/festival_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 5,
        'topico_imagem':'assets/images/images_dos_topicos/festival_3.png',
      },
    );
await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 6,
        'topico_imagem':'assets/images/images_dos_topicos/cursos_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 6,
        'topico_imagem':'assets/images/images_dos_topicos/cursos_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 6,
        'topico_imagem':'assets/images/images_dos_topicos/cursos_3.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 7,
        'topico_imagem':'assets/images/images_dos_topicos/feiras_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 7,
        'topico_imagem':'assets/images/images_dos_topicos/feiras_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 7,
        'topico_imagem':'assets/images/images_dos_topicos/feiras_3.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 8,
        'topico_imagem':'assets/images/images_dos_topicos/mobilidade_1.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 8,
        'topico_imagem':'assets/images/images_dos_topicos/mobilidade_2.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 8,
        'topico_imagem':'assets/images/images_dos_topicos/mobilidade_3.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 9,
        'topico_imagem':'assets/images/images_dos_topicos/feiras_aloj_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 9,
        'topico_imagem':'assets/images/images_dos_topicos/feiras_aloj_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 9,
        'topico_imagem':'assets/images/images_dos_topicos/feiras_aloj_3.png',
      },
    );
await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 10,
        'topico_imagem':'assets/images/images_dos_topicos/padle_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 10,
        'topico_imagem':'assets/images/images_dos_topicos/padle_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 10,
        'topico_imagem':'assets/images/images_dos_topicos/padle_3.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 11,
        'topico_imagem':'assets/images/images_dos_topicos/ginasios_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 11,
        'topico_imagem':'assets/images/images_dos_topicos/ginasios_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 11,
        'topico_imagem':'assets/images/images_dos_topicos/ginasios_3.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 12,
        'topico_imagem':'assets/images/images_dos_topicos/fitness_3.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 12,
        'topico_imagem':'assets/images/images_dos_topicos/fitness_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 12,
        'topico_imagem':'assets/images/images_dos_topicos/fitness_1.png',
      },
    );
  await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 13,
        'topico_imagem':'assets/images/images_dos_topicos/basket_1.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 13,
        'topico_imagem':'assets/images/images_dos_topicos/basket_2.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 13,
        'topico_imagem':'assets/images/images_dos_topicos/basket_3.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 14,
        'topico_imagem':'assets/images/images_dos_topicos/voleibol_1.png',
      },
    );
     await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 14,
        'topico_imagem':'assets/images/images_dos_topicos/voleibol_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 14,
        'topico_imagem':'assets/images/images_dos_topicos/voleibol_3.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 15,
        'topico_imagem':'assets/images/images_dos_topicos/atletismo_2.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 15,
        'topico_imagem':'assets/images/images_dos_topicos/atletismo_1.png',
      },
    );
    await db.insert(
      'topicos_imagens',
      {
        
        'topico_id': 15,
        'topico_imagem':'assets/images/images_dos_topicos/atletismo_3.png',
      },
    );
  }

 Future<List<Map<String, dynamic>>> consultaTopicosImagens() async {
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM topicos_imagens');
  }
 
 Future<List<Map<String, dynamic>>> consultaImagensPorTopico(
      int idTopico) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query('topicos_imagens',
        where: 'topico_id = ?', whereArgs: [idTopico]);
  }

}