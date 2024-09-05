import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:http/http.dart' as http;

class Funcoes_Publicacoes_Imagens {
  static Future<void> criarTabela_Publicacoes_imagens(Database db) async {
    await criarPastaPublicacoesImagens();
    await db.execute('CREATE TABLE publicacao_imagem('
        'id INTEGER PRIMARY KEY,'
        'caminho_imagem TEXT,'
        'publicacao_id INTEGER,'
        'FOREIGN KEY (publicacao_id) REFERENCES publicacao(id))');
  }

  static Future<void> criarPastaPublicacoesImagens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/imagens_publicacoes');
      if (!(await imagesFolder.exists())) {
        await imagesFolder.create(recursive: true);
        print('Pasta DAS PUBBLICACOES criada em: ${imagesFolder.path}');
      } else {
        print('Pasta já existe: ${imagesFolder.path}');
      }
    } else {
      print('Permissão negada.');
    }
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
      print('Imagem dA PUBLICAÇAO baixada e salva em: $filePath');
    } else {
      print('Erro ao baixar imagem: $url');
    }
  }

  static Future<void> inserirImagem(Map<String, dynamic> dadosImagem) async {
    Database db = await DatabaseHelper.basededados;

    final directory = await getExternalStorageDirectory();
    final imagesFolder =
        Directory('${directory!.path}/ALL_IMAGES/imagens_publicacoes');

    if (!await imagesFolder.exists()) {
      await imagesFolder.create(recursive: true);
    }

    // Extrai o nome da imagem original da URL
    String nomeImagemOriginal = '';
    if (dadosImagem['caminho_imagem'] != null) {
      nomeImagemOriginal = basename(dadosImagem['caminho_imagem']);
    }

    // Define o caminho local onde a imagem será salva
    final String caminhoImagemLocal =
        '${imagesFolder.path}/publicacao_${dadosImagem['publicacao_id']}_$nomeImagemOriginal';

    if (dadosImagem['caminho_imagem'] != null) {
      await _downloadAndSaveImage(
          dadosImagem['caminho_imagem'], caminhoImagemLocal);
      dadosImagem['caminho_imagem'] = caminhoImagemLocal;
    }

    // Insere a imagem com o novo caminho na tabela 'publicacao_imagem'
    await db.insert('publicacao_imagem', dadosImagem,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> consultaPublicacoesImagens() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM publicacao_imagem');
  }

  Future<Map<String, dynamic>?> retorna_primeira_imagem(
      int idPublicacao) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'publicacao_imagem',
      where: 'publicacao_id = ?',
      whereArgs: [idPublicacao],
    );
    if (results.isNotEmpty) {
      String caminhoImagem = results.first['caminho_imagem'].toString();
      return {'caminho_imagem': caminhoImagem};
    }
    return null;
  }

  static Future<void> deleteImagensByPublicacaoId(int publicacaoId) async {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'publicacao_imagem',
      where: 'publicacao_id = ?',
      whereArgs: [publicacaoId],
    );
    print('Imagens da publicação $publicacaoId removidas com sucesso.');
  }

  Future<List<String>> consultaCaminhosImagensPorPublicacao(
      int idPublicacao) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'publicacao_imagem',
      columns: ['caminho_imagem'],
      where: 'publicacao_id = ?',
      whereArgs: [idPublicacao],
    );

    List<String> caminhosImagens =
        results.map((imagem) => imagem['caminho_imagem'] as String).toList();

    return caminhosImagens;
  }

  static Future<void> apagarTodasImagens() async {
    Database db = await DatabaseHelper.basededados;
    await db.delete('publicacao_imagem');
  }
}
