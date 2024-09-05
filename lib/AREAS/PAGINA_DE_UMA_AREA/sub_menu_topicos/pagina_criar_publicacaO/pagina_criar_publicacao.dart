import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/criar_evento/pagina_previsualizar.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_criar_publicacaO/pagina_loading_pub.dart';
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

class PaginaCriarPublicacao extends StatefulWidget {
  final Color cor;
  final int idArea;

  const PaginaCriarPublicacao(
      {Key? key, required this.cor, required this.idArea})
      : super(key: key);

  @override
  _PaginaCriarPublicacaoState createState() => _PaginaCriarPublicacaoState();
}

class _PaginaCriarPublicacaoState extends State<PaginaCriarPublicacao> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();

  double _imagemAspectRatio = 1.0;
  int _currentLenght_titulo = 0;
  final int _maxLength_titulo = 50;
  int _currentLenght_descricao = 0;
  final int _maxLength_descricao = 150;
  ValueNotifier<bool> isButtonEnabled = ValueNotifier(false);
  List<Map<String, dynamic>> _topicos = [];
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _webController = TextEditingController();

  TimeOfDay? _horaSelecionada_inicio;
  TimeOfDay? _horaSelecionada_fim;
  final TextEditingController local_controller = TextEditingController();
  int? _idTipoEventoSelecionado;

  int? _idTopicoSelecionado;

  List<File> _imagensSelecionadas = [];

  // Lista com os dias da semana
  final List<String> _diasDaSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  final Map<String, String> _statusDia = {
    'Segunda-feira': 'Fechado',
    'Terça-feira': 'Fechado',
    'Quarta-feira': 'Fechado',
    'Quinta-feira': 'Fechado',
    'Sexta-feira': 'Fechado',
    'Sábado': 'Fechado',
    'Domingo': 'Fechado',
  };

  // Status de funcionamento atualizado para armazenar as horas de início e fim
  final Map<String, Map<String, TimeOfDay?>> _horarios = {
    'Segunda-feira': {'inicio': null, 'fim': null},
    'Terça-feira': {'inicio': null, 'fim': null},
    'Quarta-feira': {'inicio': null, 'fim': null},
    'Quinta-feira': {'inicio': null, 'fim': null},
    'Sexta-feira': {'inicio': null, 'fim': null},
    'Sábado': {'inicio': null, 'fim': null},
    'Domingo': {'inicio': null, 'fim': null},
  };

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

  Future<void> _selecionarHoraInicio() async {
    final TimeOfDay? horaInicioSelecionada = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada_inicio ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.cor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: widget.cor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaInicioSelecionada != null) {
      setState(() {
        _horaSelecionada_inicio = horaInicioSelecionada;
      });
    }
  }

  Future<void> _selecionarHoraFim() async {
    final TimeOfDay? horaFimSelecionada = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada_fim ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.cor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: widget.cor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaFimSelecionada != null) {
      setState(() {
        _horaSelecionada_fim = horaFimSelecionada;
      });
    }
  }

  void _editarHorario(String dia) {
    // Armazenar o estado original antes de abrir o diálogo
    TimeOfDay? horaInicioOriginal = _horarios[dia]?['inicio'];
    TimeOfDay? horaFimOriginal = _horarios[dia]?['fim'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay? horaInicio = _horarios[dia]?['inicio'];
        TimeOfDay? horaFim = _horarios[dia]?['fim'];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Editar horário para ',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: dia,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.cor,
                      ),
                    ),
                  ],
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? horaInicioSelecionada = await showTimePicker(
                        context: context,
                        initialTime: horaInicio ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: widget.cor, // Cor principal do tema
                                onPrimary: Colors
                                    .white, // Cor do texto dentro do TimePicker
                                onSurface: Colors.black,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: widget
                                      .cor, // Cor do texto nos botões do TimePicker
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (horaInicioSelecionada != null) {
                        setStateDialog(() {
                          _horarios[dia]!['inicio'] = horaInicioSelecionada;
                          horaInicio =
                              horaInicioSelecionada; // Atualiza a exibição no diálogo
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: widget.cor, // Cor do texto do botão
                      textStyle: TextStyle(
                        color: Colors.white, // Cor do texto dentro do botão
                        fontSize: 16, // Tamanho do texto (opcional)
                        fontWeight: FontWeight.bold, // Peso da fonte (opcional)
                      ),
                    ),
                    child: Text(
                      horaInicio != null
                          ? 'Hora de Início: ${horaInicio!.format(context)}'
                          : 'Hora de Início',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? horaFimSelecionada = await showTimePicker(
                        context: context,
                        initialTime: horaFim ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: widget.cor, // Cor principal do tema
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: widget
                                      .cor, // Cor do texto nos botões do TimePicker
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (horaFimSelecionada != null) {
                        setStateDialog(() {
                          _horarios[dia]!['fim'] = horaFimSelecionada;
                          horaFim =
                              horaFimSelecionada; // Atualiza a exibição no diálogo
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: widget.cor, // Cor do texto do botão
                      textStyle: TextStyle(
                        color: Colors.white, // Cor do texto dentro do botão
                        fontSize: 16, // Tamanho do texto (opcional)
                        fontWeight: FontWeight.bold, // Peso da fonte (opcional)
                      ),
                    ),
                    child: Text(
                      horaFim != null
                          ? 'Hora de Fim: ${horaFim!.format(context)}'
                          : 'Hora de Fim',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar'),
                  style: TextButton.styleFrom(
                    foregroundColor: widget.cor, // Cor do botão 'Cancelar'
                  ),
                  onPressed: () {
                    setState(() {
                      _horarios[dia]!['inicio'] = null;
                      _horarios[dia]!['fim'] = null;
                      _statusDia[dia] = 'Fechado';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Salvar'),
                  style: TextButton.styleFrom(
                    foregroundColor: widget.cor, // Cor do botão 'Salvar'
                  ),
                  onPressed: () {
                    setState(() {
                      // Aqui atualizamos a lista principal ao salvar as mudanças
                      if (horaInicio != null && horaFim != null) {
                        _statusDia[dia] =
                            '${horaInicio!.format(context)} - ${horaFim!.format(context)}';
                      }
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _carregarTopicos() async {
    // Função que consulta os tópicos da área
    List<Map<String, dynamic>> topicos =
        await Funcoes_Topicos().consultaTopicosPorArea(widget.idArea);

    // Atualiza o estado com os tópicos recuperados
    setState(() {
      _topicos = topicos;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarTopicos();
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
    _emailController.addListener(_updateButtonState);
    _webController.addListener(_updateButtonState);
    _telefoneController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _tituloController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _webController.dispose();
    local_controller.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    // Verifica se os campos essenciais estão preenchidos
    final isDescricaoNotEmpty = _descricaoController.text.trim().isNotEmpty;
    final isTituloNotEmpty = _tituloController.text.trim().isNotEmpty;
    final isLocalizacaoNotEmpty = local_controller.text.trim().isNotEmpty;

    final isHoraInicioSelecionada = _horaSelecionada_inicio != null;
    final isHoraFimSelecionada = _horaSelecionada_fim != null;

    final isTopicoSelecionado = _idTopicoSelecionado != null;

    final isImagensGaleria = _imagensSelecionadas.isNotEmpty;

    isButtonEnabled.value = isDescricaoNotEmpty &&
        isTituloNotEmpty &&
        isLocalizacaoNotEmpty &&
        isTopicoSelecionado &&
        isImagensGaleria;
  }

  Future<bool> _mostrarDialogoConfirmacao(BuildContext context) async {
    final hasUnsavedChanges = _tituloController.text.isNotEmpty ||
        _descricaoController.text.isNotEmpty ||
        local_controller.text.isNotEmpty ||
        _idTopicoSelecionado != null ||
        _horaSelecionada_inicio != null ||
        _horaSelecionada_fim != null ||
        _emailController.text.isNotEmpty ||
        _telefoneController.text.isNotEmpty ||
        _webController.text.isNotEmpty ||
        _imagensSelecionadas.isNotEmpty;

    // Se houver mudanças não salvas, exibir o diálogo de confirmação
    if (hasUnsavedChanges) {
      return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                titlePadding: const EdgeInsets.only(
                    top: 16.0), // Adiciona padding ao título
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
                      Navigator.of(context).pop(true); // Sair
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
            title: const Text('Criar Sugestão',
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
                                  Icons.subject_rounded,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Detalhes do Local',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Nome',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _tituloController,
                          cursorColor: const Color(0xFF15659F),
                          decoration: InputDecoration(
                            hintText: 'Insira o nome do local...',
                            hintStyle:
                                const TextStyle(color: Color(0xFF6C757D)),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(150, 158, 158, 158)),
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
                              color: _currentLenght_titulo <= _maxLength_titulo
                                  ? Colors.black
                                  : Colors.red,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Descreva o Local ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _descricaoController,
                          cursorColor: const Color(0xFF15659F),
                          decoration: InputDecoration(
                            hintText: 'Insira uma descrição para este local...',
                            hintStyle:
                                const TextStyle(color: Color(0xFF6C757D)),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(150, 158, 158, 158)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: widget.cor),
                            ),
                          ),
                          maxLines: 4,
                          onSubmitted: (value) {
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
                        const SizedBox(height: 5),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text(
                            'Qual tópico descreve melhor este local?',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ),
                        _topicos.isEmpty
                            ? const Center(
                                child:
                                    CircularProgressIndicator()) // Mostra um indicador de progresso enquanto os tópicos estão sendo carregados
                            : GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(), // Faz com que o GridView não seja rolável
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3, // Número de colunas
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 3, // Proporção dos itens
                                ),
                                itemCount: _topicos.length,
                                itemBuilder: (context, index) {
                                  final topico = _topicos[index];
                                  final bool isSelecionado =
                                      _idTopicoSelecionado == topico['id'];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _idTopicoSelecionado = topico[
                                            'id']; // Atualiza o ID do tópico selecionado
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelecionado
                                              ? widget.cor
                                              : Colors
                                                  .grey, // Muda a cor da borda se estiver selecionado
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // Exibe a imagem do tópico à esquerda
                                            Image.file(
                                              File(topico['topico_imagem']),
                                              width: 15,
                                              height: 15,
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(
                                                width:
                                                    10), // Espaçamento entre imagem e texto

                                            // Exibe o nome do tópico
                                            Expanded(
                                              child: Text(
                                                topico['nome_topico'],
                                                style: TextStyle(
                                                  color: isSelecionado
                                                      ? widget.cor
                                                      : Colors.black,
                                                  fontWeight: isSelecionado
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                overflow: TextOverflow
                                                    .ellipsis, // Se o nome for muito longo, ele será truncado com "..."
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        const SizedBox(height: 15),
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Endereço ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: local_controller,
                          decoration: InputDecoration(
                            hintText: 'Escreva onde é...',
                            prefixIcon: const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                  color: Color.fromARGB(150, 158, 158, 158)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: widget.cor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: widget.cor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(
                              Icons.contact_phone, // Ícone de contato
                              color: widget.cor,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Dados de Contacto',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Campo "Pagina Web"
                        const Text(
                          'Pagina Web (opcional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _webController,
                          decoration: InputDecoration(
                            hintText: 'http://',
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: widget.cor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo "Telefone/Telemovel oficial"
                        const Text(
                          'Telefone/Telemovel oficial (opcional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _telefoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: '(+351) 000-000-000',
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: widget.cor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo "Email oficial"
                        const Text(
                          'Email oficial (opcional)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Introduzir endereço de e-mail',
                            border: const OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: widget.cor),
                            ),
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
                                  Icons.access_time_filled_rounded,
                                  color: widget.cor,
                                  size: 25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Horário do Local',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _diasDaSemana.length,
                          itemBuilder: (context, index) {
                            String dia = _diasDaSemana[index];
                            TimeOfDay? horaInicio = _horarios[dia]?['inicio'];
                            TimeOfDay? horaFim = _horarios[dia]?['fim'];

                            String horarioTexto;
                            if (horaInicio == null || horaFim == null) {
                              horarioTexto = 'Fechado';
                            } else {
                              horarioTexto =
                                  '${horaInicio.format(context)} - ${horaFim.format(context)}';
                            }

                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 15.0, right: 30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      dia,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Expanded(
                                    child: Text(
                                      horarioTexto,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _editarHorario(dia);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
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
                            const SizedBox(width: 6),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                            vertical: 10.0,
                          ),
                          child: Wrap(
                            spacing: 5.0,
                            runSpacing: 5.0,
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
                                      width: MediaQuery.of(context).size.width /
                                          3.5,
                                      height:
                                          MediaQuery.of(context).size.width /
                                              3.5,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
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
                                  width:
                                      MediaQuery.of(context).size.width / 3.5,
                                  height:
                                      MediaQuery.of(context).size.width / 3.5,
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
                                        // Navegar para a página de validação passando os parâmetros
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ValidarPublicacaoCriar(
                                              titulo:
                                                  _tituloController.text.trim(),
                                              descricao: _descricaoController
                                                  .text
                                                  .trim(),

                                              imagensGaleria:
                                                  _imagensSelecionadas, // Todas as imagens
                                              idArea:
                                                  widget.idArea, // O ID da área
                                              idTopico:
                                                  _idTopicoSelecionado!, // O ID do tópico selecionado
                                              local:
                                                  local_controller.text.trim(),
                                              email:
                                                  _emailController.text.trim(),
                                              telefone: _telefoneController.text
                                                  .trim(),
                                              web: _webController.text.trim(),
                                              horarios:
                                                  _horarios, // O mapa de horários
                                            ),
                                          ),
                                        );
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
