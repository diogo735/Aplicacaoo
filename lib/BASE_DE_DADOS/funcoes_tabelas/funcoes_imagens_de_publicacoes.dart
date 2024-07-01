import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Publicacoes_Imagens{
static Future<void> criarTabela_Publicacoes_imagens(Database db) async {
    await db.execute(
        'CREATE TABLE publicacao_imagem('
        'id INTEGER PRIMARY KEY,'
        'caminho_imagem TEXT,'
        'publicacao_id INTEGER,'
        'FOREIGN KEY (publicacao_id) REFERENCES publicacao(id))'
        );
  }

 static Future<void> insertPublicacoes_imagens(Database db) async {
     await db.insert(
      'publicacao_imagem',
      {
      'caminho_imagem':'assets/images/imagens_local/fontelo_1.jpg',
      'publicacao_id':1
      },
    ); 
    await db.insert(
      'publicacao_imagem',
      {
      'caminho_imagem':'assets/images/imagens_local/fontelo_2.png',
      'publicacao_id':1
      },
    ); 
     await db.insert(
      'publicacao_imagem',
      {
      'caminho_imagem':'assets/images/imagens_local/fontelo_3.png',
      'publicacao_id':1
      },
    ); 
     await db.insert(
      'publicacao_imagem',
      {
      'caminho_imagem':'assets/images/imagens_local/fontelo_4.png',
      'publicacao_id':1
      },
    ); 
     await db.insert(
      'publicacao_imagem',
      {
      'caminho_imagem':'assets/images/imagens_local/fontelo_5.png',
      'publicacao_id':1
      },
    ); 
     await db.insert(
      'publicacao_imagem',
      {
      'caminho_imagem':'assets/images/imagens_local/fontelo_6.png',
      'publicacao_id':1
      },
    ); 
    await db.insert(
      'publicacao_imagem',
      {
      'caminho_imagem':'assets/images/campodefutbol.jpg',
      'publicacao_id':2
      },
    ); 
   
  }

   Future<List<Map<String, dynamic>>> consultaPublicacoesImagens() async {
   Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM publicacao_imagem');
  }

Future<Map<String, dynamic>?> retorna_primeira_imagem(int idPublicacao) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'publicacao_imagem',
      where: 'publicacao_id = ?',
      whereArgs: [idPublicacao],
    );
    return results.isNotEmpty ? results.first : null;
  }


}