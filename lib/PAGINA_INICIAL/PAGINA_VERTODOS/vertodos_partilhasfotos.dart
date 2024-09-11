import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/Pagina_de_uma_partilha/pagina_de_uma_partilha.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/PAGINA_INICIAL/widget_cards/card_partilhas.dart';
import 'package:provider/provider.dart';

class vertodos_partilhas extends StatefulWidget {
  @override
  _vertodos_partilhasState createState() => _vertodos_partilhasState();
}

class _vertodos_partilhasState extends State<vertodos_partilhas> {
  List<Map<String, dynamic>> partilhas = []; // Lista de eventos

  @override
  void initState() {
    super.initState();
    _carregarPartilhas(); // Carregar eventos ao iniciar a tela
  }

  /// Função para carregar os eventos da base de dados
  void _carregarPartilhas() async {
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;
    List<Map<String, dynamic>> partilhasCarregadas =
        await Funcoes_Partilhas().consultaPartilhasComCentroId(centroId);
    setState(() {
      partilhas = partilhasCarregadas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partilhas',
            style: TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            )),
        backgroundColor: const Color(0xFF15659F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: DefaultTabController(
          length: 8, // Define o número de abas
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 255, 255,
                    255), // Cor de fundo da TabBar // Cor de fundo da TabBar
                child: TabBar(
                  isScrollable: true,
                  indicatorPadding:
                      EdgeInsets.zero, // Torna a TabBar deslizável
                  labelColor: Colors.black, // Cor do texto da aba selecionada
                  unselectedLabelColor: Colors.black.withOpacity(0.4),
                  indicatorColor: const Color(0xFF15659F),
                  tabs: [
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.format_list_bulleted_rounded,
                              color: Color(0xFF15659F)),
                          SizedBox(width: 8),
                          Text(
                            "Todos",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.monitor_heart_rounded,
                              color: Color(0xFF15659F)),
                          SizedBox(width: 8),
                          Text(
                            "Saude",
                            style: TextStyle(
                              fontSize: 14,
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
                          Transform.rotate(
                            angle: 135 * 3.14 / 180,
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: Color(0xFF15659F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Desporto",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.restaurant, color: Color(0xFF15659F)),
                          SizedBox(width: 8),
                          Text(
                            "Gastronomia",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.menu_book_rounded,
                              color: Color(0xFF15659F)),
                          SizedBox(width: 8),
                          Text(
                            "Formação",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.house_rounded, color: Color(0xFF15659F)),
                          SizedBox(width: 8),
                          Text(
                            "Alojamento",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_bus, color: Color(0xFF15659F)),
                          SizedBox(width: 8),
                          Text(
                            "Trasnportes",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forest_rounded, color: Color(0xFF15659F)),
                          SizedBox(width: 8),
                          Text(
                            "Lazer",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Conteúdo da aba 1
                    Container(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: partilhas.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                                left: 4, right: 10, top: 22),
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
                                      future: partilhas[index]['id_local'] !=
                                              null
                                          ? Funcoes_Publicacoes
                                              .consultaNomeLocalPorId(
                                                  partilhas[index]['id_local'])
                                          : Future.value(''),
                                      builder: (context, localSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaCaminhoFotoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, fotoSnapshot) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PaginaDaPartilha(
                                                      cor: const Color(
                                                          0xFF15659F),
                                                      idpartilha:
                                                          partilhas[index]
                                                              ['id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: CARD_PARTILHA(
                                                Titulo: partilhas[index]
                                                    ['titulo'],
                                                fotouser:
                                                    fotoSnapshot.data ?? '',
                                                nomeuser:
                                                    usuarioSnapshot.data ?? '',
                                                imagePath: partilhas[index]
                                                    ['caminho_imagem'],
                                                context: context,
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
                    ),
                    Container(
                      child: !partilhas
                              .any((partilha) => partilha['area_id'] == 2)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Saude\n'
                                    'ainda nao tem partilhas !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: partilhas.length,
                              itemBuilder: (context, index) {
                                if (partilhas[index]['area_id'] == 2) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 22),
                                    child: FutureBuilder<String>(
                                      future: partilhas[index]['id_evento'] !=
                                              null
                                          ? Funcoes_Eventos
                                              .consultaNomeEventoPorId(
                                                  partilhas[index]['id_evento'])
                                          : Future.value(''),
                                      builder: (context, eventoSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaNomeCompletoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, usuarioSnapshot) {
                                            return FutureBuilder<String>(
                                              future: partilhas[index]
                                                          ['id_local'] !=
                                                      null
                                                  ? Funcoes_Publicacoes
                                                      .consultaNomeLocalPorId(
                                                          partilhas[index]
                                                              ['id_local'])
                                                  : Future.value(''),
                                              builder:
                                                  (context, localSnapshot) {
                                                return FutureBuilder<String>(
                                                  future: Funcoes_Usuarios
                                                      .consultaCaminhoFotoUsuarioPorId(
                                                          partilhas[index]
                                                              ['id_usuario']),
                                                  builder:
                                                      (context, fotoSnapshot) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PaginaDaPartilha(
                                                                cor: const Color(
                                                                    0xFF15659F),
                                                                idpartilha:
                                                                    partilhas[
                                                                            index]
                                                                        ['id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: CARD_PARTILHA(
                                                          Titulo:
                                                              partilhas[index]
                                                                  ['titulo'],
                                                          fotouser: fotoSnapshot
                                                                  .data ??
                                                              '',
                                                          nomeuser:
                                                              usuarioSnapshot
                                                                      .data ??
                                                                  '',
                                                          imagePath: partilhas[
                                                                  index][
                                                              'caminho_imagem'],
                                                          context: context,
                                                        ));
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    Container(
                      child: !partilhas
                              .any((partilha) => partilha['area_id'] == 1)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Desporto\n'
                                    'ainda nao tem partilhas !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: partilhas.length,
                              itemBuilder: (context, index) {
                                if (partilhas[index]['area_id'] == 1) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 22),
                                    child: FutureBuilder<String>(
                                      future: partilhas[index]['id_evento'] !=
                                              null
                                          ? Funcoes_Eventos
                                              .consultaNomeEventoPorId(
                                                  partilhas[index]['id_evento'])
                                          : Future.value(''),
                                      builder: (context, eventoSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaNomeCompletoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, usuarioSnapshot) {
                                            return FutureBuilder<String>(
                                              future: partilhas[index]
                                                          ['id_local'] !=
                                                      null
                                                  ? Funcoes_Publicacoes
                                                      .consultaNomeLocalPorId(
                                                          partilhas[index]
                                                              ['id_local'])
                                                  : Future.value(''),
                                              builder:
                                                  (context, localSnapshot) {
                                                return FutureBuilder<String>(
                                                  future: Funcoes_Usuarios
                                                      .consultaCaminhoFotoUsuarioPorId(
                                                          partilhas[index]
                                                              ['id_usuario']),
                                                  builder:
                                                      (context, fotoSnapshot) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PaginaDaPartilha(
                                                                cor: const Color(
                                                                    0xFF15659F),
                                                                idpartilha:
                                                                    partilhas[
                                                                            index]
                                                                        ['id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: CARD_PARTILHA(
                                                          Titulo:
                                                              partilhas[index]
                                                                  ['titulo'],
                                                          fotouser: fotoSnapshot
                                                                  .data ??
                                                              '',
                                                          nomeuser:
                                                              usuarioSnapshot
                                                                      .data ??
                                                                  '',
                                                          imagePath: partilhas[
                                                                  index][
                                                              'caminho_imagem'],
                                                          context: context,
                                                        ));
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    Container(
                      child: !partilhas
                              .any((partilha) => partilha['area_id'] == 3)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Gastronomia\n'
                                    'ainda nao tem partilhas !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: partilhas.length,
                              itemBuilder: (context, index) {
                                if (partilhas[index]['area_id'] == 3) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 22),
                                    child: FutureBuilder<String>(
                                      future: partilhas[index]['id_evento'] !=
                                              null
                                          ? Funcoes_Eventos
                                              .consultaNomeEventoPorId(
                                                  partilhas[index]['id_evento'])
                                          : Future.value(''),
                                      builder: (context, eventoSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaNomeCompletoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, usuarioSnapshot) {
                                            return FutureBuilder<String>(
                                              future: partilhas[index]
                                                          ['id_local'] !=
                                                      null
                                                  ? Funcoes_Publicacoes
                                                      .consultaNomeLocalPorId(
                                                          partilhas[index]
                                                              ['id_local'])
                                                  : Future.value(''),
                                              builder:
                                                  (context, localSnapshot) {
                                                return FutureBuilder<String>(
                                                  future: Funcoes_Usuarios
                                                      .consultaCaminhoFotoUsuarioPorId(
                                                          partilhas[index]
                                                              ['id_usuario']),
                                                  builder:
                                                      (context, fotoSnapshot) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PaginaDaPartilha(
                                                                cor: const Color(
                                                                    0xFF15659F),
                                                                idpartilha:
                                                                    partilhas[
                                                                            index]
                                                                        ['id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: CARD_PARTILHA(
                                                          Titulo:
                                                              partilhas[index]
                                                                  ['titulo'],
                                                          fotouser: fotoSnapshot
                                                                  .data ??
                                                              '',
                                                          nomeuser:
                                                              usuarioSnapshot
                                                                      .data ??
                                                                  '',
                                                          imagePath: partilhas[
                                                                  index][
                                                              'caminho_imagem'],
                                                          context: context,
                                                        ));
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    Container(
                      child: !partilhas
                              .any((partilha) => partilha['area_id'] == 4)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Formação\n'
                                    'ainda nao tem partilhas !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: partilhas.length,
                              itemBuilder: (context, index) {
                                if (partilhas[index]['area_id'] == 4) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 22),
                                    child: FutureBuilder<String>(
                                      future: partilhas[index]['id_evento'] !=
                                              null
                                          ? Funcoes_Eventos
                                              .consultaNomeEventoPorId(
                                                  partilhas[index]['id_evento'])
                                          : Future.value(''),
                                      builder: (context, eventoSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaNomeCompletoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, usuarioSnapshot) {
                                            return FutureBuilder<String>(
                                              future: partilhas[index]
                                                          ['id_local'] !=
                                                      null
                                                  ? Funcoes_Publicacoes
                                                      .consultaNomeLocalPorId(
                                                          partilhas[index]
                                                              ['id_local'])
                                                  : Future.value(''),
                                              builder:
                                                  (context, localSnapshot) {
                                                return FutureBuilder<String>(
                                                  future: Funcoes_Usuarios
                                                      .consultaCaminhoFotoUsuarioPorId(
                                                          partilhas[index]
                                                              ['id_usuario']),
                                                  builder:
                                                      (context, fotoSnapshot) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PaginaDaPartilha(
                                                                cor: const Color(
                                                                    0xFF15659F),
                                                                idpartilha:
                                                                    partilhas[
                                                                            index]
                                                                        ['id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: CARD_PARTILHA(
                                                          Titulo:
                                                              partilhas[index]
                                                                  ['titulo'],
                                                          fotouser: fotoSnapshot
                                                                  .data ??
                                                              '',
                                                          nomeuser:
                                                              usuarioSnapshot
                                                                      .data ??
                                                                  '',
                                                          imagePath: partilhas[
                                                                  index][
                                                              'caminho_imagem'],
                                                          context: context,
                                                        ));
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    Container(
                      child: !partilhas
                              .any((partilha) => partilha['area_id'] == 7)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Alojamento\n'
                                    'ainda nao tem partilhas !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: partilhas.length,
                              itemBuilder: (context, index) {
                                if (partilhas[index]['area_id'] == 7) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 22),
                                    child: FutureBuilder<String>(
                                      future: partilhas[index]['id_evento'] !=
                                              null
                                          ? Funcoes_Eventos
                                              .consultaNomeEventoPorId(
                                                  partilhas[index]['id_evento'])
                                          : Future.value(''),
                                      builder: (context, eventoSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaNomeCompletoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, usuarioSnapshot) {
                                            return FutureBuilder<String>(
                                              future: partilhas[index]
                                                          ['id_local'] !=
                                                      null
                                                  ? Funcoes_Publicacoes
                                                      .consultaNomeLocalPorId(
                                                          partilhas[index]
                                                              ['id_local'])
                                                  : Future.value(''),
                                              builder:
                                                  (context, localSnapshot) {
                                                return FutureBuilder<String>(
                                                  future: partilhas[index]
                                                              ['id_local'] !=
                                                          null
                                                      ? Funcoes_Publicacoes
                                                          .consultaNomeLocalPorId(
                                                              partilhas[index]
                                                                  ['id_local'])
                                                      : Future.value(''),
                                                  builder:
                                                      (context, localSnapshot) {
                                                    return FutureBuilder<
                                                        String>(
                                                      future: Funcoes_Usuarios
                                                          .consultaCaminhoFotoUsuarioPorId(
                                                              partilhas[index][
                                                                  'id_usuario']),
                                                      builder: (context,
                                                          fotoSnapshot) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        PaginaDaPartilha(
                                                                  cor: const Color(
                                                                      0xFF15659F),
                                                                  idpartilha:
                                                                      partilhas[
                                                                              index]
                                                                          [
                                                                          'id'],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: CARD_PARTILHA(
                                                            Titulo:
                                                                partilhas[index]
                                                                    ['titulo'],
                                                            fotouser:
                                                                fotoSnapshot
                                                                        .data ??
                                                                    '',
                                                            nomeuser:
                                                                usuarioSnapshot
                                                                        .data ??
                                                                    '',
                                                            imagePath: partilhas[
                                                                    index][
                                                                'caminho_imagem'],
                                                            context: context,
                                                          ),
                                                        );
                                                      },
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
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    Container(
                      child: !partilhas
                              .any((partilha) => partilha['area_id'] == 6)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Transportes\n'
                                    'ainda nao tem partilhas !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: partilhas.length,
                              itemBuilder: (context, index) {
                                if (partilhas[index]['area_id'] == 6) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 22),
                                    child: FutureBuilder<String>(
                                      future: partilhas[index]['id_evento'] !=
                                              null
                                          ? Funcoes_Eventos
                                              .consultaNomeEventoPorId(
                                                  partilhas[index]['id_evento'])
                                          : Future.value(''),
                                      builder: (context, eventoSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaNomeCompletoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, usuarioSnapshot) {
                                            return FutureBuilder<String>(
                                              future: partilhas[index]
                                                          ['id_local'] !=
                                                      null
                                                  ? Funcoes_Publicacoes
                                                      .consultaNomeLocalPorId(
                                                          partilhas[index]
                                                              ['id_local'])
                                                  : Future.value(''),
                                              builder:
                                                  (context, localSnapshot) {
                                                return FutureBuilder<String>(
                                                  future: Funcoes_Usuarios
                                                      .consultaCaminhoFotoUsuarioPorId(
                                                          partilhas[index]
                                                              ['id_usuario']),
                                                  builder:
                                                      (context, fotoSnapshot) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PaginaDaPartilha(
                                                                cor: const Color(
                                                                    0xFF15659F),
                                                                idpartilha:
                                                                    partilhas[
                                                                            index]
                                                                        ['id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: CARD_PARTILHA(
                                                          Titulo:
                                                              partilhas[index]
                                                                  ['titulo'],
                                                          fotouser: fotoSnapshot
                                                                  .data ??
                                                              '',
                                                          nomeuser:
                                                              usuarioSnapshot
                                                                      .data ??
                                                                  '',
                                                          imagePath: partilhas[
                                                                  index][
                                                              'caminho_imagem'],
                                                          context: context,
                                                        ));
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    Container(
                      child: !partilhas
                              .any((partilha) => partilha['area_id'] == 5)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Lazer\n'
                                    'ainda nao tem partilhas !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: partilhas.length,
                              itemBuilder: (context, index) {
                                if (partilhas[index]['area_id'] == 5) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 22),
                                    child: FutureBuilder<String>(
                                      future: partilhas[index]['id_evento'] !=
                                              null
                                          ? Funcoes_Eventos
                                              .consultaNomeEventoPorId(
                                                  partilhas[index]['id_evento'])
                                          : Future.value(''),
                                      builder: (context, eventoSnapshot) {
                                        return FutureBuilder<String>(
                                          future: Funcoes_Usuarios
                                              .consultaNomeCompletoUsuarioPorId(
                                                  partilhas[index]
                                                      ['id_usuario']),
                                          builder: (context, usuarioSnapshot) {
                                            return FutureBuilder<String>(
                                              future: partilhas[index]
                                                          ['id_local'] !=
                                                      null
                                                  ? Funcoes_Publicacoes
                                                      .consultaNomeLocalPorId(
                                                          partilhas[index]
                                                              ['id_local'])
                                                  : Future.value(''),
                                              builder:
                                                  (context, localSnapshot) {
                                                return FutureBuilder<String>(
                                                  future: Funcoes_Usuarios
                                                      .consultaCaminhoFotoUsuarioPorId(
                                                          partilhas[index]
                                                              ['id_usuario']),
                                                  builder:
                                                      (context, fotoSnapshot) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PaginaDaPartilha(
                                                                cor: const Color(
                                                                    0xFF15659F),
                                                                idpartilha:
                                                                    partilhas[
                                                                            index]
                                                                        ['id'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: CARD_PARTILHA(
                                                          Titulo:
                                                              partilhas[index]
                                                                  ['titulo'],
                                                          fotouser: fotoSnapshot
                                                                  .data ??
                                                              '',
                                                          nomeuser:
                                                              usuarioSnapshot
                                                                      .data ??
                                                                  '',
                                                          imagePath: partilhas[
                                                                  index][
                                                              'caminho_imagem'],
                                                          context: context,
                                                        ));
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
