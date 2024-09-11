import 'dart:async';
import 'dart:io';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/card_tags_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/galeria_na_pagina_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/lista_participantes_imagens.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_comentarios_evento/card_comentario_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_comentarios_evento/criar_comentario_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_denunciar_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_inscrever_evento/pagina_inscricao.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_lista_participantes/pagina_lista_participantes.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_todos_comentarios_eventos/pagina_todos_comentarios_eventos.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/galeria_imagem.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/paginal_lista_menbros/ver_perfil_outros_user/pagina_de_perfil.dart';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/services.dart';

class PaginaEvento extends StatefulWidget {
  final int idEvento;

  const PaginaEvento({super.key, required this.idEvento});

  @override
  _PaginaEventoState createState() => _PaginaEventoState();
}

class _PaginaEventoState extends State<PaginaEvento> {
  late String nomeEvento = '';
  late String dia = '';
  late String nomeCriador = '';
  late String caminhoFotoCriador = '';
  late String mes = '';
  late String ano = '';
  late String horas = '';

  late String dia_fim = '';
  late String mes_fim = '';
  late String ano_fim = '';
  late String horas_fim = '';
  late String local = '';
  late String numeroParticipantes = '';
  late String imagePath = '';
  late String descricao = '';
  late int idArea = 0;
  late int id_criador = 0;
  late int idTopico = 0;
  late String tipoEvento = '';
  late String imagem_tipoevento = '';
  List<int> participantesIds = [];
  List<String> participantesFotos = [];
  late String nomeArea = '';
  late Color corArea = Colors.transparent;
  late String imagemArea = '';
  List<Map<String, dynamic>> comentarios = [];
  List<String> caminhos_Imagens = [];
  late double latitude = 0;
  late double longitude = 0;
  late String topico = '';
  late String imagem_topico = '';
  late int user_id;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _inicializarCarregamento();
  }

  Future<void> _inicializarCarregamento() async {
    await _carregarDados(); // Aguarda o carregamento de todos os dados

    // Agora que todos os dados foram carregados, configurar o Timer
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        // Verifica se o widget ainda está montado
        _carregarDados(); // Recarrega todos os dados a cada 7 segundos
      }
    });
  }

  Future<void> _carregarDados() async {
    await _carregarDetalhesEvento();
    _carregarDadosTopicos();
    await _carregarParticipantes();
    await _carregarComentariosEventos();
    await _carregarImagensEvento();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer corretamente
    super.dispose();
  }

  _carregarComentariosEventos() async {
    List<Map<String, dynamic>> comentariosCarregados =
        await Funcoes_Comentarios_Eventos.consultaComentariosPorEvento(
            widget.idEvento);

    setState(() {
      comentarios = comentariosCarregados;
    });
  }

  Future<void> _carregarDetalhesEvento() async {
    try {
      List<Map<String, dynamic>> resultado =
          await Funcoes_Eventos.consultaDetalhesEventoPorId(widget.idEvento);
      if (resultado.isNotEmpty) {
        final evento = resultado.first;

        var detalhesArea = await obter_detalhes_Area(evento['area_id'] ?? 0);
        var tipoEventoDados = await Funcoes_TipodeEvento.obterDadosTipoEvento(
            evento['tipodeevento_id'] ?? 0);

        await _carregarDetalhesCriador(evento['id_criador'] ?? 0);

        if (mounted) {
          // Verifica se o widget ainda está montado antes de chamar setState
          setState(() {
            latitude = evento['latitude'] ?? 0.0;
            longitude = evento['longitude'] ?? 0.0;
            nomeEvento = evento['nome'] ?? 'Nome Desconhecido';
            dia = evento['dia_realizacao'].toString();
            mes = _obterNomeMes(evento['mes_realizacao'] ?? 1);
            ano = evento['ano_realizacao'].toString();
            horas = evento['horas'] ?? 'Horário Desconhecido';
            dia_fim = evento['dia_fim'].toString();
            mes_fim = _obterNomeMes(evento['mes_fim'] ?? 1);
            ano_fim = evento['ano_fim'].toString();
            horas_fim = evento['horas_acaba'] ?? 'Horário Desconhecido';
            descricao =
                evento['descricao_evento'] ?? 'Descrição não disponível';
            imagePath =
                evento['caminho_imagem'] ?? 'assets/images/default_image.png';
            idArea = evento['area_id'] ?? 0;
            tipoEvento = tipoEventoDados['nome'] ?? 'Tipo Desconhecido';
            imagem_tipoevento =
                tipoEventoDados['imagem'] ?? 'assets/images/sem_resultados.png';
            id_criador = evento['id_criador'];
            idTopico = evento['topico_id'];
            nomeArea = detalhesArea['nome_area'] ?? 'Área Desconhecida';
            corArea = detalhesArea['cor_area'] ?? 'Cor Padrão';
            imagemArea = detalhesArea['imagem_area'] ??
                'assets/images/default_area_image.png';
          });
          _carregarDetalhesLocal();
          _carregarDadosTopicos();
        }
      }
    } catch (e) {
      print('Erro ao carregar detalhes do evento: $e');
    }
  }

  void _carregarDadosTopicos() async {
    if (idTopico != null) {
      Map<String, String> dados =
          await Funcoes_Topicos.obterDadosTopico(idTopico);

      setState(() {
        topico = dados['nome']!;
        imagem_topico = dados['imagem']!;
      });
    } else {
      setState(() {
        topico = "Desconhecido";
        imagem_topico = "assets/images/sem_resultados.png";
      });
    }
  }

  Future<void> _carregarDetalhesLocal() async {
    try {
      Map<String, String> enderecoDetalhado = await LocalizacaoOSM()
          .getDetailedAddressFromCoordinates(latitude, longitude);
      List<String> partesDoEndereco = [
        enderecoDetalhado['name'] ?? '',
        "${enderecoDetalhado['road'] ?? ''}${enderecoDetalhado['house_number'] != null ? (enderecoDetalhado['house_number'] ?? '') : ''}",
        "${enderecoDetalhado['neighbourhood'] ?? ''}${enderecoDetalhado['village'] != null ? (enderecoDetalhado['village'] ?? '') : ''}",
        "${enderecoDetalhado['city'] ?? ''}, ${enderecoDetalhado['county'] ?? ''}",
      ];

      // Filtra as partes que são vazias ou contêm "Não disponível"
      String enderecoFormatado = partesDoEndereco
          .where((parte) => parte.isNotEmpty && parte != "")
          .join(",\n ");
      setState(() {
        local = enderecoFormatado;
      });
    } catch (e) {
      print('Erro ao obter detalhes do local: $e');
    }
  }

  _carregarImagensEvento() async {
    List<Map<String, dynamic>> imagens =
        await Funcoes_Eventos_Imagens().consultaEventosImagens();
    List<String> caminhos = [];
    for (var imagem in imagens) {
      if (imagem['evento_id'] == widget.idEvento) {
        caminhos.add(imagem['caminho_imagem']);
        print(imagem['caminho_imagem']);
      }
    }
    setState(() {
      caminhos_Imagens = caminhos;
    });
  }

  Map<String, dynamic> obter_detalhes_Area(int areaId) {
    String nomeArea = '';
    Color corArea = Colors.transparent;
    String imagemArea = '';

    switch (areaId) {
      case 2:
        nomeArea = 'Saúde';
        corArea = const Color(0xFF8F3023);
        imagemArea = 'assets/images/fav_saude.png';
        break;
      case 1:
        nomeArea = 'Desporto';
        corArea = const Color(0xFF53981D);
        imagemArea = 'assets/images/fav_desporto.png';
        break;
      case 3:
        nomeArea = 'Gastronomia';
        corArea = const Color(0xFFA91C7A);
        imagemArea = 'assets/images/fav_restaurant.png';
        break;
      case 4:
        nomeArea = 'Formação';
        corArea = const Color(0xFF3779C6);
        imagemArea = 'assets/images/fav_formacao.png';
        break;
      case 7:
        nomeArea = 'Alojamento';
        corArea = const Color(0xFF815520);
        imagemArea = 'assets/images/fav_alojamento.png';
        break;
      case 6:
        nomeArea = 'Transportes';
        corArea = const Color(0xFFB7BB06);
        imagemArea = 'assets/images/fav_transportes.png';
        break;
      case 5:
        nomeArea = 'Lazer';
        corArea = const Color(0xFF25ABAB);
        imagemArea = 'assets/images/fav_lazer.png';
        break;

      default:
        nomeArea = 'Outro';
        corArea = Colors.grey;
        imagemArea = 'assets/images/no_events.png';
        break;
    }

    return {
      'nome_area': nomeArea,
      'cor_area': corArea,
      'imagem_area': imagemArea,
    };
  }

  Future<void> _carregarDetalhesCriador(int idCriador) async {
    String caminhoFoto =
        await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(idCriador);
    String nomeCompleto =
        await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(idCriador);
    Usuario? usuarioAtual =
        Provider.of<Usuario_Provider>(context, listen: false)
            .usuarioSelecionado;
    setState(() {
      caminhoFotoCriador = caminhoFoto;
      if (usuarioAtual != null && usuarioAtual.id_user == idCriador) {
        nomeCriador = "Eu";
      } else {
        nomeCriador = nomeCompleto;
      }
    });
  }

  Future<void> _carregarParticipantes() async {
    try {
      participantesIds =
          await Funcoes_Participantes_Evento.getParticipantesEvento(
              widget.idEvento);
      List<String> fotos = [];
      for (int id in participantesIds) {
        String foto =
            await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(id);
        fotos.add(foto);
      }
      setState(() {
        participantesFotos =
            fotos; // Atualiza a lista de fotos dos participantes
      });
    } catch (e) {
      print('Erro ao carregar participantes: $e');
    }
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    // Construa a URL do Google Maps
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    final Uri url = Uri.parse(googleMapsUrl);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not open the map.';
    }
  }

  Color getCorPorAreaId(int idArea) {
    switch (idArea) {
      case 2:
        return const Color(0xFF8F3023); // Saúde
      case 1:
        return const Color(0xFF53981D); // Desporto
      case 3:
        return const Color(0xFFA91C7A); // Gastronomia
      case 4:
        return const Color(0xFF3779C6); // Formação
      case 7:
        return const Color(0xFF815520); // Alojamento
      case 6:
        return const Color(0xFFB7BB06); // Transportes
      case 5:
        return const Color(0xFF25ABAB); // Lazer
      default:
        return const Color(0xFF15659F); // Cor padrão
    }
  }

  String _obterNomeMes(int mes) {
    switch (mes) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '';
    }
  }

  double calcular_media_classificacao() {
    if (comentarios.isEmpty) {
      return 0.0;
    }
    double somaClassificacoes = 0;
    for (var comentario in comentarios) {
      somaClassificacoes += comentario['classificacao'];
    }
    return somaClassificacoes / comentarios.length;
  }

  void _selecionarAmigo(
      BuildContext context, int usuarioId, int eventoId) async {
    // Carrega a lista de usuários do banco de dados
    List<Map<String, dynamic>> usuarios =
        await Funcoes_Usuarios().consultaUsuarios();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecione um amigo'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                var usuario = usuarios[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: FileImage(File(usuario['caminho_foto'])),
                  ),
                  title: Text(usuario['nome']),
                  onTap: () {
                    _enviarNotificacao(
                        usuarioId, usuario['id'], usuario['nome'], eventoId);
                    Navigator.of(context)
                        .pop(); // Fecha o diálogo após a seleção
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _mostrarOpcoesDeCompartilhamento(
      BuildContext context,
      int usuarioId,
      int eventoId,
      String tituloEvento,
      String dataEvento,
      String localEvento) {
    String partilha =
        'Confira este evento: $tituloEvento \nData: $dataEvento \nLocal: $localEvento  \n\n Não perca! Compartilhe com os seus amigos';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.share,
                color: const Color.fromARGB(255, 30, 112,
                    179), // Altera a cor do ícone de compartilhamento para azul
              ),
              title: Text('Compartilhar nas Redes Sociais'),
              onTap: () {
                Share.share(partilha); // Compartilha a string formatada
                Navigator.of(context).pop(); // Fecha o modal
              },
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: const Color.fromARGB(255, 26, 125,
                    206), // Altera a cor do ícone de compartilhamento para azul
              ),
              title: Text('Compartilhar com um Amigo'),
              onTap: () {
                Navigator.of(context).pop(); // Fecha o modal
                _selecionarAmigo(context, usuarioId, eventoId);
              },
            ),
          ],
        );
      },
    );
  }

  void _enviarNotificacao(
      int usuarioId, int amigoId, String nomeAmigo, int eventoId) async {
    try {
      // Busque o título do evento antes de enviar a notificação
      String tituloEvento =
          await Funcoes_Eventos.consultaNomeEventoPorId(eventoId);

      await ApiUsuarios().enviarNotificacaoEvento(usuarioId, amigoId, eventoId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Notificação enviada para $nomeAmigo sobre o evento "$tituloEvento"')),
      );
    } catch (e) {
      print('Erro ao enviar notificação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar notificação')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;

    // Aqui você usa as variáveis que já têm os dados reais do evento
    String tituloEvento = nomeEvento; // Nome do evento carregado
    String dataEvento = '$dia de $mes, $ano'; // Data do evento formatada
    String localEvento = local; // Local do evento

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Evento',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            )),
        backgroundColor: getCorPorAreaId(idArea),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: IconButton(
              padding: const EdgeInsets.all(3),
              icon: const Icon(Icons.share),
              onPressed: () {
                _mostrarOpcoesDeCompartilhamento(
                    context,
                    user_id, // ID do usuário atual
                    widget.idEvento, // ID do evento
                    tituloEvento, // Nome real do evento
                    dataEvento, // Data real do evento
                    localEvento); // Substitua `usuarioId` e `eventoId` pelos valores corretos
              }, // -----------------------------------------------------------
              iconSize: 23,
            ),
          ),
        ],
      ), //--------------------APP BARR
      backgroundColor: const Color.fromARGB(255, 242, 242, 242),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //////////////->>>>>>>>>>>>>>>>IMAGEM DO EVENTO
            if (imagePath.isNotEmpty)
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ImagemFullscreen(caminhoImagem: imagePath),
                        ),
                      );
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3.5,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File(imagePath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height /
                          (3.5 * 10), // Altura do contêiner vermelho
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 242, 242, 242),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              //>>>>>>>>>>>>>>>>>>>CARACTERISTICAS DO EVENTO
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //const SizedBox(height: 10),//////////nome
                  Text(
                    nomeEvento,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.event_available,
                          color: getCorPorAreaId(idArea)),
                      const SizedBox(width: 5),
                      Text(
                        '$dia de $mes $ano',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 20),
                      Icon(Icons.access_time_filled_rounded,
                          color: getCorPorAreaId(idArea)),
                      const SizedBox(width: 5),
                      Text(
                        horas,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.event_busy_rounded, color: Colors.red),
                      const SizedBox(width: 5),
                      Text(
                        '$dia_fim de $mes_fim $ano_fim',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.timelapse_rounded, color: Colors.red),
                      const SizedBox(width: 5),
                      Text(
                        horas_fim,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.location_on,
                          color: getCorPorAreaId(idArea),
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'Localização',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      local,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: ElevatedButton.icon(
                        onPressed: () => _openGoogleMaps(latitude, longitude),
                        icon: Image.asset(
                          'assets/images/local_vermapa.png', // Caminho da imagem nos assets
                          width: 20, // Largura da imagem
                          height: 20, // Altura da imagem
                          color:
                              Colors.white, // Se você quiser colorir a imagem
                        ),
                        label: const Text(
                          'Ver no Mapa',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: getCorPorAreaId(idArea),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10), // Padding interno
                        ),
                      )),
                  const SizedBox(
                    height: 15,
                  ),
                  //<<<<<<<<<<<<<<<<<participantes
                  Row(
                    children: [
                      // Primeiro Container
                      Expanded(
                        flex: 1,
                        child: Container(
                          //color: Colors.blue,
                          child: Column(
                            children: [
                              // Linha com o ícone e o texto "Organizado por"
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(
                                      Icons.emoji_people_rounded,
                                      color: getCorPorAreaId(
                                          idArea), // Cores dinâmicas baseadas em ID
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Organizado por',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          pagina_de_perfil_vista(
                                              idUsuario: id_criador),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          34), // Adiciona 10 pixels de padding à esquerda
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: FileImage(File(
                                            caminhoFotoCriador)), // Usa FileImage com File
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          nomeCriador,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      // Segundo Container
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width /
                                  12.5), // Ajuste o valor conforme necessário
                          child: Container(
                            //color: Color.fromARGB(148, 159, 122, 120),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people_rounded,
                                      color: getCorPorAreaId(
                                          idArea), // Cores dinâmicas baseadas em ID
                                      size: 25,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Vão(${participantesIds.length})',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PagListaParticipantesEvento(
                                          idEvento: widget.idEvento,
                                          cor: getCorPorAreaId(idArea),
                                        ),
                                      ),
                                    );
                                  },
                                  child: buildStackedImages(participantesFotos),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

/////////////////////<<<<<<<<<<<<<DESCRICAO
                  ///
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.subject_rounded,
                          color: getCorPorAreaId(idArea),
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'Sobre este Evento',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(descricao,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.15,
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  /////<<<<<<<<<<<<<<<<<<<<<<<<<<RELACIONADO COM O EVENTO
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: getCorPorAreaId(idArea),
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'Relacionado com este Evento',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    padding: const EdgeInsets.only(left: 30),
                    child: Wrap(
                      spacing: 15, // Espaço horizontal entre os chips
                      runSpacing: 10, // Espaço vertical entre as linhas
                      children: [
                        if (topico.isNotEmpty && imagem_topico.isNotEmpty)
                          cardAreaInteressesCustom(
                            nomeArea: topico,
                            corArea: corArea,
                            imagemArea: imagem_topico,
                          ),
                        if (tipoEvento.isNotEmpty &&
                            imagem_tipoevento.isNotEmpty)
                          cardTipoInteressesCustom(
                            nomeArea: tipoEvento,
                            corArea: corArea,
                            imagemArea: imagem_tipoevento,
                          ),
                      ],
                    ),
                  ),
////<<<<<<<<<<<<<<<<<<<<<<<COMENTARIOS E AVALIACOES
                  ///
                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.message_rounded,
                          color: getCorPorAreaId(idArea),
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'Comentaios e Avaliações',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  if (comentarios.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: Row(
                        children: [
                          Text(
                            calcular_media_classificacao().toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingStars(
                                starSize: 13,
                                rating: calcular_media_classificacao(),
                                fillColor: Colors.amber,
                                emptyColor: Colors.grey,
                              ),
                              Text(
                                "com base em ${comentarios.length} comentário(s)",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        criar_cometario_evento(
                                            cor: getCorPorAreaId(idArea),
                                            id_evento: widget.idEvento)),
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all<Color>(Colors.white),
                              foregroundColor:
                                  WidgetStateProperty.all<Color>(corArea),
                              overlayColor: WidgetStateProperty.all<Color>(
                                  Colors.green[100]!),
                              side: WidgetStateProperty.all<BorderSide>(
                                  BorderSide(color: corArea, width: 1)),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            child: const Text("Comentar"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 14, right: 14),
                        child: CARD_COMENTAARIO_EVENTO(
                          idComentario: comentarios.last['id'],
                          userId: comentarios.last['user_id'],
                          dataComentario: comentarios.last['data_comentario'],
                          classificacao: comentarios.last['classificacao'],
                          textoComentario: comentarios.last['texto_comentario'],
                          idEvento: comentarios.last['evento_id'],
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 10,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => pag_cometarios_evento(
                                    id_evento: widget.idEvento,
                                    cor: getCorPorAreaId(idArea)),
                              ));
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(corArea),
                          foregroundColor: WidgetStateProperty.all<Color>(
                              const Color.fromARGB(255, 255, 255, 255)),
                          overlayColor: WidgetStateProperty.all<Color>(
                              corArea.withOpacity(0.3)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        child: const Text("Mostrar todos os comentários"),
                      ),
                    ),
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, right: 30, top: 10, bottom: 5),
                      child: Center(
                        child: Text(
                          "Sem comentários ainda!",
                          style: TextStyle(
                            color: Color.fromARGB(255, 148, 148, 148),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 10,
                      padding: const EdgeInsets.only(
                        left: 14.0,
                        right: 14,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => criar_cometario_evento(
                                    cor: getCorPorAreaId(idArea),
                                    id_evento: widget.idEvento)),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(corArea),
                          overlayColor: WidgetStateProperty.all<Color>(
                              corArea.withOpacity(0.3)),
                          side: WidgetStateProperty.all<BorderSide>(
                              BorderSide(color: corArea, width: 1)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        child: const Text("Comentar"),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.photo_library,
                          color: getCorPorAreaId(idArea),
                          size: 25,
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const Text(
                        'Galeria',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (caminhos_Imagens.isNotEmpty)
                    ImageGalleryLayout(
                      idEvento: widget.idEvento,
                      imagePaths: caminhos_Imagens,
                      cor: getCorPorAreaId(idArea),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 30.0, right: 30, top: 10, bottom: 5),
                      child: Center(
                        child: Text(
                          "Sem imagens ainda!",
                          style: TextStyle(
                            color: Color.fromARGB(255, 148, 148, 148),
                          ),
                        ),
                      ),
                    ),

                  //////DENUNCIAR
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.dangerous,
                            color: Color.fromARGB(255, 235, 7, 7),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Pag_denunciar_evento(
                                  id_evento: widget.idEvento),
                            ),
                          );
                        },
                        child: const Text(
                          'Denunciar Evento',
                          style: TextStyle(
                            color: Color.fromARGB(255, 235, 7, 7),
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.15,
                            decoration: TextDecoration.underline,
                            decorationColor: Color.fromARGB(255, 235, 7, 7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: buildSpeedDial(context, corArea, widget.idEvento),
    );
  }
}

Widget buildSpeedDial(BuildContext context, Color cor, int idEvento) {
  return SpeedDial(
    backgroundColor: cor, // Cor de fundo do SpeedDial
    foregroundColor: Colors.white, // Cor do ícone/texto
    curve: Curves.bounceIn,
    overlayOpacity: 0.0,
    buttonSize: const Size(150, 60),

    onPress: () async {
      // Obtenha o ID do usuário logado
      final usuarioProvider =
          Provider.of<Usuario_Provider>(context, listen: false);
      int usuarioId = usuarioProvider.usuarioSelecionado!.id_user;

      // Verifica se o usuário já está inscrito no evento
      bool inscrito =
          await Funcoes_Participantes_Evento.verificarInscricaoUsuarioEvento(
              usuarioId, idEvento);

      if (inscrito) {
        // Se o usuário já está inscrito, exibe um diálogo de confirmação
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              titlePadding:
                  const EdgeInsets.all(16.0), // Padding ao redor do título
              // ignore: prefer_const_constructors
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.warning_amber_rounded, // Ícone que representa o aviso
                    color: Colors.red,
                    size: 48, // Tamanho do ícone
                  ),
                  SizedBox(height: 8), // Espaço entre o ícone e o título
                  Text(
                    'Você está inscrito neste Evento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'Deseja anular a inscrição?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Cor de fundo do botão "Não"
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        child: const Text(
                          'Não',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 10), // Espaço entre os botões
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                        ),
                        child: const Text(
                          'Sim',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          String resultado = await ApiEventos()
                              .removerParticipanteEvento(usuarioId, idEvento);

                          if (resultado == "Inscrição cancelada com sucesso!") {
                            await Funcoes_Participantes_Evento
                                .removerParticipanteEvento(usuarioId, idEvento);
                          }
                          Navigator.of(context).pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    resultado ==
                                            "Inscrição cancelada com sucesso!"
                                        ? Icons.check_circle_outline
                                        : Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Espaço entre o ícone e o texto
                                  Expanded(
                                    child: Text(resultado),
                                  ),
                                ],
                              ),
                              backgroundColor: resultado ==
                                      "Inscrição cancelada com sucesso!"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PagInscricaoEvento(
              idEvento: idEvento,
              cor: cor,
            ),
          ),
        );
      }
    },
    child: Container(
      width: 33,
      height: 33,
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
                'assets/images/increver_evento.png'), // Caminho para a imagem
            fit: BoxFit.cover),
        shape: BoxShape.circle,
      ),
    ), // Tamanho do botão principal
  );
}

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double starSize;
  final Color fillColor;
  final Color emptyColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    required this.starSize,
    this.fillColor = Colors.amber,
    this.emptyColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        if (index + 1 <= rating) {
          // Estrela preenchida
          return Icon(
            Icons.star,
            size: starSize,
            color: fillColor,
          );
        } else if (index < rating && index + 1 > rating) {
          // Estrela parcialmente preenchida
          return Icon(
            Icons.star_half,
            size: starSize,
            color: fillColor,
          );
        } else {
          // Estrela vazia
          return Icon(
            Icons.star_border,
            size: starSize,
            color: emptyColor,
          );
        }
      }),
    );
  }
}
