import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Comentarios_das_Partilhas {
  static Future<void> createPartilhasComentariosTable(Database db) async {
    await db.execute('CREATE TABLE comentairos_das_partilhas('
        'id INTEGER PRIMARY KEY, '
        'id_usuario INTEGER, '
        'partilha_id INTEGER,'
        'texto_comentario TEXT,'
        'data_comentario TEXT,'
        'hora_comentario TEXT,'
        'FOREIGN KEY (id_usuario) REFERENCES usuario(id), '
        'FOREIGN KEY (partilha_id) REFERENCES partilha(id)'
        ')');
  }

  static Future<void> insertComentairiosPartilhas(Database db) async {
    await db.insert(
    'comentairos_das_partilhas',
    {
      'id_usuario': 2, 
      'partilha_id': 1, 
      'texto_comentario': 'Que foto incrível! Vamos lá, time!',
      'data_comentario': '3/05/2024', 
      'hora_comentario': '18:30', 
    },
  );
  await db.insert(
    'comentairos_das_partilhas',
    {
      'id_usuario': 4, 
      'partilha_id': 1, 
      'texto_comentario': 'Essa torcida está animada demais! Vai ser uma grande vitória!',
      'data_comentario': '1/05/2024', 
      'hora_comentario': '18:35', 
    },
  );
  await db.insert(
    'comentairos_das_partilhas',
    {
      'id_usuario': 5, 
      'partilha_id': 1, 
      'texto_comentario': 'Estamos com vocês até o fim! Vamos lá!',
      'data_comentario': '23/05/2024', 
      'hora_comentario': '01:15', 
    },
  );
  }

   static Future<void> insertComentario(Map<String, dynamic> comentario) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert(
      'comentairos_das_partilhas',
      comentario,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  
  static Future<void> deleteComentariosByPartilhaId(int partilhaId) async {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'comentairos_das_partilhas',
      where: 'partilha_id = ?',
      whereArgs: [partilhaId],
    );
  }

  Future<List<Map<String, dynamic>>> consultaComentairosPartilhas() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM comentairos_das_partilhas');
  }

  Future<List<Map<String, dynamic>>> consultaComentariosPorPartilha(int idPartilha) async {
    try {
      Database db = await DatabaseHelper.basededados;
      return await db.query(
        'comentairos_das_partilhas',
        where: 'partilha_id = ?',
        whereArgs: [idPartilha],
      );
    } catch (e) {
      print('Erro ao consultar comentários da partilha: $e');
      return [];
    }
  }

 static Future<void> criarComentario(int idUsuario, int idPartilha, String textoComentario,BuildContext context) async {
  try {
    Database db = await DatabaseHelper.basededados;


 String dataFormatada = DateFormat('dd/MM/yyyy').format(DateTime.now());

    // Formate a hora atual
    String horaFormatada = TimeOfDay.now().format(context as BuildContext);

    await db.insert(
      'comentairos_das_partilhas',
      {
        'id_usuario': idUsuario,
        'partilha_id': idPartilha,
        'texto_comentario': textoComentario,
        'data_comentario': dataFormatada,
        'hora_comentario': horaFormatada,
      },
    );
  } catch (e, stackTrace) {
    print('Erro ao criar comentário: $e\n$stackTrace');
    throw Exception('Erro ao criar comentário: $e');
  }
}

}
