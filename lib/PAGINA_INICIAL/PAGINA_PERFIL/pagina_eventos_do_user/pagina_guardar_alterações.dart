import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_PERFIL/pagina_eventos_do_user/pagina_evento_atualizado_com_sucesso.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EventoUpdaterWidget extends StatefulWidget {
  final int eventoId;
  final int idTopico;
  final int idArea;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFim;
  final String local;
  final int? idTipoEvento;
  final String titulo;
  final String descricao;
  final File? capa;
  final List<File> imagensGaleria;

  const EventoUpdaterWidget({
    required this.eventoId,
    required this.idTopico,
    required this.idArea,
    required this.dataInicio,
    required this.dataFim,
    required this.horaInicio,
    required this.horaFim,
    required this.local,
    required this.idTipoEvento,
    required this.titulo,
    required this.descricao,
    required this.capa,
    required this.imagensGaleria,
    Key? key,
  }) : super(key: key);

  @override
  _EventoUpdaterWidgetState createState() => _EventoUpdaterWidgetState();
}

class _EventoUpdaterWidgetState extends State<EventoUpdaterWidget> {
  String formatarDataHora(DateTime dateTime) {
    final DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    return "${formatter.format(dateTime)}+00";
  }

  Future<Map<String, double>> _getCoordinatesFromName(String local) async {
    LocalizacaoOSM localizacaoOSM = LocalizacaoOSM();
    var coordinates = await localizacaoOSM.getCoordinatesFromName(local);
    return {
      'latitude': coordinates['latitude']!,
      'longitude': coordinates['longitude']!,
    };
  }

  Future<void> _checkConnectivity() async {
    // Obtém o estado atual da conectividade
    var connectivityResult = await (Connectivity().checkConnectivity());

    // Verifica se não há nenhuma conexão de rede disponível
    if (connectivityResult == ConnectivityResult.none) {
       Navigator.of(context).pop();
      throw Exception('Sem conexão com a internet');
      
    }
  }

 Future<void> atualizarEventoExistente() async {
  try {
    // Verifica a conectividade antes de iniciar todo o processo
    await _checkConnectivity();
  } on SocketException {
    // Se não houver conexão com a internet, exibe a mensagem de erro e volta para a página anterior
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text('Sem conexão com a internet'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop(); // Sai para a página anterior
    return; // Sai da função
  }

  String? capaImagemUrl;
  List<String> galeriaUrls = [];

  // Obtenha as coordenadas do local
  Map<String, double> coordinates;
  try {
    coordinates = await _getCoordinatesFromName(widget.local);
  } catch (e) {
    _showErrorSnackBar('Erro ao obter as coordenadas: $e');
    return;
  }

  // Upload da imagem da capa, se houver
  if (widget.capa != null) {
    try {
      capaImagemUrl = await _uploadImage(widget.capa!);
    } catch (e) {
      _showErrorSnackBar('Erro ao fazer upload da capa do evento: $e');
      return;
    }
  }

  // Upload das imagens da galeria
  if (widget.imagensGaleria.isNotEmpty) {
    try {
      for (File imagem in widget.imagensGaleria) {
        String url = await _uploadImage(imagem);
        galeriaUrls.add(url);
      }
    } catch (e) {
      print('Erro ao fazer upload das imagens da galeria: $e');
      return;
    }
  } else {
    print('Nenhuma imagem selecionada para a galeria.');
  }

  // Combinar a data e a hora de início
  DateTime dataHoraInicio = DateTime(
    widget.dataInicio!.year,
    widget.dataInicio!.month,
    widget.dataInicio!.day,
    widget.horaInicio!.hour,
    widget.horaInicio!.minute,
  );

  // Combinar a data e a hora de fim
  DateTime dataHoraFim = DateTime(
    widget.dataFim!.year,
    widget.dataFim!.month,
    widget.dataFim!.day,
    widget.horaFim!.hour,
    widget.horaFim!.minute,
  );

  // Formatar as datas para o formato desejado
  String dataInicioatividade = formatarDataHora(dataHoraInicio);
  String dataFimatividade = formatarDataHora(dataHoraFim);

  // Prepara o mapa com os dados do evento a ser atualizado
  Map<String, dynamic> eventoAtualizado = {
    'id': widget.eventoId,
    'nome': widget.titulo,
    'descricao': widget.descricao,
    'topico_id': widget.idTopico,
    'datainicioatividade': dataInicioatividade,
    'datafimatividade': dataFimatividade,
    'capa_imagem_evento': capaImagemUrl,
    'latitude': coordinates['latitude'],
    'longitude': coordinates['longitude'],
    'tipodeevento_id': widget.idTipoEvento,
  };

  ApiEventos apiEventos = ApiEventos();
  try {
    bool sucesso =
        await apiEventos.atualizarEvento(widget.eventoId, eventoAtualizado);
    bool sucesso_removeu_imagens =
        await apiEventos.removerTodasImagensDoEvento(widget.eventoId);
    if (sucesso && sucesso_removeu_imagens) {
      print('Evento atualizado com sucesso! ID do evento: ${widget.eventoId}');
      await Funcoes_Eventos.atualizarEvento(eventoAtualizado);
      // Navega para outra página
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaginaEventoAtualizadoComSucesso(),
        ),
      );

      if (galeriaUrls.isNotEmpty) {
        try {
          String galeriaResultado = await apiEventos
              .adicionarImagensGaleriaUrls(widget.eventoId, galeriaUrls);
          print(galeriaResultado);
          if (galeriaResultado == "Imagens adicionadas com sucesso!") {
            Navigator.of(context)
                .pop(true); // Sucesso, retorna para a tela anterior
          } else {
            _showErrorSnackBar(galeriaResultado);
          }
        } catch (e) {
          print('Erro ao adicionar imagens à galeria do evento: $e');
          _showErrorSnackBar('Erro ao adicionar imagens à galeria: $e');
          Navigator.of(context).pop(false);
        }
      } else {
        Navigator.of(context)
            .pop(true); // Sucesso, retorna para a tela anterior
      }
    } else {
      _showErrorSnackBar('Erro ao atualizar o evento.');
      Navigator.of(context).pop(false);
    }
  } catch (e) {
    _showErrorSnackBar('Erro inesperado: $e');
    Navigator.of(context).pop(false);
  }
}


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<String> _uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload'),
    );
    request.fields['key'] = '4d755673a2dc94483064445f4d5c54e9';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['data']['url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  @override
  void initState() {
    super.initState();
    atualizarEventoExistente();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 20,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 6),
              const Text(
                'A Atualizar Evento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 5),
              customCircularProgress(),
              const Spacer(),
              const Text(
                '... por favor aguarde alguns segundos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7E868D),
                  fontSize: 16,
                  fontFamily: 'ABeeZee',
                  fontWeight: FontWeight.w400,
                  height: 0.09,
                ),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget customCircularProgress() {
  return Stack(
    alignment: Alignment.center,
    children: [
      const SizedBox(
        width: 80,
        height: 80,
        child: CircularProgressIndicator(
          strokeWidth: 6,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF15659F)),
        ),
      ),
      Image.asset(
        'assets/images/circulo_progresso.png',
        width: 45,
        height: 45,
        fit: BoxFit.cover,
      ),
    ],
  );
}
