import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_likes_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiPartilhas {
  final String apiUrlPartilhas =
      'https://backend-teste-q43r.onrender.com/albuns/partilhasde1centro/';

  final String apiUrlCriarPartilha =
      'https://backend-teste-q43r.onrender.com/albuns/create';

  final String apiUrlComentarios =
      'https://backend-teste-q43r.onrender.com/comentarios_albuns/todoscomentarios/';

  final String apiUrlCriarComentario =
      'https://backend-teste-q43r.onrender.com/comentarios_albuns/criarcomentario';

  final String apiUrlLikesDeUmCentro =
      'https://backend-teste-q43r.onrender.com/likepartilhas/likesde1centro/';

  final String apiUrlCriarLike =
      'https://backend-teste-q43r.onrender.com/likepartilhas/darlike1partilha';
  final String apiUrlDeletarLike =
      'https://backend-teste-q43r.onrender.com/likepartilhas/apagar1like1parilha';
Future<void> fetchAndStorePartilhas(int centroId) async {
  // Verificar conectividade
  try {
    await _checkConnectivity();
  } catch (e) {
    print('Erro de conectividade: $e');
    return;
  }

  // Buscar o JWT Token para autenticação
  String? jwtToken = TokenService().getToken();
  if (jwtToken == null) {
    throw Exception('JWT Token is not set.');
  }

  // Gerar a URL completa e verificar se está correta
  String fullUrl = '$apiUrlPartilhas$centroId';
  print('URL gerada: $fullUrl');

  try {
    // Verifique se a URL está correta
    Uri uri = Uri.parse(fullUrl);
    print('URI válida: $uri');

    // Fazer a requisição GET para a API de "álbuns" (backend)
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    // Verificar o status da resposta
    print('Status da resposta: ${response.statusCode}');
    if (response.statusCode == 200) {
      List<dynamic> albunsList = json.decode(response.body);

      if (albunsList.isEmpty) {
        print('Nenhuma partilha encontrada para o centro $centroId.');
        return;  // Se não houver partilhas, não faz mais nada
      }

      await Funcoes_Partilhas.deleteAllPartilhas();

      for (var album in albunsList) {
        await Funcoes_Partilhas.insertPartilha({
          'id': album['id'], // ID do álbum (partilha)
          'titulo': album['nome'], // Título do álbum
          'descricao': album['descricao'], // Descrição do álbum
          'caminho_imagem': album['capa_imagem_album'], // Capa do álbum (imagem)
          'data': album['createdAt'], // Data de criação
          'hora': album['createdAt'], // Hora de criação (se aplicável)
          'id_usuario': album['autor_id'], // ID do autor do álbum
          'area_id': album['area_id'], // Área onde o álbum foi criado
          'centro_id': album['centro_id'], // Centro relacionado ao álbum
        });
      }

      print('Dados das partilhas carregados com sucesso.');
    } else if (response.statusCode == 404) {
      print('Nenhuma partilha encontrada para o centro $centroId.');
    } else {
      print('Falha ao carregar as partilhas (álbuns) para o centro $centroId.');
    }
  } catch (e) {
    print('Erro ao carregar os dados: $e');
  }
}



  Future<void> criarPartilha(Map<String, dynamic> partilha) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.post(
      Uri.parse(apiUrlCriarPartilha),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode(partilha),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Partilha criada com sucesso');
    } else {
      print('Falha ao criar a partilha: ${response.body}');
    }
  }

  Future<void> fetchAndStoreComentarios() async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    List<Map<String, dynamic>> partilhas =
        await Funcoes_Partilhas.consultaPartilhas();

    for (var partilha in partilhas) {
      final response = await http.get(
        Uri.parse('$apiUrlComentarios${partilha['id']}'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> comentariosList = json.decode(response.body);
        await Funcoes_Comentarios_das_Partilhas.deleteComentariosByPartilhaId(
            partilha['id']);

        for (var comentario in comentariosList) {
          // Separar a data e a hora
          String dataComentario = comentario['data_comentario']
              .split('T')[0]; // Extrai a parte da data
          String horaComentario = comentario['data_comentario']
              .split('T')[1]
              .split('.')[0]; // Extrai a parte da hora

          await Funcoes_Comentarios_das_Partilhas.insertComentario({
            'id': comentario['id'], // ID do comentário
            'texto_comentario':
                comentario['texto_comentario'], // Texto do comentário
            'data_comentario':
                dataComentario, // Data extraída do campo 'data_comentario'
            'hora_comentario':
                horaComentario, // Hora extraída do campo 'data_comentario'
            'id_usuario':
                comentario['user_id'], // ID do usuário que fez o comentário
            'partilha_id': partilha['id'], // ID da partilha (álbum no backend)
          });
        }
        print(
            '    ->>>>Dados dos comentários das partilhas carregados com SUCESSO.');
      } else {
        print(
            'Falha ao carregar os comentários para a partilha ${partilha['id']}');
      }
    }
  }

  Future<bool> criarComentario(
      int partilhaId, Map<String, dynamic> comentario) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.post(
      Uri.parse(apiUrlCriarComentario),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode(comentario),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Comentário criado com sucesso');
      return true;
    } else {
      print('Falha ao criar o comentário: ${response.body}');
      return false;
    }
  }

  Future<void> fetchAndStoreLikes(int centroId) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(
      Uri.parse('$apiUrlLikesDeUmCentro$centroId'),
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> likesList = json.decode(response.body);

      await Funcoes_Likes_das_Partilhas.deleteLikesByCentroId(centroId);

      for (var like in likesList) {
        await Funcoes_Likes_das_Partilhas.insertLike({
          'id': like['id'],
          'id_usuario': like['id_usuario'],
          'partilha_id': like['partilha_id'],
        });
      }
    } else {
      print('Falha ao carregar os likes');
    }
  }

  Future<bool> criarLike(int id_usuario, int partilha_id) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.post(
      Uri.parse(apiUrlCriarLike),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode({
        'id_usuario': id_usuario,
        'partilha_id': partilha_id,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Like feito com sucesso');
      return true;
    } else {
      print('Falha ao criar o like: ${response.body}');
      return false;
    }
  }

  Future<bool> apagarLike(int id_usuario, int partilha_id) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.delete(
      Uri.parse(apiUrlDeletarLike),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: json.encode({
        'id_usuario': id_usuario,
        'partilha_id': partilha_id,
      }),
    );

    if (response.statusCode == 200) {
      print('Like apagado com sucesso');
      return true;
    } else {
      print('Falha ao deletar o like: ${response.body}');
      return false;
    }
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }
  }
}
