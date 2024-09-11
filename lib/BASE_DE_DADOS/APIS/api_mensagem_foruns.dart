import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_foruns.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mensagens_do_forum.dart';
import 'package:sqflite/sqflite.dart';

class ApiMensagensForum {
  final String apiUrl =
      'https://backend-teste-q43r.onrender.com/mensagem_forum';

  Future<void> fetchAndStoreMensagensForum() async {
    try {
      // Verifica a conectividade com a internet
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Sem conexão com a internet');
      }

      // Recupera o JWT Token
      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token não está definido.');
      }

      // Buscar os IDs dos fóruns já armazenados no banco de dados
      List<int> idsForunsExistentes =
          await Funcoes_Foruns().consultaIdsDosForuns();

      // Iterar sobre cada fórum existente
      for (int forumId in idsForunsExistentes) {
        // Fazer a requisição para buscar as mensagens do fórum específico
        final response =
            await http.get(Uri.parse('$apiUrl/forum/$forumId'), headers: {
          'Authorization': 'Bearer $jwtToken',
        });
await Funcoes_Mensagens_foruns.apagarTodasMensagens();
        // Se a requisição for bem-sucedida
        if (response.statusCode == 200) {
          // Decodifica a resposta da API
          List<dynamic> mensagensList = json.decode(response.body);
      
      
          if (mensagensList.isNotEmpty) {
            final funcoesMensagensForuns = Funcoes_Mensagens_foruns();
            Database db = await DatabaseHelper.basededados;

            // Inserir cada mensagem no banco de dados
            for (var mensagem in mensagensList) {
              DateTime dataHora = DateTime.parse(mensagem['createdat']);
              await funcoesMensagensForuns.inserirMensagemNoBancoDeDados(
                forumId: mensagem['forum_id'],
                userId: mensagem['user_id'],
                textoMensagem: mensagem['texto_mensagem'],
                dataHora: dataHora,
              );
            }
            print("Mensagens do fórum $forumId carregadas com sucesso!");
          } else {
            // Se a lista de mensagens estiver vazia (nenhuma mensagem encontrada)
            print("Nenhuma mensagem encontrada para o fórum $forumId.");
          }
        } else {
          // Verifica a mensagem de erro antes de apagar as mensagens
          var responseBody = json.decode(response.body);
          if (responseBody['message'] ==
              'Nenhuma mensagem encontrada para este fórum') {
            // Chama Funcoes_Mensagens_foruns.apagarTodasMensagens() somente se esta resposta for recebida
            
            print(
                "Nenhuma mensagem encontrada para o fórum $forumId. Todas as mensagens foram apagadas.");
          } else {
            print(
                "Erro ao carregar as mensagens do fórum $forumId: ${response.body}");
          }
        }
      }
    } catch (e) {
      // Tratamento de erro genérico
      print('Erro ao carregar os dados: $e');
      rethrow;
    }
  }
}
