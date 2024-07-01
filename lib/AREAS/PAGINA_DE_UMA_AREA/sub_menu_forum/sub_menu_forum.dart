import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_foruns.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mensagens_do_forum.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_forum/card_mensagem_forum.dart';

import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';

class SubmenuForum extends StatefulWidget {
  final int id_area;
  final Color cor_da_area;

  SubmenuForum({
    required this.id_area,
    required this.cor_da_area,
  });

  @override
  _SubmenuForumState createState() => _SubmenuForumState();
}

class _SubmenuForumState extends State<SubmenuForum> {
  List<Map<String, dynamic>> mensagens = [];
  final controller = TextEditingController();
  int? forumId;
  @override
  void initState() {
    super.initState();
    _carregarForumId();
  }

  Future<void> _carregarForumId() async {
    Funcoes_Foruns funcoesForuns = Funcoes_Foruns();
    int? id = await funcoesForuns.consultaForumPorArea(widget.id_area);

    if (id != null) {
      setState(() {
        forumId = id;
      });
      _carregarMensagens();
    } else {
      print('Nenhum fórum encontrado para a área ${widget.id_area}');
    }
  }

  void _carregarMensagens() async {
    if (forumId == null) return;

    Funcoes_Mensagens_foruns funcoesMensagens = Funcoes_Mensagens_foruns();
    List<Map<String, dynamic>> mensagensCarregadas =
        await funcoesMensagens.consultaMensagemForumPorForumId(forumId!);

    List<Map<String, dynamic>> mensagensOrdenadas =
        List.from(mensagensCarregadas);

    // Ordena as mensagens por data e hora
    mensagensOrdenadas.sort((a, b) {
      // Comparar o mês
      int mesComparacao = a['mes'].compareTo(b['mes']);
      if (mesComparacao != 0) return mesComparacao;

      // Comparar o dia
      int diaComparacao = a['dia'].compareTo(b['dia']);
      if (diaComparacao != 0) return diaComparacao;

      // Comparar a hora
      int horaComparacao = a['hora'].compareTo(b['hora']);
      if (horaComparacao != 0) return horaComparacao;

      // Comparar os minutos
      return a['minutos'].compareTo(b['minutos']);
    });

    setState(() {
      mensagens = mensagensOrdenadas;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<Usuario_Provider>(context);
    final userId = usuarioProvider.usuarioSelecionado?.id_user ?? 0;

    return Stack(
      children: [
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: mensagens.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/sem_mesagens.png',
                          width:
                              80, 
                          height: 80,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ainda não há mensagens !',
                          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 156, 156, 156)),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: mensagens.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 60),
                        );
                      }
                      final mensagem = mensagens[mensagens.length - index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 1),
                        child: FutureBuilder<Widget>(
                          future: MENSAGEM_FORUM(
                            idUser: mensagem['user_id'],
                            textMensagem: mensagem['texto_mensagem'],
                            hora: mensagem['hora'],
                            minutos: mensagem['minutos'],
                            dia: mensagem['dia'],
                            mes: mensagem['mes'],
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return const Text('Erro ao carregar a mensagem');
                            } else {
                              return snapshot.data ?? Container();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          //////////////////////o input da mensagem
          bottom: 10,
          left: 5,
          right: 5,
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: widget.cor_da_area,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox.shrink(),
                IconButton(
                  onPressed: () {},
                  icon: Transform.rotate(
                    angle: 45 * 3.1415926535 / 180,
                    child: const Icon(
                      Icons.link,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox.shrink(),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'mensagem...',
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontFamily: 'ABeeZee'),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () async {
                    String mensagemTexto = controller.text.trim();
                    if (mensagemTexto.isNotEmpty) {
                      await Funcoes_Mensagens_foruns()
                          .inserirMensagemNoBancoDeDados(
                        forumId: forumId!,
                        userId: userId,
                        textoMensagem: mensagemTexto,
                        dia: DateTime.now().day,
                        mes: DateTime.now().month,
                        hora: DateTime.now().hour,
                        minutos: DateTime.now().minute,
                      );
                      _carregarMensagens(); 
                      controller.clear(); 
                      FocusScope.of(context)
                          .unfocus(); 
                      print('Mensagem enviada!');
                    }
                  },
                  icon: Transform.rotate(
                    angle: 320 * 3.1415926535 / 180,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
