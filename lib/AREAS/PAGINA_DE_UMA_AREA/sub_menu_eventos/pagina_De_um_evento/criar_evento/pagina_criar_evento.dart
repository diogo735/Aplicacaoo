import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/criar_evento/pagina_previsualizar.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:http/http.dart' as http;
import 'package:ficha3/BASE_DE_DADOS/APIS/api_partilhas.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';

class CriarEvento extends StatefulWidget {
  final Color cor;
  final int idArea;

  const CriarEvento({Key? key, required this.cor, required this.idArea})
      : super(key: key);

  @override
  _CriarEventoState createState() => _CriarEventoState();
}

class _CriarEventoState extends State<CriarEvento> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  File? _imagemSelecionada;
  double _imagemAspectRatio = 1.0;
  int _currentLenght_titulo = 0;
  final int _maxLength_titulo = 50;
  int _currentLenght_descricao = 0;
  final int _maxLength_descricao = 150;
  ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);

  DateTime? _dataSelecionada_inicio;
  DateTime? _dataSelecionada_fim;
  TimeOfDay? _horaSelecionada_inicio;
  TimeOfDay? _horaSelecionada_fim;
  final TextEditingController local_controller = TextEditingController();
  int? _idTipoEventoSelecionado;
  String? _nomeTipoEventoSelecionado;
  String? _imagemTipoEventoSelecionado;
  int? _idTopicoSelecionado;
  String? _nomeTopicoSelecionado;
