import 'dart:convert';
import 'dart:io';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_recuperar_passe.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'dart:developer' as dev;

class ApiUsuarios {
  final String apiUrlUsuarios =
      'https://backend-teste-q43r.onrender.com/users/listarallUsers';
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
    final Uri url = Uri.parse('https://backend-teste-q43r.onrender.com/users/update/$userId');

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
    dev.log('Dados enviados para o servidor: $usuario', name: 'ApiUsuarios.criarUsuario');

    // Codificar o payload em JSON
    final body = json.encode(usuario);
    dev.log('Encoded JSON: $body', name: 'ApiUsuarios.criarUsuario');

    // Enviar a requisição POST para criar o usuário
    final response = await http.post(
      Uri.parse(urlCreate),
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json', // Cabeçalho Content-Type necessário
      },
      body: body,
    );

    // Log da resposta do servidor
    dev.log('Response Status: ${response.statusCode}', name: 'ApiUsuarios.criarUsuario');
    dev.log('Response Body: ${response.body}', name: 'ApiUsuarios.criarUsuario');

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

  
}
