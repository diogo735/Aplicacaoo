import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_foruns.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mensagens_do_forum.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_forum/card_mensagem_forum.dart';

import 'package:provider/provider.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_foruns.dart';

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
    _sincronizarForuns();
    _carregarForumId();
    listarForuns();
  }

  Future<void> _sincronizarForuns() async {
    try {
      // Obtenha o centroId dinamicamente, conforme necessário
      // Neste exemplo, estou assumindo que o centroId pode ser 5, mas você deve substituir isso por um valor dinâmico.
      int centroId = 5;

      // Chame a função que sincroniza os fóruns da API e armazena no banco de dados local
      await ApiForuns().fetchAndStoreForuns(centroId);

      // Após a sincronização, tente carregar o fórum correspondente
      await _carregarForumId();
    } catch (e) {
      print('Erro ao sincronizar e carregar os fóruns: $e');
    }
  }

  void _carregarMensagens() async {
    if (forumId == null) return;

    await Funcoes_Mensagens_foruns().sincronizarMensagensDoBackend(forumId!);

    Funcoes_Mensagens_foruns funcoesMensagens = Funcoes_Mensagens_foruns();
    List<Map<String, dynamic>> mensagensCarregadas =
        await funcoesMensagens.consultaMensagemForumPorForumId(forumId!);

    if (mensagensCarregadas.isEmpty) {
      print("Nenhuma mensagem encontrada no banco de dados local.");
    } else {
      print("Mensagens carregadas: $mensagensCarregadas");
    }

    List<Map<String, dynamic>> mensagensConvertidas = [];

    for (var mensagem in mensagensCarregadas) {
      DateTime createdAt = DateTime.parse(mensagem['created_at']);

      mensagensConvertidas.add({
        'user_id': mensagem['user_id'],
        'texto_mensagem': mensagem['texto_mensagem'],
        'hora': createdAt.hour,
        'minutos': createdAt.minute,
        'dia': createdAt.day,
        'mes': createdAt.month,
      });
    }

    setState(() {
      mensagens = mensagensConvertidas;
    });
  }

 Future<void> _carregarForumId() async {
  try {
    Funcoes_Foruns funcoesForuns = Funcoes_Foruns();
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;

    // Verifica se o centroSelecionado não é nulo
    if (centroSelecionado != null) {
      int? id = await funcoesForuns.consultaForumPorAreaECentro(
          widget.id_area, centroSelecionado.id);

      if (id != null) {
        // Verifica se o widget ainda está montado antes de chamar setState
        if (mounted) {
          setState(() {
            forumId = id;
          });
          // Carrega as mensagens apenas se o fórum for encontrado
          _carregarMensagens();
        }
      } else {
        print('Nenhum fórum encontrado para a área ${widget.id_area}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: Nenhum fórum encontrado para esta área.'),
            ),
          );
        }
      }
    } else {
      // Se o centroSelecionado for nulo, informa o usuário
      print('Nenhum centro selecionado.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: Nenhum centro selecionado.'),
          ),
        );
      }
    }
  } catch (e) {
    // Tratamento de erro genérico
    print('Erro ao carregar o fórum: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar o fórum: $e'),
        ),
      );
    }
  }
}


  Future<void> listarForuns() async {
    Funcoes_Foruns funcoesForuns = Funcoes_Foruns();
    List<Map<String, dynamic>> foruns = await funcoesForuns.consultaForum();

    print('Foruns no banco de dados:');
    for (var forum in foruns) {
      print(forum);
    }
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
                          width: 80,
                          height: 80,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ainda não há mensagens!',
                          style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 156, 156, 156)),
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
                    if (forumId == null) {
                      print('Erro: forumId é nulo');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Erro ao identificar o fórum. Tente novamente.')),
                      );
                      return; // Interrompe a execução se forumId for nulo
                    }

                    if (mensagemTexto.isNotEmpty) {
                      bool sucesso = await Funcoes_Mensagens_foruns()
                          .processarInsercaoMensagem(
                        forumId: forumId!,
                        userId: userId,
                        textoMensagem: mensagemTexto,
                      );

                      if (sucesso) {
                        _carregarMensagens(); // Recarrega as mensagens após o envio bem-sucedido
                        controller.clear(); // Limpa o campo de texto
                        FocusScope.of(context).unfocus(); // Fecha o teclado
                        print('Mensagem enviada e armazenada com sucesso!');
                        // ScaffoldMessenger.of(context).showSnackBar(
                        // SnackBar(content: Text('Mensagem enviada e armazenada com sucesso!')),
                        // );
                      } else {
                        print('Falha ao enviar a mensagem.');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Falha ao enviar a mensagem.')),
                        );
                      }
                    } else {
                      print('Mensagem vazia.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('A mensagem não pode estar vazia.')),
                      );
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
