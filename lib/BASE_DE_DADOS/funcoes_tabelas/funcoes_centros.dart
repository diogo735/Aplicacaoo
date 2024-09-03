import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Centros {
  static Future<void> createCentrosTable(Database db) async {
    await criarPastaCentrosImagens();
    await db.execute('CREATE TABLE centros('
        'id INTEGER PRIMARY KEY, '
        'nome TEXT, '
        'morada TEXT, '
        'imagem_centro TEXT)');
  }

  static Future<void> criarPastaCentrosImagens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/centros');
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

  static Future<void> insertCentro(Map<String, dynamic> centro) async {
    Database db = await DatabaseHelper.basededados;
    final directory = await getExternalStorageDirectory();
    final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/centros');
    final String caminhoImagemLocal =
        '${imagesFolder.path}/imagem_centro${centro['id']}.jpg';
    await _downloadAndSaveImage(centro['imagem_centro'], caminhoImagemLocal);

    centro['imagem_centro'] = caminhoImagemLocal;

    await db.insert(
      'centros',
      centro,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> consultaCentros() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM centros');
  }

  static Future<String> consultaNomeCentroPorId(int centroId) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'centros', // Nome da tabela
      columns: ['nome'], // Colunas que você deseja retornar
      where: 'id = ?', // Condição de filtro
      whereArgs: [centroId], // Argumento da condição de filtro
    );

    if (resultado.isNotEmpty) {
      return resultado.first['nome'] as String; // Retorna o nome do centro
    } else {
      return ''; // Retorna uma string vazia se não encontrar nenhum centro com o ID fornecido
    }
  }
}
