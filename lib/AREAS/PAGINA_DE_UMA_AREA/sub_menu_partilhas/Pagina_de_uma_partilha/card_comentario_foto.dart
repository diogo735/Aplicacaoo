import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:intl/intl.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';

class CARD_COMENTAARIO_FOTO extends StatefulWidget {
  final int idComentario;
  final int userId;
  final String dataComentario;
  final String horaComentario;
  final String textoComentario;
  final int idPartilha;

  CARD_COMENTAARIO_FOTO({
    Key? key,
    required this.idComentario,
    required this.userId,
    required this.dataComentario,
    required this.horaComentario,
    required this.textoComentario,
    required this.idPartilha,
  }) : super(key: key);

  @override
  _CARD_COMENTAARIO_FOTOState createState() => _CARD_COMENTAARIO_FOTOState();
}

class _CARD_COMENTAARIO_FOTOState extends State<CARD_COMENTAARIO_FOTO> {
  String nomeUsuario = '';
  String caminhoFotoUsuario = 'assets/images/sem_imagem.png';
  late int user_id;
  String data_comentario = '';
  @override
  void initState() {
    super.initState();

    _carregarDadosUsuario();
  }

  @override
  void didUpdateWidget(CARD_COMENTAARIO_FOTO oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _carregarDadosUsuario();
    }
  }

  Future<void> _carregarDadosUsuario() async {
    setState(() {
      nomeUsuario = '';
      caminhoFotoUsuario = 'assets/images/sem_imagem.png';
    });

    String nome =
        await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(widget.userId);
    String caminhoFoto =
        await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(widget.userId);

    setState(() {
      nomeUsuario = nome;
      caminhoFotoUsuario =
          caminhoFoto.isEmpty ? 'assets/images/sem_imagem.png' : caminhoFoto;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;

    List<String> partesData = widget.dataComentario.split('/');
    int dia = int.parse(partesData[0]);
    int mes = int.parse(partesData[1]);
    int ano = int.parse(partesData[2]);

// "YYYY-MM-DD"
    String dataFormatada =
        '$ano-${mes.toString().padLeft(2, '0')}-${dia.toString().padLeft(2, '0')}';

//data atual
    DateTime dataAtual = DateTime.now();
    DateTime dataComentarioFormatada = DateTime.parse(dataFormatada);

    if (dataAtual.year == dataComentarioFormatada.year &&
        dataAtual.month == dataComentarioFormatada.month &&
        dataAtual.day == dataComentarioFormatada.day) {
      data_comentario = 'Hoje';
    } else {
      data_comentario = widget.dataComentario;
    }
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 5),
            width: MediaQuery.of(context).size.width - 10,
            decoration: BoxDecoration(
              color: const Color(0x00FFFFFF),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 55,
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 5, right: 10, left: 5),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 214, 214, 214),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userId == user_id ? 'Eu' : nomeUsuario,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data_comentario + ' às ${widget.horaComentario}',
                      style: const TextStyle(
                        color: Color(0xFF49454F),
                        fontSize: 13,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Texto do comentário
                    Text(
                      widget.textoComentario,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundImage: FileImage(File(caminhoFotoUsuario)),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: PopupMenuButton(
              offset: const Offset(-5, 40),
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry>[
                  const PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Denunciar',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              icon: const Icon(Icons.more_vert, size: 21),
            ),
          ),
        ],
      ),
    );
  }
}
