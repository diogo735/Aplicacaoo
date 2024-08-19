import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class Funcoes_Participantes_Evento {
  static Future<void> createParticipantesEventoTable(Database db) async {
    
    await db.execute('''
      CREATE TABLE lista_participantes_evento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        evento_id INTEGER NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuario(id) ,
        FOREIGN KEY (evento_id) REFERENCES evento(id) 
      )
    ''');
  }

 

  static Future<void> inscreverUsuarioEmEvento(int usuarioId, int eventoId) async {
    Database db = await DatabaseHelper.basededados;
    await db.insert('lista_participantes_evento', {
      'usuario_id': usuarioId,
      'evento_id': eventoId
    });
  }

  static Future<List<int>> getParticipantesEvento(int eventoId) async {
    Database db = await DatabaseHelper.basededados;
    final List<Map<String, dynamic>> resultado = await db.query(
      'lista_participantes_evento',
      columns: ['usuario_id'],
      where: 'evento_id = ?',
      whereArgs: [eventoId]
    );
    return resultado.map((row) => row['usuario_id'] as int).toList();
  }

  static Future<void> removerParticipanteEvento(int usuarioId, int eventoId) async {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'lista_participantes_evento',
      where: 'usuario_id = ? AND evento_id = ?',
      whereArgs: [usuarioId, eventoId]
    );
    print("Usuário removido do evento com sucesso.");
  }

static Future<int> getNumeroDeParticipantes(int eventoId) async {
    Database db = await DatabaseHelper.basededados;
    final List<Map<String, dynamic>> resultado = await db.query(
      'lista_participantes_evento',
      columns: ['usuario_id'],
      where: 'evento_id = ?',
      whereArgs: [eventoId]
    );
    return resultado.length;
  }
  
  static Future<List<Map<String, dynamic>>> getEventosInscritoDoUsuario(int usuarioId) async {
    Database db = await DatabaseHelper.basededados;
    return await db.query(
      'lista_participantes_evento',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId]
    );
  }
  static Future<void> deleteAllParticipantes() async {
    Database db = await DatabaseHelper.basededados; 
    await db.delete('lista_participantes_evento');  
  }
  static Future<bool> verificarInscricaoUsuarioEvento(int usuarioId, int eventoId) async {
    Database db = await DatabaseHelper.basededados;
    final List<Map<String, dynamic>> resultado = await db.query(
      'lista_participantes_evento',
      columns: ['id'],  
      where: 'usuario_id = ? AND evento_id = ?',
      whereArgs: [usuarioId, eventoId],
      limit: 1  
    );

    return resultado.isNotEmpty;  // Retorna true se houver algum resultado, caso contrário false
  }
}
