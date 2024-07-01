import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/Pagina_de_uma_partilha/pagina_de_uma_partilha.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/centro_provider.dart';
import '../BASE_DE_DADOS/basededados.dart';
import '../BASE_DE_DADOS/ver_estruturaBD.dart';
import 'package:ficha3/usuario_provider.dart';
import 'widget_cards/card_destaques_do_dia.dart';
import 'widget_cards/card_evetos_HOME.dart';
import 'widget_cards/card_publicacoes.dart';
import 'widget_cards/card_partilhas.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/vertodos_eventos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/vertodos_partilhasfotos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/vertodos_publicacoes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ficha3/PAGINA_mudar_centro.dart';

class InicioPage extends StatefulWidget {
  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> eventos = [];
  List<Map<String, dynamic>> publicacoes = [];
  List<Map<String, dynamic>> partilhas = [];
  List<Map<String, dynamic>> centros = [];
  //late int centroId;
  Timer? _timerAPI;
  Timer? _timerDB;

  @override
  void initState() {
    super.initState();
    _carregarCentros();
    _carregarEventos();
    _carregarPublicacoes();
    _carregarPartilhasfotos();
    _iniciarTimers();
  }

  void _iniciarTimers() {
    // Carregar partilhas da API a cada 30 segundos
    _timerAPI = Timer.periodic(
        Duration(seconds: 30), (Timer t) => _carregarPartilhasDaAPI());

    // Carregar partilhas da base de dados a cada 15 segundos
    _timerDB = Timer.periodic(
        Duration(seconds: 15), (Timer t) => _carregarPartilhasfotos());
  }

  Future<void> _carregarPartilhasDaAPI() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
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
        print('Dados das partilhas da API carregados com sucesso.');

        print('Iniciando o carregamento dos comentários das partilhas...');
        await ApiPartilhas().fetchAndStoreComentarios();
        print('Dados dos comentários das partilhas carregados com sucesso.');

        print('Iniciando o carregamento dos likes das partilhas...');
        await ApiPartilhas().fetchAndStoreLikes(centroSelecionado.id);
        print('Dados dos likes das partilhas carregados com sucesso.');
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
    //int centroId = 2; //////////////////
    List<Map<String, dynamic>> eventosCarregados =
        await funcoesEventos.consultaEventosPorCentroId(centroId);
    setState(() {
      eventos = eventosCarregados;
    });
  }

  /// Função para carregar os centros da base de dados
  void _carregarCentros() async {
    List<Map<String, dynamic>> centrosCarregados =
        await Funcoes_Centros.consultaCentros();
    setState(() {
      centros = centrosCarregados;
    });
  }

  ///Função para carregar as PUBLICACOES da base de dados///////////////////////////////////////////////////////
  void _carregarPublicacoes() async {
    Funcoes_Publicacoes funcoespublicacoes = Funcoes_Publicacoes();
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;
    List<Map<String, dynamic>> publicacoesCarregadas =
        await funcoespublicacoes.consultaPublicacoesPorCentroId(centroId);
    setState(() {
      publicacoes = publicacoesCarregadas;
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

  @override
  void dispose() {
    _timerAPI?.cancel();
    _timerDB?.cancel();
    super.dispose();
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
                      scrollDirection: Axis.horizontal, //  scroll horizontal
                      itemCount: eventos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, bottom: 10),
                          child: CARD_EVENTO(
                            nomeEvento: eventos[index]['nome'],
                            dia: eventos[index]['dia_realizacao'],
                            mes: eventos[index]['mes_realizacao'],
                            ano: eventos[index]['ano_realizacao'],
                            horas: eventos[index]['horas'],
                            local: eventos[index]['local'],
                            numeroParticipantes:
                                eventos[index]['numero_inscritos'].toString(),
                            imagePath: eventos[index]['caminho_imagem'],
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
                      scrollDirection: Axis.horizontal, //  scroll horizontal
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, bottom: 10),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media: publicacoes[index]
                                    ['classificacao_media']
                                .toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
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
                    )),

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
                                              nomeEvento_OU_Local:
                                                  'ainda sem isto', // Ajuste conforme necessário
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
                              'não tem partilhas ainda!',
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
