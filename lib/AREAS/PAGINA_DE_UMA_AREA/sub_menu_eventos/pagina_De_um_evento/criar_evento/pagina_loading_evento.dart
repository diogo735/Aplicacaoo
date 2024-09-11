import 'dart:convert';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/criar_evento/pagina_evento_validado.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ValidarEventoCriar extends StatefulWidget {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFim;
  final double latitude;
  final double longitude;
  final int? idTipoEvento;
  final String titulo;
  final String descricao;
  final File? capa;
  final List<File> imagensGaleria;
  final int idArea;
  final int idTopico;

  const ValidarEventoCriar({
    Key? key,
    this.dataInicio,
    this.dataFim,
    this.horaInicio,
    this.horaFim,
    required this.latitude,
    required this.longitude,
    this.idTipoEvento,
    required this.titulo,
    required this.descricao,
    this.capa,
    required this.imagensGaleria,
    required this.idArea,
    required this.idTopico,
  }) : super(key: key);

  @override
  _ValidarEventoCriarState createState() => _ValidarEventoCriarState();
}

class _ValidarEventoCriarState extends State<ValidarEventoCriar> {
  String formatarDataHora(DateTime data) {
    return DateFormat("yyyy-MM-ddTHH:mm:ss").format(data) +
        "Z"; // Formato ISO 8601 com UTC
  }

  void criarNovoEvento() async {
    String? capaImagemUrl;
    List<String> galeriaUrls = [];

    if (widget.capa != null) {
      try {
        capaImagemUrl = await _uploadImage(widget.capa!);
      } catch (e) {
        _showErrorSnackBar('Erro ao fazer upload da capa do evento: $e');
        Navigator.of(context).pop();
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
      // Opcional: Pode adicionar um aviso ao usuário ou simplesmente continuar sem imagens.
    }

    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final user_id = usuarioProvider.usuarioSelecionado!.id_user;
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado!.id;

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
   

    Map<String, dynamic> novoEvento = {
      'nome': widget.titulo,
      'descricao': widget.descricao,
      'topico_id': widget.idTopico,
      'datainicioatividade': dataInicioatividade,
      'datafimatividade': dataFimatividade,
      'estado': 'Por validar',
      'centro_id': centroSelecionado,
      'autor_id': user_id,
      'capa_imagem_evento': capaImagemUrl ?? '',
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'area_id': widget.idArea,
      'tipodeevento_id': widget.idTipoEvento,
    };
    ApiEventos apiEventos = ApiEventos();
    try {
      int? eventoId = await apiEventos.criarEvento(novoEvento);

      if (eventoId != null) {
        print('Evento criado com sucesso! ID do evento: $eventoId');
        // Adicionar as URLs das imagens da galeria ao evento criado
        if (galeriaUrls.isNotEmpty) {
          try {
            String galeriaResultado = await apiEventos
                .adicionarImagensGaleriaUrls(eventoId, galeriaUrls);
            print(galeriaResultado);
            String resultadoParticipante =
                await apiEventos.adicionarParticipanteEvento(user_id, eventoId);
            print(resultadoParticipante);
            if (galeriaResultado == "Imagens adicionadas com sucesso!") {
              // Navegar para outra página
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => PaginaEventoValidado(
                          cor: widget.idArea,
                        )),
              );
            } else {
              // Se houver outro resultado, você pode lidar com isso aqui
              _showErrorSnackBar(galeriaResultado);
            }
          } catch (e) {
            print('Erro ao adicionar imagens à galeria do evento: $e');
            _showErrorSnackBar('Erro ao adicionar imagens à galeria: $e');
            Navigator.of(context).pop(); // Voltar à página anterior
          }
        }
      } else {
        _showErrorSnackBar('Erro ao criar o evento.');
        Navigator.of(context).pop(); // Voltar à página anterior
      }
    } on SocketException {
      _showErrorSnackBar('Sem conexão com a internet.');
      Navigator.of(context).pop(); // Voltar à página anterior
    } catch (e) {
      _showErrorSnackBar('Erro inesperado: $e');
      Navigator.of(context).pop(); // Voltar à página anterior
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
    criarNovoEvento(); // Chama a função para criar o evento quando a página carrega
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to block the user from going back
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
                'A validar Evento',
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
