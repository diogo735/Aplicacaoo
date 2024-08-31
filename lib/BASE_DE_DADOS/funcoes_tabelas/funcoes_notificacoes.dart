import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
class Funcoes_Notificacoes {
  // Método para criar a tabela de notificações no banco de dados
  static Future<void> createNotificacoesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notificacoes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        mensagem TEXT NOT NULL,
        lida INTEGER DEFAULT 0,  -- Armazena 0 ou 1
        ja_mostrei_notificacao INTEGER DEFAULT 0,
        FOREIGN KEY (usuario_id) REFERENCES usuario(id)
      )
    ''');
  }

  // Método para limpar a tabela de notificações
  static Future<void> clearTable() async {
    Database db = await DatabaseHelper.basededados;
    await db.delete('notificacoes');
  }

  // Método para inserir uma nova notificação no banco de dados
 static Future<void> insertNotificacao(Map<String, dynamic> notificacao) async {
  Database db = await DatabaseHelper.basededados;

  await db.insert(
    'notificacoes',
    notificacao,
    conflictAlgorithm: ConflictAlgorithm.ignore, // Usa ignore para não sobrescrever
  );
}

static Future<List<Map<String, dynamic>>> consultaNotificacaoPorId(int id) async {
    Database db = await DatabaseHelper.basededados;

    // Consulta a notificação com o ID especificado
    return await db.query(
      'notificacoes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
static Future<void> updateNotificacao(int id, Map<String, dynamic> valoresAtualizados) async {
  Database db = await DatabaseHelper.basededados;

  await db.update(
    'notificacoes',
    valoresAtualizados,
    where: 'id = ?',
    whereArgs: [id],
  );
}

  // Método para consultar todas as notificações de um usuário específico
  static Future<List<Map<String, dynamic>>> consultaNotificacoesPorUsuario(int usuarioId) async {
    Database db = await DatabaseHelper.basededados;

    return await db.query(
      'notificacoes',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
  }

   static Future<void> deleteNotificacao(int notificacaoId) async {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'notificacoes',
      where: 'id = ?',
      whereArgs: [notificacaoId],
    );
  }
}