String? _imagemTopicoSelecionado;


  List<File> _imagensSelecionadas = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final Image image = Image.file(imageFile);
      final Completer<Size> completer = Completer<Size>();
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        }),
      );
      final Size imageSize = await completer.future;

      setState(() {
        _imagemSelecionada = imageFile;
        _imagemAspectRatio = imageSize.width / imageSize.height;
        _updateButtonState();
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final Image image = Image.file(imageFile);
      final Completer<Size> completer = Completer<Size>();
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        }),
      );
      final Size imageSize = await completer.future;

      setState(() {
        _imagemSelecionada = imageFile;
        _imagemAspectRatio = imageSize.width / imageSize.height;
        _updateButtonState();
      });
    }
  }

  void _mostraropcoesparaselecionarImagem(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  _pickImage();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tirar Foto'),
                onTap: () {
                  _takePhoto();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage2() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      setState(() {
        _imagensSelecionadas.add(imageFile);
        _updateButtonState();
      });
    }
  }

  Future<void> _takePhoto2() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      setState(() {
        _imagensSelecionadas.add(imageFile);
        _updateButtonState();
      });
    }
  }

  void _mostraropcoesparaselecionarImagem2(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  _pickImage2();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tirar Foto'),
                onTap: () {
                  _takePhoto2();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatarData(DateTime data) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(data);
  }

  Future<int?> _mostrarDialogoDeSelecao(BuildContext context) async {
    Funcoes_TipodeEvento funcoesTipodeEvento = Funcoes_TipodeEvento();

    List<Map<String, dynamic>> tipos =
        await funcoesTipodeEvento.consultatipodeevento();

    return await showDialog<int?>(
      context: context,
      builder: (BuildContext context) {
        double alturaMaxima = MediaQuery.of(context).size.height * 0.9;
        double larguraDesejada = MediaQuery.of(context).size.width;
        double alturaLista = alturaMaxima * 0.84;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Dialog(
              backgroundColor: const Color.fromARGB(0, 244, 67, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: alturaMaxima,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 170, 80, 80),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15),
                              child: Text(
                                'Selecionar tipo de evento:',
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
                            Container(
                              height: alturaLista,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: tipos.map((tipo) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context,
                                            tipo[
                                                'id']); // Retorna o ID ao invés de usar setState
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: const Color.fromARGB(
                                            255, 21, 20, 22),
                                        backgroundColor: const Color.fromARGB(
                                            0, 255, 255, 255),
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.file(
                                                File(tipo[
                                                    'caminho_imagem']), // Caminho da imagem do tipo
                                                width: 30,
                                                height: 30,
                                              ),
                                              const SizedBox(width: 15),
                                              Text(
                                                tipo[
                                                    'nome_tipo'], // Nome do tipo de evento
                                                style: TextStyle(
                                                  color: widget.cor,
                                                  fontSize: 19,
                                                  fontFamily: 'ABeeZee',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: SizedBox(
                        height: 40,
                        width: double.infinity,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<int?> _mostrarDialogoDeSelecaoTopico(BuildContext context) async {
    Funcoes_Topicos funcoesTopicos = Funcoes_Topicos();

    List<Map<String, dynamic>> topicos =
        await funcoesTopicos.consultaTopicosPorArea(widget.idArea);

    return await showDialog<int?>(
      context: context,
      builder: (BuildContext context) {
        double alturaMaxima = MediaQuery.of(context).size.height * 0.9;
        double larguraDesejada = MediaQuery.of(context).size.width;
        double alturaLista = alturaMaxima * 0.84;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Dialog(
              backgroundColor: const Color.fromARGB(0, 244, 67, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                height: alturaMaxima,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(0, 170, 80, 80),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15),
                              child: Text(
                                'Selecionar Tópico do Evento:',
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
                            Container(
                              height: alturaLista,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: topicos.map((topico) {
                                    return ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context,
                                            topico[
                                                'id']); // Retorna o ID ao invés de usar setState
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: const Color.fromARGB(
                                            255, 21, 20, 22),
                                        backgroundColor: const Color.fromARGB(
                                            0, 255, 255, 255),
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.file(
                                                File(topico[
                                                    'topico_imagem']), // Caminho da imagem do tópico
                                                width: 30,
                                                height: 30,
                                              ),
                                              const SizedBox(width: 15),
                                              Text(
                                                topico[
                                                    'nome_topico'], // Nome do tópico
                                                style: TextStyle(
                                                  color: widget.cor,
                                                  fontSize: 19,
                                                  fontFamily: 'ABeeZee',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0.0),
                      child: SizedBox(
                        height: 40,
                        width: double.infinity,
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tituloController.addListener(() {
      setState(() {
        _currentLenght_titulo = _tituloController.text.length;
      });
    });
    _descricaoController.addListener(() {
      setState(() {
        _currentLenght_descricao = _descricaoController.text.length;
      });
    });
    _tituloController.addListener(_updateButtonState);
    _descricaoController.addListener(_updateButtonState);
    local_controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _tituloController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    final isDescricaoNotEmpty = _descricaoController.text.trim().isNotEmpty;
    final isTituloNotEmpty = _tituloController.text.trim().isNotEmpty;
    final isLocalizacaoNotEmpty = local_controller.text.trim().isNotEmpty;
    final isCapaSelecionada = _imagemSelecionada != null;
    final isDataInicioSelecionada = _dataSelecionada_inicio != null;
    final isDataFimSelecionada = _dataSelecionada_fim != null;
    final isHoraInicioSelecionada = _horaSelecionada_inicio != null;
    final isHoraFimSelecionada = _horaSelecionada_fim != null;
    final isTipoEventoSelecionado = _idTipoEventoSelecionado != null;
    final isTopicoSelecionado=_idTopicoSelecionado!=null;
    final isImagensGaleria=_imagensSelecionadas.isNotEmpty;

    isButtonEnabled.value = isDescricaoNotEmpty &&
        isTituloNotEmpty &&
        isLocalizacaoNotEmpty &&
        isCapaSelecionada &&
        isDataInicioSelecionada &&
        isDataFimSelecionada &&
        isHoraInicioSelecionada &&
        isHoraFimSelecionada &&
        isTipoEventoSelecionado&&
        isTopicoSelecionado&&
        isImagensGaleria;
  }

  Future<bool> _mostrarDialogoConfirmacao(BuildContext context) async {
    // Verifica se alguma das variáveis está preenchida ou diferente de null
    if (_dataSelecionada_inicio != null ||
        _dataSelecionada_fim != null ||
        _horaSelecionada_inicio != null ||
        _horaSelecionada_fim != null ||
        local_controller.text.isNotEmpty ||
        _idTipoEventoSelecionado != null ||
        _nomeTipoEventoSelecionado != null ||
        _imagemTipoEventoSelecionado != null ||
        _tituloController.text.isNotEmpty ||
        _descricaoController.text.isNotEmpty ||
        _imagemSelecionada != null ||
        _imagensSelecionadas.isNotEmpty) {
      return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                titlePadding: const EdgeInsets.only(
                    top:
                        16.0), // Adiciona padding ao título para espaço extra acima do ícone
                title: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 48, // Tamanho do ícone
                    ),
                    SizedBox(height: 8), // Espaço entre o ícone e o título
                    Text(
                      'Deseja sair?',
                      textAlign:
                          TextAlign.center, // Centraliza o texto do título
                    ),
                  ],
                ),
                content: const Text(
                  'As informações inseridas serão perdidas. Deseja continuar?',
                  textAlign: TextAlign.center, // Centraliza o texto do conteúdo
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Não sair
                    },
                    child: const Text('Não'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF15659F),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Sim'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF15659F),
                    ),
                  ),
                ],
              );
            },
          ) ??
          false; // Retorna false se o diálogo for fechado sem uma resposta
    } else {
      // Se nenhuma das condições for verdadeira, permitir a navegação sem mostrar o diálogo
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final shouldPop = await _mostrarDialogoConfirmacao(context);
          return shouldPop;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Criar Evento',
                style: TextStyle(
                  fontSize: 21,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Roboto',
                )),
            backgroundColor: widget.cor,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () async {
                final shouldPop = await _mostrarDialogoConfirmacao(context);
                if (shouldPop) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          body: GestureDetector(
              onTap: () {
                // Remove o foco de qualquer campo de texto atualmente focado
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.image_rounded,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Text(
                              'Defenir Capa do Evento',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: GestureDetector(
                            onTap: () =>
                                _mostraropcoesparaselecionarImagem(context),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: _imagemSelecionada != null
                                  ? null
                                  : MediaQuery.of(context).size.height / 3.5,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _imagemSelecionada != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          10), // Aplica bordas arredondadas
                                      child: AspectRatio(
                                        aspectRatio: _imagemAspectRatio,
                                        child: Image.file(
                                          _imagemSelecionada!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'assets/images/fundo_capa_criar_evento.png',
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.subject_rounded,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Text(
                              'Detalhes do Evento',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Título',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Column(
                          children: [
                            TextField(
                              controller: _tituloController,
                              cursorColor: const Color(0xFF15659F),
                              decoration: InputDecoration(
                                hintText: 'insira o titulo do evento...',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF6C757D)),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color:
                                          Color.fromARGB(150, 158, 158, 158)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: widget.cor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                '$_currentLenght_titulo /$_maxLength_titulo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      _currentLenght_titulo <= _maxLength_titulo
                                          ? Colors.black
                                          : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          child: Padding(
                            padding: EdgeInsets.only(left: 15.0),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Descreva o Evento ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            // Remove o foco do campo de texto atual, o que fecha o teclado
                            FocusScope.of(context).unfocus();
                          },
                          child: Column(
                            children: [
                              TextField(
                                controller: _descricaoController,
                                cursorColor: const Color(0xFF15659F),
                                decoration: InputDecoration(
                                  hintText:
                                      'insira um breve resumo do seu evento...',
                                  hintStyle:
                                      const TextStyle(color: Color(0xFF6C757D)),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                            Color.fromARGB(150, 158, 158, 158)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: widget.cor),
                                  ),
                                ),
                                textInputAction: TextInputAction.done,
                                maxLines: 4, // Limita a uma única linha
                                onSubmitted: (value) {
                                  // Desfoca e fecha o teclado ao pressionar "Done"
                                  FocusScope.of(context).unfocus();
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  '$_currentLenght_descricao /$_maxLength_descricao',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _currentLenght_descricao <=
                                            _maxLength_descricao
                                        ? Colors.black
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.event_available,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Text(
                              'Defina a data do Evento',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0, right: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "O evento começa",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        DateTime? data = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _dataSelecionada_inicio ??
                                                  DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: widget.cor,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: widget.cor,
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (data != null) {
                                          // Verifica se a data de início não é posterior à data de término
                                          if (_dataSelecionada_fim != null &&
                                              data.isAfter(
                                                  _dataSelecionada_fim!)) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'A data de início não pode ser posterior à data de término !!!',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() {
                                            _dataSelecionada_inicio = data;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.calendar_today,
                                          color: Colors.grey),
                                      label: Text(
                                        _dataSelecionada_inicio != null
                                            ? '${_dataSelecionada_inicio!.day}/${_dataSelecionada_inicio!.month}/${_dataSelecionada_inicio!.year}'
                                            : 'Dia',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        side: BorderSide(color: widget.cor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        TimeOfDay? hora = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              _horaSelecionada_inicio ??
                                                  TimeOfDay.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: widget.cor,
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                                textButtonTheme:
                                                    TextButtonThemeData(
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: widget.cor,
                                                  ),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        );

                                        if (hora != null) {
                                          // Verifica se a hora de início não é posterior à hora de término
                                          if (_dataSelecionada_fim != null &&
                                              _horaSelecionada_fim != null &&
                                              isSameDay(_dataSelecionada_fim!,
                                                  _dataSelecionada_inicio!)) {
                                            DateTime dataHoraFim = DateTime(
                                              _dataSelecionada_fim!.year,
                                              _dataSelecionada_fim!.month,
                                              _dataSelecionada_fim!.day,
                                              _horaSelecionada_fim!.hour,
                                              _horaSelecionada_fim!.minute,
                                            );

                                            DateTime dataHoraInicio = DateTime(
                                              _dataSelecionada_inicio!.year,
                                              _dataSelecionada_inicio!.month,
                                              _dataSelecionada_inicio!.day,
                                              hora.hour,
                                              hora.minute,
                                            );

                                            if (dataHoraInicio
                                                .isAfter(dataHoraFim)) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'A hora de início não pode ser posterior à hora de término !!!',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }
                                          }

                                          setState(() {
                                            _horaSelecionada_inicio = hora;
                                          });
                                        }
                                      },
                                      icon: const Icon(Icons.access_time,
                                          color: Colors.grey),
                                      label: Text(
                                        _horaSelecionada_inicio != null
                                            ? '${_horaSelecionada_inicio!.format(context)}'
                                            : 'Hora',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        side: BorderSide(color: widget.cor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                "O evento termina",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _dataSelecionada_inicio == null
                                          ? null // Desativa o botão se a data de início não foi selecionada
                                          : () async {
                                              DateTime? data =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    _dataSelecionada_fim ??
                                                        DateTime.now(),
                                                firstDate:
                                                    _dataSelecionada_inicio!,
                                                lastDate: DateTime(2100),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          ColorScheme.light(
                                                        primary: widget.cor,
                                                        onPrimary: Colors.white,
                                                        onSurface: Colors.black,
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              widget.cor,
                                                        ),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );

                                              if (data != null) {
                                                if (data.isBefore(
                                                    _dataSelecionada_inicio!)) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'A data de término não pode ser anterior à data de início !!!',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                setState(() {
                                                  _dataSelecionada_fim = data;
                                                });
                                              }
                                            },
                                      icon: const Icon(Icons.calendar_today,
                                          color: Colors.grey),
                                      label: Text(
                                        _dataSelecionada_fim != null
                                            ? '${_dataSelecionada_fim!.day}/${_dataSelecionada_fim!.month}/${_dataSelecionada_fim!.year}'
                                            : 'Dia',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        side: BorderSide(color: widget.cor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _dataSelecionada_inicio == null
                                          ? null // Desativa o botão se a data de início não foi selecionada
                                          : () async {
                                              TimeOfDay? hora =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime:
                                                    _horaSelecionada_fim ??
                                                        TimeOfDay.now(),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          ColorScheme.light(
                                                        primary: widget.cor,
                                                        onPrimary: Colors.white,
                                                        onSurface: Colors.black,
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              widget.cor,
                                                        ),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );

                                              if (hora != null) {
                                                if (_dataSelecionada_inicio != null &&
                                                    _horaSelecionada_inicio !=
                                                        null &&
                                                    isSameDay(
                                                        _dataSelecionada_fim!,
                                                        _dataSelecionada_inicio!)) {
                                                  DateTime dataHoraInicio =
                                                      DateTime(
                                                    _dataSelecionada_inicio!
                                                        .year,
                                                    _dataSelecionada_inicio!
                                                        .month,
                                                    _dataSelecionada_inicio!
                                                        .day,
                                                    _horaSelecionada_inicio!
                                                        .hour,
                                                    _horaSelecionada_inicio!
                                                        .minute,
                                                  );

                                                  DateTime dataHoraFim =
                                                      DateTime(
                                                    _dataSelecionada_fim!.year,
                                                    _dataSelecionada_fim!.month,
                                                    _dataSelecionada_fim!.day,
                                                    hora.hour,
                                                    hora.minute,
                                                  );

                                                  if (dataHoraFim.isBefore(
                                                      dataHoraInicio)) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'A hora de término não pode ser anterior à hora de início !!!',
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                }

                                                setState(() {
                                                  _horaSelecionada_fim = hora;
                                                });
                                              }
                                            },
                                      icon: const Icon(Icons.access_time,
                                          color: Colors.grey),
                                      label: Text(
                                        _horaSelecionada_fim != null
                                            ? '${_horaSelecionada_fim!.format(context)}'
                                            : 'Hora',
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 13),
                                        side: BorderSide(color: widget.cor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.location_on,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Text(
                              'Localização do Evento',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: local_controller,
                          decoration: InputDecoration(
                            hintText:
                                'Escreva o local do evento...', // Texto de dica
                            prefixIcon: const Icon(
                              Icons.location_on, // Ícone de localização
                              color: Colors.grey, // Cor do ícone
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: widget.cor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: widget.cor,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: widget.cor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.local_offer_rounded,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Text(
                              'Tipo de Evento',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: OutlinedButton(
                            onPressed: () async {
                              int? idSelecionado =
                                  await _mostrarDialogoDeSelecao(context);

                              if (idSelecionado != null) {
                                _idTipoEventoSelecionado = idSelecionado;

                                Map<String, String> dados =
                                    await Funcoes_TipodeEvento
                                        .obterDadosTipoEvento(
                                            _idTipoEventoSelecionado!);

                                setState(() {
                                  _nomeTipoEventoSelecionado = dados["nome"];
                                  _imagemTipoEventoSelecionado =
                                      dados["imagem"];
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              side: BorderSide(color: widget.cor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: _nomeTipoEventoSelecionado == null
                                ? const Text(
                                    'Selecionar tipo',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.file(
                                        File(_imagemTipoEventoSelecionado!),
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _nomeTipoEventoSelecionado!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 30),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Tópico do Evento',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: OutlinedButton(
                            onPressed: () async {
                              int? idSelecionado =
                                  await _mostrarDialogoDeSelecaoTopico(context);

                              if (idSelecionado != null) {
                                _idTopicoSelecionado = idSelecionado;

                                Map<String, String> dados =
                                    await Funcoes_Topicos.obterDadosTopico(
                                        _idTopicoSelecionado!);

                                setState(() {
                                  _nomeTopicoSelecionado = dados["nome"];
                                  _imagemTopicoSelecionado =
                                      dados["imagem"];
                                  _idTopicoSelecionado=idSelecionado;
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 8),
                              side: BorderSide(color: widget.cor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: _nomeTopicoSelecionado == null
                                ? const Text(
                                    'Selecionar tópico',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.file(
                                        File(_imagemTopicoSelecionado!),
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _nomeTopicoSelecionado!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(
                                  Icons.image,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Text(
                              'Galeria',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 231, 230, 230),
                            borderRadius: BorderRadius.circular(
                                12), // Cantos arredondados
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, // Padding horizontal de 15
                            vertical: 10.0, // Padding vertical (opcional)
                          ),
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double spacing =
                                  5.0; // Espaçamento entre as imagens

                              return Wrap(
                                spacing: spacing,
                                runSpacing: spacing,
                                children: [
                                  ..._imagensSelecionadas
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    File imageFile = entry.value;

                                    return Stack(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.5,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3.5,
                                          decoration: BoxDecoration(
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: DecorationImage(
                                              image: FileImage(imageFile),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _imagensSelecionadas
                                                    .removeAt(index);
                                                    _updateButtonState();
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                    198, 244, 67, 54),
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              child: const Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                  GestureDetector(
                                    onTap: () =>
                                        _mostraropcoesparaselecionarImagem2(
                                            context),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          3.5,
                                      height:
                                          MediaQuery.of(context).size.width /
                                              3.5,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[200],
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '+\nCarregar',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 35),
                        Center(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: isButtonEnabled,
                            builder: (context, isEnabled, child) {
                              return ElevatedButton.icon(
                                onPressed: isEnabled
                                    ? () {
                                        // Redireciona para a página "evento"
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CarregandoPagina(
                                                  idTopico: _idTopicoSelecionado!,
                                              idArea: widget.idArea,
                                              dataInicio:
                                                  _dataSelecionada_inicio,
                                              dataFim: _dataSelecionada_fim,
                                              horaInicio:
                                                  _horaSelecionada_inicio,
                                              horaFim: _horaSelecionada_fim,
                                              local: local_controller.text,
                                              idTipoEvento:
                                                  _idTipoEventoSelecionado,
                                              titulo: _tituloController.text,
                                              descricao:
                                                  _descricaoController.text,
                                              capa: _imagemSelecionada,
                                              imagensGaleria:
                                                  _imagensSelecionadas,
                                            ),
                                          ),
                                        );
                                        ;
                                      }
                                    : null,
                                label: const Text(
                                  'Continuar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  backgroundColor: widget.cor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: () async {
                              final shouldPop =
                                  await _mostrarDialogoConfirmacao(context);
                              if (shouldPop) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ));
  }
}
