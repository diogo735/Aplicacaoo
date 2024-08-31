import 'dart:io';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_comentarios_evento/denuncirar_comentario.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_eventos.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';

import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CARD_COMENTAARIO_EVENTO extends StatefulWidget {
  final int idComentario;
  final int userId;
  final String dataComentario;
  final int classificacao;
  final String textoComentario;
  final int idEvento;

  CARD_COMENTAARIO_EVENTO({
    Key? key,
    required this.idComentario,
    required this.userId,
    required this.dataComentario,
    required this.classificacao,
    required this.textoComentario,
    required this.idEvento,
  }) : super(key: key);

  @override
  _CARD_COMENTAARIO_PUBState createState() => _CARD_COMENTAARIO_PUBState();
}

class _CARD_COMENTAARIO_PUBState extends State<CARD_COMENTAARIO_EVENTO> {
  String nomeUsuario = '';
  String caminhoFotoUsuario = 'assets/images/sem_imagem.png';
  late int user_id;
  String nome_classificacao(int classificacao) {
    switch (classificacao) {
      case 1:
        return 'Péssimo';
      case 2:
        return 'Fraco';
      case 3:
        return 'Razoável';
      case 4:
        return 'Muito Bom';
      case 5:
        return 'Excelente';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  @override
  void didUpdateWidget(CARD_COMENTAARIO_EVENTO oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _carregarDadosUsuario();
    }
  }

  String formatarDataHora(String dataHoraOriginal) {
    DateTime dateTime = DateTime.parse(dataHoraOriginal);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime dateOfOriginal =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOfOriginal == today) {
      // Se for hoje, formata apenas a hora
      return "hoje às ${DateFormat('HH:mm').format(dateTime)}";
    } else {
      // Se não for hoje, formata a data completa
      return DateFormat("dd/MM/yyyy 'às' HH:mm").format(dateTime);
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
    //user_id = usuarioProvider.usuarioSelecionado!.id_user;
    user_id = 1;
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 10,
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: FileImage(File(caminhoFotoUsuario)),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userId == user_id ? 'Eu' : '$nomeUsuario',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatarDataHora(widget.dataComentario),
                            style: const TextStyle(
                              color: Color(0xFF49454F),
                              fontSize: 13,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      RatingStars(
                        starSize: 20,
                        rating: widget.classificacao.toDouble(),
                        fillColor: const Color(0xFFFAFF00),
                        emptyColor: Colors.grey,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        nome_classificacao(widget.classificacao),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.textoComentario,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.15,
                        )),
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 1.0,
            right: 1,
            child: PopupMenuButton(
              offset: const Offset(-5, 40),
              itemBuilder: (BuildContext context) {
                final usuarioProvider =
                    Provider.of<Usuario_Provider>(context, listen: false);
                final int userIdProvider =
                    usuarioProvider.usuarioSelecionado!.id_user;

                return <PopupMenuEntry>[
                  if (widget.userId == userIdProvider)
                    PopupMenuItem(
                      onTap: () async {
                        String resultado = await ApiEventos()
                            .apagarComentario(widget.idComentario);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: resultado == "Sem conexão com a internet."
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.wifi_off,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(resultado),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_rounded,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(resultado),
                                    ],
                                  ),
                            backgroundColor: resultado == "Comentário Apagado !"
                                ? Colors.green
                                : Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        if (resultado == "Comentário Apagado !") {
                          await Funcoes_Comentarios_Eventos
                              .deletarComentarioPorId(widget.idComentario);
                          // Navigator.pop(context, true);
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Apagar',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    PopupMenuItem(
                      onTap: () {
                        mostrarDialogoDenuncia(
                            context,
                            nomeUsuario,
                            caminhoFotoUsuario,
                            widget.textoComentario,
                            widget.idComentario,
                            widget.idEvento);
                      },
                      child: const Row(
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

void mostrarDialogoDenuncia(
    BuildContext context,
    String nome,
    String caminho_foto,
    String texto,
    int id_comentario_denunciado,
    int id_evento) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return DenunciaDialog(
        nome: nome,
        id_comentario_denunciado: id_comentario_denunciado,
        id_evento: id_evento,
        caminhoFoto: caminho_foto,
        texto: texto,
      );
    },
  );
}

class RatingStars extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double starSize;
  final Color fillColor;
  final Color emptyColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxRating = 5,
    required this.starSize,
    this.fillColor = Colors.amber,
    this.emptyColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        if (index + 1 <= rating) {
          // Estrela preenchida
          return Icon(
            Icons.star,
            size: starSize,
            color: fillColor,
          );
        } else if (index < rating && index + 1 > rating) {
          // Estrela parcialmente preenchida
          return Icon(
            Icons.star_half,
            size: starSize,
            color: fillColor,
          );
        } else {
          // Estrela vazia
          return Icon(
            Icons.star_border,
            size: starSize,
            color: emptyColor,
          );
        }
      }),
    );
  }
}
