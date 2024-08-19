import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';

class ApiTopicos {
  final String apiUrl =
      'https://backend-teste-q43r.onrender.com/topicos/listarTopicos';

  Future<void> fetchAndStoreTopicos() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Sem conexão com a internet');
      }

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Bearer $jwtToken',
      });

      if (response.statusCode == 200) {
        List<dynamic> topicosList = json.decode(response.body);

        for (var topico in topicosList) {
          await Funcoes_Topicos.insertTopico({
            'id': topico['id'],
            'nome_topico': topico['nome'],
            'area_id': topico['area_id'],
            'topico_imagem': topico['topico_icon'], 
          });
        }
        print("     -->Tópicos carregados com sucesso!");
      } else {
       print("Falha ao carregar os tópicos: ${response.body}");
      }
    } catch (e) {
      print('Erro ao carregar os dados: $e');
      rethrow;
    }
  }
}
