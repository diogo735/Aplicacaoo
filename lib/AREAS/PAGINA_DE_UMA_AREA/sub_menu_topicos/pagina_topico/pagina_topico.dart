import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_criar_publicacaO/pagina_criar_publicacao.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicosfavoritos_user.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos_imgens.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/card_publicacao.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagnia_de_uma_publicacao.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class paginatopico extends StatefulWidget {
  final int idtopico;
  final Color cor;

  paginatopico({required this.idtopico, required this.cor});
  @override
  _paginatopicoState createState() => _paginatopicoState();
}

class _paginatopicoState extends State<paginatopico> {
  double _latitude = 0;
  double _longitude = 0;
  Map<int, String> imagemPaths = {};
  bool isLoading = true;
  int? areaId;
  @override
  void initState() {
    super.initState();
    carregarAreaId(widget.idtopico);
    buscarDetalhesTopico(widget.idtopico);
    buscarImagensDoTopico(widget.idtopico);
    _verificarSeFavorito();
    _carregarPublicacoes(widget.idtopico);
  }

  late String nomeDoTopico = "";
  late List<String> imagensDoTopico = [];
  List<Map<String, dynamic>> publicacoes = [];

  Future<void> buscarDetalhesTopico(int idtopico) async {
    String? nome = await Funcoes_Topicos.obternomedoTopico(idtopico);
    setState(() {
      nomeDoTopico = nome!;
    });
  }

  Future<void> carregarAreaId(int idTopico) async {
    // Chama a função para obter os dados do tópico
    Map<String, dynamic> dadosTopico =
        await Funcoes_Topicos.obterDadosTopicoEid(idTopico);

    setState(() {
      areaId = int.tryParse(dadosTopico['area_id']);
    });
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

  void _carregarPublicacoes(int idtopico) async {
    await _getLocation();

    Funcoes_Publicacoes_Imagens funcoesPublicacoesImagens =
        Funcoes_Publicacoes_Imagens();

    // Crie uma lista mutável a partir da lista retornada
    List<Map<String, dynamic>> publicacoesCarregadas =
        (await Funcoes_Publicacoes.consultarPublicacoesPorIdTopico(idtopico))
            .map((publicacao) => Map<String, dynamic>.from(publicacao))
            .toList();

    for (var publicacao in publicacoesCarregadas) {
      Map<String, dynamic>? primeiraImagem = await funcoesPublicacoesImagens
          .retorna_primeira_imagem(publicacao['id']);
      imagemPaths[publicacao['id']] = primeiraImagem != null
          ? primeiraImagem['caminho_imagem']
          : 'assets/images/sem_imagem.png';

      String local = publicacao['local'];

      // Obter coordenadas do local da publicação
      Map<String, double> coordenadas =
          await LocalizacaoOSM().getCoordinatesFromName(local);

      // Salvar as coordenadas na publicação
      publicacao['latitude'] = coordenadas['latitude'];
      publicacao['longitude'] = coordenadas['longitude'];

      // Calcular a distância entre o usuário e o local da publicação
      double distance = calculateDistance(_latitude, _longitude,
          coordenadas['latitude']!, coordenadas['longitude']!);

      // Armazenar a distância formatada como string na publicação
      publicacao['distance'] =
          "${distance.toStringAsFixed(1)} Km"; // Certifique-se de que a distância é armazenada como String
    }

    if (!mounted) return;
    setState(() {
      publicacoes = publicacoesCarregadas;
      isLoading = false;
    });
  }

  Future<void> buscarImagensDoTopico(int idtopico) async {
    List<Map<String, dynamic>> imagens =
        await Funcoes_Topicos_imagens().consultaImagensPorTopico(idtopico);
    setState(() {
      imagensDoTopico =
          imagens.map((imagem) => imagem['topico_imagem'] as String).toList();
    });
  }

  bool isFavorited = false;
// Função para verificar se o tópico é favorito
  void _verificarSeFavorito() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final user_id = usuarioProvider.usuarioSelecionado!.id_user;

    List<int> topicosFavoritos =
        await Funcoes_TopicosFavoritos.obeter_topicos_favoritos_do_userid(
            user_id);

    setState(() {
      isFavorited = topicosFavoritos.contains(widget.idtopico);
    });
  }

  void toggleFavorite() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final user_id = usuarioProvider.usuarioSelecionado!.id_user;

    // Verifica a conexão com a internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8.0),
              Text('Sem conexão com a internet.'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return; // Sai da função se não houver conexão com a internet
    }

    print('Botão de estrela foi clicado');

    setState(() {
      isFavorited = !isFavorited;
    });

