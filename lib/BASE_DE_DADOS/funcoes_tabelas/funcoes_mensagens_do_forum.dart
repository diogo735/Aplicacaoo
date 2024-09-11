// ignore_for_file: camel_case_types
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_foruns.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';

class Funcoes_Mensagens_foruns {
  static Future<void> createMensagemForumTable(Database db) async {
    await db.execute('CREATE TABLE mensagem_forum('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'forum_id INTEGER,'
        'user_id INTEGER,'
        'texto_mensagem TEXT,'
        'created_at TEXT,'
        'FOREIGN KEY (forum_id) REFERENCES forum(id),'
        'FOREIGN KEY (user_id) REFERENCES user(id)'
        ')');
  }

  Future<bool> enviarMensagemParaBackend({
    required int forumId,
    required int userId,
    required String textoMensagem,
    required DateTime dataHora,
  }) async {
    try {
      final String? jwtToken = TokenService().getToken(); // Obtém o token JWT

      if (jwtToken == null) {
        print('Erro: JWT Token não está definido.');
        return false; // Retorna false se o token não estiver definido
      }

      final url = Uri.parse(
          'https://backend-teste-q43r.onrender.com/mensagem_forum/create');
      String dataIso =
          dataHora.toIso8601String(); // Converte DateTime para string ISO 8601

      final mensagem = {
        'forum_id': forumId,
        'user_id': userId,
        'texto_mensagem': textoMensagem,
        'createdat': dataIso,
      };

      final response = await http.post(
        url, // Aqui já passamos o objeto Uri diretamente
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json', // Corrigido 'application/json'
        },
        body: jsonEncode(mensagem),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // A resposta JSON pode conter a mensagem enviada. Consideramos isso um sucesso.
        print('Mensagem enviada com sucesso: ${response.body}');
        return true;
      } else {
        // Se o status code não for de sucesso, mostra a resposta do erro.
        print('Erro ao enviar mensagem: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      return false;
    }
  }

  // Função para inserir a mensagem no banco de dados local
  Future<void> inserirMensagemNoBancoDeDados({
    required int forumId,
    required int userId,
    required String textoMensagem,
    required DateTime dataHora,
  }) async {
    String dataIso =
        dataHora.toIso8601String(); // Converte para string ISO 8601

    Database db = await DatabaseHelper.basededados;
    await db.insert(
      'mensagem_forum',
      {
        'forum_id': forumId,
        'user_id': userId,
        'texto_mensagem': textoMensagem,
        'created_at': dataIso, // Armazena a data e hora como string
      },
    );
  }

  static Future<void> apagarMensagensPorForumId(int forumId) async {
    Database db = await DatabaseHelper.basededados;
    await db.delete(
      'mensagem_forum',
      where: 'forum_id = ?',
      whereArgs: [forumId],
    );
    print("Mensagens do fórum com ID $forumId foram apagadas.");
  }

  // Função para inserir a mensagem no banco de dados local
  static Future<void> insertMensagemForum({
    required Database db,
    required int forumId,
    required int userId,
    required String textoMensagem,
    required DateTime createdAt,
  }) async {
    await db.insert(
      'mensagem_forum',
      {
        'forum_id': forumId,
        'user_id': userId,
        'texto_mensagem': textoMensagem,
        'created_at':
            createdAt.toIso8601String(), // Usando ISO8601 para armazenar a data
      },
    );
  }

  Future<bool> processarInsercaoMensagem({
    required int forumId,
    required int userId,
    required String textoMensagem,
  }) async {
    DateTime now = DateTime.now(); // Captura o horário atual

    print('Enviando mensagem para o backend...');
    bool sucesso = await enviarMensagemParaBackend(
      forumId: forumId,
      userId: userId,
      textoMensagem: textoMensagem,
      dataHora: now,
    );

    if (sucesso) {
      print('Mensagem enviada para o backend com sucesso!');
      Database db = await DatabaseHelper.basededados;
      await insertMensagemForum(
        db: db,
        forumId: forumId,
        userId: userId,
        textoMensagem: textoMensagem,
        createdAt: now,
      );
      print('Mensagem armazenada no banco de dados local.');
      return true;
    } else {
      print('Falha ao enviar a mensagem para o backend.');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> consultaMensagemForumPorForumId(
      int forumId) async {
    Database db = await DatabaseHelper.basededados;
    return await db
        .rawQuery('SELECT * FROM mensagem_forum WHERE forum_id = ?', [forumId]);
  }

  Future<void> sincronizarMensagensDoBackend(int forumId) async {
    try {
      final String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        print('Erro: JWT Token não está definido.');
        return;
      }

      final url = Uri.parse(
          'https://backend-teste-q43r.onrender.com/mensagem_forum/forum/$forumId');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> mensagens = json.decode(response.body);
        Database db = await DatabaseHelper.basededados;

        await Funcoes_Mensagens_foruns.apagarMensagensPorForumId(forumId);

        for (var mensagem in mensagens) {
          await Funcoes_Mensagens_foruns.insertMensagemForum(
            db: db,
            forumId: mensagem['forum_id'],
            userId: mensagem['user_id'],
            textoMensagem: mensagem['texto_mensagem'],
            createdAt: DateTime.parse(mensagem['createdat']),
          );
        }
        print("Mensagens sincronizadas com sucesso!");
      } else {
        print('Erro ao sincronizar mensagens: ${response.body}');
      }
    } catch (e) {
      print('Erro ao sincronizar mensagens: $e');
    }
  }
  static Future<void> apagarTodasMensagens() async {
  Database db = await DatabaseHelper.basededados;
  
  // Apaga todas as mensagens da tabela 'mensagem_forum'
  await db.delete('mensagem_forum');
  
  print("Todas as mensagens foram apagadas.");
}

}
