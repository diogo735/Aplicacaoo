import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_horario_publicacao.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';

class ApiPublicacoes {
  final String apiUrl =
      'https://backend-teste-q43r.onrender.com/publicacoes/listarPublicacoes';

  final String apiUrlcomentarios =
      'https://backend-teste-q43r.onrender.com/comentarios/comentariospubdeambos/centro';

  final String apiUrlcriar =
      'https://backend-teste-q43r.onrender.com/publicacoes/create';

  final String apiUrlComentario =
      'https://backend-teste-q43r.onrender.com/comentarios/criarpubcomentario';

  final String apiUrlDenunciaPublicacao =
      'https://backend-teste-q43r.onrender.com/denuncias/create';

final String apiUrlDeletarComentario = 'https://backend-teste-q43r.onrender.com/comentarios/apagarpubcomentario';



  Future<void> _inserirPublicacaoLocalmente(
      Map<String, dynamic> publicacao) async {
    int publicacaoId = publicacao['id'];

    await Funcoes_Publicacoes.insertPublicacao({
      'id': publicacao['id'],
      'descricao_local': publicacao['descricao'],
      'data_publicacao': publicacao['createdAt'],
      'estado_publicacao': publicacao['estado'],
      'centro_id': publicacao['centro_id'],
      'area_id': publicacao['area_id'], // Verificação de null safety
      'topico_id': publicacao['topico_id'], // Verificação de null safety
      'pagina_web': publicacao['paginaweb'],
      'telemovel': publicacao['telemovel'],
      'email': publicacao['email'],
      'user_id': publicacao['autor_id'], // Verificação de null safety
      'local': publicacao['localizacao'],
      'nome': publicacao['titulo'],
    });

    print("    --> Publicação $publicacaoId guardada com sucesso!");

    // Limpar horários antigos (se existirem)
    await Funcoes_Publicacoes_Horario.deleteHorariosByPublicacaoId(
        publicacaoId);

    // Inserir novos horários
    Map<String, dynamic> horario = publicacao['horario'];
    for (var dia in horario.keys) {
      String horarioDia = horario[dia]?.toString() ?? 'Fechado';

      String horaAberto, horaFechar;

      if (horarioDia == 'Fechado') {
        horaAberto = 'Fechado';
        horaFechar = 'Fechado';
      } else {
        var horas = horarioDia.split('-');
        horaAberto = horas[0].trim();
        horaFechar = horas[1].trim();
      }

      await Funcoes_Publicacoes_Horario.insertPublicacaoHorario({
        'publicacao_id': publicacaoId,
        'dia_semana': dia,
        'hora_aberto': horaAberto,
        'hora_fechar': horaFechar,
      });
    }

    print(
        "    --> Horários da publicação $publicacaoId guardados com sucesso!");

    // Limpar imagens antigas (se existirem)
    await Funcoes_Publicacoes_Imagens.deleteImagensByPublicacaoId(publicacaoId);

    // Verificar se a galeria não é nula antes de processá-la
    if (publicacao['galeria'] != null) {
      List<String> galeria = (publicacao['galeria'] as List<dynamic>)
          .map((item) => item.toString())
          .toList();

      // Inserir novas imagens
      for (var urlImagem in galeria) {
        await Funcoes_Publicacoes_Imagens.inserirImagem({
          'publicacao_id': publicacaoId,
          'caminho_imagem': urlImagem,
        });
      }
      print(
          "    --> Imagens da publicação $publicacaoId guardadas com sucesso!");
    } else {
      print(
          "    --> Nenhuma imagem encontrada para a publicação $publicacaoId.");
    }
  }

