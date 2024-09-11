import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/Pagina_de_uma_partilha/pagina_de_uma_partilha.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagnia_de_uma_publicacao.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_mensagem_foruns.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';

import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'widget_cards/card_destaques_do_dia.dart';
import 'widget_cards/card_evetos_HOME.dart';
import 'widget_cards/card_publicacoes.dart';
import 'widget_cards/card_partilhas.dart';

import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/vertodos_eventos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/vertodos_partilhasfotos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/vertodos_publicacoes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ficha3/PAGINA_mudar_centro.dart';

class InicioPage extends StatefulWidget {
  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> eventos = [];
  Map<int, String> localPorEvento = {};
  List<Map<String, dynamic>> publicacoes = [];
  Map<int, String> imagemPaths = {};
  List<Map<String, dynamic>> partilhas = [];
  List<Map<String, dynamic>> centros = [];
  double _latitude = 0;
  double _longitude = 0;
  //late int centroId;
  Timer? _timerAPI;
  Timer? _timerDB;
  Map<int, int> numeroParticipantesPorEvento = {};
  Map<int, List<Map<String, dynamic>>> comentariosPorPublicacao = {};
  bool _isLoadingPublicacoes = true;
  @override
  void initState() {
    super.initState();
    _getLocation();
    _carregarCentros();
    _carregarEventos();
    carregarNumeroDeParticipantes();
    carregarLocais();
    _carregarPublicacoes();
    _carregarPartilhasfotos();
    _iniciarTimers();
  }

  void _iniciarTimers() {
    _timerAPI = Timer.periodic(
      Duration(seconds: 30),
      (Timer t) {
        if (mounted) {
          _carregarEventosDaAPI();
          _carregarPublicacoesDaAPI();
          _carregarPartilhasDaAPI();
          _carregarMensagensdosfrounsDaAPI();
        } else {
          t.cancel(); // Cancela o timer se o widget não estiver mais montado
        }
      },
    );

    Timer(Duration(milliseconds: 300), () {
      if (mounted) {
        carregarNumeroDeParticipantes();
        carregarLocais();
      }
    });

    _timerDB = Timer.periodic(Duration(seconds: 15), (Timer t) {
      if (mounted) {
        _carregarEventos();
        _carregarPublicacoes();
        carregarNumeroDeParticipantes();
        _carregarPartilhasfotos();
        carregarLocais();
      } else {
        t.cancel(); // Cancela o timer se o widget não estiver mais montado
      }
    });
  }

  Future<void> _carregarComentariosPublicacoesLocal() async {
    Funcoes_Comentarios_Publicacoes funcoesComentarios =
        Funcoes_Comentarios_Publicacoes();

    for (var publicacao in publicacoes) {
      int publicacaoId = publicacao['id'];

      // Consultar os comentários para esta publicação
      List<Map<String, dynamic>> comentariosCarregados =
          await funcoesComentarios
              .consultaComentariosPorPublicacao(publicacaoId);

      // Adiciona os comentários no mapa de comentários por publicação
      comentariosPorPublicacao[publicacaoId] = comentariosCarregados;
    }
  }

  Future<void> _getLocation() async {
    Localizacao localizacao = Localizacao();
    try {
      // Obter a posição atual do dispositivo
      Position position = await localizacao.determinaposicao();

      // Atualizar o estado com as coordenadas obtidas
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      print("Erro ao obter a localização: $e");
    }
  }

  Future<void> _carregarPartilhasDaAPI() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (!mounted) return;
      if (connectivityResult == ConnectivityResult.none) {
        print('Sem conexão com a internet');
        return;
      }

      final centroProvider =
          Provider.of<Centro_Provider>(context, listen: false);
      final centroSelecionado = centroProvider.centroSelecionado;

