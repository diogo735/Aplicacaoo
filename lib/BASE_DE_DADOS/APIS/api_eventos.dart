import 'dart:convert';
import 'dart:io';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';

class ApiEventos {
  final String apiUrlEventos =
      'https://backend-teste-q43r.onrender.com/eventos/listarEventosAPP/';
  // final String apiUrlCriarEvento = 'https://backend-teste-q43r.onrender.com/eventos/criar';
  final String apiUrlAtualizarEventos =
      'https://backend-teste-q43r.onrender.com/eventos/update/';
  // final String apiUrlDeletarEvento = 'https://backend-teste-q43r.onrender.com/eventos/deletar/';
  final String apiUrlTipoEvento =
      'https://backend-teste-q43r.onrender.com/tipodeevento/listarTipos';

  final String apiUrlParticipantesEvento =
      'https://backend-teste-q43r.onrender.com/listaparticipantes_evento/listarparticipanteambos/';

  final String apiUrlComentariosEvento =
      'https://backend-teste-q43r.onrender.com/comentarios_eventos/comentariosdeambos/centro/';

  final String apiUrlImagensEvento =
      'https://backend-teste-q43r.onrender.com/galeria_evento/listar_toas_imagens_ambos/centro/';

  final String apiUrlcriarComentariosEvento =
      'https://backend-teste-q43r.onrender.com/comentarios_eventos/criarcomentario';
  final String apiUrlDeletarComentario =
      'https://backend-teste-q43r.onrender.com/comentarios_eventos/apagarcomentario';
  final String apiUrlCriarDenuncia =
      'https://backend-teste-q43r.onrender.com/denuncias_comentarios_eventos/criarDenuncia';
  final String apiUrlCriarDenunciaEvento =
      'https://backend-teste-q43r.onrender.com/denuncias_de_eventos/criar';
  final String apiUrlAdicionarParticipanteEvento =
      'https://backend-teste-q43r.onrender.com/listaparticipantes_evento/adicionar_participante';

  final String apiUrlCriarEvento =
      'https://backend-teste-q43r.onrender.com/eventos/create';
  final String apiUrlAdicionarImagensGaleria =
      'https://backend-teste-q43r.onrender.com/galeria_evento/criarvarias';

  final String apiUrlEventosUsuario =
      'https://backend-teste-q43r.onrender.com/eventos/eventosdousuario/';

  final String apiUrlRemoverImagensGaleria='https://backend-teste-q43r.onrender.com/galeria_evento/remover_todas_as_imagens';
  //api para buscar os eventos
  final String apiUrlremovergaleria =
      'https://backend-teste-q43r.onrender.com/galeria_evento/remover_todas_as_imagens';

 final String apiUrlRemoverParticipanteEvento='https://backend-teste-q43r.onrender.com/listaparticipantes_evento/remover_participante/';



  Future<void> fetchAndStoreEventos(int centroId, int usuarioId) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    // Função para processar eventos e evitar duplicações
    Future<void> processarEventos(List<dynamic> eventosList,
        Set<int> eventosExistentes, String origem) async {
      if (eventosList.isEmpty) {
        print("Nenhum evento para carregar de $origem.");
        return;
      }

      for (var evento in eventosList) {
        if (!eventosExistentes.contains(evento['id'])) {
          // Converter a string da data para DateTime
          DateTime dataInicioAtividade =
              DateTime.parse(evento['datainicioatividade']);

          // Formatar horas e minutos como 'HH:mm'
          String horas = dataInicioAtividade.hour.toString().padLeft(2, '0');
          String minutos =
              dataInicioAtividade.minute.toString().padLeft(2, '0');
          String horario = '$horas:$minutos';

          DateTime dataFimAtividade =
              DateTime.parse(evento['datafimatividade']);

          // Formatar horas e minutos como 'HH:mm'
          String horas_fim = dataFimAtividade.hour.toString().padLeft(2, '0');
          String minutos_fim =
              dataFimAtividade.minute.toString().padLeft(2, '0');
          String horario_fim = '$horas_fim:$minutos_fim';

          await Funcoes_Eventos.insertEvento({
            'id': evento['id'],
            'nome': evento['nome'],
            'descricao_evento': evento['descricao'],
            'caminho_imagem': evento['capa_imagem_evento'],
            'dia_realizacao': dataInicioAtividade.day,
            'mes_realizacao': dataInicioAtividade.month,
            'ano_realizacao': dataInicioAtividade.year,
            'horas': horario,
            'estado_evento': evento['estado'],
            'dia_fim': dataFimAtividade.day,
            'mes_fim': dataFimAtividade.month,
            'ano_fim': dataFimAtividade.year,
            'horas_acaba': horario_fim,
            'latitude': evento['latitude'],
            'longitude': evento['longitude'],
            'area_id': evento['area_id'],
            'tipodeevento_id': evento['tipodeevento_id'],
            'topico_id': evento['topico_id'],
            'centro_id': evento['centro_id'],
            'id_criador': evento['autor_id']
          });

          // Adiciona o ID do evento ao conjunto para evitar duplicações
          eventosExistentes.add(evento['id']);
        }
      }
      print("   ->Eventos de $origem carregados e armazenados com sucesso!");
    }

