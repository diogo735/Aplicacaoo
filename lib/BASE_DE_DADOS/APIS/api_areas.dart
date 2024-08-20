import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areas.dart';

class ApiAreas {
  final String apiUrl =
      'https://backend-teste-q43r.onrender.com/areas/listarAreas';

  Future<void> fetchAndStoreAreas() async {
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
        List<dynamic> areasList = json.decode(response.body);
        await Funcoes_Areas.clearTable();
        for (var area in areasList) {
          await Funcoes_Areas.insertArea({
            'id': area['id'],
            'nome_area': area['nome'],
          });
        }
        print("     -->Áreas carregadas com sucesso!");
      } else {
        throw Exception('Falha ao carregar as áreas: ${response.body}');
      }
    } catch (e) {
      print('Erro ao carregar os dados: $e');
      rethrow;
    }
  }


  
}
