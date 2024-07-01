import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


class Funcoes_Eventos{
static Future<void> 
createEventoTable(Database db) async {//CRIA A TABELA DE EVENTOS
await criarPastaEventosImgens();
    await db.execute(
        'CREATE TABLE evento('
        'id INTEGER PRIMARY KEY,'
        'nome TEXT,' 
        'dia_realizacao INTEGRER,'
        'mes_realizacao INTEGER,'
        'ano_realizacao INTEGER,'
        'horas TEXT,'
        'local TEXT,'
        'numero_inscritos INTEGER,'
        'caminho_imagem TEXT,'
        'area_id INTEGRER,'
        'tipodeevento_id INTEGRER,'
        'topico_id INTEGRER,'
        'centro_id INTEGRER,'
        'FOREIGN KEY (topico_id) REFERENCES topicos(id), '
        'FOREIGN KEY (centro_id) REFERENCES centros(id), '
        'FOREIGN KEY (area_id) REFERENCES areas(id), '
        'FOREIGN KEY (tipodeevento_id) REFERENCES tipo_evento(id)'
        ')'
        );
  }



  static Future<void> criarPastaEventosImgens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final baseFolder = Directory('${directory!.path}/ALL_IMAGES');
      final imagesFolder = Directory('${baseFolder.path}/imagens_eventos');
      if (!(await imagesFolder.exists())) {
        await imagesFolder.create(recursive: true);
        print('Pasta criada em: ${imagesFolder.path}');

      await _copyInitialImage(imagesFolder.path);

      } else {
        print('Pasta já existe: ${imagesFolder.path}');
      }
    } else {
      print('Permissão negada.');
    }
  }

static Future<void> _copyInitialImage(String folderPath) async {
  final ByteData data = await rootBundle.load('assets/images/evento_fut.jpg');
  final List<int> bytes = data.buffer.asUint8List();
  final File file = File('$folderPath/evento_futebol.jpg');
  await file.writeAsBytes(bytes);
  print('íiiiiImagem inicial copiada para: ${file.path}');
}


 static Future<void> insertEvents(Database db) async {

  final directory = await getExternalStorageDirectory();
  final imagesFolder = Directory('${directory!.path}/ALL_IMAGES/imagens_eventos');
  final String imagePath = '${imagesFolder.path}/evento_futebol.jpg';
  

  await db.insert(
    'evento',
    {
      'nome': 'Campeonato de Futebol',
      'dia_realizacao': 10,
      'mes_realizacao': 5,
      'ano_realizacao': 2024,
      'horas': '15:00',
      'numero_inscritos': 26,
      'local': 'Estadio Municipal do Fontelo',
      'caminho_imagem': imagePath,
      'area_id': 2,
      'topico_id':1,
      'centro_id':5,
      'tipodeevento_id': 12,
    },
  );
  
  
}

 Future<List<Map<String, dynamic>>> consultaEventos() async {
  Database db = await DatabaseHelper.basededados;
   return await db.rawQuery('SELECT * FROM evento');
  }
 
 Future<List<Map<String, dynamic>>> consultaEventosPorArea(int areaId) async {
  Database db = await DatabaseHelper.basededados;
  return await db.query(
    'evento',
    where: 'area_id = ?', 
    whereArgs: [areaId], 
  );
}

 Future<List<Map<String, dynamic>>> consultaEventosPorTopico(int topicoId) async {
  Database db = await DatabaseHelper.basededados;
  return await db.query(
    'evento',
    where: 'topico_id = ?', 
    whereArgs: [topicoId], 
  );
}

Future<List<Map<String, dynamic>>> consultaEventosPorCentroId(int centroId) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'evento',
      where: 'centro_id = ?', 
      whereArgs: [centroId], 
    );
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

static Future<List<Map<String, dynamic>>> consultaDetalhesEventoPorId(int idEvento) async {
  Database db = await DatabaseHelper.basededados;
  return await db.query(
    'evento',
    where: 'id = ?', 
    whereArgs: [idEvento], 
  );
}


}