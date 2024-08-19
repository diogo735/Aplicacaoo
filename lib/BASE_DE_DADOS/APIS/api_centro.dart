import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:http/http.dart' as http;
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  final String apiUrl =
      'https://backend-teste-q43r.onrender.com/centros/listarCentros';

  Future<void> fetchAndStoreCentros() async {
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
     // print(
         // "Response status: ${response.statusCode}"); // Imprime o status da resposta
     // print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> centrosList = json.decode(response.body);

        for (var centro in centrosList) {
          await Funcoes_Centros.insertCentro({
            'id': centro['id'],
            'nome': centro['nome'],
            'morada': centro['morada'],
            'imagem_centro': centro['imagem'],
          });
        }
        print("     -->Centros carregados com sucesso!");
      } else {
        throw Exception('Falha ao carregar os centros: ${response.body}');
      }
    } catch (e) {
      print('Erro ao carregar os dadossss: $e');
      rethrow;
    }
  }
}