    // Set para armazenar IDs de eventos já processados
    Set<int> eventosExistentes = {};

    // Carregar eventos do centro
    final responseCentro = await http.get(
      Uri.parse('$apiUrlEventos$centroId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (responseCentro.statusCode == 200) {
      List<dynamic> eventosListCentro = json.decode(responseCentro.body);
      await processarEventos(eventosListCentro, eventosExistentes, "Centro");
    } else {
      print('Falha ao carregar os eventos do centro: ${responseCentro.body}');
    }

    // Carregar eventos do usuário
    final responseUsuario = await http.get(
      Uri.parse('$apiUrlEventosUsuario$usuarioId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (responseUsuario.statusCode == 200) {
      List<dynamic> eventosListUsuario = json.decode(responseUsuario.body);
      await processarEventos(eventosListUsuario, eventosExistentes, "Usuário");
    } else {
      print('Falha ao carregar os eventos do usuário: ${responseUsuario.body}');
    }
  }

  Future<bool> atualizarEvento(int eventoId, Map<String, dynamic> eventoAtualizado) async {
  await _checkConnectivity();

  String? jwtToken = TokenService().getToken();
  if (jwtToken == null) {
    throw Exception('JWT Token is not set.');
  }

  final url = Uri.parse('$apiUrlAtualizarEventos$eventoId'); 

  try {
    final response = await http.put(
      url,  
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',  
      },
      body: json.encode(eventoAtualizado),
    );

    if (response.statusCode == 200) {
      return true;  // Success

    } else {
      print('Failed to update event. Status code: ${response.statusCode}');
      return false;  // Failure
    }
  } catch (e) {
    print('Error updating event: $e');
    return false;  // Failure due to exception
  }
}


  Future<bool> removerTodasImagensDoEvento(int eventoId) async {
  try {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    // Preparando a URL com o ID do evento
    var url = Uri.parse('$apiUrlremovergaleria/$eventoId');

    // Preparando a requisição
    var response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
    );

    // Verificando a resposta
    if (response.statusCode == 200) {
      return true; // Sucesso
    } else if (response.statusCode == 404) {
      return false; // Nenhuma imagem encontrada ou evento inexistente
    } else {
      return false; // Falha ao remover imagens
    }
  } on SocketException {
    return false; // Sem conexão com a internet
  } on Exception catch (e) {
    return false; // Ocorreu um erro
  }
}

  //api para buscar os tipos de evento
  Future<void> fetchAndStoreTiposDeEvento() async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(
      Uri.parse(apiUrlTipoEvento),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      List<dynamic> tiposEventoList = json.decode(response.body);
      if (tiposEventoList.isEmpty) {
        print("Nenhum tipo de evento para carregar.");
        return;
      }
      for (var tipoEvento in tiposEventoList) {
        await Funcoes_TipodeEvento.insertipodeevento({
          'id': tipoEvento['id'],
          'nome_tipo': tipoEvento['nome_tipo'],
          'caminho_imagem': tipoEvento['caminho_imagem']
        });
      }
      print("   ->Tipos de evento carregados com sucesso!");
    } else {
      print('Falha ao carregar os tipos de evento: ${response.body}');
    }
  }

  Future<void> fetchAndStoreParticipantes(int centroId, int autorId) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(
      Uri.parse('$apiUrlParticipantesEvento$centroId/autor/$autorId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      List<dynamic> participantesList = json.decode(response.body);
      if (participantesList.isEmpty) {
        print("Nenhum participante para carregar.");
        return;
      }
      await Funcoes_Participantes_Evento.deleteAllParticipantes();

      for (var participante in participantesList) {
        await Funcoes_Participantes_Evento.inscreverUsuarioEmEvento(
            participante['usuario_id'], participante['evento_id']);
      }
      print("   ->Participantes de eventos carregados com sucesso!");
    } else {
      print('Falha ao carregar participantes do evento :${response.body}');
    }
  }

  //api para buscar os comentarios do evento
  Future<void> fetchAndStoreComentariosEvento(int centroId, int autorid) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(
      Uri.parse('$apiUrlComentariosEvento$centroId/autor/$autorid'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      List<dynamic> comentariosList = json.decode(response.body);

      if (comentariosList.isEmpty) {
        print("Nenhum comentario para carregar.");
        return;
      }
      await Funcoes_Comentarios_Eventos.deleteAllcomentarios();

      for (var comentario in comentariosList) {
        await Funcoes_Comentarios_Eventos.insertComentarioEvento({
          'id': comentario['id'],
          'user_id': comentario['user_id'],
          'evento_id': comentario['evento_id'],
          'data_comentario': comentario['data_comentario'],
          'classificacao': comentario['classificacao'],
          'texto_comentario': comentario['texto_comentario'],
        });
      }
      print("   ->Comentarios de eventos carregados com sucesso!");
    } else {
      print('Falha ao carregar comentários do evento:${response.body}');
    }
  }

