import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_topicos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_PERFIL/pagina_eventos_do_user/card_eventos_por_validar.dart';

import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/card_eventos_vertodos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/calendariogeral_eventos/calendario_evetnos_geral.dart';
import 'package:provider/provider.dart';

class Pag_meus_eventos extends StatefulWidget {
  @override
  _Pag_meus_eventosState createState() => _Pag_meus_eventosState();
}

class _Pag_meus_eventosState extends State<Pag_meus_eventos>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> eventos = []; // Lista de eventos

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
    await _carregarEventos();
    await _carregarDadosDaAPI();

    setState(() {
      _isLoading = false; // Define como falso após o carregamento dos dados
    });
  }

  Future<void> _carregarDadosDaAPI() async {
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);

    final centroSelecionado = centroProvider.centroSelecionado;
    final userId = usuarioProvider.usuarioSelecionado!.id_user;

    // Verificar conectividade com a internet
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      print(
          'Sem conexão com a internet. Não será possível carregar dados da API.');
      return; // Se não houver conexão, sai da função.
    }

    if (centroSelecionado != null) {
      try {
        print('4->>Iniciando o carregamento dos EVENTOS...');
        await ApiEventos().fetchAndStoreEventos(centroSelecionado.id, userId);

        print('5->>Iniciando o carregamento dos PARTICIPANTES DOS EVENTOS...');
        await ApiEventos()
            .fetchAndStoreParticipantes(centroSelecionado.id, userId);

        print('6->>Iniciando o carregamento dos IMAGENS DOS EVENTOS...');
        await ApiEventos()
            .fetchAndStoreImagensEvento(centroSelecionado.id, userId);

        print('7->>Iniciando o carregamento dos COMENTARIOS DOS EVENTOS...');
        await ApiEventos()
            .fetchAndStoreComentariosEvento(centroSelecionado.id, userId);

        // Após carregar os dados da API, atualize a lista de eventos locais
        await _carregarEventos();
      } on SocketException catch (e) {
        print('Erro de conectividade: $e');
      } catch (e) {
        print('Erro ao carregar dados da API: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Cancelar o timer da base de dados
    super.dispose();
  }

  Future<void> _carregarEventos() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final userId = usuarioProvider.usuarioSelecionado!.id_user;

    List<Map<String, dynamic>> eventosCarregados =
        await Funcoes_Eventos.consultaEventosPorAutor(userId);

    setState(() {
      eventos = eventosCarregados;

      _pendentesCount = eventos
          .where((evento) => evento['estado_evento'] == 'Por validar')
          .length;
      _ativosCount =
          eventos.where((evento) => evento['estado_evento'] == 'Ativa').length;
      _finalizadosCount = eventos
          .where((evento) => evento['estado_evento'] == 'Finalizada')
          .length;
      _reportadosCount = eventos
          .where((evento) => evento['estado_evento'] == 'Denunciada')
          .length;
      print("Eventos carregados");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Eventos',
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
              color: const Color.fromARGB(
                  255, 255, 255, 255), // Cor de fundo da TabBar
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorPadding: EdgeInsets.zero, // Torna a TabBar deslizável
                labelColor: Colors.black, // Cor do texto da aba selecionada
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
                        const Icon(
                          Icons.archive,
                          color: Color(0xFF607D8B),
                        ),
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
                const SizedBox(
                    height: 16), // Espaço entre o indicador e o texto
                const Text(
                  "... carregando eventos por validar ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : eventos.any((evento) => evento['estado_evento'] == 'Por validar')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  if (eventos[index]['estado_evento'] == 'Por validar') {
                    return Container(
                      margin:
                          const EdgeInsets.only(left: 4, right: 10, top: 20),
                      child: CARD_EVENTO_por_validar(
                        id_topico: eventos[index]['topico_id'],
                        context: context,
                        id: eventos[index]['id'],
                        nomeEvento: eventos[index]['nome'],
                        dia: eventos[index]['dia_realizacao'],
                        mes: eventos[index]['mes_realizacao'],
                        ano: eventos[index]['ano_realizacao'],
                        horas: eventos[index]['horas'],
                        imagePath: eventos[index]['caminho_imagem'],
                        tipo_evento: eventos[index]['tipodeevento_id'],
                      ),
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
                    Image.asset(
                      'assets/images/pendente.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem eventos por validar !',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
  }

  Widget _buildAtivosTab() {
    final DateTime now = DateTime.now().toLocal();

    return _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: _indicatorColor),
                const SizedBox(
                    height: 16), // Espaço entre o indicador e o texto
                const Text(
                  "... carregando eventos ativos ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : eventos.any((evento) => evento['estado_evento'] == 'Ativa')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  if (eventos[index]['estado_evento'] == 'Ativa') {
                    return Container(
                      margin:
                          const EdgeInsets.only(left: 4, right: 10, top: 20),
                      child: CARD_EVENTO_VERTODOS(
                        id_topico: eventos[index]['topico_id'],
                        context: context,
                        id: eventos[index]['id'],
                        nomeEvento: eventos[index]['nome'],
                        dia: eventos[index]['dia_realizacao'],
                        mes: eventos[index]['mes_realizacao'],
                        ano: eventos[index]['ano_realizacao'],
                        horas: eventos[index]['horas'],
                        imagePath: eventos[index]['caminho_imagem'],
                        tipo_evento: eventos[index]['tipodeevento_id'],
                      ),
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
                    Image.asset(
                      'assets/images/no_events.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem eventos ativos!',
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
                const SizedBox(
                    height: 16), // Espaço entre o indicador e o texto
                const Text(
                  "... carregando eventos que já acabaram ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : eventos.any((evento) => evento['estado_evento'] == 'Finalizada')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  if (eventos[index]['estado_evento'] == 'Finalizada') {
                    return Container(
                      margin:
                          const EdgeInsets.only(left: 4, right: 10, top: 20),
                      child: CARD_EVENTO_VERTODOS(
                        id_topico: eventos[index]['topico_id'],
                        context: context,
                        id: eventos[index]['id'],
                        nomeEvento: eventos[index]['nome'],
                        dia: eventos[index]['dia_realizacao'],
                        mes: eventos[index]['mes_realizacao'],
                        ano: eventos[index]['ano_realizacao'],
                        horas: eventos[index]['horas'],
                        imagePath: eventos[index]['caminho_imagem'],
                        tipo_evento: eventos[index]['tipodeevento_id'],
                      ),
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
                    Image.asset(
                      'assets/images/no_events.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem eventos finalizados!',
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
                const SizedBox(
                    height: 16), // Espaço entre o indicador e o texto
                const Text(
                  "... carregando eventos por validar! ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          )
        : eventos.any((evento) => evento['estado_evento'] == 'Denunciada')
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  if (eventos[index]['estado_evento'] == 'Denunciada') {
                    return Container(
                      margin:
                          const EdgeInsets.only(left: 4, right: 10, top: 20),
                      child: CARD_EVENTO_VERTODOS(
                        id_topico: eventos[index]['topico_id'],
                        context: context,
                        id: eventos[index]['id'],
                        nomeEvento: eventos[index]['nome'],
                        dia: eventos[index]['dia_realizacao'],
                        mes: eventos[index]['mes_realizacao'],
                        ano: eventos[index]['ano_realizacao'],
                        horas: eventos[index]['horas'],
                        imagePath: eventos[index]['caminho_imagem'],
                        tipo_evento: eventos[index]['tipodeevento_id'],
                      ),
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
                    Image.asset(
                      'assets/images/no_events.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Não tem eventos denunciados!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
  }
}
