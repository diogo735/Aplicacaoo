import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagnia_de_uma_publicacao.dart';

import 'package:ficha3/BASE_DE_DADOS/APIS/api_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/PAGINA_INICIAL/widget_cards/card_publicacoes.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:provider/provider.dart';

class Pag_meus_locais extends StatefulWidget {
  @override
  _Pag_meus_locaisState createState() => _Pag_meus_locaisState();
}

class _Pag_meus_locaisState extends State<Pag_meus_locais>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> publicacoes = [];

  late TabController _tabController;
  Color _indicatorColor = const Color(0xFF15659F);
  bool _isLoading = true;
  int _pendentesCount = 0;
  int _ativosCount = 0;
  int _finalizadosCount = 0;
  int _reportadosCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarDados();

    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _indicatorColor = const Color.fromARGB(255, 233, 111, 4);
            break;
          case 1:
            _indicatorColor = Colors.green;
            break;
          case 2:
            _indicatorColor = const Color(0xFF607D8B);
            break;
          case 3:
            _indicatorColor = Colors.red;
            break;
        }
      });
    });
  }

  void _carregarDados() async {
    await _carregarPublicacoes();
    await _carregarDadosDaAPI();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _carregarDadosDaAPI() async {
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);

    final centroSelecionado = centroProvider.centroSelecionado;
    final userId = usuarioProvider.usuarioSelecionado!.id_user;

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      print(
          'Sem conexão com a internet. Não será possível carregar dados da API.');
      return;
    }

    if (centroSelecionado != null) {
      try {
        print('1->>Iniciando o carregamento das PUBLICAÇÕES...');
        await ApiPublicacoes().fetchAndStorePublicacoes(centroSelecionado.id);
        await _carregarPublicacoes();
      } on SocketException catch (e) {
        print('Erro de conectividade: $e');
      } catch (e) {
        print('Erro ao carregar dados da API: $e');
      }
    }
  }

  Future<void> _carregarPublicacoes() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final userId = usuarioProvider.usuarioSelecionado!.id_user;

    List<Map<String, dynamic>> publicacoesCarregadas =
        await Funcoes_Publicacoes.consultarPublicacoesPorAutor(userId);

    if (mounted) {
      setState(() {
        publicacoes = publicacoesCarregadas;
        _pendentesCount = publicacoes
            .where((publicacao) =>
                publicacao['estado_publicacao'] == 'Por validar')
            .length;
        _ativosCount = publicacoes
            .where((publicacao) => publicacao['estado_publicacao'] == 'Ativa')
            .length;
        _finalizadosCount = publicacoes
            .where(
                (publicacao) => publicacao['estado_publicacao'] == 'Finalizada')
            .length;
        _reportadosCount = publicacoes
            .where(
                (publicacao) => publicacao['estado_publicacao'] == 'Denunciada')
            .length;
        print("Publicações carregadas");
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Publicações',
            style: TextStyle(
              fontSize: 22,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            )),
        backgroundColor: const Color(0xFF15659F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorPadding: EdgeInsets.zero,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black.withOpacity(0.4),
                indicatorColor: _indicatorColor,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.hourglass_bottom_rounded,
                            color: Color.fromARGB(255, 233, 111, 4)),
                        const SizedBox(width: 8),
                        Text(
                          "Pendentes ($_pendentesCount)",
                          style: const TextStyle(
                            color: Color.fromARGB(255, 233, 111, 4),
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
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          "Ativos ($_ativosCount)",
                          style: const TextStyle(
                            color: Colors.green,
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
                        const Icon(Icons.archive, color: Color(0xFF607D8B)),
                        const SizedBox(width: 8),
                        Text(
                          "Finalizados ($_finalizadosCount)",
                          style: const TextStyle(
                            color: Color(0xFF607D8B),
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
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          "Reportados ($_reportadosCount)",
                          style: const TextStyle(
                            color: Colors.red,
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
                controller: _tabController,
                children: [
                  _buildPendentesTab(),
                  _buildAtivosTab(),
                  _buildFinalizadosTab(),
                  _buildReportadosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendentesTab() {
    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _indicatorColor),
                const SizedBox(height: 16),
                const Text(
                  "... carregando locais por validar ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : publicacoes.any((publicacao) =>
                publicacao['estado_publicacao'] == 'Por validar')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: publicacoes.length,
                itemBuilder: (context, index) {
                  if (publicacoes[index]['estado_publicacao'] ==
                      'Por validar') {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: Funcoes_Publicacoes_Imagens()
                          .retorna_primeira_imagem(publicacoes[index]['id']),
                      builder: (context, snapshot) {
                        String imagePath =
                            'assets/images/sem_imagem.png'; // Imagem padrão

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data != null) {
                          imagePath = snapshot.data!['caminho_imagem'];
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 15, top: 10),
                          child: GestureDetector(
                            onTap: () {
                              // Navegação para a página de detalhes
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pagina_publicacao(
                                    idPublicacao: publicacoes[index]['id'],
                                    cor: const Color.fromARGB(255, 16, 62, 101),
                                  ),
                                ),
                              );
                            },
                            child: CARD_PUBLICACAO(
                              publicacaoId: publicacoes[index]['id'],
                              nomePublicacao: publicacoes[index]['nome'],
                              local: publicacoes[index]['local'],
                              classificacao_media: "4.5",
                              imagePath: imagePath,
                              distancia: "2 km",
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem publicações por validar!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
  }

  Widget _buildAtivosTab() {
    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _indicatorColor),
                const SizedBox(height: 16),
                const Text(
                  "... carregando publicações ativas ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : publicacoes
                .any((publicacao) => publicacao['estado_publicacao'] == 'Ativa')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: publicacoes.length,
                itemBuilder: (context, index) {
                  if (publicacoes[index]['estado_publicacao'] == 'Ativa') {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: Funcoes_Publicacoes_Imagens()
                          .retorna_primeira_imagem(publicacoes[index]['id']),
                      builder: (context, snapshot) {
                        String imagePath = 'assets/images/sem_imagem.png';

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data != null) {
                          imagePath = snapshot.data!['caminho_imagem'];
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 15, top: 10),
                          child: GestureDetector(
                            onTap: () {
                              // Navegação para a página de detalhes
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pagina_publicacao(
                                    idPublicacao: publicacoes[index]['id'],
                                    cor: const Color.fromARGB(255, 16, 62, 101),
                                  ),
                                ),
                              );
                            },
                            child: CARD_PUBLICACAO(
                              publicacaoId: publicacoes[index]['id'],
                              nomePublicacao: publicacoes[index]['nome'],
                              local: publicacoes[index]['local'],
                              classificacao_media: "4.5",
                              imagePath: imagePath,
                              distancia: "2 km",
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem publicações ativas!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
  }

  Widget _buildFinalizadosTab() {
    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _indicatorColor),
                const SizedBox(height: 16),
                const Text(
                  "... carregando publicações finalizadas ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : publicacoes.any(
                (publicacao) => publicacao['estado_publicacao'] == 'Finalizada')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: publicacoes.length,
                itemBuilder: (context, index) {
                  if (publicacoes[index]['estado_publicacao'] == 'Finalizada') {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: Funcoes_Publicacoes_Imagens()
                          .retorna_primeira_imagem(publicacoes[index]['id']),
                      builder: (context, snapshot) {
                        String imagePath = 'assets/images/sem_imagem.png';

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data != null) {
                          imagePath = snapshot.data!['caminho_imagem'];
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 15, top: 10),
                          child: GestureDetector(
                            onTap: () {
                              // Navegação para a página de detalhes
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pagina_publicacao(
                                    idPublicacao: publicacoes[index]['id'],
                                    cor: const Color.fromARGB(255, 16, 62, 101),
                                  ),
                                ),
                              );
                            },
                            child: CARD_PUBLICACAO(
                              publicacaoId: publicacoes[index]['id'],
                              nomePublicacao: publicacoes[index]['nome'],
                              local: publicacoes[index]['local'],
                              classificacao_media: "4.5",
                              imagePath: imagePath,
                              distancia: "2 km",
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem publicações finalizadas!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
  }

  Widget _buildReportadosTab() {
    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _indicatorColor),
                const SizedBox(height: 16),
                const Text(
                  "... carregando publicações reportadas ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : publicacoes.any(
                (publicacao) => publicacao['estado_publicacao'] == 'Denunciada')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: publicacoes.length,
                itemBuilder: (context, index) {
                  if (publicacoes[index]['estado_publicacao'] == 'Denunciada') {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: Funcoes_Publicacoes_Imagens()
                          .retorna_primeira_imagem(publicacoes[index]['id']),
                      builder: (context, snapshot) {
                        String imagePath = 'assets/images/sem_imagem.png';

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data != null) {
                          imagePath = snapshot.data!['caminho_imagem'];
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 15, top: 10),
                          child: GestureDetector(
                            onTap: () {
                              // Navegação para a página de detalhes
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pagina_publicacao(
                                    idPublicacao: publicacoes[index]['id'],
                                    cor: const Color.fromARGB(255, 16, 62, 101),
                                  ),
                                ),
                              );
                            },
                            child: CARD_PUBLICACAO(
                              publicacaoId: publicacoes[index]['id'],
                              nomePublicacao: publicacoes[index]['nome'],
                              local: publicacoes[index]['local'],
                              classificacao_media: "4.5",
                              imagePath: imagePath,
                              distancia: "2 km",
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem publicações reportadas!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
  }
}
