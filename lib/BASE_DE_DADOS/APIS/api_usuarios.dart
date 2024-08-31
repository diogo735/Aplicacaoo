import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areafavoritas_douser.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicosfavoritos_user.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart'; // Certifique-se de importar corretamente

class ApiUsuarios {
  final String apiUrlUsuarios =
      'https://backend-teste-q43r.onrender.com/users/listarallUsers'; // Altere para a URL correta

  final String apiUrlAreasFavoritas =
      'https://backend-teste-q43r.onrender.com/areasfavoritas/listar_areas_favoritas_toadas';

  final String apiUrlTopicosFavoritos =
      'https://backend-teste-q43r.onrender.com/topicosfavoritos/topicos_favoritos_todos';

  final String apiUrlInserirAreaFavorita =
      'https://backend-teste-q43r.onrender.com/areasfavoritas/add_area_favorita';

  final String apiUrlRemoverAreaFavorita =
      'https://backend-teste-q43r.onrender.com/areasfavoritas/apagar_area_favorita';

  final String apiUrlInserirTopicoFavorito='https://backend-teste-q43r.onrender.com/topicosfavoritos/topicos_favoritos/create';

  final String apiUrlRemoverTopicoFavorito='https://backend-teste-q43r.onrender.com/topicosfavoritos/topicos_favoritos/delete';


  Future<void> fetchAndStoreUsuarios() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }
    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(Uri.parse(apiUrlUsuarios), headers: {
      'Authorization': 'Bearer $jwtToken',
    });
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
      print("    ->Usuarios carregados com sucesso!");
    } else {
      throw Exception('Falha ao carregar os usuários');
    }
  }
Future<void> fetchAndStoreAreasFavoritas() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('Sem conexão com a internet');
  }

  String? jwtToken = TokenService().getToken();
  if (jwtToken == null) {
    throw Exception('JWT Token não está definido.');
  }

  final response = await http.get(Uri.parse(apiUrlAreasFavoritas), headers: {
    'Authorization': 'Bearer $jwtToken',
  });

  if (response.statusCode == 200) {
    // Limpa a tabela antes de armazenar novos dados
    await Funcoes_AreasFavoritas.clearTable();

    // Decodifica o JSON da resposta
    final decodedResponse = json.decode(response.body);

    if (decodedResponse is List) {
      // Se a resposta for uma lista diretamente
      if (decodedResponse.isNotEmpty) {
        for (var area in decodedResponse) {
          await Funcoes_AreasFavoritas.insertAreaFavorita({
            'id': area['id'],
            'usuario_id': area['usuario_id'],
            'area_id': area['area_id'],
          });
        }
        print("      >Áreas favoritas carregadas com sucesso!");
      } else {
        print("Nenhuma área favorita encontrada.");
      }
    } else if (decodedResponse is Map<String, dynamic>) {
      // Se a resposta for um mapa contendo a chave 'areas_favoritas'
      if (decodedResponse.containsKey('areas_favoritas') && decodedResponse['areas_favoritas'] is List) {
        final List<dynamic> areasList = decodedResponse['areas_favoritas'];

        if (areasList.isNotEmpty) {
          for (var area in areasList) {
            await Funcoes_AreasFavoritas.insertAreaFavorita({
              'id': area['id'],
              'usuario_id': area['usuario_id'],
              'area_id': area['area_id'],
            });
          }
          print("      >Áreas favoritas carregadas com sucesso!");
        } else {
          print("Nenhuma área favorita encontrada.");
        }
      } else {
        print("Nenhuma área favorita encontrada ou chave 'areas_favoritas' não está presente.");
      }
    } else {
      print("Formato inesperado de resposta.");
    }
  } else {
    print("Falha ao carregar as áreas favoritas");
  }
}

