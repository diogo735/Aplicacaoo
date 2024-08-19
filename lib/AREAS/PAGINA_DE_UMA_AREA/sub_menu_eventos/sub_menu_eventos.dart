import 'dart:async';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/card_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/criar_evento/pagina_criar_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/calendariogeral_eventos/calendario_evetnos_geral.dart';
import 'package:ficha3/centro_provider.dart';
import 'package:flutter/material.dart';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/calendario_area/calendario_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:provider/provider.dart';

class submenueventos extends StatefulWidget {
  final int id_area;
  final Color cor_da_area;

  submenueventos({
    required this.id_area,
    required this.cor_da_area,
  });
  @override
  _submenueventosState createState() => _submenueventosState();
}

class _submenueventosState extends State<submenueventos> {
  List<Map<String, dynamic>> eventos = [];
  List<Map<String, dynamic>> topicos = [];
  double bottomMargin = 20.0;
  double rightMargin = 12.0;
  Map<int, String> localPorEvento = {};
  Map<int, int> numeroParticipantesPorEvento = {};
  bool _loading = true;
 @override
  void dispose() {
    // Limpeza de recursos, se necessário
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });

    // Aguarda o carregamento dos eventos, locais e participantes
    await _carregarEventos();
    await Future.wait([
      carregarNumeroDeParticipantes(),
      carregarLocais(),
    ]);
    await _carregarTopicos();

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _carregarEventos() async {
    print('Iniciando o carregamento dos eventos...');

    Funcoes_Eventos funcoesEventos = Funcoes_Eventos();

    // Obtém o centro selecionado do provider
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;

    if (centroSelecionado == null) {
      print('Nenhum centro selecionado!');
      return; // Sai da função se não houver centro selecionado
    }

    int centroId = centroSelecionado.id;

    try {
      // Consulta os eventos da área e centro selecionados
      List<Map<String, dynamic>> eventosCarregados =
          await funcoesEventos.consultaEventosPorArea(widget.id_area, centroId);

      print('Eventos carregados: ${eventosCarregados.length} encontrados');

      if (mounted) {
        setState(() {
          eventos = eventosCarregados;
        });
      }

      print('Eventos atualizados no estado');
    } catch (e) {
      print('Erro ao carregar eventos: $e');
    }
  }

  Future<void> _carregarTopicos() async {
    Funcoes_Topicos funcoesTopicos = Funcoes_Topicos();
    List<Map<String, dynamic>> topicosCarregados =
        await funcoesTopicos.consultaTopicosPorArea(widget.id_area);
    
    if (mounted) {
      setState(() {
        topicos = topicosCarregados;
      });
    }
  }

  Future<void> carregarNumeroDeParticipantes() async {
    Map<int, int> participantes = {};

    for (var evento in eventos) {
      int eventoId = evento['id'];
      int numeroDeParticipantes =
          await Funcoes_Participantes_Evento.getNumeroDeParticipantes(eventoId);
      participantes[eventoId] = numeroDeParticipantes;
    }

    if (mounted) {
      setState(() {
        numeroParticipantesPorEvento = participantes;
      });
    }
  }

  Future<void> carregarLocais() async {
    for (var evento in eventos) {
      int eventoId = evento['id'];
      double latitude = evento['latitude']; 
      double longitude =
          evento['longitude']; 
      String address = await _getAddressUsingOSM(latitude, longitude);
      
      if (mounted) {
        setState(() {
          localPorEvento[eventoId] = address;
        });
      }
    }
  }

  Future<String> _getAddressUsingOSM(double latitude, double longitude) async {
    LocalizacaoOSM localizacaoOSM = LocalizacaoOSM();
    return await localizacaoOSM.getEnderecoFromCoordinates(latitude, longitude);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: widget.cor_da_area,
              ),
            )
          : eventos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/no_events.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Sem eventos ainda !',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 156, 156, 156)),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: eventos.asMap().entries.map((entry) {
                          int index = entry.key;
                          var evento = entry.value;

                          int eventoId = evento['id'];
                          int numeroParticipantes =
                              numeroParticipantesPorEvento[eventoId] ?? 0;
                          String local =
                              localPorEvento[eventoId] ?? 'Carregando...';

                          return Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: GestureDetector(
                              onTap: () {
                                // Navegue para a página de detalhes do evento
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaginaEvento(
                                      idEvento: eventoId,
                                    ),
                                  ),
                                );
                              },
                              child: CARD_EVENTO(
                                cor: widget.cor_da_area,
                                nomeEvento: evento['nome'],
                                tocpico_evento: evento['topico_id'],
                                dia: evento['dia_realizacao'],
                                mes: evento['mes_realizacao'],
                                ano: evento['ano_realizacao'],
                                local: local,
                                numeroParticipantes:
                                    numeroParticipantes.toString(),
                                imagePath: evento['caminho_imagem'],
                                tipo_evento: evento['tipodeevento_id'],
                                horas: evento['horas'],
                                context: context,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        backgroundColor: widget.cor_da_area,
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
                side: BorderSide(width: 1, color: widget.cor_da_area),
                borderRadius: BorderRadius.circular(15),
              ),
              color: widget.cor_da_area, // Cor de fundo do botão
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
                      'Criar Evento',
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
            backgroundColor: widget.cor_da_area,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CriarEvento(
                    cor: widget.cor_da_area,
                    idArea: widget.id_area,
                  ),
                ),
              );
            },
          ),
          if (eventos.isNotEmpty)
            SpeedDialChild(
              child: Material(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: widget.cor_da_area),
                  borderRadius: BorderRadius.circular(15),
                ),
                color: const Color.fromARGB(
                    255, 255, 255, 255), // Cor de fundo do botão
                child: Container(
                  alignment: Alignment.center, // Alinhamento do texto
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt_outlined,
                          color: widget.cor_da_area), // Adiciona o ícone aqui
                      const SizedBox(
                          width: 8), // Espaçamento entre o ícone e o texto
                      Text(
                        'Filtrar por',
                        style: TextStyle(
                          color: widget.cor_da_area, // Cor do texto
                          fontSize: 16,
                          fontWeight: FontWeight.bold, // Peso da fonte do texto
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: widget.cor_da_area,
              onTap: () {
                _abrirFiltrarPor();
              },
            ),
          if (eventos.isNotEmpty)
            SpeedDialChild(
              child: Material(
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: widget.cor_da_area),
                  borderRadius: BorderRadius.circular(15),
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, color: widget.cor_da_area),
                      const SizedBox(width: 8),
                      Text(
                        'Ordenar por',
                        style: TextStyle(
                          color: widget.cor_da_area,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: widget.cor_da_area,
              onTap: () {
                _abrirOrdenarPor();
              },
            ),
          SpeedDialChild(
            child: Material(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: widget.cor_da_area),
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color.fromARGB(
                  255, 255, 255, 255), // Cor de fundo do botão
              child: Container(
                alignment: Alignment.center, // Alinhamento do texto
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: widget.cor_da_area), // Adiciona o ícone aqui
                    const SizedBox(
                        width: 8), // Espaçamento entre o ícone e o texto
                    Text(
                      'Calendario',
                      style: TextStyle(
                        color: widget.cor_da_area,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: widget.cor_da_area,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CalendarioGeralEventos(
                          id_area: widget.id_area,
                          cor_da_area: widget.cor_da_area,
                        )),
              );
            },
          ),
          // Adicione mais botões conforme necessário
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ////FLOATING BOTOM
      ///
    );
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
                        'Ordenar Eventos por:',
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
                        Funcoes_Eventos funcoeseventos = Funcoes_Eventos();
                        final centroProvider = Provider.of<Centro_Provider>(
                            context,
                            listen: false);
                        final centroSelecionado =
                            centroProvider.centroSelecionado;
                        int centroId = centroSelecionado!.id;
                        List<Map<String, dynamic>> evetnosOrdenados =
                            await funcoeseventos.consultaEventosPorArea(
                                centroId, widget.id_area);
                        setState(() {
                          eventos = evetnosOrdenados;
                          //print("Grupos ordenados:");
                          //for (var grupo in grupos) {
                          // print(grupo[
                          //   'nome']);
                          // }
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
                      onPressed: () {
                        List<Map<String, dynamic>> eventosOrdenados =
                            List.from(eventos);
                        ordenarPorNumeroMembros(eventosOrdenados);
                        setState(() {
                          eventos = eventosOrdenados;
                          //print("Grupos ordenados:");
                          //for (var grupo in grupos) {
                          // print(grupo[
                          //   'nome']);
                          // }
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
                              Icons.group_rounded,
                              color: Color(0xFF79747E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mais Participantes',
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
                        });
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

  List<Map<String, dynamic>> ordenarPorNumeroMembros(
      List<Map<String, dynamic>> lista) {
    lista.sort((a, b) {
      if (a['numero_inscritos'] != null && b['numero_inscritos'] != null) {
        return b['numero_inscritos'].compareTo(a['numero_inscritos']);
      }
      return 0;
    });
    return lista;
  }

  List<Map<String, dynamic>> ordenarPorDataCriacao(
      List<Map<String, dynamic>> lista) {
    lista.sort((a, b) {
      if (a['ano_realizacao'] != null &&
          a['mes_realizacao'] != null &&
          a['dia_realizacao'] != null &&
          b['ano_realizacao'] != null &&
          b['mes_realizacao'] != null &&
          b['dia_realizacao'] != null) {
        // Crie objetos DateTime para cada grupo
        DateTime dataA = DateTime(
            a['ano_realizacao'], a['mes_realizacao'], a['dia_realizacao']);
        DateTime dataB = DateTime(
            b['ano_realizacao'], b['mes_realizacao'], b['dia_realizacao']);

        return dataB.compareTo(dataA);
      }
      return 0;
    });
    return lista;
  }

  void _abrirFiltrarPor() {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                      child: Text(
                        'Filtrar Eventos por:',
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
                    for (var topico in topicos)
                      ElevatedButton(
                        onPressed: () async {
                          final centroProvider = Provider.of<Centro_Provider>(
                              context,
                              listen: false);
                          final centroSelecionado =
                              centroProvider.centroSelecionado;
                          int centroId = centroSelecionado!.id;
                          Funcoes_Eventos funcoeseventos = Funcoes_Eventos();
                          List<Map<String, dynamic>> eventosOrdenados =
                              await funcoeseventos.consultaEventosPorArea(
                                  centroId, widget.id_area);
                          eventos = eventosOrdenados;

                          List<Map<String, dynamic>> eventosDoTopico =
                              filtrarEventosPorTopico(eventos, topico['id']);
                          setState(() {
                            eventos = eventosDoTopico;
                          });

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 21, 20, 22),
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  topico[
                                      'topico_imagem'], // Caminho da imagem do tópico
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  topico['nome_topico'], // Nome do tópico
                                  style: TextStyle(
                                    color: widget.cor_da_area,
                                    fontSize: 19,
                                    fontFamily: 'ABeeZee',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
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

  List<Map<String, dynamic>> filtrarEventosPorTopico(
      List<Map<String, dynamic>> eventos, int idTopico) {
    return eventos.where((evento) => evento['topico_id'] == idTopico).toList();
  }
}