//api para bucar as imagens do evento
  Future<void> fetchAndStoreImagensEvento(int centroId, int autorId) async {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(
      Uri.parse('$apiUrlImagensEvento$centroId/autor/$autorId'),
      headers: {'Authorization': 'Bearer $jwtToken'},
    );

    if (response.statusCode == 200) {
      List<dynamic> imagensList = json.decode(response.body);
      if (imagensList.isEmpty) {
        print("Nenhuma imagem para carregar.");
        return;
      }
      await Funcoes_Eventos_Imagens.apagarTodasImagens();

      for (var imagem in imagensList) {
        await Funcoes_Eventos_Imagens.inserirImagem({
          'caminho_imagem': imagem['caminho_imagem'],
          'evento_id': imagem['evento_id']
        });
      }
      print("   ->Imagens de eventos carregados com sucesso!");
    } else {
      print('Falha ao carregar imagens dos eventos:${response.body}');
    }
  }

//API PARA CRIAR UM COMENTARIO NUM EVENTO
  Future<String> criarComentario(Map<String, dynamic> comentario) async {
    try {
      // Verifica a conectividade antes de tentar enviar o comentário
      await _checkConnectivity();

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      final response = await http.post(
        Uri.parse('$apiUrlcriarComentariosEvento'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(comentario),
      );

      if (response.statusCode == 201) {
        String successMessage = "Comentário publicado!";
        //print(successMessage);
        return successMessage;
      } else {
        String failureMessage = 'Falha ao criar comentário!';
        //print(failureMessage);
        return failureMessage;
      }
    } on SocketException {
      String offlineMessage = "Sem conexão com a internet.";
      return offlineMessage;
    } on Exception catch (e) {
      String errorMessage = "Ocorreu um erro: $e";

      return errorMessage;
    }
  }

//API PARA APAGAR UM COMENTARIO DE UM EVENTO
  Future<String> apagarComentario(int idComentario) async {
    try {
      await _checkConnectivity();

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      final response = await http.delete(
        Uri.parse('$apiUrlDeletarComentario/$idComentario'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return "Comentário Apagado !";
      } else {
        return 'Falha ao apagar comentário!';
      }
    } on SocketException {
      return "Sem conexão com a internet.";
    } on Exception catch (e) {
      return "Ocorreu um erro: $e";
    }
  }

//API PARA FAZER A DENUNCIA DE UM COMENTARIOS DE UM EVENTO
  Future<String> criarDenuncia(
      int idComentarioDenunciado,
      int idEvento,
      int idDenunciador,
      String motivoDenuncia,
      String descricaoDenuncia) async {
    try {
      await _checkConnectivity();

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      final response = await http.post(
        Uri.parse('$apiUrlCriarDenuncia'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_comentario_denunciado': idComentarioDenunciado,
          'id_evento': idEvento,
          'id_denunciador': idDenunciador,
          'motivo_denuncia': motivoDenuncia,
          'descricao_denuncia': descricaoDenuncia,
        }),
      );

      if (response.statusCode == 201) {
        return "Comentario Denuciado!";
      } else {
        return 'Falha ao criar denúncia!';
      }
    } on SocketException {
      return "Sem conexão com a internet.";
    } on Exception catch (e) {
      return "Ocorreu um erro: $e";
    }
  }

// API PARA FAZER A DENÚNCIA DE UM EVENTO
  Future<String> criarDenunciaEvento(int idEvento, int idDenunciador,
      String motivoDenuncia, String descricaoDenuncia) async {
    try {
      await _checkConnectivity();

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      final response = await http.post(
        Uri.parse('$apiUrlCriarDenunciaEvento'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_evento_denunciado': idEvento,
          'id_denunciador': idDenunciador,
          'motivo_denuncia': motivoDenuncia,
          'descricao_denuncia': descricaoDenuncia,
        }),
      );

      if (response.statusCode == 201) {
        return "Evento Denunciado!";
      } else {
        return 'Falha ao criar denúncia!';
      }
    } on SocketException {
      return "Sem conexão com a internet.";
    } on Exception catch (e) {
      return "Ocorreu um erro: $e";
    }
  }

