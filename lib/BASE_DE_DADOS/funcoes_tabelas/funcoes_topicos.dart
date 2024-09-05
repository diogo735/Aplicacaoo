import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:http/http.dart' as http;

class Funcoes_Topicos{
static Future<void> createTopicosTable(Database db) async {//CRIA A TABELA DE EVENTOS
   await criarPastatopicosImgens();
    await db.execute(
        'CREATE TABLE topicos(id INTEGER PRIMARY KEY, nome_topico TEXT,area_id INTEGER,topico_imagem TEXT)');
  }

static Future<void> _downloadAndSaveImage(String url, String filePath) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final File file = File(filePath);

      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      await file.writeAsBytes(bytes);
      print('Imagem baixada e salva em: $filePath');
    } else {
      print('Erro ao baixar imagem: $url');
    }
  }

static Future<void> criarPastatopicosImgens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/imagens_topicos');
      if (!(await imagesFolder.exists())) {
        await imagesFolder.create(recursive: true);
        print('Pasta criada em: ${imagesFolder.path}');
      } else {
        print('Pasta já existe: ${imagesFolder.path}');
      }
    } else {
      print('Permissão negada.');
    }
  }

   static Future<void> insertTopico(Map<String, dynamic> topico) async {
    Database db = await DatabaseHelper.basededados;

    final directory = await getExternalStorageDirectory();
    final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/imagens_topicos');

    // Use o ID do tópico para criar o nome do arquivo
    final String caminhoImagemLocal = '${imagesFolder.path}/topico_${topico['id']}.jpg';

    // Baixa e salva a imagem localmente
    await _downloadAndSaveImage(topico['topico_imagem'], caminhoImagemLocal);

    // Atualiza o caminho da imagem
    topico['topico_imagem'] = caminhoImagemLocal;

    await db.insert(
      'topicos',
      topico,
      conflictAlgorithm: ConflictAlgorithm.replace,
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

static Future<Map<String, String>> obterDadosTopico(int idTopico) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> resultado = await db.query(
      'topicos',
      where: 'id = ?',
      whereArgs: [idTopico],
    );
    
    if (resultado.isNotEmpty) {
      return {
        'nome': resultado.first['nome_topico'],
        'imagem': resultado.first['topico_imagem'],
      };
    } else {
      return {
        'nome': 'Desconhecido',
        'imagem': 'assets/images/sem_resultados.png',
      };
    }
  }
  static Future<Map<String, dynamic>> obterDadosTopicoEid(int idTopico) async {
  Database db = await DatabaseHelper.basededados;
  List<Map<String, dynamic>> resultado = await db.query(
    'topicos',
    where: 'id = ?',
    whereArgs: [idTopico],
  );
  
  if (resultado.isNotEmpty) {
    return {
      'id': resultado.first['id'].toString(),
      'nome': resultado.first['nome_topico'],
      'imagem': resultado.first['topico_imagem'],
      'area_id': resultado.first['area_id'].toString(),
    };
  } else {
    return {
      'id': '0',
      'nome': 'Desconhecido',
      'imagem': 'assets/images/sem_resultados.png',
      'area_id': '0',
    };
  }
}

}