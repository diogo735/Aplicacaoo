import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart'; // Certifique-se de importar corretamente

class ApiUsuarios {
  final String apiUrlUsuarios = 'https://backend-teste-q43r.onrender.com/users/listarallUsers'; // Altere para a URL correta

  Future<void> fetchAndStoreUsuarios() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }
    final response = await http.get(Uri.parse(apiUrlUsuarios));
    if (response.statusCode == 200) {
      List<dynamic> usuariosList = json.decode(response.body);
      for (var usuario in usuariosList) {
        await Funcoes_Usuarios.insertUsuario({
          'id': usuario['id'],
          'nome': usuario['nome'],
          'sobrenome': usuario['sobrenome'],
          'caminho_foto': usuario['caminho_foto'],
          'caminho_fundo': usuario['caminho_fundo'],
          'sobre_min': usuario['sobre_min'],
          'centro_id': usuario['centro_id'],
        });
      }
    } else {
      throw Exception('Falha ao carregar os usuários');
    }
  }
}
