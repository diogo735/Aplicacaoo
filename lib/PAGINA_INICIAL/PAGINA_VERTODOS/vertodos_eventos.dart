import 'package:ficha3/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/card_eventos_vertodos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/calendariogeral_eventos/calendario_evetnos_geral.dart';
import 'package:provider/provider.dart';

class vertodos_eventos extends StatefulWidget {
  @override
  _vertodos_eventosState createState() => _vertodos_eventosState();
}

class _vertodos_eventosState extends State<vertodos_eventos> {
  List<Map<String, dynamic>> eventos = []; // Lista de eventos

  @override
  void initState() {
    super.initState();
    _carregarEventos(); // Carregar eventos ao iniciar a tela
  }

  /// Função para carregar os eventos da base de dados
  void _carregarEventos() async {
    Funcoes_Eventos funcoesEventos = Funcoes_Eventos();
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;

    List<Map<String, dynamic>> eventosCarregados =
        await funcoesEventos.consultaEventosPorCentroId(centroId);
    setState(() {
      eventos = eventosCarregados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos',
            style: TextStyle(
              fontSize: 24,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            )),
        backgroundColor: const Color(0xFF15659F),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: IconButton(
              padding:
                  const EdgeInsets.all(3), // Define o preenchimento do ícone
              icon: const Icon(Icons.calendar_month_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => calendariogeral_eventos()),
                );
              },
              iconSize: 27,
            ),
          ),
        ],
      ),
      body: Container(
        color: const Color.fromARGB(255, 233, 233, 233),
        child: DefaultTabController(
          length: 8, // Define o número de abas
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(
                    255, 255, 255, 255), // Cor de fundo da TabBar
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
                        itemCount: eventos.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(
                                left: 4, right: 10, top: 20),
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
                        },
                      ),
                    ),
                    Container(
                      //saude
                      child: !eventos.any((evento) => evento['area_id'] == 2)
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
                                    'ainda nao tem eventos !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                if (eventos[index]['area_id'] == 2) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 20),
                                    child: CARD_EVENTO_VERTODOS(
                                      id_topico: eventos[index]['topico_id'],
                                      context: context,
                                      id: eventos[index]['id'],
                                      nomeEvento: eventos[index]['nome'],
                                      dia: eventos[index]['dia_realizacao'],
                                      mes: eventos[index]['mes_realizacao'],
                                      ano: eventos[index]['ano_realizacao'],
                                      horas: eventos[index]['horas'],
                                      imagePath: eventos[index]
                                          ['caminho_imagem'],
                                      tipo_evento: eventos[index]
                                          ['tipodeevento_id'],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ), //desporto
                    Container(
                      child: !eventos.any((evento) => evento['area_id'] == 1)
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
                                    'ainda nao tem eventos !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                if (eventos[index]['area_id'] == 1) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 20),
                                    child: CARD_EVENTO_VERTODOS(
                                      id_topico: eventos[index]['topico_id'],
                                      context: context,
                                      id: eventos[index]['id'],
                                      nomeEvento: eventos[index]['nome'],
                                      dia: eventos[index]['dia_realizacao'],
                                      mes: eventos[index]['mes_realizacao'],
                                      ano: eventos[index]['ano_realizacao'],
                                      horas: eventos[index]['horas'],
                                      imagePath: eventos[index]
                                          ['caminho_imagem'],
                                      tipo_evento: eventos[index]
                                          ['tipodeevento_id'],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ), //gastronomia
                    Container(
                      child: !eventos.any((evento) => evento['area_id'] == 3)
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
                                    'ainda nao tem eventos !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                if (eventos[index]['area_id'] == 3) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 20),
                                    child: CARD_EVENTO_VERTODOS(
                                      id_topico: eventos[index]['topico_id'],
                                      context: context,
                                      id: eventos[index]['id'],
                                      nomeEvento: eventos[index]['nome'],
                                      dia: eventos[index]['dia_realizacao'],
                                      mes: eventos[index]['mes_realizacao'],
                                      ano: eventos[index]['ano_realizacao'],
                                      horas: eventos[index]['horas'],
                                      imagePath: eventos[index]
                                          ['caminho_imagem'],
                                      tipo_evento: eventos[index]
                                          ['tipodeevento_id'],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ), //formacao
                    Container(
                      child: !eventos.any((evento) => evento['area_id'] == 4)
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
                                    'ainda nao tem eventos !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                if (eventos[index]['area_id'] == 4) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 20),
                                    child: CARD_EVENTO_VERTODOS(
                                      id_topico: eventos[index]['topico_id'],
                                      context: context,
                                      id: eventos[index]['id'],
                                      nomeEvento: eventos[index]['nome'],
                                      dia: eventos[index]['dia_realizacao'],
                                      mes: eventos[index]['mes_realizacao'],
                                      ano: eventos[index]['ano_realizacao'],
                                      horas: eventos[index]['horas'],
                                      imagePath: eventos[index]
                                          ['caminho_imagem'],
                                      tipo_evento: eventos[index]
                                          ['tipodeevento_id'],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    // ALOJAMENTO
                    Container(
                      child: !eventos.any((evento) => evento['area_id'] == 7)
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
                                    'ainda nao tem eventos !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                if (eventos[index]['area_id'] == 7) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 20),
                                    child: CARD_EVENTO_VERTODOS(
                                      id_topico: eventos[index]['topico_id'],
                                      context: context,
                                      id: eventos[index]['id'],
                                      nomeEvento: eventos[index]['nome'],
                                      dia: eventos[index]['dia_realizacao'],
                                      mes: eventos[index]['mes_realizacao'],
                                      ano: eventos[index]['ano_realizacao'],
                                      horas: eventos[index]['horas'],
                                      imagePath: eventos[index]
                                          ['caminho_imagem'],
                                      tipo_evento: eventos[index]
                                          ['tipodeevento_id'],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ),
                    //TRANSPORTES
                    Container(
                      child: !eventos.any((evento) => evento['area_id'] == 6)
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
                                    'ainda nao tem eventos !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                if (eventos[index]['area_id'] == 6) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 20),
                                    child: CARD_EVENTO_VERTODOS(
                                      id_topico: eventos[index]['topico_id'],
                                      context: context,
                                      id: eventos[index]['id'],
                                      nomeEvento: eventos[index]['nome'],
                                      dia: eventos[index]['dia_realizacao'],
                                      mes: eventos[index]['mes_realizacao'],
                                      ano: eventos[index]['ano_realizacao'],
                                      horas: eventos[index]['horas'],
                                      imagePath: eventos[index]
                                          ['caminho_imagem'],
                                      tipo_evento: eventos[index]
                                          ['tipodeevento_id'],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    ), //LAZER
                    Container(
                      child: !eventos.any((evento) => evento['area_id'] == 5)
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
                                    'ainda nao tem eventos !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: eventos.length,
                              itemBuilder: (context, index) {
                                if (eventos[index]['area_id'] == 5) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        left: 4, right: 10, top: 20),
                                    child: CARD_EVENTO_VERTODOS(
                                      id_topico: eventos[index]['topico_id'],
                                      context: context,
                                      id: eventos[index]['id'],
                                      nomeEvento: eventos[index]['nome'],
                                      dia: eventos[index]['dia_realizacao'],
                                      mes: eventos[index]['mes_realizacao'],
                                      ano: eventos[index]['ano_realizacao'],
                                      horas: eventos[index]['horas'],
                                      imagePath: eventos[index]
                                          ['caminho_imagem'],
                                      tipo_evento: eventos[index]
                                          ['tipodeevento_id'],
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                    )
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
