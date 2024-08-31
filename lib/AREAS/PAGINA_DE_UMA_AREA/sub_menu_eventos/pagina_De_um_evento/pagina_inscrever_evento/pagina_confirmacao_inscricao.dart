import 'package:device_calendar/device_calendar.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_inscrever_evento/card_evento_confirma.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class PagConfirmacaoInscricao extends StatefulWidget {
  final int idEvento;
  final Color cor;

  const PagConfirmacaoInscricao({
    super.key,
    required this.idEvento,
    required this.cor,
  });

  @override
  _PagConfirmacaoInscricaoState createState() =>
      _PagConfirmacaoInscricaoState();
}

class _PagConfirmacaoInscricaoState extends State<PagConfirmacaoInscricao> {
  Map<String, dynamic>? eventoDetalhes;
  int numeroDeParticipantes = 0;
  String caminhoImagemTopico = '';
  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
    _carregarDetalhesEvento();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<void> _carregarDetalhesEvento() async {
    // Perform all async operations outside of setState
    Map<String, dynamic>? detalhes =
        await Funcoes_Eventos.consultaDetalhesEventoPorId2(widget.idEvento);
    int participantes =
        await Funcoes_Participantes_Evento.getNumeroDeParticipantes(
            widget.idEvento);

    // Carregar imagem do tópico
    String imagemTopico = await Funcoes_Topicos.getCaminhoImagemDoTopico(
        detalhes?['topico_id'] ?? 0);

    // Once all async operations are complete, call setState
    setState(() {
      eventoDetalhes = detalhes;
      numeroDeParticipantes = participantes;
      caminhoImagemTopico = imagemTopico;
    });
  }

  Future<void> _addEventToCalendar(
      String nomeEvento, tz.TZDateTime eventDate) async {
    // Solicitar permissões para acessar o calendário
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        return; // Permissão negada, não é possível continuar
      }
    }

    // Obter os calendários disponíveis
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    final calendars = calendarsResult?.data;
    if (calendars == null || calendars.isEmpty) {
      return; // Nenhum calendário disponível
    }

    // Usar o primeiro calendário disponível (você pode permitir que o usuário escolha)
    final selectedCalendar = calendars.first;

    // Criar um novo evento
    final event = Event(
      selectedCalendar.id,
      title: nomeEvento,
      start: eventDate,
      end:
      eventDate.add(const Duration(hours: 2)), 
    );

    // Adicionar o evento ao calendário
    final result = await _deviceCalendarPlugin.createOrUpdateEvent(event);

    if (result?.isSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento adicionado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao adicionar o evento.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Confirmação',
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: widget.cor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 12),
                  const Icon(
                    Icons.check_rounded,
                    color: Color.fromARGB(255, 21, 101, 159),
                    size: 150,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Inscrição Concluída!',
                    style: TextStyle(
                      fontSize: 26, // Tamanho do texto
                      fontWeight: FontWeight.bold, // Negrito
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (eventoDetalhes != null) ...[
                    CARD_EVENTO_Da_confirmacao(
                      nomeEvento: eventoDetalhes!['nome'],
                      dia: int.parse(
                          eventoDetalhes!['dia_realizacao'].toString()),
                      mes: int.parse(
                          eventoDetalhes!['mes_realizacao'].toString()),
                      numeroParticipantes: numeroDeParticipantes,
                      imagePath: eventoDetalhes!['caminho_imagem'],
                      imagem_topico: caminhoImagemTopico,
                    ),
                  ],
                  const SizedBox(height: 25),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aviso:\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Irá receber alertas caso o organizador faça alguma alteração ou caso o evento seja cancelado.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15, right: 15, left: 15),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (eventoDetalhes != null) {
                        // Construct the DateTime from event details
                        int dia = int.parse(
                            eventoDetalhes!['dia_realizacao'].toString());
                        int mes = int.parse(
                            eventoDetalhes!['mes_realizacao'].toString());
                        int ano = int.parse(
                            eventoDetalhes!['ano_realizacao'].toString());

                        // Extrair a hora e minuto do campo 'horas'
                        String horas = eventoDetalhes!['horas'];
                        List<String> partesHoras = horas.split(':');
                        int hora = int.parse(partesHoras[0]);
                        int minuto = int.parse(partesHoras[1]);

                        // Criar um objeto DateTime combinando a data e a hora
                        final DateTime eventDate =
                            DateTime(ano, mes, dia, hora, minuto);

                        // Convert
                        final tz.TZDateTime tzEventDate =
                            tz.TZDateTime.from(eventDate, tz.local);

                        await _addEventToCalendar(
                            eventoDetalhes!['nome'], tzEventDate);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.cor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today, // Ícone de agenda
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Adicionar a Agenda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // Voltar
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.cor,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        color: widget.cor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
