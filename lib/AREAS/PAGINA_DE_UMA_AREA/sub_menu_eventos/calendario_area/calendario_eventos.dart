import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/calendario_area/card_evento_do_calendario.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';

class calendariogeral_eventos extends StatefulWidget {
  final int id_area;
  final Color cor_da_area;

  calendariogeral_eventos({
    required this.id_area,
    required this.cor_da_area,
  });
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

  
  void _carregarEventos() async {
    Funcoes_Eventos funcoesEventos = Funcoes_Eventos();
    List<Map<String, dynamic>> eventosCarregados =
         await funcoesEventos.consultaEventosPorArea(widget.id_area);
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
    List<Map<String, dynamic>> eventosNumMes = eventos.where((evento) {
      return evento['mes_realizacao'] == _selectedDay.month &&
          evento['ano_realizacao'] == _selectedDay.year;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario de Desporto',
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: widget.cor_da_area,
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
                titleTextStyle:  TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.cor_da_area,
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
                  color: const Color.fromARGB(0, 21, 102, 159),
                  border: Border.all(
                      color: widget.cor_da_area, width: 2),
                ),
                todayTextStyle: TextStyle(
                  color: widget.cor_da_area,
                ),
                markerDecoration:  BoxDecoration(
                  color: widget.cor_da_area,
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
                          // Texto "Ainda sem Eventos!" abaixo da imagem
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
                                return const Text(
                                    'Erro ao carregar imagem'); // Tratar erro
                              } else {
                                String caminhoDoTopico = snapshot.data ?? '';
                                return CARD_EVENTO_DO_CALENDARIO(
                                  cor:widget.cor_da_area,
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
                              return const SizedBox
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
