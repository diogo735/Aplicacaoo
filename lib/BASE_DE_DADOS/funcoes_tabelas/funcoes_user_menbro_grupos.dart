import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

// ignore: camel_case_types
class Funcoes_User_menbro_grupos {
  static Future<void> createUsuariomenbrodegruposTable(Database db) async {
    await db.execute('CREATE TABLE usuario_menbro_grupo('
        'id INTEGER PRIMARY KEY, '
        'usuario_id INTEGER, '
        'grupo_id INTEGER, '
        'FOREIGN KEY (usuario_id) REFERENCES usuario(id), '
        'FOREIGN KEY (grupo_id) REFERENCES grupo(id)'
        ')');
  }

  static Future<void> insertUsuariomenbrodegrupos(Database db) async {
    await db.insert(
      'usuario_menbro_grupo',
      {'usuario_id': 1, 'grupo_id': 1},
    );
    await db.insert(
      'usuario_menbro_grupo',
      {'usuario_id': 2, 'grupo_id': 1},
    );
    await db.insert(
      'usuario_menbro_grupo',
      {'usuario_id': 3, 'grupo_id': 1},
    );
    await db.insert(
      'usuario_menbro_grupo',
      {'usuario_id': 4, 'grupo_id': 1},
    );
  }

  static Future<List<int>> obterGruposDoUsuario(int usuarioId) async {
    try {
      Database db = await DatabaseHelper.basededados;
      List<Map<String, dynamic>> results = await db.query(
        'usuario_menbro_grupo',
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
        columns: ['grupo_id'],
      );
      return results.map<int>((row) => row['grupo_id'] as int).toList();
    } catch (e) {
      print('Erro ao obter grupos do usuário: $e');
      return [];
    }
  }

  static Future<List<int>> obterUsuariosDoGrupo(int grupoId) async {
    try {
      Database db = await DatabaseHelper.basededados;
      List<Map<String, dynamic>> results = await db.query(
        'usuario_menbro_grupo',
        where: 'grupo_id = ?',
        whereArgs: [grupoId],
        columns: ['usuario_id'],
      );
      return results.map<int>((row) => row['usuario_id'] as int).toList();
    } catch (e) {
      print('Erro ao obter usuários do grupo: $e');
      return [];
    }
  }

static Future<void> removerUsuarioDoGrupo(int idUsuario, int idGrupo) async {
  try {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'usuario_menbro_grupo',
      where: 'usuario_id = ? AND grupo_id = ?',
      whereArgs: [idUsuario, idGrupo],
    );
    print('Usuário removido do grupo com sucesso!');
  } catch (error) {
    print('Erro ao remover usuário do grupo: $error');
  }
}

}