//api para inscrever num evento
  Future<String> adicionarParticipanteEvento(
      int usuarioId, int eventoId) async {
    try {
      await _checkConnectivity();

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      final response = await http.post(
        Uri.parse('$apiUrlAdicionarParticipanteEvento'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'usuario_id': usuarioId,
          'evento_id': eventoId,
        }),
      );

      if (response.statusCode == 201) {
        return "Inscrito com sucesso!";
      } else if (response.statusCode == 409) {
        return 'Ja estas registado neste evento';
      } else {
        return 'Falha ao adicionar participante!';
      }
    } on SocketException {
      return "Sem conexão com a internet.";
    } on Exception catch (e) {
      return "Ocorreu um erro: $e";
    }
  }


Future<String> removerParticipanteEvento(int usuarioId, int eventoId) async {
  try {
    await _checkConnectivity();

    String? jwtToken = TokenService().getToken();
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.delete(
      Uri.parse('$apiUrlRemoverParticipanteEvento$usuarioId/$eventoId'), 
      headers: {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usuario_id': usuarioId,
        'evento_id': eventoId,
      }),
    );

    if (response.statusCode == 200) {
      return "Inscrição cancelada com sucesso!";
    } else if (response.statusCode == 404) {
      return 'Participante não encontrado neste evento.';
    } else {
      return 'Falha ao remover participante!';
    }
  } on SocketException {
    return "Sem conexão com a internet.";
  } on Exception catch (e) {
    return "Ocorreu um erro: $e";
  }
}

  // Função para criar um evento
  Future<int?> criarEvento(Map<String, dynamic> eventoData) async {
    try {
      // Verifica a conectividade antes de tentar enviar o evento
      await _checkConnectivity();

      // Obtém o token JWT
      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      // Envia o pedido para criar o evento
      final response = await http.post(
        Uri.parse(apiUrlCriarEvento),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(eventoData),
      );

      if (response.statusCode == 201 ||response.statusCode == 200) {
        // Decodifica a resposta JSON
        final responseData = jsonDecode(response.body);

        int? eventoId = responseData['id'];
        print("criou o evento ");
        return eventoId; // Retorna o evento_id
      } else {
        print('Falha ao criar evento 11111: ${response.body}');
        return null;
      }
    } on SocketException {
      print("Sem conexão com a internet.");
      return null;
    } on Exception catch (e) {
      print("Ocorreu um erro: $e");
      return null;
    }
  }

  /// Função para adicionar imagens à galeria do evento
  Future<String> adicionarImagensGaleriaUrls(
      int eventoId, List<String> urls) async {
    try {
      // Verifica a conectividade antes de tentar enviar as imagens
      await _checkConnectivity();

      String? jwtToken = TokenService().getToken();
      if (jwtToken == null) {
        throw Exception('JWT Token is not set.');
      }

      // Verifique se `eventoId` e `urls` não são nulos ou vazios
      if (eventoId == null || urls.isEmpty) {
        return 'Erro: eventoId ou lista de URLs está nulo ou vazio';
      }

      // Preparando a requisição
      var request = http.Request(
        'POST',
        Uri.parse(apiUrlAdicionarImagensGaleria),
      );

      // Adicionando o token de autorização no cabeçalho
      request.headers['Authorization'] = 'Bearer $jwtToken';
      request.headers['Content-Type'] = 'application/json';

      // Preparando o corpo da requisição
      request.body = jsonEncode({
        'evento_id': eventoId,
        'imagens': urls,
      });

      // Imprimindo os valores
      print('Evento ID: $eventoId');
      print('URLs das Imagens: ${urls.join(', ')}');

      // Enviando a requisição
      var response = await http.Client().send(request);

      // Verificando a resposta
      if (response.statusCode == 201) {
        return "Imagens adicionadas com sucesso!";
      } else {
        var responseData = await response.stream.bytesToString();
        return 'Falha ao adicionar imagens: $responseData';
      }
    } on SocketException {
      return "Sem conexão com a internet.";
    } on Exception catch (e) {
      return "Ocorreu um erro: $e";
    }
  }
}


Future<void> _checkConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('Sem conexão com a internet');
  }
}
