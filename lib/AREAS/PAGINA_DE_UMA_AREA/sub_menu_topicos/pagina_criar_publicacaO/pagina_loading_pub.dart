import 'dart:convert';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/criar_evento/pagina_evento_validado.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_criar_publicacaO/pagina_local_valido.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_publicacoes.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ValidarPublicacaoCriar extends StatefulWidget {
  final String titulo;
  final String descricao;

  final List<File> imagensGaleria;
  final int idArea;
  final int idTopico;
  final String local;
  final String email;
  final String telefone;
  final String web;
  final Map<String, Map<String, TimeOfDay?>> horarios;

  const ValidarPublicacaoCriar({
    Key? key,
    required this.titulo,
    required this.descricao,
    required this.imagensGaleria,
    required this.idArea,
    required this.idTopico,
    required this.local,
    required this.email,
    required this.telefone,
    required this.web,
    required this.horarios,
  }) : super(key: key);

  @override
  _ValidarPublicacaoCriarState createState() => _ValidarPublicacaoCriarState();
}

class _ValidarPublicacaoCriarState extends State<ValidarPublicacaoCriar> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      criarNovaPub(); // Chamando criarNovaPub() após o initState
      _isInitialized = true; // Garante que seja chamado apenas uma vez
    }
  }

  void criarNovaPub() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final user_id = usuarioProvider.usuarioSelecionado!.id_user;
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado!.id;

    // Formatando horários
    Map<String, String> horariosFormatados = {};
    widget.horarios.forEach((dia, horario) {
      final inicio = horario['inicio'];
      final fim = horario['fim'];

      if (inicio != null && fim != null) {
        horariosFormatados[dia] =
            '${inicio.format(context)}-${fim.format(context)}';
      } else {
        horariosFormatados[dia] = 'Fechado';
      }
    });

    List<String> galeriaUrls = [];
    if (widget.imagensGaleria.isNotEmpty) {
      try {
        for (File imagem in widget.imagensGaleria) {
          String url = await _uploadImage(imagem);
          galeriaUrls.add(url);
        }
      } catch (e) {
        _showErrorSnackBar('Erro ao fazer upload das imagens: $e');
        return; // Retorna caso haja erro no upload das imagens
      }
    } else {
      _showErrorSnackBar('Nenhuma imagem selecionada para a galeria.');
      return; // Opcional: pode continuar sem imagens
    }

    // Montando o objeto da nova publicação
    Map<String, dynamic> novaPublicacao = {
      'titulo': widget.titulo,
      'descricao': widget.descricao,
      'topico_id': widget.idTopico,
      'centro_id': centroSelecionado,
      'autor_id': user_id,
      'area_id': widget.idArea,
      'localizacao': widget.local,
      'paginaweb': widget.web,
      'telemovel': widget.telefone,
      'email': widget.email,
      'horario': horariosFormatados, // Horários formatados
      'estado': 'Por validar', // Estado inicial da publicação
      'visivel': true, // Definindo a visibilidade
      'galeria': galeriaUrls,
    };

    // Chamando a API para criar a publicação
    ApiPublicacoes apiPublicacoes = ApiPublicacoes();

    try {
      String resultado = await apiPublicacoes.criarPublicacao(novaPublicacao);

      if (resultado == 'Publicação criada e salva localmente com sucesso!') {
        print(resultado);

        // Navegar para a página de sucesso ou validação
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaginaLocalValidado(
              cor: widget.idArea,
            ),
          ),
        );
      } else {
        _showErrorSnackBar(resultado); // Exibir a mensagem de erro
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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to block the user from going back
        return true;
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
                'A validar Publicação',
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
