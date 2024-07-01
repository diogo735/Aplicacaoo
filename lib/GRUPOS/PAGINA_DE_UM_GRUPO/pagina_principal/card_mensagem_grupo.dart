import 'package:ficha3/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:intl/intl.dart';

class CARD_COMENTAARIO_grupo extends StatefulWidget {
  final int idComentario;
  final int userId;
  final String ano;
  final String mes;
  final String dia;
  final String horas;
  final String minutos;
  final String textoComentario;
  final int idgrupo;

  CARD_COMENTAARIO_grupo({
    Key? key,
    required this.idComentario,
    required this.userId,
    required this.ano,
    required this.dia,
    required this.mes,
    required this.horas,
    required this.minutos,
    required this.textoComentario,
    required this.idgrupo,
  }) : super(key: key);

  @override
  _CARD_COMENTAARIO_grupoState createState() => _CARD_COMENTAARIO_grupoState();
}

class _CARD_COMENTAARIO_grupoState extends State<CARD_COMENTAARIO_grupo> {
  String nomeUsuario = '';
  String caminhoFotoUsuario = 'assets/images/sem_imagem.png';
  late int user_id;

  @override
  void initState() {
    super.initState();
    _carregarDadosUsuario();
  }

  @override
  void didUpdateWidget(CARD_COMENTAARIO_grupo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _carregarDadosUsuario();
    }
  }

  Future<void> _carregarDadosUsuario() async {
    if (!mounted) return;

    String nome =
        await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(widget.userId);
    String caminhoFoto =
        await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(widget.userId);
    if (!mounted) return;
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

    DateTime now = DateTime.now();
    int ano = int.tryParse(widget.ano) ?? 0;
    int mes = int.tryParse(widget.mes) ?? 0;
    int dia = int.tryParse(widget.dia) ?? 0;
    int horas = int.tryParse(widget.horas) ?? 0;
    int minutos = int.tryParse(widget.minutos) ?? 0;

    DateTime messageDate = DateTime(ano, mes, dia, horas, minutos);

    final DateFormat formatter = DateFormat('HH:mm');
    final formattedTime = formatter.format(messageDate);

    String formattedDate;

    if (now.year == messageDate.year &&
        now.month == messageDate.month &&
        now.day == messageDate.day) {
      formattedDate = 'Hoje às $formattedTime';
    } else {
      formattedDate =
          '${widget.dia.padLeft(2, '0')}/${widget.mes.padLeft(2, '0')}/${widget.ano} às $formattedTime';
    }
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(caminhoFotoUsuario),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user_id == widget.userId ? 'Eu' : nomeUsuario,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            color: Color(0xFF89939C),
                            fontSize: 14,
                            fontFamily: 'ABeeZee',
                            fontWeight: FontWeight.w400,
                            height: 0.11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: RichText(
                text: TextSpan(
                  children: texto_user_referencia(widget.textoComentario),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
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
    );
  }
}

List<TextSpan> texto_user_referencia(String text) {
  List<TextSpan> spans = [];
  List<String> parts = text.split(' @');

  if (text.startsWith('@')) {
    spans.add(
      TextSpan(
        text: '',
        style: const TextStyle(color: Colors.black),
      ),
    );
    parts = text.substring(1).split(' @');
  }

  for (int i = 0; i < parts.length; i++) {
    if (i == 0 && !text.startsWith('@')) {
      spans.add(
        TextSpan(
          text: parts[i] + (i < parts.length - 1 ? ' ' : ''),
          style: const TextStyle(color: Colors.black),
        ),
      );
    } else {
      List<String> subParts = parts[i].split(' ');
      if (subParts.isNotEmpty) {
        // Adiciona as duas primeiras palavras em azul
        String blueText =
            subParts.length > 1 ? subParts[0] + ' ' + subParts[1] : subParts[0];
        spans.add(
          TextSpan(
            text: '@' + blueText + ' ',
            style: const TextStyle(color: Colors.blue),
          ),
        );

        if (subParts.length > 2) {
          spans.add(
            TextSpan(
              text: subParts.sublist(2).join(' ') + ' ',
              style: const TextStyle(color: Colors.black),
            ),
          );
        }
      }
    }
  }

  return spans;
}