    try {
      if (isFavorited) {
        bool sucesso =
            await ApiUsuarios().inserirTopicoFavorito(user_id, widget.idtopico);
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.star_rounded, color: Colors.white),
                  const SizedBox(width: 8.0),
                  Text('"$nomeDoTopico" marcado como tópico favorito!'),
                ],
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            isFavorited = false;
          });
        }
      } else {
        bool sucesso =
            await ApiUsuarios().removerTopicoFavorito(user_id, widget.idtopico);
        if (sucesso) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Icon(Icons.star_outline, color: Colors.white),
                  const SizedBox(width: 8.0),
                  Text('"$nomeDoTopico" removido dos tópicos favoritos.'),
                ],
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          setState(() {
            isFavorited = true;
          });
        }
      }
    } catch (e) {
      // Tratamento de exceções relacionadas à rede
      print('Erro ao tentar alterar o tópico favorito: $e');
      setState(() {
        isFavorited = !isFavorited; // Reverte a mudança no estado
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8.0),
              Text('Falha ao conectar ao servidor.'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double bottomMargin = 20.0;
  double rightMargin = 12.0;
  double appBarHeight = 250.0;

  bool floating_botao = true;

  bool clicouporcurar = false;
  String pesquisa = '';
  bool exibirResultadosPesquisa = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        body: clicouporcurar ? _corpoquandopesquiso() : _corponormal(),
        floatingActionButton: Visibility(
          visible: floating_botao,
          child: SpeedDial(
            icon: Icons.add,
            backgroundColor: widget.cor,
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            curve: Curves.bounceIn,
            overlayColor: null,
            overlayOpacity: 0.0,
            buttonSize: const Size(150, 60),
            childrenButtonSize: const Size(150, 60),
            children: [
              SpeedDialChild(
                child: Material(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: widget.cor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: widget.cor, // Cor de fundo do botão
                  child: Container(
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.create_rounded,
                            color: Color.fromARGB(
                                255, 255, 255, 255)), // Adicione o ícone aqui
                        SizedBox(width: 6),
                        Text(
                          'Sugerir Local',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                backgroundColor: widget.cor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaginaCriarPublicacao(
                        idArea: areaId!,
                        cor: widget.cor,
                      ),
                    ),
                  );
                },
              ),
              if (publicacoes.isNotEmpty)
                SpeedDialChild(
                  child: Material(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: widget.cor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color.fromARGB(
                        255, 255, 255, 255), // Cor de fundo do botão
                    child: Container(
                      alignment: Alignment.center, // Alinhamento do texto
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sort,
                              color: widget.cor), // Adiciona o ícone aqui
                          SizedBox(width: 8),
                          Text(
                            'Ordenar por',
                            style: TextStyle(
                              color: widget.cor, // Cor do texto
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold, // Peso da fonte do texto
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: widget.cor,
                  onTap: () {
                    _abrirOrdenarPor();
                  },
                ),
              if (publicacoes.isNotEmpty)
                SpeedDialChild(
                  child: Material(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1, color: widget.cor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded, color: widget.cor),
                          SizedBox(width: 8),
                          Text(
                            'Procurar por',
                            style: TextStyle(
                              color: widget.cor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  backgroundColor: widget.cor,
                  onTap: () {
                    setState(() {
                      clicouporcurar = true;
                      floating_botao = false;
                    });
                  },
                ),

              // Adicione mais botões conforme necessário
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _corpoquandopesquiso() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nomeDoTopico ?? 'Tópico',
          style: const TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: widget.cor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isFavorited ? Icons.star : Icons.star_outline,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                toggleFavorite();
              });
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 226, 226, 226),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        pesquisa = value;
                      });
                    },
                    onSubmitted: (value) {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        exibirResultadosPesquisa = true;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Procurar por ...',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: widget.cor),
                      ),
                    ),
                    cursorColor: widget.cor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: widget.cor),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      exibirResultadosPesquisa = true;
                    });
                  },
                ),
              ],
            ),
            Visibility(
              visible: exibirResultadosPesquisa,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: publicacoes
                      .where((publication) =>
                          publication['nome']
                              ?.toLowerCase()
                              ?.contains(pesquisa.toLowerCase()) ??
                          false)
                      .length,
                  itemBuilder: (context, index) {
                    var resultados = publicacoes
                        .where((publication) =>
                            publication['nome']
                                ?.toLowerCase()
                                ?.contains(pesquisa.toLowerCase()) ??
                            false)
                        .toList();

                    var publication = resultados[index];

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: Funcoes_Publicacoes_Imagens()
                          .retorna_primeira_imagem(publication['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Erro ao carregar imagem');
                        } else {
                          // Se não houver imagem, define um caminho de imagem padrão
                          String imagePath = snapshot.data?['caminho_imagem'] ??
                              'assets/images/imagem_padrao.png';

                          // Verificando outros dados que podem ser null
                          String nomePublicacao =
                              publication['nome'] ?? 'Nome não disponível';
                          String local =
                              publication['local'] ?? 'Local não disponível';

                          return InkWell(
                            onTap: () {
                              // Aqui você pode navegar para a página do evento
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pagina_publicacao(
                                    idPublicacao: publication['id'],
                                    cor: widget.cor,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: 10, bottom: 10, left: 5, right: 5),
                              child: CARD_PUBLICACAO(
                                context: context,
                                nomePublicacao: nomePublicacao,
                                local: local,
                                classificacao_media:
                                    '0', // Pode ser ajustado conforme necessário
                                imagePath:
                                    imagePath, // Caminho correto da imagem ou imagem padrão
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> ordenarPorgostos(
      List<Map<String, dynamic>> lista) {
    lista.sort((a, b) {
      if (a['classificacao_media'] != null &&
          b['classificacao_media'] != null) {
        return b['classificacao_media'].compareTo(a['classificacao_media']);
      }
      return 0;
    });
    return lista;
  }

  void _abrirOrdenarPor() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Ordenar Locais por:',
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
                    ElevatedButton(
                      onPressed: () async {
                        List<Map<String, dynamic>> pubOrdenados =
                            await Funcoes_Publicacoes
                                .consultarPublicacoesPorIdTopico(
                                    widget.idtopico);
                        setState(() {
                          publicacoes = pubOrdenados;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 21, 20, 22),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/icon_destaque.png',
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Em Destaque',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF79747E),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Color(0xFF79747E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mais Perto',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        List<Map<String, dynamic>> pubOrdenados =
                            List.from(publicacoes);
                        ordenarPorgostos(pubOrdenados);
                        setState(() {
                          publicacoes = pubOrdenados;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF79747E),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_up_alt_rounded,
                              color: Color(0xFF79747E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Melhor Classificação',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        /*
                        List<Map<String, dynamic>> eventosOrdenados =
                            List.from(eventos);
                        ordenarPorDataCriacao(eventosOrdenados);
                        setState(() {
                          eventos = eventosOrdenados;
                          //print("Grupos ordenados:");
                          //for (var grupo in grupos) {
                          // print(grupo[
                          //   'nome']);
                          // }
                        });*/
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF79747E),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/icon_maisnovos.png',
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mais Recentes',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          setState(() {
                            floating_botao =
                                true; // Atualiza o estado do botão flutuante
                          });
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
        );
      },
    );
  }

  Widget _corponormal() {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            title: Text(
              nomeDoTopico,
              style: const TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
              ),
            ),
            backgroundColor: widget.cor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.star : Icons.star_outline,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    toggleFavorite();
                  });
                },
              ),
            ],
            floating: false,
            pinned: true,
            snap: false,
            expandedHeight: appBarHeight - 50,
            flexibleSpace: FlexibleSpaceBar(
              background: imagensDoTopico.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: appBarHeight,
                        enlargeCenterPage: false,
                        autoPlay: true,
                        aspectRatio: 16 / 9,
                        viewportFraction: 1.0,
                      ),
                      items: imagensDoTopico.map((imagem) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(imagem),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(
                                    0.20), // Ajuste o valor de opacidade conforme necessário
                                BlendMode
                                    .darken, // Aqui você pode ajustar o modo de mistura conforme desejado
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : Container(),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, color: widget.cor),
                        SizedBox(width: 8),
                        Text(
                          "Locais",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description, color: widget.cor),
                        SizedBox(width: 8),
                        Text(
                          "Documentação",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                indicatorColor: widget.cor,
                labelColor: widget.cor,
                unselectedLabelColor: Color.fromARGB(56, 0, 0, 0),
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body:
          isLoading // Exibe o indicador de carregamento enquanto as publicações estão sendo carregadas
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(widget.cor),
                  ),
                )
              : TabBarView(
                  children: [
                    Container(
                        child: publicacoes.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/sem_resultados.png',
                                      width: 85,
                                      height: 85,
                                      fit: BoxFit.contain,
                                    ),
                                    const Text(
                                      'Sem locais !',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(
                                              255, 156, 156, 156)),
                                    )
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: publicacoes.map((publication) {
                                    // Aqui, obtém o path da imagem associada ao id da publicação
                                    String imagePath =
                                        imagemPaths[publication['id']] ??
                                            'assets/images/sem_imagem.png';

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    pagina_publicacao(
                                                      idPublicacao:
                                                          publication['id'],
                                                      cor: widget.cor,
                                                    )));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 5,
                                            right: 5),
                                        child: CARD_PUBLICACAO(
                                          context: context,
                                          nomePublicacao: publication['nome'],
                                          local: publication['local'],
                                          classificacao_media: 5.toString(),
                                          imagePath:
                                              imagePath, // Passando o caminho correto da imagem
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )),
                    Container(
                      child: const Center(
                        child: Text('Função ainda não disponível!'),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
