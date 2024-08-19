import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/calendariogeral_eventos/card_evento_do_calendario.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';

class calendariogeral_eventos extends StatefulWidget {
  @override
  _calendariogeral_eventosState createState() =>
      _calendariogeral_eventosState();
}

class _calendariogeral_eventosState extends State<calendariogeral_eventos> {
  List<Map<String, dynamic>> eventos = []; // Lista de eventos
  DateTime today = DateTime.now();
  DateTime _selectedDay = DateTime.now(); // Adicione esta variável

  @override
  void initState() {
    super.initState();
    initializeDateFormatting("pt_BR");
    {
      _carregarEventos();
    }
  }

  /// Função para carregar os eventos da base de dados
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

  //
  List<Map<String, dynamic>> _obter_eventos_numdia(DateTime day) {
    return eventos.where((evento) {
      return evento['dia_realizacao'] == day.day &&
          evento['mes_realizacao'] == day.month &&
          evento['ano_realizacao'] == day.year;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar eventos para o mês selecionado
    List<Map<String, dynamic>> eventos_num_Mes = eventos.where((evento) {
      return evento['mes_realizacao'] == _selectedDay.month &&
          evento['ano_realizacao'] == _selectedDay.year;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario de Eventos',
          style: TextStyle(
            fontSize: 22,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color(0xFF15659F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color.fromARGB(255, 243, 243, 243),
      body: Column(
        children: [
          Container(
            color: Color.fromARGB(255, 243, 243, 243),
            child: TableCalendar(
              locale: "pt_BR",
              rowHeight: 40,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF15659F),
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
                ), // Estilo dos dias de semana
                weekendStyle: TextStyle(
                  color: Color(0xFF1F2225),
                  fontSize: 14,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                  height: 0.11,
                ), // Estilo dos fins de semana
              ),
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 3, 14),
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(5), // Define o raio dos cantos
                  color: Color.fromARGB(0, 21, 102, 159),
                  border: Border.all(
                      color: Color.fromARGB(197, 21, 102, 159), width: 2),
                ),
                todayTextStyle: TextStyle(
                  color: const Color.fromARGB(197, 21, 102, 159),
                ),
                markerDecoration: BoxDecoration(
                  color: const Color(0xFF15659F),
                  shape: BoxShape.circle,
                ),
                markerMargin: EdgeInsets.symmetric(horizontal: 1.0),
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
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 1.0),
                  child: Text(
                    'Eventos em ${DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDay).replaceRange(0, 1, DateFormat('MMMM', 'pt_BR').format(_selectedDay).substring(0, 1).toUpperCase())}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'ABeeZee',
                      fontWeight: FontWeight.w600,
                      height: 0.11,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                if (eventos_num_Mes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      'Nº total: ${eventos_num_Mes.length}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 167, 167, 167),
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
          SizedBox(height: 10),
          Expanded(
            child: Container(
              width: 340,
              child: eventos_num_Mes.isEmpty
                  ? Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Texto "Ainda sem Eventos!" abaixo da imagem
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/no_events.png',
                                width: 60,
                                height: 60,
                              ),
                              SizedBox(height: 10),
                              Text(
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
                      itemCount: eventos_num_Mes.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        return FutureBuilder<String>(
                          future: Funcoes_Topicos.getCaminhoImagemDoTopico(
                              eventos_num_Mes[index]['topico_id']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasError) {
                                return Text(
                                    'Erro ao carregar imagem'); // Tratar erro
                              } else {
                                String caminho_do_topico = snapshot.data ?? '';
                                return FutureBuilder<int>(
                                  future: Funcoes_Participantes_Evento
                                      .getNumeroDeParticipantes(
                                          eventos_num_Mes[index]['id']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return Text(
                                            'Erro ao carregar participantes'); // Tratar erro
                                      } else {
                                        int numeroParticipantes =
                                            snapshot.data ?? 0;
                                        return GestureDetector(
                                          onTap: () {
                                            // Navega para a nova página quando o cartão for clicado
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaginaEvento(
                                                        idEvento:
                                                            eventos_num_Mes[
                                                                index]['id']),
                                              ),
                                            );
                                          },
                                          child: CARD_EVENTO_DO_CALENDARIO2(
                                            context: context,
                                            nomeEvento: eventos_num_Mes[index]
                                                ['nome'],
                                            dia: eventos_num_Mes[index]
                                                ['dia_realizacao'],
                                            mes: eventos_num_Mes[index]
                                                ['mes_realizacao'],
                                            numeroParticipantes:
                                                numeroParticipantes,
                                            imagePath: eventos_num_Mes[index]
                                                ['caminho_imagem'],
                                            imagem_topico: caminho_do_topico,
                                          ),
                                        );
                                      }
                                    } else {
                                      return SizedBox
                                          .shrink(); // Retorna um widget vazio enquanto aguarda
                                    }
                                  },
                                );
                              }
                            } else {
                              return SizedBox
                                  .shrink(); // Retorna um widget vazio enquanto aguarda
                            }
                          },
                        );
                      },
                    ),
            ),
          )
        ],
      ),
    );
  }
}