  Future<void> fetchAndStorePublicacoes(int centroId) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Sem conexão com a internet');
      }

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      final response = await http.get(Uri.parse('$apiUrl/$centroId'), headers: {
        'Authorization': 'Bearer $jwtToken',
      });

      if (response.statusCode == 200) {
        List<dynamic> publicacoesList = json.decode(response.body);

        await Funcoes_Publicacoes.deletePublicacoesByCentroId(centroId);
        print(" --> Publicações anteriores deletadas com sucesso!");

        for (var publicacao in publicacoesList) {
          await Funcoes_Publicacoes.insertPublicacao({
            'id': publicacao['id'],
            'descricao_local': publicacao['descricao'],
            'data_publicacao': publicacao['createdAt'],
            'estado_publicacao': publicacao['estado'],
            'centro_id': publicacao['centro_id'],
            'area_id': publicacao['area']['id'],
            'topico_id': publicacao['topico']['id'],
            'pagina_web': publicacao['paginaweb'],
            'telemovel': publicacao['telemovel'],
            'email': publicacao['email'],
            'user_id': publicacao['autor']['id'],
            'local': publicacao['localizacao'],
            'nome': publicacao['titulo'],
          });
          print(
              "    --> Detalhes da publicação ${publicacao['id']} guardados com sucesso!");

          await Funcoes_Publicacoes_Horario.deleteHorariosByPublicacaoId(
              publicacao['id']);
          await Funcoes_Publicacoes_Imagens.deleteImagensByPublicacaoId(
              publicacao['id']);

          // HORARIO DE FUNCIONAMENTO
          Map<String, dynamic> horario = publicacao['horario'];
          for (var dia in horario.keys) {
            String horarioDia = horario[dia]?.toString() ?? 'Fechado';

            String horaAberto, horaFechar;

            if (horarioDia == 'Fechado') {
              horaAberto = 'Fechado';
              horaFechar = 'Fechado';
            } else {
              var horas = horarioDia.split('-');
              horaAberto = horas[0].trim();
              horaFechar = horas[1].trim();
            }

            await Funcoes_Publicacoes_Horario.insertPublicacaoHorario({
              'publicacao_id': publicacao['id'],
              'dia_semana': dia,
              'hora_aberto': horaAberto,
              'hora_fechar': horaFechar,
            });
          }

          print(
              "    --> Horários da publicação ${publicacao['id']} guardados com sucesso!");
          // IMAGENS DOS EVENTOS

          List<String> galeria = (publicacao['galeria'] as List<dynamic>)
              .map((item) => item.toString())
              .toList();

          for (var urlImagem in galeria) {
            await Funcoes_Publicacoes_Imagens.inserirImagem({
              'publicacao_id': publicacao['id'],
              'caminho_imagem': urlImagem,
            });
          }
          print(
              "    --> Imagens da publicação ${publicacao['id']} guardadas com sucesso!");
        }

        print("     -->P U B LICAÇÕES carregadas com sucesso!");
      } else {
        print("Falha ao carregar as publicações: ${response.body}");
      }
    } catch (e) {
      print('Erro ao carregar os dados: $e');
      rethrow;
    }
  }

  Future<String> criarPublicacao(Map<String, dynamic> novaPublicacao) async {
    try {
      // Verificar a conectividade com a internet
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Sem conexão com a internet');
      }

      // Pegar o token JWT
      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      // Enviar a requisição HTTP POST com os dados da nova publicação
      final response = await http.post(
        Uri.parse(apiUrlcriar), // URL da API
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(novaPublicacao),
      );

      // Verificar o resultado da requisição
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Se a publicação for criada com sucesso, processar a resposta
        final Map<String, dynamic> publicacaoCriada =
            json.decode(response.body);

        // Verificar se o campo 'id' existe e não é nulo
        if (publicacaoCriada['publicacao'] != null &&
            publicacaoCriada['publicacao']['id'] != null) {
          int publicacaoId = publicacaoCriada['publicacao']['id'] as int;
          print('Publicação criada com sucesso! ID: $publicacaoId');

          // Chamar a função para salvar localmente
          await _inserirPublicacaoLocalmente(publicacaoCriada['publicacao']);

          return 'Publicação criada e salva localmente com sucesso!';
        } else {
          print('Erro: O ID da publicação retornado pela API é null');
          return 'Erro: O ID da publicação retornado pela API é null';
        }
      } else {
        // Tratar o erro de resposta inadequada
        print('Erro ao criar publicação: ${response.body}');
        return 'Erro ao criar publicação: ${response.body}';
      }
    } catch (e) {
      // Captura qualquer exceção e exibe o erro
      print('Erro ao criar publicação: $e');
      return 'Erro ao criar publicação: $e';
    }
  }

  Future<void> fetchAndStoreComentarios(int centroId, int autorId) async {
    try {
      // Verificar a conectividade
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('Sem conexão com a internet');
      }

      // Obter o JWT Token
      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token não está definido');
      }

      // Fazer a requisição HTTP
      final response = await http.get(
          Uri.parse('$apiUrlcomentarios/$centroId/autor/$autorId'),
          headers: {
            'Authorization': 'Bearer $jwtToken',
          });

      if (response.statusCode == 200) {
        // Decodificar a resposta JSON
        List<dynamic> comentariosList = json.decode(response.body);

        await Funcoes_Comentarios_Publicacoes.deleteComentariosPorCentroId(
            centroId);

        for (var comentario in comentariosList) {
          await Funcoes_Comentarios_Publicacoes
              .inserir_comentario_feito_pelo_user(
            idComentario: comentario['id'],
            idUser: comentario['user_id'],
            classificacao: comentario['classificacao'] ?? 0,
            texto: comentario['conteudo'],
            data: comentario['data_comentario'],
            idPublicacao: comentario['publicacao_id'],
          );
        }

        print(" --> Comentários carregados e armazenados com sucesso!");
      } else {
        print("Falha ao carregar os comentários: ${response.body}");
      }
    } catch (e) {
      print('Erro ao carregar os comentários: $e');
      rethrow;
    }
  }

  Future<String> criarComentario(Map<String, dynamic> comentario) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        return "Sem conexão com a internet.";
      }

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception("Token JWT não disponível.");
      }

      final response = await http.post(
        Uri.parse(apiUrlComentario),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(comentario),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Decodificar o corpo da resposta JSON
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Obter o ID do comentário recém-criado
        final int comentarioId = jsonResponse['comentario']['id'];

        await Funcoes_Comentarios_Publicacoes
            .inserir_comentario_feito_pelo_user(
          idComentario: comentarioId,
          idUser: comentario['user_id'],
          classificacao: comentario['classificacao'] ?? 0,
          texto: comentario['conteudo'],
          data: comentario['data_comentario'],
          idPublicacao: comentario['publicacao_id'],
        );

        return "Comentário publicado com sucesso!";
      } else {
        return "Erro ao publicar comentário: ${response.body}";
      }
    } catch (e) {
      return 'Erro ao enviar o comentário: $e';
    }
  }


  Future<String> criarDenunciaPublicacao(
      int comentarioPublicacaoId,
      int denuncianteId,
      String motivo,
      String informacaoAdicional) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        return "Sem conexão com a internet.";
      }

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception("Token JWT não disponível.");
      }

      final response = await http.post(
        Uri.parse(apiUrlDenunciaPublicacao),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'comentario_publicacao_id': comentarioPublicacaoId,
          'denunciante_id': denuncianteId,
          'motivo': motivo,
          'informacao_adicional': informacaoAdicional,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return "Denúncia enviada com sucesso!";
      } else {
        return "Erro ao enviar denúncia: ${response.body}";
      }
    } catch (e) {
      return 'Erro ao enviar a denúncia: $e';
    }
  }

   Future<String> apagarComentarioPublicacao(int idComentario) async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        return "Sem conexão com a internet.";
      }

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        return "Token JWT não disponível.";
      }

      final response = await http.delete(
        Uri.parse('$apiUrlDeletarComentario/$idComentario'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        return "Comentário Apagado!";
      } else {
        return "Erro ao apagar comentário: ${response.body}";
      }
    } catch (e) {
      return 'Erro ao enviar a solicitação: $e';
    }
  }
}
