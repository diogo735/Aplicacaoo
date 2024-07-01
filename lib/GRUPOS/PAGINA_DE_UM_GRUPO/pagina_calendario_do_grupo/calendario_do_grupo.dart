import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Adicione este import
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_calendario_do_grupo/card_evento_do_calendario.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';

class CALENDARIO_DO_GRUPO extends StatefulWidget {
  final int idGrupo;

  const CALENDARIO_DO_GRUPO({super.key, required this.idGrupo});
  @override
  _CALENDARIO_DO_GRUPOState createState() => _CALENDARIO_DO_GRUPOState();
}

class _CALENDARIO_DO_GRUPOState extends State<CALENDARIO_DO_GRUPO> {
  List<Map<String, dynamic>> eventos = []; // Lista de eventos
  DateTime today = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, dynamic>? grupo;
  bool floating_botao = true; // Adicione esta variável

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("pt_BR");
    _carregarDetalhesDoGrupo();
  }

  void _carregarDetalhesDoGrupo() async {
    grupo = await Funcoes_Grupos.detalhes_do_grupo(widget.idGrupo);
    if (grupo != null) {
      _carregarEventos();
      print('Detalhes do grupo: $grupo');
      setState(() {
        grupo = grupo;
      });
    }
  }

  void _carregarEventos() async {
    if (grupo != null) {
      int topicoId = grupo!['topico_id'];
      print('O tópico do grupo é: $topicoId');
      Funcoes_Eventos funcoesEventos = Funcoes_Eventos();
      List<Map<String, dynamic>> eventosCarregados =
          await funcoesEventos.consultaEventosPorTopico(topicoId);
      setState(() {
        eventos = eventosCarregados;
      });
    }
  }

  List<Map<String, dynamic>> _obter_eventos_numdia(DateTime day) {
    return eventos.where((evento) {
      return evento['dia_realizacao'] == day.day &&
          evento['mes_realizacao'] == day.month &&
          evento['ano_realizacao'] == day.year;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> eventosNumMes = eventos.where((evento) {
      return evento['mes_realizacao'] == _selectedDay.month &&
          evento['ano_realizacao'] == _selectedDay.year;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendário do Grupo',
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color(0xFF15659F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 243, 243, 243),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 243, 243, 243),
            child: TableCalendar(
              locale: "pt_BR",
              rowHeight: 40,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15659F),
                ),
                titleTextFormatter: (day, locale) =>
                    '${DateFormat('MMMM', locale).format(day).substring(0, 1).toUpperCase()}${DateFormat('MMMM', locale).format(day).substring(1)} ${DateFormat('yyyy', locale).format(day)}',
              ),
              focusedDay: today,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Color(0xFF1F2225),
                  fontSize: 14,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                  height: 0.11,
                ),
                weekendStyle: TextStyle(
                  color: Color(0xFF1F2225),
                  fontSize: 14,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                  height: 0.11,
                ),
              ),
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 3, 14),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(5), // Define o raio dos cantos
                  color: const Color.fromARGB(0, 21, 102, 159),
                  border: Border.all(color: Color(0xFF15659F), width: 2),
                ),
                todayTextStyle: const TextStyle(
                  color: Color(0xFF15659F),
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF15659F),
                  shape: BoxShape.circle,
                ),
                markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),
              ),
              onPageChanged: (focusedDay) {
                setState(() {
                  today = focusedDay;
                  _selectedDay = focusedDay;
                });
              },
              eventLoader: _obter_eventos_numdia,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 1.0),
                  child: Text(
                    'Eventos em ${DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDay).replaceRange(0, 1, DateFormat('MMMM', 'pt_BR').format(_selectedDay).substring(0, 1).toUpperCase())}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'ABeeZee',
                      fontWeight: FontWeight.w600,
                      height: 0.11,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                if (eventosNumMes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Text(
                      'Nº total: ${eventosNumMes.length}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 167, 167, 167),
                        fontSize: 12,
                        fontFamily: 'ABeeZee',
                        fontWeight: FontWeight.w400,
                        height: 0.11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SizedBox(
              width: 340,
              child: eventosNumMes.isEmpty
                  ? Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/no_events.png',
                                width: 60,
                                height: 60,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Ainda sem Eventos!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(255, 151, 151, 151),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: eventosNumMes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        return FutureBuilder<String>(
                          future: Funcoes_Topicos.getCaminhoImagemDoTopico(
                              eventosNumMes[index]['topico_id']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return const Text('Erro ao carregar imagem');
                              } else {
                                String caminhoDoTopico = snapshot.data ?? '';
                                return CARD_EVENTO_DO_CALENDARIO(
                                  context,
                                  nomeEvento: eventosNumMes[index]['nome'],
                                  dia: eventosNumMes[index]['dia_realizacao'],
                                  mes: eventosNumMes[index]['mes_realizacao'],
                                  numeroParticipantes: eventosNumMes[index]
                                      ['numero_inscritos'],
                                  imagePath: eventosNumMes[index]
                                      ['caminho_imagem'],
                                  imagem_topico: caminhoDoTopico,
                                );
                              }
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        );
                      },
                    ),
            ),
          )
        ],
      ),
      floatingActionButton: Visibility(
        visible: floating_botao,
        child: SpeedDial(
          icon: Icons.add,
          backgroundColor: const Color(0xFF15659F),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          curve: Curves.bounceIn,
          overlayColor: null,
          overlayOpacity: 0.0,
          buttonSize: const Size(150, 60),
          childrenButtonSize: const Size(150, 60),
          ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
