import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Publicacoes_Horario {

  static Future<void> criarTabela_Publicacoes_horario(Database db) async {
    await db.execute('CREATE TABLE horarios_funcionamento('
        'id INTEGER PRIMARY KEY,'
        'publicacao_id INTEGER,'
        'dia_semana TEXT,'
        'hora_aberto TEXT,'
        'hora_fechar TEXT,'
        'FOREIGN KEY (publicacao_id) REFERENCES publicacao(id))');
  }

 static Future<void>  insertPublicacoes_horario(Database db) async {

    await db.insert(
      'horarios_funcionamento',
      {
        'publicacao_id': 1,
        'dia_semana': 'Segunda-feira',
        'hora_aberto': '08:00',
        'hora_fechar': '18:00',
      },
    );
    await db.insert(
      'horarios_funcionamento',
      {
        'publicacao_id': 1,
        'dia_semana':  'Terça-feira',
        'hora_aberto': '08:00',
        'hora_fechar': '18:00',
      },
    );
    await db.insert(
      'horarios_funcionamento',
      {
        'publicacao_id': 1,
        'dia_semana': 'Quarta-feira',
        'hora_aberto': '08:00',
        'hora_fechar': '18:00',
      },
    );
    await db.insert(
      'horarios_funcionamento',
      {
        'publicacao_id': 1,
        'dia_semana': 'Quinta-feira',
        'hora_aberto': '08:00',
        'hora_fechar': '18:00',
      },
    );
    await db.insert(
      'horarios_funcionamento',
      {
        'publicacao_id': 1,
        'dia_semana': 'Sexta-feira',
        'hora_aberto': '08:00',
        'hora_fechar': '18:00',
      },
    );
    await db.insert(
      'horarios_funcionamento',
      {
        'publicacao_id': 1,
        'dia_semana': 'Sábado',
        'hora_aberto': '09:00',
        'hora_fechar': '19:00',
      },
    );
    await db.insert(
      'horarios_funcionamento',
      {
        'publicacao_id': 1,
        'dia_semana':'Domingo',
        'hora_aberto': '10:00',
        'hora_fechar': '20:00',
      },
    );

 }

  Future<List<Map<String, dynamic>>> consultaPublicacoesHorario() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM horarios_funcionamento');
  }


   static Future<List<Map<String, dynamic>>> consultarHorariosPorPublicacao(int idPublicacao) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'horarios_funcionamento',
      where: 'publicacao_id = ?',
      whereArgs: [idPublicacao],
    );
  }
}