      if (centroSelecionado != null) {
        print('Iniciando o carregamento dos dados das partilhas da API...');
        await ApiPartilhas().fetchAndStorePartilhas(centroSelecionado.id);
        if (!mounted) return;

        await ApiPartilhas().fetchAndStoreComentarios();
        if (!mounted) return;
        print('Dados dos comentários das partilhas carregados com sucesso.');
      } else {
        print('Nenhum centro selecionado');
      }
    } on SocketException catch (e) {
      print('Erro de rede: $e');
    } catch (e) {
      print('Erro: $e');
    }
  }
 Future<void> _carregarMensagensdosfrounsDaAPI() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (!mounted) return;
      if (connectivityResult == ConnectivityResult.none) {
        print('Sem conexão com a internet');
        return;
      }

      final centroProvider =
          Provider.of<Centro_Provider>(context, listen: false);
      final centroSelecionado = centroProvider.centroSelecionado;

      if (centroSelecionado != null) {
        print('Iniciando o carregamento das mensagens dos foruns da API...');
         print('2.2.3->>Iniciando o carregamento das MENSAGENS DOS FORUNS...');
        await ApiMensagensForum().fetchAndStoreMensagensForum();
        if (!mounted) return;
        print('Dados dos comentários dos foruns carregados com sucesso.');
      } else {
        print('Nenhum centro selecionado');
      }
    } on SocketException catch (e) {
      print('Erro de rede: $e');
    } catch (e) {
      print('Erro: $e');
    }
  }
  Future<void> _carregarMensagensDaAPI() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (!mounted) return;
      if (connectivityResult == ConnectivityResult.none) {
        print('Sem conexão com a internet');
        return;
      }

      final centroProvider =
          Provider.of<Centro_Provider>(context, listen: false);
      final centroSelecionado = centroProvider.centroSelecionado;

      if (centroSelecionado != null) {
        print('Iniciando o carregamento dos dados das partilhas da API...');
        await ApiPartilhas().fetchAndStorePartilhas(centroSelecionado.id);
        if (!mounted) return;

        await ApiPartilhas().fetchAndStoreComentarios();
        if (!mounted) return;
        print('Dados dos comentários das partilhas carregados com sucesso.');
      } else {
        print('Nenhum centro selecionado');
      }
    } on SocketException catch (e) {
      print('Erro de rede: $e');
    } catch (e) {
      print('Erro: $e');
    }
  }

  Future<void> _carregarEventosDaAPI() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (!mounted) return;
      if (connectivityResult == ConnectivityResult.none) {
        print('Sem conexão com a internet');
        return;
      }

      final usuarioProvider =
          Provider.of<Usuario_Provider>(context, listen: false);
      final user_id = usuarioProvider.usuarioSelecionado!.id_user;

      final centroProvider =
          Provider.of<Centro_Provider>(context, listen: false);
      final centroSelecionado = centroProvider.centroSelecionado;

      if (centroSelecionado != null) {
        print('1->>Iniciando o carregamento dos EVENTOS...');
        await ApiEventos().fetchAndStoreEventos(centroSelecionado.id, user_id);
        if (!mounted) return;

        print('2->>Iniciando o carregamento dos PARTICIPANTES DOS EVENTOS...');
        await ApiEventos()
            .fetchAndStoreParticipantes(centroSelecionado.id, user_id);
        if (!mounted) return;

        print('3->>Iniciando o carregamento das IMAGENS DOS EVENTOS...');
        await ApiEventos()
            .fetchAndStoreImagensEvento(centroSelecionado.id, user_id);
        if (!mounted) return;

        print('4->>Iniciando o carregamento dos COMENTÁRIOS DOS EVENTOS...');
        await ApiEventos()
            .fetchAndStoreComentariosEvento(centroSelecionado.id, user_id);
        if (!mounted) return;
      } else {
        print('Nenhum centro selecionado');
      }
    } on SocketException catch (e) {
      print('Erro de rede: $e');
    } catch (e) {
      print('Erro: $e');
    }
  }

  Future<void> _carregarPublicacoesDaAPI() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (!mounted) return;
      if (connectivityResult == ConnectivityResult.none) {
        print('Sem conexão com a internet');
        return;
      }

      final usuarioProvider =
          Provider.of<Usuario_Provider>(context, listen: false);
      final user_id = usuarioProvider.usuarioSelecionado!.id_user;

      final centroProvider =
          Provider.of<Centro_Provider>(context, listen: false);
      final centroSelecionado = centroProvider.centroSelecionado;

      if (centroSelecionado != null) {
        print('1->>Iniciando o carregamento das PUBLICAÇÕES...');
        await ApiPublicacoes().fetchAndStorePublicacoes(centroSelecionado.id);

        print('2->>Iniciando o carregamento das COMENTARIOS PUBLICAÇÕES...');
        await ApiPublicacoes()
            .fetchAndStoreComentarios(centroSelecionado.id, user_id);

        if (!mounted) return;
      } else {
        print('Nenhum centro selecionado');
      }
    } on SocketException catch (e) {
      print('Erro de rede: $e');
    } catch (e) {
      print('Erro: $e');
    }
  }

  ///Função para carregar os eventos da base de dados//////////////////////////////////////////////////
  void _carregarEventos() async {
    Funcoes_Eventos funcoesEventos = Funcoes_Eventos();
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;

    List<Map<String, dynamic>> eventosCarregados =
        await funcoesEventos.consultaEventosPorCentroId(centroId);
    if (!mounted) return;
    setState(() {
      eventos = eventosCarregados;
    });
  }

  /// Função para carregar os centros da base de dados
  void _carregarCentros() async {
    List<Map<String, dynamic>> centrosCarregados =
        await Funcoes_Centros.consultaCentros();
    if (!mounted) return;
    setState(() {
      centros = centrosCarregados;
    });
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    print(
        'Latitude IIInicial: $startLatitude, Longitude inicial: $startLongitude');
    print('Latitude FFFinal: $endLatitude, Longitude final: $endLongitude');
    // Calcula a distância em metros
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    // Converte para quilômetros e arredonda para uma casa decimal
    double distanceInKilometers =
        double.parse((distanceInMeters / 1000).toStringAsFixed(1));
    return distanceInKilometers;
  }

  ///Função para carregar as PUBLICACOES da base de dados///////////////////////////////////////////////////////
  void _carregarPublicacoes() async {
    setState(() {
      _isLoadingPublicacoes = true; // Iniciar o carregamento
    });

    await _getLocation();

    Funcoes_Publicacoes funcoesPublicacoes = Funcoes_Publicacoes();
    Funcoes_Publicacoes_Imagens funcoesPublicacoesImagens =
        Funcoes_Publicacoes_Imagens();
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;

    List<Map<String, dynamic>> publicacoesCarregadas =
        (await funcoesPublicacoes.consultaPublicacoesPorCentroId(centroId))
            .map((publicacao) => Map<String, dynamic>.from(publicacao))
            .toList();

    for (var publicacao in publicacoesCarregadas) {
      Map<String, dynamic>? primeiraImagem = await funcoesPublicacoesImagens
          .retorna_primeira_imagem(publicacao['id']);
      imagemPaths[publicacao['id']] = primeiraImagem != null
          ? primeiraImagem['caminho_imagem']
          : 'assets/images/sem_imagem.png';

      String local = publicacao['local'];

      Map<String, double> coordenadas =
          await LocalizacaoOSM().getCoordinatesFromName(local);

      List<Map<String, dynamic>> comentariosCarregados =
          await Funcoes_Comentarios_Publicacoes()
              .consultaComentariosPorPublicacao(publicacao['id']);
      comentariosPorPublicacao[publicacao['id']] = comentariosCarregados;

      double mediaClassificacao =
          calcular_media_classificacao(comentariosCarregados);

      publicacao['mediaClassificacao'] = mediaClassificacao;

      publicacao['latitude'] = coordenadas['latitude'];
      publicacao['longitude'] = coordenadas['longitude'];

      double distance = calculateDistance(_latitude, _longitude,
          coordenadas['latitude']!, coordenadas['longitude']!);

      publicacao['distance'] = "${distance.toStringAsFixed(1)} Km";
    }

    if (!mounted) return;
    setState(() {
      publicacoes = publicacoesCarregadas;
      _isLoadingPublicacoes = false; // Finaliza o carregamento
    });
  }

  void _carregarPartilhasfotos() async {
    Funcoes_Partilhas funcoespartilhas = Funcoes_Partilhas();
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;

    print('Iniciando o carregamento dos dados das partilhas da BDLOCALL...');
    List<Map<String, dynamic>> partilhascarregadas =
        await funcoespartilhas.consultaPartilhasComCentroId(centroId);
    if (!mounted) return;
    setState(() {
      partilhas = partilhascarregadas;
    });
  }

  void _consultarPartilhas() async {
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;
    Funcoes_Partilhas funcoespartilhas = Funcoes_Partilhas();
    await funcoespartilhas.consultaPartilhasComCentroId(centroId);
  }

  void _mostrarCentros() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SizedBox(
            // Defina uma altura fixa para o modal
            height: MediaQuery.of(context)
                .size
                .height, // Por exemplo, 90% da altura da tela
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 15),
                            child: Text(
                              'Selecionar Polo Softinsa:',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 0.3,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0xFFCAC4D0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: centros.length,
                            itemBuilder: (BuildContext context, int index) {
                              var centro = centros[index];
                              return Column(
                                children: [
                                  ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: SizedBox(
                                        width: 80,
                                        height: 100,
                                        child: Image.file(
                                          File(centro['imagem_centro']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      centro['nome'],
                                      style: const TextStyle(
                                        color: Color(0xFF15659F),
                                        fontSize: 20,
                                        fontFamily: 'ABeeZee',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Pag_mudar_centro(
                                                    idCentro: centro['id'])),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 7),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  )
                ],
              ),
            ));
      },
    );
  }

  Future<void> carregarNumeroDeParticipantes() async {
    Map<int, int> participantes = {};

    for (var evento in eventos) {
      int eventoId = evento['id'];
      int numeroDeParticipantes =
          await Funcoes_Participantes_Evento.getNumeroDeParticipantes(eventoId);
      participantes[eventoId] = numeroDeParticipantes;
    }

    if (!mounted) return;
    setState(() {
      numeroParticipantesPorEvento = participantes;
    });
  }

  Future<void> carregarLocais() async {
    for (var evento in eventos) {
      if (!mounted) return; // Verificação antes de realizar qualquer operação

      int eventoId = evento['id'];
      double latitude = evento['latitude']; // Supondo que você tenha latitude
      double longitude =
          evento['longitude']; // Supondo que você tenha longitude

      try {
        String address = await _getAddressUsingOSM(latitude, longitude);

        if (!mounted) return; // Verificação após a operação assíncrona
        setState(() {
          localPorEvento[eventoId] = address;
        });
      } catch (e) {
        // Trate o erro, caso ocorra
        print('Erro ao obter o endereço: $e');
      }
    }
  }

  Future<String> _getAddressUsingOSM(double latitude, double longitude) async {
    LocalizacaoOSM localizacaoOSM = LocalizacaoOSM();
    return await localizacaoOSM.getEnderecoFromCoordinates(latitude, longitude);
  }

  @override
  void dispose() {
    print(
        "-----------------------------------------------------------------------dispose chamado");
    _timerAPI?.cancel();
    _timerDB?.cancel();
    super.dispose();
  }

  Color getColorForArea(int areaId) {
    switch (areaId) {
      case 1:
        return const Color(0xFF53981D); // Desporto
      case 2:
        return const Color(0xFF8F3023); // Saúde
      case 3:
        return const Color(0xFFA91C7A); // Gastronomia
      case 4:
        return const Color(0xFF3779C6); // Formação
      case 5:
        return const Color(0xFF25ABAB); // Lazer
      case 6:
        return const Color(0xFFB7BB06); // Transportes
      case 7:
        return const Color(0xFF815520); // Alojamento
      case 0:
        return const Color.fromARGB(255, 255, 255, 255); // Ver Info
      default:
        return Colors.grey; // Cor padrão para IDs não reconhecidos
    }
  }

  double calcular_media_classificacao(List comentarios) {
    if (comentarios.isEmpty) {
      return 0.0;
    }
    double somaClassificacoes = 0;
    for (var comentario in comentarios) {
      somaClassificacoes += comentario['classificacao'];
    }
    return somaClassificacoes / comentarios.length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final centroProvider = Provider.of<Centro_Provider>(context);
    final centroSelecionado = centroProvider.centroSelecionado;

    return Scaffold(
      //////////////////////////////////////////////////////A P P   B A R ////////////////////////////////////////////////////
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
            255, 255, 255, 255), // Definindo a cor de fundo como branco
        title: Row(
          children: [
            // Espaço entre o texto e o botão
            TextButton(
              onPressed: _mostrarCentros,
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255,
                    255), // Define a cor de fundo do botão para branco
                padding: const EdgeInsets.symmetric(
                    vertical: 20), // Aumenta a altura do botão
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // Remove os cantos arredondados
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centraliza o conteúdo horizontalmente
                children: [
                  Icon(Icons.location_on_sharp,
                      color: Color(0xFF15659F)), // Adiciona um ícone à esquerda
                  SizedBox(
                      width:
                          10), // Adiciona um espaço de 10 pixels entre o ícone e o texto
                  Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centraliza o conteúdo verticalmente
                    crossAxisAlignment:
                        CrossAxisAlignment.start, //alinha aesquerda
                    children: [
                      Text(
                        centroSelecionado != null
                            ? centroSelecionado.morada
                            : "morada do Centro",
                        style: TextStyle(
                          color: Color(0xFF15659F),
                          fontSize: 15,
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w300,
                          height: 0.09,
                        ),
                      ),
                      SizedBox(
                          height:
                              20), // Adiciona um espaço de 20 pixels entre as linhas de texto
                      Text(
                        centroSelecionado != null
                            ? centroSelecionado.nome
                            : "Nome do Centro",
                        style: TextStyle(
                          color: Color(0xFF15659F),
                          fontSize: 15.89,
                          fontFamily: 'Ubuntu',
                          fontWeight: FontWeight.w500,
                          height: 0.09,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 1),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: Color(0xFF15659F)), // Adiciona um ícone à esquerda
                ],
              ),
            ),
            Expanded(
                child:
                    Container()), //o container força o icone a ir para a esquerda
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/pagina_de_perfil');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: Provider.of<Usuario_Provider>(context)
                              .usuarioSelecionado
                              ?.foto !=
                          null
                      ? FileImage(File(Provider.of<Usuario_Provider>(context)
                          .usuarioSelecionado!
                          .foto!))
                      : AssetImage('assets/images/default_user_image.png')
                          as ImageProvider,
                ),
              ),
            )
          ],
        ),
      ),

      //////////////////////////////////////////////////////C O R P O ////////////////////////////////////////////////////
      backgroundColor: const Color(0xFFF6F6F6),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20.0, left: 10.0),
              child: SizedBox(
                width: 190,
                height: 22,
                child: Text(
                  'Destaques do Dia',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w700,
                    height: 0.07,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 240, // Altura do slider
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 240,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: false,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: [
                  ///FALTA POR DE ACORDO COM O CENTRO |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
                  CARD_DESTAQUES('Onde passear ?', 'assets/images/rossio.jpg'),
                  CARD_DESTAQUES('Onde dormir ?', 'assets/images/hotel.jpg'),
                  CARD_DESTAQUES('Onde comer ?', 'assets/images/keb.webp'),
                  CARD_DESTAQUES('Onde comprar ?', 'assets/images/forum.jpg'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 4; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == i
                          ? const Color(0xFF15659F)
                          : Colors.grey,
                    ),
                  ),
              ],
            ),

            /// L I S T A DE  E V E  N  T O S //////
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10.0, right: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Eventos',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      // height: 0.07,
                    ),
                  ),
                  if (eventos.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => vertodos_eventos()),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              color: Color(0xFF15659F),
                              fontSize: 16,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w500,
                              //height: 0.10,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: Color(0xFF15659F),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Lista horizontal de cards de eventos
            eventos.isNotEmpty
                ? SizedBox(
                    height: 227, // Altura da lista
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // Scroll horizontal
                      itemCount: eventos.length,
                      itemBuilder: (context, index) {
                        int eventoId = eventos[index]['id'];
                        int numeroParticipantes =
                            numeroParticipantesPorEvento[eventoId] ?? 0;
                        String local =
                            localPorEvento[eventoId] ?? 'Carregando...';
                        return GestureDetector(
                          onTap: () {
                            // Navega para a página do evento ao tocar no card
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaginaEvento(
                                  idEvento: eventos[index][
                                      'id'], // Certifique-se de passar o ID correto
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 4, right: 10, bottom: 10),
                            child: CARD_EVENTO(
                              nomeEvento: eventos[index]['nome'],
                              dia: eventos[index]['dia_realizacao'],
                              mes: eventos[index]['mes_realizacao'],
                              ano: eventos[index]['ano_realizacao'],
                              horas: eventos[index]['horas'],
                              local: local,
                              numeroParticipantes:
                                  numeroParticipantes.toString(),
                              imagePath: eventos[index]['caminho_imagem'],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: SizedBox(
                      height: 170, // Altura da lista
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/no_events.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Infelizmente,\n'
                              'o centro de ${centroSelecionado!.nome} \n'
                              'não tem eventos ainda!',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )),

            /// L I S T A DE  P U B L I C A  Ç O E S //////
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10.0, right: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Publicações',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      height: 0.07,
                    ),
                  ),
                  if (publicacoes.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Navegar para a nova página aqui
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => vertodos_publicacoes()),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              color: Color(0xFF15659F),
                              fontSize: 16,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w500,
                              height: 0.10,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: Color(0xFF15659F),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            publicacoes.isNotEmpty
                ? SizedBox(
                    height: 227,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, // scroll horizontal
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        int publicacaoId = publicacoes[index]['id'];
                        String imagePath = imagemPaths[publicacaoId] ??
                            'assets/images/sem_imagem.png';
// Supondo que você tem um mapa ou lista com os comentários por publicação
                        List comentarios =
                            comentariosPorPublicacao[publicacaoId] ?? [];

                        // Calcular a média de classificação da publicação
                        double mediaClassificacao =
                            calcular_media_classificacao(comentarios);
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => pagina_publicacao(
                                  idPublicacao: publicacaoId,
                                  cor: getColorForArea(publicacoes[index]
                                      ['area_id']), // ou outra cor apropriada
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 4, right: 10, bottom: 10),
                            child: CARD_PUBLICACAO(
                              nomePublicacao: publicacoes[index]['nome'],
                              local: publicacoes[index]['local'],
                              classificacao_media:
                                  mediaClassificacao.toStringAsFixed(1),
                              publicacaoId: publicacaoId,
                              imagePath: imagePath,
                              distancia:
                                  publicacoes[index]['distance'] as String,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: SizedBox(
                      height: 170, // Altura da lista
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/sem_resultados.png',
                              width: 50,
                              height: 50,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Infelizmente,\n'
                              'o centro de ${centroSelecionado!.nome} \n'
                              'não tem publicacões ainda!',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

            /// L I S T A DE  PARTILHAS //////
            Padding(
              padding: EdgeInsets.only(
                top: partilhas.isNotEmpty ? 5.0 : 15.0,
                left: 10.0,
                right: 1.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Partilhas',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w700,
                      height: 0.07,
                    ),
                  ),
                  if (partilhas.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => vertodos_partilhas()),
                        );
                      },
                      child: const Row(
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              color: Color(0xFF15659F),
                              fontSize: 16,
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w500,
                              height: 0.10,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: Color(0xFF15659F),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            partilhas.isNotEmpty
                ? SizedBox(
                    height: 294,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: partilhas.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: MediaQuery.of(context).size.width - 15,
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, bottom: 10),
                          child: FutureBuilder<String>(
                            future: partilhas[index]['id_evento'] != null
                                ? Funcoes_Eventos.consultaNomeEventoPorId(
                                    partilhas[index]['id_evento'])
                                : Future.value(''),
                            builder: (context, eventoSnapshot) {
                              return FutureBuilder<String>(
                                future: Funcoes_Usuarios
                                    .consultaNomeCompletoUsuarioPorId(
                                        partilhas[index]['id_usuario']),
                                builder: (context, usuarioSnapshot) {
                                  return FutureBuilder<String>(
                                    future: partilhas[index]['id_local'] != null
                                        ? Funcoes_Publicacoes
                                            .consultaNomeLocalPorId(
                                                partilhas[index]['id_local'])
                                        : Future.value(''),
                                    builder: (context, localSnapshot) {
                                      return FutureBuilder<String>(
                                        future: Funcoes_Usuarios
                                            .consultaCaminhoFotoUsuarioPorId(
                                                partilhas[index]['id_usuario']),
                                        builder: (context, fotoSnapshot) {
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaginaDaPartilha(
                                                    cor:
                                                        const Color(0xFF15659F),
                                                    idpartilha: partilhas[index]
                                                        ['id'],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: CARD_PARTILHA(
                                              context: context,
                                              Titulo: partilhas[index][
                                                  'titulo'], // Ajuste conforme necessário
                                              fotouser: fotoSnapshot.data ?? '',
                                              nomeuser:
                                                  usuarioSnapshot.data ?? '',
                                              imagePath: partilhas[index]
                                                  ['caminho_imagem'],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: SizedBox(
                      height: 170, // Altura da lista
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/sem_partilhas.png',
                              width: 45,
                              height: 45,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Infelizmente,\n'
                              'o centro de ${centroSelecionado!.nome} \n'
                              'não tem partilhas ainda!\n',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )),
          ],
        ),
      ),
    );
  }
}