Future<void> fetchAndStoreTopicosFavoritos() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('Sem conexão com a internet');
  }

  String? jwtToken = TokenService().getToken();
  if (jwtToken == null) {
    throw Exception('JWT Token não está definido.');
  }

  final response =
      await http.get(Uri.parse(apiUrlTopicosFavoritos), headers: {
    'Authorization': 'Bearer $jwtToken',
  });

  if (response.statusCode == 200) {
    // Limpa a tabela antes de armazenar novos dados
    await Funcoes_TopicosFavoritos.clearTable();

    // Decodifica o JSON da resposta
    final decodedResponse = json.decode(response.body);

    // Verifica se a resposta é um mapa ou uma lista
    if (decodedResponse is List) {
      final List<dynamic> topicosList = decodedResponse;

      // Verifica se a lista não está vazia
      if (topicosList.isNotEmpty) {
        for (var topico in topicosList) {
          await Funcoes_TopicosFavoritos.insertTopicoFavorito({
            'id': topico['id'],
            'usuario_id': topico['usuario_id'],
            'topico_id': topico['topico_id'],
          });
        }
        // Mostra mensagem de sucesso
        print("      >Tópicos favoritos carregados com sucesso!");
      } else {
        print("Nenhum tópico favorito encontrado.");
      }
    } else if (decodedResponse is Map) {
      // Caso a resposta seja um mapa (não uma lista)
      if (decodedResponse.containsKey('topicos_favoritos') && decodedResponse['topicos_favoritos'] is List) {
        final List<dynamic> topicosList = decodedResponse['topicos_favoritos'];

        if (topicosList.isNotEmpty) {
          for (var topico in topicosList) {
            await Funcoes_TopicosFavoritos.insertTopicoFavorito({
              'id': topico['id'],
              'usuario_id': topico['usuario_id'],
              'topico_id': topico['topico_id'],
            });
          }
          print("      >Tópicos favoritos carregados com sucesso!");
        } else {
          print("Nenhum tópico favorito encontrado.");
        }
      } else {
        print("Nenhum tópico favorito encontrado ou chave 'topicos_favoritos' não está presente.");
      }
    } else {
      print("Formato de resposta inesperado.");
    }
  } else {
    print("Falha ao carregar os tópicos favoritos");
    //throw Exception('Falha ao carregar os tópicos favoritos');
  }
}



  Future<bool> inserirAreaFavorita(int usuarioId, int areaId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('Sem conexão com a internet');
      return false;
    }

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      print('JWT Token não está definido.');
      return false;
    }

    final response = await http.post(
      Uri.parse(apiUrlInserirAreaFavorita),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usuario_id': usuarioId,
        'area_id': areaId,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Resposta da API: ${response.body}');
      await Funcoes_AreasFavoritas.insertAreaFavorita({
        'usuario_id': usuarioId,
        'area_id': areaId,
      });
      print('Área favorita inserida com sucesso!');
      return true;
    } else {
      print(
          'Falha ao inserir área favorita. Código de status: ${response.statusCode}');
      print('Resposta da API: ${response.body}');
      return false;
    }
  }

  Future<bool> removerAreaFavorita(int usuarioId, int areaId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print('Sem conexão com a internet');
      return false;
    }

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      print('JWT Token não está definido.');
      return false;
    }

    final response = await http.delete(
      Uri.parse(apiUrlRemoverAreaFavorita),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usuario_id': usuarioId,
        'area_id': areaId,
      }),
    );

    if (response.statusCode == 200) {
      await Funcoes_AreasFavoritas.removeAreaFavorita(usuarioId, areaId);

      print('Área favorita removida com sucesso!');
      return true;
    } else {
      print('Falha ao remover área favorita');
      return false;
    }
  }

Future<bool> inserirTopicoFavorito(int usuarioId, int topicoId) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    print('Sem conexão com a internet');
    return false;
  }

  String? jwtToken = TokenService().getToken();
  if (jwtToken == null) {
    print('JWT Token não está definido.');
    return false;
  }

  final response = await http.post(
    Uri.parse(apiUrlInserirTopicoFavorito),  
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'usuario_id': usuarioId,
      'topico_id': topicoId,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    print('Resposta da API: ${response.body}');
    await Funcoes_TopicosFavoritos.insertTopicoFavorito({
      'usuario_id': usuarioId,
      'topico_id': topicoId,
    });
    print('Tópico favorito inserido com sucesso!');
    return true;
  } else {
    print('Falha ao inserir tópico favorito. Código de status: ${response.statusCode}');
    print('Resposta da API: ${response.body}');
    return false;
  }
}


Future<bool> removerTopicoFavorito(int usuarioId, int topicoId) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    print('Sem conexão com a internet');
    return false;
  }

  String? jwtToken = TokenService().getToken();
  if (jwtToken == null) {
    print('JWT Token não está definido.');
    return false;
  }

  final response = await http.delete(
    Uri.parse(apiUrlRemoverTopicoFavorito),  
    headers: {
      'Authorization': 'Bearer $jwtToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'usuario_id': usuarioId,
      'topico_id': topicoId,
    }),
  );

  if (response.statusCode == 200 ||response.statusCode == 201) {

    await Funcoes_TopicosFavoritos.removeTopicoFavorito(usuarioId, topicoId);

    print('Tópico favorito removido com sucesso!');
    return true;
  } else {
    print('Falha ao remover tópico favorito');
    return false;
  }
}

}
