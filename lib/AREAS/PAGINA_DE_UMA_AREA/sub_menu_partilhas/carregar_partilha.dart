import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ficha3/BASE_DE_DADOS/APIS/api_partilhas.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';

class CriarPartilha extends StatefulWidget {
  final Color cor;
  final int idArea;

  const CriarPartilha({Key? key, required this.cor, required this.idArea})
      : super(key: key);

  @override
  _CriarPartilhaState createState() => _CriarPartilhaState();
}

class _CriarPartilhaState extends State<CriarPartilha> {
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
                leading: Icon(Icons.photo_library),
                title: Text('Escolher da Galeria'),
                onTap: () {
                  _pickImage();
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Tirar Foto'),
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

  String formatarData(DateTime data) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(data);
  }
Future<void> _salvarPartilha() async {
  if (_formKey.currentState!.validate()) {
    if (_imagemSelecionada != null) {
      try {
        // Carregar a imagem e obter a URL
        final imageUrl = await _uploadImage(_imagemSelecionada!);

        // Obter os dados do usuário e do centro
        final userProvider = Provider.of<Usuario_Provider>(context, listen: false);
        final centroProvider = Provider.of<Centro_Provider>(context, listen: false);

        String datafomatada = formatarData(DateTime.now());

        // Adaptar os dados da partilha para o formato esperado pelo backend (álbum)
        Map<String, dynamic> album = {
          'nome': _tituloController.text, // Título da partilha -> nome do álbum
          'descricao': _descricaoController.text,
          'capa_imagem_album': imageUrl, // Caminho da imagem
          'centro_id': centroProvider.centroSelecionado?.id ?? 1,
          'area_id': widget.idArea,
          'autor_id': userProvider.usuarioSelecionado?.id_user ?? 1, // Usuário (autor)
          'estado': 'Ativa', // Opcional, pode ser "Ativa" por padrão
        };

        // Enviar os dados para a API
        await ApiPartilhas().criarPartilha(album);

        // Exibir feedback de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Partilha criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpar os campos do formulário
        _tituloController.clear();
        _descricaoController.clear();
        setState(() {
          _imagemSelecionada = null;
        });

        // Retornar para a página anterior
        Navigator.pop(context);
      } catch (e) {
        // Exibir mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao criar a partilha: $e')),
        );
      }
    } else {
      // Caso a imagem não tenha sido selecionada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma imagem.')),
      );
    }
  }
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
    _descricaoController.addListener(_updateButtonState);
    _tituloController.addListener(_updateButtonState);
  }

void _updateButtonState() {
  final isDescricaoNotEmpty = _descricaoController.text.isNotEmpty;
  final isTituloNotEmpty = _tituloController.text.isNotEmpty;
  isButtonEnabled.value = isDescricaoNotEmpty && isTituloNotEmpty;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Partilha',
            style: TextStyle(
              fontSize: 21,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            )),
        backgroundColor: widget.cor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                      padding: EdgeInsets.only(left: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.image_rounded,
                          color: widget.cor,
                          size: 25,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Selecionar Partilha',
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
                    onTap: () => _mostraropcoesparaselecionarImagem(context),
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
                          : Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: const Color.fromARGB(255, 147, 145, 145),
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.subject_rounded,
                          color: widget.cor,
                          size: 25,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      'Detalhes da Partilha',
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
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text.rich(
                      TextSpan(
                        children: const [
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
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    TextField(
                      controller: _tituloController,
                      cursorColor: Color(0xFF15659F),
                      decoration: InputDecoration(
                        hintText: 'insira o titulo da partilha...',
                        hintStyle: TextStyle(color: Color(0xFF6C757D)),
                        border: OutlineInputBorder(
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
                  ],
                ),
                SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text.rich(
                      TextSpan(
                        children: const [
                          TextSpan(
                            text: 'Descrição ',
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
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    TextField(
                      controller: _descricaoController,
                      cursorColor: Color(0xFF15659F),
                      minLines: 4,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'insira a descrição da partilha...',
                        hintStyle: TextStyle(color: Color(0xFF6C757D)),
                        border: OutlineInputBorder(
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
                        '$_currentLenght_descricao /$_maxLength_descricao',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              _currentLenght_descricao <= _maxLength_descricao
                                  ? Colors.black
                                  : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isButtonEnabled,
                    builder: (context, isEnabled, child) {
                      return ElevatedButton.icon(
                        onPressed: isEnabled ? _salvarPartilha : null,
                        icon: Icon(
                          Icons.check,
                          size: 25,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Publicar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
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
      ),
    );
  }
}
