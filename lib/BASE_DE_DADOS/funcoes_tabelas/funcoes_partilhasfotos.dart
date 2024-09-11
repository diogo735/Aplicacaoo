import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Partilhas {
  static Future<void> createPartilhasTable(Database db) async {
    await criarPastaPartilhasImagens();
    await db.execute('''
      CREATE TABLE partilha(
        id INTEGER PRIMARY KEY,
        titulo TEXT,
        descricao TEXT,
        caminho_imagem TEXT,
        data TEXT,
        hora TEXT,
        id_usuario INTEGER,
        --id_evento INTEGER,
        --id_local INTEGER,
        area_id INTEGER,
        centro_id INTEGER,
        FOREIGN KEY (area_id) REFERENCES areas(id),
        FOREIGN KEY (centro_id) REFERENCES centros(id),
        FOREIGN KEY (id_usuario) REFERENCES usuario(id)
        -- FOREIGN KEY (id_evento) REFERENCES evento(id),
        -- FOREIGN KEY (id_local) REFERENCES publicacao(id)
      )
    ''');
  }

static Future<void> criarPastaPartilhasImagens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/partilhas');
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

 static Future<void> insertPartilha(Map<String, dynamic> partilha) async {
    Database db = await DatabaseHelper.basededados;

    final directory = await getExternalStorageDirectory();
    final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/partilhas');

    // Use o ID da partilha para criar o nome do arquivo
    final String caminhoImagemLocal = '${imagesFolder.path}/partilha_${partilha['id']}.jpg';

    await _downloadAndSaveImage(partilha['caminho_imagem'], caminhoImagemLocal);

    partilha['caminho_imagem'] = caminhoImagemLocal;

    await db.insert(
      'partilha',
      partilha,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertPartilhas(Database db) async {
    await db.insert(
      'partilha',
      {
        'titulo': 'A Torcida Mais Animada!!!🤣',
        'descricao': 'Aqui está um momento inesquecível como os topas de verdade! Que venham muitas mais aventuras como esta! 💪⚽️🎉',
        'caminho_imagem': 'assets/images/partilha1.png',
        'data': '30/04/2024', // Exemplo de data
        'hora': '14:00', // Exemplo de hora
        'id_usuario': 3, // Exemplo de ID do usuário
        'id_evento': null, // Exemplo de ID do evento associado (pode ser nulo)
        'id_local': 1,
        'area_id': 2,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'Basketebol é fiche',
        'descricao': 'A minha bola de basket',
        'caminho_imagem': 'assets/images/imagens_partilhasfotos/partilha_basket.jpg',
        'data': '12/01/2024', 
        'hora': '10:16', 
        'id_usuario': 2, 
        'id_evento':2, 
        'id_local': null,
        'area_id': 2,
      },
    );/*
    await db.insert(
      'partilha',
      {
        'titulo': ' O Jogo de Tênis que Encanta 🎾',
        'descricao': 'Descrição da Partilha 2',
        'caminho_imagem': 'assets/images/partilha2.png',
        'data': '16/06/2023', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 4, // Exemplo de ID do usuário
        'id_evento': 2, // Sem evento associado (pode ser nulo)
        'id_local': null,
        'area_id': 2,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'A pedalar com as amigas 😊',
        'descricao': 'Descrição da Partilha 3',
        'caminho_imagem': 'assets/images/partilha3.jpg',
        'data': '02/03/2024', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 5, // Exemplo de ID do usuário
        'id_evento': 3, // Sem evento associado (pode ser nulo)
        'id_local': null,
        'area_id': 2,
      },
    );

    await db.insert(
      'partilha',
      {
        'titulo': 'partilha saude 4',
        'descricao': 'Descrição da Partilha 4',
        'caminho_imagem': 'assets/images/partilha_saude.png',
        'data': '14/12/2023',
        'hora': '16:00',
        'id_usuario': 1,
        'id_evento': 5,
        'id_local': null,
        'area_id': 1,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'partilha gastronomia 5 ',
        'descricao': 'Descrição da Partilha 4',
        'caminho_imagem': 'assets/images/partilha_gastronomia.jpg',
        'data': '01/05/2024', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 2, // Exemplo de ID do usuário
        'id_evento': 6, // Sem evento associado (pode ser nulo)
        'id_local': null,
        'area_id': 3,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'partilha formaçao 6 ',
        'descricao': 'Descrição da Partilha 6',
        'caminho_imagem': 'assets/images/partilha_formacao.jpg',
        'data': '16/01/2024', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 1, // Exemplo de ID do usuário
        'id_evento': 7, // Sem evento associado (pode ser nulo)
        'id_local': null,
        'area_id': 4,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'partilha alojamento 7 ',
        'descricao': 'Descrição da Partilha 7',
        'caminho_imagem': 'assets/images/partilha_alojamento.jpg',
        'data': '19/01/2024', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 2, // Exemplo de ID do usuário
        'id_evento': null, // Sem evento associado (pode ser nulo)
        'id_local': 6,
        'area_id': 5,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'partilha transportes 8 ',
        'descricao': 'Descrição da Partilha 8',
        'caminho_imagem': 'assets/images/partilha_transportes.jpg',
        'data': '12/08/2023', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 1, // Exemplo de ID do usuário
        'id_evento': 9, // Sem evento associado (pode ser nulo)
        'id_local': null,
        'area_id': 6,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'partilha lazer 9',
        'descricao': 'Descrição da Partilha 9',
        'caminho_imagem': 'assets/images/partilha_lazer.jpg',
        'data': '16/09/2023', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 2, // Exemplo de ID do usuário
        'id_evento': null, // Sem evento associado (pode ser nulo)
        'id_local': 8,
        'area_id': 7,
      },
    );
    await db.insert(
      'partilha',
      {
        'titulo': 'Coorrida foi boa kkk!!',
        'descricao': 'Descrição da Partilha ',
        'caminho_imagem': 'assets/images/partilha_ciclismo.png',
        'data': '16/06/2023', // Exemplo de data
        'hora': '16:00', // Exemplo de hora
        'id_usuario': 2, // Exemplo de ID do usuário
        'id_evento': 3, // Sem evento associado (pode ser nulo)
        'id_local': null,
        'area_id': 2,
      },
    );*/
  }

 static Future<List<Map<String, dynamic>>> consultaPartilhas() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM partilha');
  }

  Future<List<Map<String, dynamic>>> consultaPartilhasComAreaId(
      int areaId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> partilhas = await db.query(
      'partilha',
      where: 'area_id = ?',
      whereArgs: [areaId],
    );
    return partilhas;
  }

Future<List<Map<String, dynamic>>> consultaPartilhasComAreaIdECentroId(
    int areaId, int centroId) async {
  Database db = await DatabaseHelper.basededados;
  List<Map<String, dynamic>> partilhas = await db.query(
    'partilha',
    where: 'area_id = ? AND centro_id = ?',
    whereArgs: [areaId, centroId],
  );
  return partilhas;
}

static Future<void> deleteAllPartilhas() async {
    Database db = await DatabaseHelper.basededados; 
    await db.delete('partilha');  
  }

Future<List<Map<String, dynamic>>> consultaPartilhasComCentroId(int centroId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> partilhas = await db.query(
      'partilha',
      where: 'centro_id = ?',
      whereArgs: [centroId],
    );
    return partilhas;
  }
  Future<Map<String, dynamic>> buscarDetalhesPartilha(int idPartilha) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'partilha',
      where: 'id = ?',
      whereArgs: [idPartilha],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      throw Exception('Nenhuma partilha encontrada com este id');
    }
  }
  Future<int> contarPartilhasPorUsuario(int idUsuario) async {
  Database db = await DatabaseHelper.basededados;
  
  // Faz uma consulta SQL para contar o número de partilhas do usuário
  List<Map<String, dynamic>> result = await db.rawQuery(
    'SELECT COUNT(*) as total FROM partilha WHERE id_usuario = ?',
    [idUsuario],
  );
  
  // O resultado será uma lista com um mapa contendo a chave 'total'
  int totalPartilhas = Sqflite.firstIntValue(result) ?? 0;

  return totalPartilhas;
}

}
