import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mensagens_do_forum.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_foruns.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';

class ApiForuns {
  final String apiUrlBase =
      'https://backend-teste-q43r.onrender.com/forum/listarporcentroAPP';

  Future<void> fetchAndStoreForuns(int centroId) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Sem conexão com a internet');
      }

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token não está definido.');
      }

      final String apiUrl = '$apiUrlBase/$centroId';

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $jwtToken',
      });

      if (response.statusCode == 200) {
        List<dynamic> forunsList = json.decode(response.body);

        Database db = await DatabaseHelper.basededados;
        await Funcoes_Mensagens_foruns.apagarTodasMensagens();

        for (var forum in forunsList) {
          Map<String, dynamic> forumData = {
            'id': forum['id'],
            'area_id': forum['area_id'],
            'centro_id': forum['centro_id'],
            'nome': forum['nome'],
            'estado': forum['estado'],
          };
          await Funcoes_Foruns.insertForum(db, forumData);
        }
        print("  --->Fóruns carregados com sucesso!");
      } else {
        print("Falha ao carregar os fóruns: ${response.body}");
      }
    } catch (e) {
      print('Erro ao carregar os dados: $e');
      rethrow;
    }
  }
}
