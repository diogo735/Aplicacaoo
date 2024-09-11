import 'dart:convert';
import 'dart:io';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areafavoritas_douser.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_notificacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicosfavoritos_user.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart'; // Certifique-se de importar corretamente
import 'dart:developer' as dev;

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

  final String apiUrlInserirTopicoFavorito =
      'https://backend-teste-q43r.onrender.com/topicosfavoritos/topicos_favoritos/create';

  final String apiUrlRemoverTopicoFavorito =
      'https://backend-teste-q43r.onrender.com/topicosfavoritos/topicos_favoritos/delete';

  final String apiUrlNotificacoes =
      'https://backend-teste-q43r.onrender.com/notificacoes/usuario/';

  final String apiUrlBaseNotificacoes =
      'https://backend-teste-q43r.onrender.com/notificacoes/delete/';

  final String urlUpdate =
      'https://backend-teste-q43r.onrender.com/users/update/:id';

  final String urlVerificarEmail =
      'https://backend-teste-q43r.onrender.com/users/verificar_email_google';

  final String urlCreate =
      'https://backend-teste-q43r.onrender.com/users/create';

  Future<String> uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload'),
    );
    request.fields['key'] = '4d755673a2dc94483064445f4d5c54e9';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['data']['url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> updatePassword(int userId, String newPassword) async {
    final Uri url = Uri.parse(
        'https://backend-teste-q43r.onrender.com/users/update/$userId');

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken'
    };

    final body = jsonEncode({
      'password': newPassword,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Senha atualizada com sucesso!');
      } else {
        print('Erro ao atualizar senha: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao atualizar senha: $e');
    }
  }

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
        if (decodedResponse.containsKey('areas_favoritas') &&
            decodedResponse['areas_favoritas'] is List) {
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
          print(
              "Nenhuma área favorita encontrada ou chave 'areas_favoritas' não está presente.");
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
        if (decodedResponse.containsKey('topicos_favoritos') &&
            decodedResponse['topicos_favoritos'] is List) {
          final List<dynamic> topicosList =
              decodedResponse['topicos_favoritos'];

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
          print(
              "Nenhum tópico favorito encontrado ou chave 'topicos_favoritos' não está presente.");
        }
      } else {
        print("Formato de resposta inesperado.");
      }
    } else {
      print("Falha ao carregar os tópicos favoritos");
      //throw Exception('Falha ao carregar os tópicos favoritos');
    }
  }

  Future<Map<String, dynamic>?> verificarEmail(String email) async {
    try {
      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token não está definido.');
      }

      final response = await http.get(
        Uri.parse('$urlVerificarEmail?email=$email'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('userId')) {
          return {
            'userId': data['userId'],
            'userName': data['userName'],
          };
        } else {
          print(data['message']);
          return null;
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao verificar email: $e');
      return null;
    }
  }

  Future<void> criarUsuario(Map<String, dynamic> usuario) async {
    try {
      // Verificar a conectividade com a internet
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Sem conexão com a internet');
      }

      // Obter o token JWT
      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token não está definido.');
      }
      dev.log('Token $jwtToken');

      // Log do payload que será enviado
      dev.log('Dados enviados para o servidor: $usuario',
          name: 'ApiUsuarios.criarUsuario');

      // Codificar o payload em JSON
      final body = json.encode(usuario);
      dev.log('Encoded JSON: $body', name: 'ApiUsuarios.criarUsuario');

      // Enviar a requisição POST para criar o usuário
      final response = await http.post(
        Uri.parse(urlCreate),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type':
              'application/json', // Cabeçalho Content-Type necessário
        },
        body: body,
      );

      // Log da resposta do servidor
      dev.log('Response Status: ${response.statusCode}',
          name: 'ApiUsuarios.criarUsuario');
      dev.log('Response Body: ${response.body}',
          name: 'ApiUsuarios.criarUsuario');

      // Tentar decodificar a resposta JSON
      final jsonData = jsonDecode(response.body);
      dev.log('Parsed JSON: $jsonData', name: 'ApiUsuarios.criarUsuario');

      // Verificar o código de status da resposta
      if (response.statusCode == 200) {
        print("Usuário criado com sucesso!");
      } else {
        throw Exception('Falha ao criar o usuário: ${jsonData['error']}');
      }
    } catch (e) {
      print('Erro ao criar usuário: $e');
      throw Exception('Erro ao criar usuário: $e');
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
      print(
          'Falha ao inserir tópico favorito. Código de status: ${response.statusCode}');
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      await Funcoes_TopicosFavoritos.removeTopicoFavorito(usuarioId, topicoId);

      print('Tópico favorito removido com sucesso!');
      return true;
    } else {
      print('Falha ao remover tópico favorito');
      return false;
    }
  }

  Future<void> fetchAndStoreNotificacoes(int usuarioId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token não está definido.');
    }

    final apiUrlNotificacoes2 =
        'https://backend-teste-q43r.onrender.com/notificacoes/usuario/$usuarioId';

    final response = await http.get(Uri.parse(apiUrlNotificacoes2), headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (response.statusCode == 200) {
      List<dynamic> notificacoesList = json.decode(response.body);
      for (var notificacaoJson in notificacoesList) {
        // Tenta buscar o valor de `ja_mostrei_notificacao` já existente no banco de dados
        List<Map<String, dynamic>> notificacaoExistente =
            await Funcoes_Notificacoes.consultaNotificacaoPorId(
                notificacaoJson['id']);

        int jaMostreiNotificacao = 0; // Valor padrão

        // Se a notificação já existir no banco, mantenha o valor de `ja_mostrei_notificacao`
        if (notificacaoExistente.isNotEmpty) {
          jaMostreiNotificacao =
              notificacaoExistente.first['ja_mostrei_notificacao'];
        }

        // Cria um mapa para a notificação
        Map<String, dynamic> notificacaoMap = {
          'id': notificacaoJson['id'],
          'usuario_id': notificacaoJson['usuario_id'],
          'tipo': notificacaoJson['tipo'],
          'mensagem': notificacaoJson['mensagem'],
          'lida': notificacaoJson['lida'] ? 1 : 0,
          'ja_mostrei_notificacao':
              jaMostreiNotificacao, // Mantém o valor existente
        };

        // Insere ou atualiza a notificação no banco de dados local
        await Funcoes_Notificacoes.insertNotificacao(notificacaoMap);
      }
      print("Notificações carregadas com sucesso!");
    } else {
      throw Exception('Falha ao carregar as notificações');
    }
  }

  Future<void> deleteNotificacao(int notificacaoId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token não está definido.');
    }

    final apiUrlDeleteNotificacao = '$apiUrlBaseNotificacoes$notificacaoId';

    final response =
        await http.delete(Uri.parse(apiUrlDeleteNotificacao), headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (response.statusCode == 200 || response.statusCode == 204) {
      await Funcoes_Notificacoes.deleteNotificacao(notificacaoId);
      print("Notificação excluída com sucesso!");
    } else {
      throw Exception('Falha ao excluir a notificação no servidor');
    }
  }

   Future<void> enviarNotificacaoEvento(int usuarioId, int amigoId, int eventoId) async {
    // Verificar a conectividade com a internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    // Obter o token JWT
    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token não está definido.');
    }

    // Construir o mapa da notificação
    Map<String, dynamic> notificacaoMap = {
      'usuario_id': amigoId,
      'tipo': 'evento',
      'mensagem': 'O usuário $usuarioId quer que você veja o evento $eventoId',
      'lida': 0, // 0 indica que a notificação ainda não foi lida
      'ja_mostrei_notificacao': 0, // 0 indica que a notificação ainda não foi mostrada
    };

    // Enviar a notificação para o backend
    final apiUrl = 'https://backend-teste-q43r.onrender.com/notificacoes/create';
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(notificacaoMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Se a notificação foi enviada com sucesso, insira-a no banco de dados local
      await Funcoes_Notificacoes.insertNotificacao(notificacaoMap);
      print('Notificação enviada e armazenada com sucesso!');
    } else {
      throw Exception('Falha ao enviar a notificação: ${response.body}');
    }
  }


}
