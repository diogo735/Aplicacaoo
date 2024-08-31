import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/card_tags_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/criar_evento/pagina_loading_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/galeria_na_pagina_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/galeria_imagem.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class CarregandoPagina extends StatefulWidget {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFim;
  final String local;
  final int? idTipoEvento;
  final String titulo;
  final String descricao;
  final File? capa;
  final List<File> imagensGaleria;
  final int idArea;
  final int idTopico;

  CarregandoPagina({
    Key? key,
    this.dataInicio,
    this.dataFim,
    this.horaInicio,
    this.horaFim,
    required this.local,
    required this.idArea,
    this.idTipoEvento,
    required this.idTopico,
    required this.titulo,
    required this.descricao,
    this.capa,
    required this.imagensGaleria,
  }) : super(key: key);

  @override
  _CarregandoPaginaState createState() => _CarregandoPaginaState();
}

class _CarregandoPaginaState extends State<CarregandoPagina> {
  double? _latitude;
  double? _longitude;
  late int user_id;
  late String nomeCriador = '';
  late String caminhoFotoCriador = '';

  late String nomeArea;
  late Color corArea;
  late String imagemArea;
  late String tipoEvento = '';
  late String imagem_tipoevento = '';
  late String _address = '';
  late String topico = '';
  late String imagem_topico = '';

  @override
  void initState() {
    super.initState();
    _getCoordinatesFromName();
    _carregarDetalhesCriador();
    _carregarDetalhesArea();
    _carregarDadosTipoEvento();
    _carregarDadosTopicos();
  }

  void _carregarDetalhesArea() {
    Map<String, dynamic> detalhesArea = obter_detalhes_Area(widget.idArea);

    setState(() {
      nomeArea = detalhesArea['nome_area'];
      corArea = detalhesArea['cor_area'];
      imagemArea = detalhesArea['imagem_area'];
    });
  }

  void _carregarDadosTipoEvento() async {
    if (widget.idTipoEvento != null) {
      Map<String, String> dados =
          await Funcoes_TipodeEvento.obterDadosTipoEvento(widget.idTipoEvento!);

      setState(() {
        tipoEvento = dados['nome']!;
        imagem_tipoevento = dados['imagem']!;
      });
    } else {
      setState(() {
        tipoEvento = "Desconhecido";
        imagem_tipoevento = "assets/images/sem_resultados.png";
      });
    }
  }

