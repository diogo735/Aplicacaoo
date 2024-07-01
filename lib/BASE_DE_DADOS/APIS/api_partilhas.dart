import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_likes_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class ApiPartilhas {
  final String apiUrlPartilhas =
      'https://backend-teste-q43r.onrender.com/partilhas/partilhasde1centro/';
  final String apiUrlCriarPartilha =
      'https://backend-teste-q43r.onrender.com/partilhas/criarpartilha';

  final String apiUrlComentarios =
      'https://backend-teste-q43r.onrender.com/comentarios_partilhas/comentairosde1partilha/';

  final String apiUrlCriarComentario =
      'https://backend-teste-q43r.onrender.com/comentarios_partilhas/criarcomentario/';

  final String apiUrlLikesDeUmCentro =
      'https://backend-teste-q43r.onrender.com/likepartilhas/likesde1centro/';

  final String apiUrlCriarLike =
      'https://backend-teste-q43r.onrender.com/likepartilhas/darlike1partilha';
  final String apiUrlDeletarLike =
      'https://backend-teste-q43r.onrender.com/likepartilhas/apagar1like1parilha';

  Future<void> fetchAndStorePartilhas(int centroId) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }
    final response = await http.get(Uri.parse('$apiUrlPartilhas$centroId'));
    if (response.statusCode == 200) {
      List<dynamic> partilhasList = json.decode(response.body);

      await Funcoes_Partilhas.deleteAllPartilhas();

      for (var partilha in partilhasList) {
        await Funcoes_Partilhas.insertPartilha({
          'id': partilha['id'],
          'titulo': partilha['titulo'],
          'descricao': partilha['descricao'],
          'caminho_imagem': partilha['caminho_imagem'],
          'data': partilha['data'],
          'hora': partilha['hora'],
          'id_usuario': partilha['id_usuario'],
          //'id_evento': partilha['id_evento'],
          //'id_local': partilha['id_local'],
          'area_id': partilha['area_id'],
          'centro_id': partilha['centro_id'],
        });
      }
    } else {
      print('Falha ao carregar as partilhas');
    }
  }

  Future<void> criarPartilha(Map<String, dynamic> partilha) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    final response = await http.post(
      Uri.parse(apiUrlCriarPartilha),
      headers: {
        'Content-Type': 'application/json',
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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    List<Map<String, dynamic>> partilhas =
        await Funcoes_Partilhas.consultaPartilhas();

    for (var partilha in partilhas) {
      final response =
          await http.get(Uri.parse('$apiUrlComentarios${partilha['id']}'));
      if (response.statusCode == 200) {
        List<dynamic> comentariosList = json.decode(response.body);
        await Funcoes_Comentarios_das_Partilhas.deleteComentariosByPartilhaId(
            partilha[
                'id']); // Função para deletar comentários antigos da partilha

        for (var comentario in comentariosList) {
          await Funcoes_Comentarios_das_Partilhas.insertComentario({
            'id': comentario['id'],
            'texto_comentario': comentario['texto_comentario'],
            'data_comentario': comentario['data_comentario'],
            'hora_comentario': comentario['hora_comentario'],
            'id_usuario': comentario['id_usuario'],
            'partilha_id': partilha['id'],
          });
        }
      } else {
        print(
            'Falha ao carregar os comentários para a partilha ${partilha['id']}');
      }
    }
  }

  Future<bool> criarComentario(
      int partilhaId, Map<String, dynamic> comentario) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    final response = await http.post(
      Uri.parse('$apiUrlCriarComentario$partilhaId'),
      headers: {
        'Content-Type': 'application/json',
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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    final response =
        await http.get(Uri.parse('$apiUrlLikesDeUmCentro$centroId'));
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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    final response = await http.post(
      Uri.parse(apiUrlCriarLike),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id_usuario': id_usuario,
        'partilha_id': partilha_id
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
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }

    final response = await http.delete(
      Uri.parse(apiUrlDeletarLike),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id_usuario': id_usuario,
        'partilha_id': partilha_id
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
}
