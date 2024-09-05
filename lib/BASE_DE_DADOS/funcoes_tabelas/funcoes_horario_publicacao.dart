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

  static Future<void> deleteHorariosByPublicacaoId(int publicacaoId) async {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'horarios_funcionamento',
      where: 'publicacao_id = ?',
      whereArgs: [publicacaoId],
    );
    print('Horários da publicação $publicacaoId removidos com sucesso.');
  }

  static Future<void> insertPublicacaoHorario(
      Map<String, dynamic> horario) async {
    Database db = await DatabaseHelper.basededados;

    await db.insert(
      'horarios_funcionamento',
      horario,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> consultaPublicacoesHorario() async {
    Database db = await DatabaseHelper.basededados;
    return await db.rawQuery('SELECT * FROM horarios_funcionamento');
  }

  static Future<List<Map<String, dynamic>>> consultarHorariosPorPublicacao(
      int idPublicacao) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'horarios_funcionamento',
      where: 'publicacao_id = ?',
      whereArgs: [idPublicacao],
    );
  }
}
