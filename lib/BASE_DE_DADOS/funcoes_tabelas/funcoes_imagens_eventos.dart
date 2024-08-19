import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Eventos_Imagens {
  static Future<void> criarTabela_Eventos_imagens(Database db) async {
    await criarPastaEventosImgens();
    await db.execute(
        'CREATE TABLE evento_imagem('
        'id INTEGER PRIMARY KEY,'
        'caminho_imagem TEXT,'
        'evento_id INTEGER,'
        'FOREIGN KEY (evento_id) REFERENCES evento(id))'
    );
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

static Future<void> criarPastaEventosImgens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/imagens_eventos');
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
 

 static Future<void> inserirImagem(Map<String, dynamic> dadosImagem) async {
    Database db = await DatabaseHelper.basededados;

    
    final directory = await getExternalStorageDirectory();
    final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/imagens_eventos');

   
    if (!await imagesFolder.exists()) {
      await imagesFolder.create(recursive: true);
    }

 // Extrai o nome da imagem original da URL
    String nomeImagemOriginal = '';
    if (dadosImagem['caminho_imagem'] != null) {
      nomeImagemOriginal = basename(dadosImagem['caminho_imagem']);
    }
    // Define o caminho local onde a imagem será salva
    final String caminhoImagemLocal = '${imagesFolder.path}/evento_${dadosImagem['evento_id']}_$nomeImagemOriginal';

    
    if (dadosImagem['caminho_imagem'] != null) {
      await _downloadAndSaveImage(dadosImagem['caminho_imagem'], caminhoImagemLocal);
      dadosImagem['caminho_imagem'] = caminhoImagemLocal;
    }

    // Insere a imagem com o novo caminho na tabela 'evento_imagem'
    await db.insert('evento_imagem', dadosImagem, conflictAlgorithm: ConflictAlgorithm.replace);
  }



  Future<List<Map<String, dynamic>>> consultaEventosImagens() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM evento_imagem');
  }

  Future<Map<String, dynamic>?> retorna_primeira_imagem_evento(int idEvento) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'evento_imagem',
      where: 'evento_id = ?',
      whereArgs: [idEvento],
    );
    return results.isNotEmpty ? results.first : null;
  }

    static Future<void> apagarTodasImagens() async {
      Database db = await DatabaseHelper.basededados;
    await db.delete('evento_imagem');
  }

  Future<List<String>> consultaCaminhosImagensPorEvento(int idEvento) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'evento_imagem',
      columns: ['caminho_imagem'], 
      where: 'evento_id = ?', 
      whereArgs: [idEvento], 
    );

    // Extrai os caminhos das imagens dos resultados da consulta
    List<String> caminhosImagens = results.map((imagem) => imagem['caminho_imagem'] as String).toList();
    
    return caminhosImagens;
  }
}
