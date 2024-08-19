import 'dart:io';
import 'dart:typed_data';
import 'package:ficha3/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p; 
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Funcoes_Eventos {
  static Future<void> createEventoTable(Database db) async {
    await criarPastaEventosImgens();
    await db.execute('CREATE TABLE evento('
        'id INTEGER PRIMARY KEY,'
        'nome TEXT,'
        'dia_realizacao INTEGER,'
        'mes_realizacao INTEGER,'
        'ano_realizacao INTEGER,'
        'dia_fim INTEGER,'
        'mes_fim INTEGER,'
        'ano_fim INTEGER,'
        'horas_acaba TEXT,'
        'horas TEXT,'
        'caminho_imagem TEXT,'
        'latitude REAL,' // Campo adicionado
        'longitude REAL,' // Campo adicionado
        'area_id INTEGER,'
        'tipodeevento_id INTEGER,'
        'topico_id INTEGER,'
        'centro_id INTEGER,'
        'id_criador INTEGER,'
        'estado_evento TEXT,'
        'descricao_evento TEXT,'
        'FOREIGN KEY (topico_id) REFERENCES topicos(id), '
        'FOREIGN KEY (centro_id) REFERENCES centros(id), '
        'FOREIGN KEY (area_id) REFERENCES areas(id), '
        'FOREIGN KEY (id_criador) REFERENCES usuario(id),'
        'FOREIGN KEY (tipodeevento_id) REFERENCES tipo_evento(id)'
        ')');
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

  static Future<void> insertEvento(Map<String, dynamic> evento) async {
    Database db = await DatabaseHelper.basededados;

    final directory = await getExternalStorageDirectory();
    final imagesFolder =
        Directory('${directory!.path}/ALL_IMAGES/imagens_eventos');

    // Use o ID da partilha para criar o nome do arquivo
    final String caminhoImagemLocal =
        '${imagesFolder.path}/capa_do_evento_${evento['id']}.jpg';

    await _downloadAndSaveImage(evento['caminho_imagem'], caminhoImagemLocal);

    evento['caminho_imagem'] = caminhoImagemLocal;

    await db.insert(
      'evento',
      evento,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertEvents(Database db) async {
    final directory = await getExternalStorageDirectory();
    final imagesFolder =
        Directory('${directory!.path}/ALL_IMAGES/imagens_eventos');
    final String imagePath = '${imagesFolder.path}/evento_futebol.jpg';

    await db.insert(
      'evento',
      {
        'nome': 'Campeonato de Futebol',
        'dia_realizacao': 10,
        'mes_realizacao': 5,
        'ano_realizacao': 2024,
        'horas': '15:00',
        'local': 'Estadio Municipal do Fontelo',
        'caminho_imagem': imagePath,
        'latitude': 40.640506, // Exemplo de latitude
        'longitude': -8.653753, // Exemplo de longitude
        'area_id': 2,
        'topico_id': 1,
        'centro_id': 5,
        'id_criador': 1,
        'tipodeevento_id': 12,
      },
    );
  }

  Future<List<Map<String, dynamic>>> consultaEventos() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM evento');
  }

Future<List<Map<String, dynamic>>> consultaEventosPorArea(int areaId, int centroId) async {
  // Consulta ao banco de dados
  Database db = await DatabaseHelper.basededados;
  return await db.query(
    'evento',
    where: 'area_id = ? AND centro_id = ? AND estado_evento IN (?, ?)',
    whereArgs: [areaId, centroId, 'Ativa', 'Finalizada'],
  );
}



  Future<List<Map<String, dynamic>>> consultaEventosPorTopico(
      int topicoId) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'evento',
      where: 'topico_id = ? AND estado_evento IN (?, ?)',
      whereArgs: [topicoId, 'Ativa', 'Finalizada'],
    );
  }

  Future<List<Map<String, dynamic>>> consultaEventosPorCentroId(
      int centroId) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'evento',
      where: 'centro_id = ? AND estado_evento IN (?, ?)',
      whereArgs: [centroId, 'Ativa', 'Finalizada'],
    );
  }

 static Future<void> atualizarEvento(Map<String, dynamic> eventoAtualizado) async {
  Database db = await DatabaseHelper.basededados;

  // Verifique se o mapa contém o ID do evento a ser atualizado
  if (eventoAtualizado.containsKey('id')) {
    // Construa o caminho local para salvar a imagem da capa
    final directory = await getExternalStorageDirectory();
    final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/imagens_eventos');
    final String caminhoImagemLocal = '${imagesFolder.path}/capa_do_evento_${eventoAtualizado['id']}.jpg';

    // Baixe a imagem e salve no caminho local
    await _downloadAndSaveImage(eventoAtualizado['capa_imagem_evento'], caminhoImagemLocal);

    // Atualize o caminho da imagem no evento para o caminho local
    eventoAtualizado['capa_imagem_evento'] = caminhoImagemLocal;

    // Construa o mapa para atualizar o evento
    Map<String, dynamic> eventoMap = {
      'nome': eventoAtualizado['nome'],
      'dia_realizacao': DateTime.parse(eventoAtualizado['datainicioatividade']).day,
      'mes_realizacao': DateTime.parse(eventoAtualizado['datainicioatividade']).month,
      'ano_realizacao': DateTime.parse(eventoAtualizado['datainicioatividade']).year,
      'dia_fim': DateTime.parse(eventoAtualizado['datafimatividade']).day,
      'mes_fim': DateTime.parse(eventoAtualizado['datafimatividade']).month,
      'ano_fim': DateTime.parse(eventoAtualizado['datafimatividade']).year,
      'horas': DateTime.parse(eventoAtualizado['datainicioatividade'])
          .toIso8601String()
          .split('T')
          .last,
      'horas_acaba': DateTime.parse(eventoAtualizado['datafimatividade'])
          .toIso8601String()
          .split('T')
          .last,
      'caminho_imagem': eventoAtualizado['capa_imagem_evento'],
      'latitude': eventoAtualizado['latitude'],
      'longitude': eventoAtualizado['longitude'],
      'tipodeevento_id': eventoAtualizado['tipodeevento_id'],
      'topico_id': eventoAtualizado['topico_id'],
      'descricao_evento': eventoAtualizado['descricao_evento'],
    };

    // Atualize o evento no banco de dados local
    await db.update(
      'evento',
      eventoMap,
      where: 'id = ?',
      whereArgs: [eventoAtualizado['id']],
    );

    print('Evento atualizado localmente com sucesso!');
  } else {
    print('Erro: O mapa de evento não contém um ID válido.');
  }
}


  static Future<String> consultaNomeEventoPorId(int idEvento) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'evento',
      columns: ['nome'],
      where: 'id = ?', // Condição WHERE para filtrar por id_evento
      whereArgs: [idEvento], // Argumentos da condição WHERE
    );

    if (resultado.isNotEmpty) {
      // Se houver resultados, retorne o nome do evento
      return resultado.first['nome'];
    } else {
      // Se não houver resultados, retorne uma string vazia ou uma mensagem de erro
      return '';
    }
  }

  static Future<List<Map<String, dynamic>>> consultaDetalhesEventoPorId(
      int idEvento) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'evento',
      where: 'id = ?',
      whereArgs: [idEvento],
    );
  }

  static Future<Map<String, dynamic>?> consultaDetalhesEventoPorId2(
      int idEvento) async {
    Database db = await DatabaseHelper.basededados;
    List<Map<String, dynamic>> resultado = await db.query(
      'evento',
      where: 'id = ?',
      whereArgs: [idEvento],
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    } else {
      return null;
    }
  }

  static Future<int> contarEventosPorAutor(int autorId) async {
    Database db = await DatabaseHelper.basededados;

    int count = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM evento WHERE id_criador = ?', [autorId])) ??
        0;

    return count;
  }

  static Future<List<Map<String, dynamic>>> consultaEventosPorAutor(
      int autorId) async {
    Database db = await DatabaseHelper.basededados;

    List<Map<String, dynamic>> resultado = await db.query(
      'evento',
      where: 'id_criador = ?',
      whereArgs: [autorId],
    );

    return resultado;
  }

  static Future<void> deleteAllEventos() async {
    Database db = await DatabaseHelper.basededados;
    await db.delete('evento');
  }

  static getNumeroDeParticipantes(int idEvento) {}
}
