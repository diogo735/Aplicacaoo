import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';

import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class criar_cometario_pub extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_publicacao;
  final Color cor;

  // ignore: non_constant_identifier_names
  const criar_cometario_pub({super.key, required this.id_publicacao,required this.cor});

  @override
  // ignore: library_private_types_in_public_api
  _criar_cometario_pubState createState() => _criar_cometario_pubState();
}

// ignore: camel_case_types
class _criar_cometario_pubState extends State<criar_cometario_pub> {
  List<Map<String, dynamic>> comentarios = [];
  String nomePub = '';
  String fotoPub = '';
  String localPub = '';
  int _avaliacao = 0;
  String descricao = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  late int user_id;

  @override
  void initState() {
    super.initState();
    _carregarInformacoesPublicacao();
  }

  void _carregarInformacoesPublicacao() async {
    Map<String, dynamic>? publicacao =
        await Funcoes_Publicacoes.detalhes_por_id(widget.id_publicacao);

    if (publicacao != null) {
      setState(() {
        nomePub = publicacao['nome'];
        localPub = publicacao['local'];
        _carregarFotoPublicacao();
      });
    }
  }

  void _carregarFotoPublicacao() async {
    Map<String, dynamic>? imagemPublicacao = await Funcoes_Publicacoes_Imagens()
        .retorna_primeira_imagem(widget.id_publicacao);
    if (imagemPublicacao != null) {
      setState(() {
        fotoPub = imagemPublicacao['caminho_imagem'];
      });
    }
  }

  // ignore: non_constant_identifier_names

  void _sumeterFormulario(int userid) {
    if (_formKey.currentState!.validate()) {
      String comentario = _comentarioController.text;
      int avaliacao = _avaliacao;

      print('Comentário: $comentario');
      print('Avaliação: $avaliacao');

      setState(() {
        _avaliacao = 0;
        descricao = '';
      });

      String data = DateFormat('dd/MM/yyyy').format(DateTime.now());
      Funcoes_Comentarios_Publicacoes.inserir_comentario_feito_pelo_user(
        userid,
        avaliacao,
        comentario,
        data,
        widget.id_publicacao,
      );
    }
  }

  void _onRatingUpdate(double rating) {
    setState(() {
      _avaliacao = rating.toInt();
      switch (_avaliacao) {
        case 1:
          descricao = 'Péssimo';
          break;
        case 2:
          descricao = 'Fraco';
          break;
        case 3:
          descricao = 'Razoavél';
          break;
        case 4:
          descricao = 'Muito Bom';
          break;
        case 5:
          descricao = 'Excelente';
          break;
        default:
          descricao = 'Péssimo';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Criar Comentario',
          style: TextStyle(
            fontSize: 18,
            color: widget.cor,
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme:  IconThemeData(color: widget.cor),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: KeyboardDismissOnTap(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: fotoPub.isNotEmpty
                                ? AssetImage(fotoPub)
                                : const AssetImage(
                                        'assets/images/sem_imagem.png')
                                    as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nomePub,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              localPub,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Classifique o Local',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                   SizedBox(height: 5),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 40.0,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: widget.cor,
                    ),
                    onRatingUpdate: _onRatingUpdate,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    descricao,
                    style:  TextStyle(
                      color: widget.cor,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Escreva o Comentario',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _comentarioController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.cor),
                      ),
                    ),
                    cursorColor: widget.cor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu comentário';
                      }
                      return null;
                    },
                    maxLines: 5,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (_avaliacao == 0 ||
                            _comentarioController.text == '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Por favor, preencha todos os campos !'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          _sumeterFormulario(user_id);
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Comentário publicado!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: widget.cor,
                      ),
                      child: const Text('Publicar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
