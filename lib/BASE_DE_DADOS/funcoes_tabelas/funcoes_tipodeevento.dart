import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_TipodeEvento{
static Future<void> create_TipodeEVENTO_Table(Database db) async {//CRIA A TABELA DE EVENTOS
 await criarPastatipodeevetnoImgens();
    await db.execute(
        'CREATE TABLE tipo_evento(id INTEGER PRIMARY KEY, nome_tipo TEXT,caminho_imagem TEXT)');
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

  static Future<void> criarPastatipodeevetnoImgens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/imagens_tipo_evento');
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
  static Future<void> insertipodeevento(Map<String, dynamic> tipo_evento) async {//INSERE OS EVENTOS
 
    Database db = await DatabaseHelper.basededados;

    final directory = await getExternalStorageDirectory();
    final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/imagens_tipo_evento');

    // Use o ID da partilha para criar o nome do arquivo
    final String caminhoImagemLocal = '${imagesFolder.path}/tipo_${tipo_evento['id']}.jpg';

    await _downloadAndSaveImage(tipo_evento['caminho_imagem'], caminhoImagemLocal);

    tipo_evento['caminho_imagem'] = caminhoImagemLocal;

    await db.insert(
      'tipo_evento',
      tipo_evento,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  
  }



 Future<List<Map<String, dynamic>>> consultatipodeevento() async {//FAZ A CONSULTO DOS EVENTOS DA TABELA
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM tipo_evento');
  }
 

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

static Future<Map<String, String>> obterDadosTipoEventoComleto(int idTipoEvento) async {
  // Conectar ao banco de dados
  Database db = await DatabaseHelper.basededados;


  List<Map<String, dynamic>> resultado = await db.query(
    'tipo_evento',
    where: 'id = ?',
    whereArgs: [idTipoEvento],
  );

  // Verificar se o resultado não está vazio
  if (resultado.isNotEmpty) {
    // Retornar os dados em um Map<String, String>
    return {
      'nome_tipo': resultado.first['nome_tipo'] ?? 'Desconhecido',
      'caminho_imagem': resultado.first['caminho_imagem'] ?? '',
    };
  } else {
   
    return {
      'nome_tipo': 'Desconhecido',
      'caminho_imagem': '',
    };
  }
}



static Future<Map<String, String>> obterDadosTipoEvento(int id) async {
  Database db = await DatabaseHelper.basededados;

  final List<Map<String, dynamic>> maps = await db.query(
    'tipo_evento',
    columns: ['nome_tipo', 'caminho_imagem'],
    where: 'id = ?',
    whereArgs: [id],
  );

  if (maps.isNotEmpty) {
    return {
      "nome": maps.first['nome_tipo'],
      "imagem": maps.first['caminho_imagem'] ?? 'assets/images/sem_resultados.png'
    };
  } else {
    return {
      "nome": "Desconhecido",
      "imagem": "assets/images/sem_resultados.png"
    };
  }
}

}
