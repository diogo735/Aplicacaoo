import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Usuarios {
  static Future<void> createUsuariosTable(Database db) async {
    await criarPastaUsuariosImagens();
    await db.execute('CREATE TABLE usuario('
        'id INTEGER PRIMARY KEY, '
        'nome TEXT, '
        'sobrenome TEXT, '
        'caminho_foto TEXT,'
        'caminho_fundo TEXT,'
        'sobre_min TEXT,'
        'centro_id INTEGER,'
        'FOREIGN KEY (centro_id) REFERENCES centros(id)'
        ')');
  }

  static Future<int> consultaCentroIdPorUsuarioId(int idUsuario) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      columns: ['centro_id'],
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['centro_id'] ?? 0;
    } else {
      return 0;
    }
  }

  static Future<void> insertUsuarios(Database db) async {
    await db.insert(
      'usuario',
      {
        'nome': 'Susana',
        'sobrenome': 'Carvalho',
        'caminho_foto': 'assets/images/pessoa5.jpg',
        'caminho_fundo': 'assets/images/fundo_susana.jpg',
        'centro_id': 5,
        'sobre_min':
            'Para mim, a neve não é apenas um clima, é uma paixão que aquece meu coração gelado! ❄️⛷️🏂 #AmoNeve #InvernoÉVida'
      },
    );

    /*
     await db.insert(
      'usuario',
      {
        'nome': 'Lucas',
        'sobrenome': 'Oliveira',
        'caminho_foto': 'assets/images/pessoa7.jpeg'
      },
    );
     await db.insert(
      'usuario',
      {
        'nome': 'Julia',
        'sobrenome': 'Matos',
        'caminho_foto': 'assets/images/pessoa8.jpg'
      },
    );
     
     await db.insert(
      'usuario',
      {
        'nome': 'Luara ',
        'sobrenome': 'Costa',
        'caminho_foto': 'assets/images/pessoa9.jpg'
      },
    );*/
  }

  static Future<void> criarPastaUsuariosImagens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/usuarios');
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

  static Future<void> insertUsuario(Map<String, dynamic> usuario) async {
    Database db = await DatabaseHelper.basededados;

    final directory = await getExternalStorageDirectory();
    final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/usuarios');

    // Use o ID do usuário para criar os nomes dos arquivos
    final String caminhoFotoLocal =
        '${imagesFolder.path}/fotodeperfil_user${usuario['id']}.jpg';
    final String caminhoFundoLocal =
        '${imagesFolder.path}/fundoperfil_user${usuario['id']}.jpg';

    await _downloadAndSaveImage(usuario['caminho_foto'], caminhoFotoLocal);
    await _downloadAndSaveImage(usuario['caminho_fundo'], caminhoFundoLocal);

    usuario['caminho_foto'] = caminhoFotoLocal;
    usuario['caminho_fundo'] = caminhoFundoLocal;

    await db.insert(
      'usuario',
      usuario,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> consultaUsuarios() async {
    //FAZ A CONSULTO DOS EVENTOS DA TABELA
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM usuario');
  }

  static Future<String> consultaNomeCompletoUsuarioPorId(int idUsuario) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      columns: ['nome', 'sobrenome'],
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      String nome = resultado.first['nome'];
      String sobrenome = resultado.first['sobrenome'];

      return '$nome $sobrenome';
    } else {
      return '';
    }
  }

  static Future<Map<String, dynamic>?> consultaUsuarioPorId(
      int idUsuario) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    } else {
      return null;
    }
  }

  static Future<String> consultaCaminhoFotoUsuarioPorId(int idUsuario) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      columns: ['caminho_foto'],
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['caminho_foto'];
    } else {
      return ''; // Retorna uma string vazia se não houver resultados
    }
  }

  static Future<String> consultaCaminhoFOTOFUNDOUsuarioPorId(
      int idUsuario) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'usuario',
      columns: ['caminho_fundo'],
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['caminho_fundo'];
    } else {
      return ''; // Retorna uma string vazia se não houver resultados
    }
  }

  static Future<String> obterSobreMimUsuarioPorId(int userId) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> results = await db.query(
      'usuario',
      where: 'id = ?',
      whereArgs: [userId],
      columns: ['sobre_min'],
    );
    if (results.isNotEmpty) {
      return results.first['sobre_min'];
    } else {
      return ' ';
    }
  }

  

}