  void _carregarDadosTopicos() async {
    if (widget.idTipoEvento != null) {
      Map<String, String> dados =
          await Funcoes_Topicos.obterDadosTopico(widget.idTopico);

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

  Map<String, dynamic> obter_detalhes_Area(int areaId) {
    String nomeArea = '';
    Color corArea = Colors.transparent;
    String imagemArea = '';

    switch (areaId) {
      case 1:
        nomeArea = 'Saúde';
        corArea = const Color(0xFF8F3023);
        imagemArea = 'assets/images/fav_saude.png';
        break;
      case 2:
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
      case 5:
        nomeArea = 'Alojamento';
        corArea = const Color(0xFF815520);
        imagemArea = 'assets/images/fav_alojamento.png';
        break;
      case 6:
        nomeArea = 'Transportes';
        corArea = const Color(0xFFB7BB06);
        imagemArea = 'assets/images/fav_transportes.png';
        break;
      case 7:
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

  Future<void> _carregarDetalhesCriador() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;
    String caminhoFoto =
        await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(user_id);
    String nomeCompleto =
        await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(user_id);
    Usuario? usuarioAtual =
        Provider.of<Usuario_Provider>(context, listen: false)
            .usuarioSelecionado;
    setState(() {
      caminhoFotoCriador = caminhoFoto;
      if (usuarioAtual != null && usuarioAtual.id_user == user_id) {
        nomeCriador = "Eu";
      } else {
        nomeCriador = nomeCompleto;
      }
    });
  }

  void _getCoordinatesFromName() async {
    LocalizacaoOSM localizacaoOSM = LocalizacaoOSM();
    var coordinates = await localizacaoOSM.getCoordinatesFromName(widget.local);
    setState(() {
      _latitude = coordinates['latitude'];
      _longitude = coordinates['longitude'];
    });
    _carregarDetalhesLocal();
  }

  Future<void> _carregarDetalhesLocal() async {
    try {
      Map<String, String> enderecoDetalhado = await LocalizacaoOSM()
          .getDetailedAddressFromCoordinates(_latitude!, _longitude!);
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
        _address = enderecoFormatado;
      });
    } catch (e) {
      print('Erro ao obter detalhes do local: $e');
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
      case 1:
        return const Color(0xFF8F3023); // Saúde
      case 2:
        return const Color(0xFF53981D); // Desporto
      case 3:
        return const Color(0xFFA91C7A); // Gastronomia
      case 4:
        return const Color(0xFF3779C6); // Formação
      case 5:
        return const Color(0xFF815520); // Alojamento
      case 6:
        return const Color(0xFFB7BB06); // Transportes
      case 7:
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

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;
    // Exemplo de impressão do idTopico
    //print('O id do tópico recebido é: ${widget.idTopico}');

    return Scaffold(
        appBar: AppBar(
          title: const Text('Pré-Vizualização',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
              )),
          backgroundColor: getCorPorAreaId(widget.idArea),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 242, 242, 242),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //////////////->>>>>>>>>>>>>>>>IMAGEM DO EVENTO
                  if (widget.capa != null && widget.capa!.existsSync())
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ImagemFullscreen(
                                    caminhoImagem: widget.capa!.path),
                              ),
                            );
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 3.5,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(widget.capa!),
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
                          widget.titulo,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.event_available,
                                color: getCorPorAreaId(widget.idArea)),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.dataInicio!.day} de ${_obterNomeMes(widget.dataInicio!.month)} ${widget.dataInicio!.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 20),
                            Icon(Icons.access_time_filled_rounded,
                                color: getCorPorAreaId(widget.idArea)),
                            const SizedBox(width: 5),
                            Text(
                              widget.horaInicio!.format(context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.event_busy_rounded,
                                color: Colors.red),
                            const SizedBox(width: 5),
                            Text(
                              '${widget.dataFim!.day} de ${_obterNomeMes(widget.dataFim!.month)} ${widget.dataFim!.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 20),
                            const Icon(Icons.timelapse_rounded,
                                color: Colors.red),
                            const SizedBox(width: 5),
                            Text(
                              widget.horaFim!.format(context),
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
                                color: getCorPorAreaId(widget.idArea),
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
                            _address,
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
                            onPressed: () =>
                                _openGoogleMaps(_latitude!, _longitude!),
                            icon: Image.asset(
                              'assets/images/local_vermapa.png', // Caminho da imagem nos assets
                              width: 20, // Largura da imagem
                              height: 20, // Altura da imagem
                              color: Colors
                                  .white, // Se você quiser colorir a imagem
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
                              backgroundColor: getCorPorAreaId(widget.idArea),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10), // Padding interno
                            ),
                          ),
                        ),
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
                                            color:
                                                getCorPorAreaId(widget.idArea),
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
                                      onTap: () {},
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                34), // Adiciona 10 pixels de padding à esquerda
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: FileImage(
                                                  File(caminhoFotoCriador)),
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
                                        12.5),
                                child: Container(
                                  //color: Color.fromARGB(148, 159, 122, 120),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.people_rounded,
                                            color:
                                                getCorPorAreaId(widget.idArea),
                                            size: 25,
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Vão(0)',
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
                                color: getCorPorAreaId(widget.idArea),
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
                            child: Text(widget.descricao,
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
                                color: getCorPorAreaId(widget.idArea),
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
                                color: getCorPorAreaId(widget.idArea),
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

                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.photo_library,
                                color: getCorPorAreaId(widget.idArea),
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
                        widget.imagensGaleria.isNotEmpty
                            ? ImageGalleryLayout2(
                                nome: widget.titulo,
                                imagePaths: widget.imagensGaleria
                                    .map((file) => file.path)
                                    .toList(),
                                cor: getCorPorAreaId(widget.idArea),
                              )
                            : const Padding(
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
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20.0, // Position the button slightly above the bottom
              left: 20.0,
              right: 20.0,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ValidarEventoCriar(
                        dataInicio: widget.dataInicio,
                        dataFim: widget.dataFim,
                        horaInicio: widget.horaInicio,
                        horaFim: widget.horaFim,
                        latitude: _latitude!,
                        longitude: _longitude!,
                        idTipoEvento: widget.idTipoEvento,
                        titulo: widget.titulo,
                        descricao: widget.descricao,
                        capa: widget.capa,
                        imagensGaleria: widget.imagensGaleria,
                        idArea: widget.idArea,
                        idTopico: widget.idTopico,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.check,
                  size: 25,
                  color: Colors.white,
                ),
                label: const Text(
                  'Publicar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  backgroundColor: corArea,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

Widget buildSpeedDial(
  BuildContext context,
  Color cor,
) {
  return SpeedDial(
    backgroundColor: Colors.transparent, // Make the background transparent
    foregroundColor: Colors.white, // Icon/text color
    curve: Curves.bounceIn,
    overlayOpacity: 0.0,
    buttonSize: const Size(
        double.infinity, 60), // Make button width infinite to match the parent
    onPress: () {},
    child: Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Add your onPressed logic here
        },
        icon: const Icon(
          Icons.check,
          size: 25,
          color: Colors.white,
        ),
        label: const Text(
          'Publicar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 5, // Add some shadow to make it more prominent
          backgroundColor: cor, // Button background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Adjust the border radius
          ),
        ),
      ),
    ),
  );
}
