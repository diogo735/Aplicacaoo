import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiService {
  final String apiUrl =
      'https://backend-teste-q43r.onrender.com/centros/listarCentros';

  Future<void> fetchAndStoreCentros() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    final response = await http.get(Uri.parse(apiUrl));


    if (response.statusCode == 200) {
      List<dynamic> centrosList = json.decode(response.body);

      for (var centro in centrosList) {
        await Funcoes_Centros.insertCentro({
          'id': centro['id'],
          'nome': centro['nome'],
          'morada': centro['morada'],
          'imagem_centro': centro['imagem_centro'],
        });
      }
    } else {
      throw Exception('Falha ao carregar os centros');
    }
  }
}
