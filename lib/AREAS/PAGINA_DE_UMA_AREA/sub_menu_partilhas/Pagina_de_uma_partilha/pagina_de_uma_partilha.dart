import 'dart:io';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/galeria_imagem.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:flutter/material.dart';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'dart:async';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_likes_partilhas.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/BASE_DE_DADOS/ver_estruturaBD.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/Pagina_de_uma_partilha/card_comentario_foto.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagnia_de_uma_publicacao.dart';

class PaginaDaPartilha extends StatefulWidget {
  final int idpartilha;
  final Color cor;

  const PaginaDaPartilha(
      {super.key, required this.idpartilha, required this.cor});
  @override
  _PaginaDaPartilhaState createState() => _PaginaDaPartilhaState();
}

class _PaginaDaPartilhaState extends State<PaginaDaPartilha> {
  late Timer _timer;

  late bool isLiked = false;
  List<Map<String, dynamic>> comentarios = [];
  late int user_id;
  String titulo = '';
  String descricao = '';
  String caminhoImagem = '';
  String data = '';
  String hora = '';
  int? idUsuario;
  int? idEvento;
  int? idLocal;
  int? areaId;
  int? gostos;
  String nomeuser = '';
  String caminhoFotouser = '';
  int numeroDeLikes = 0;
  final controller = TextEditingController();
  late String capa_evento = "";
  late String nomeEvento = "";
  late int diaEvento = 0;
  late int mesEvento = 0;
  late int numeroParticipantes = 0;
  late String nomeLocal = "";
  late String classlocal = "";
  late String moradalocal = "";
  late String capa_locla = "";

  @override
  void initState() {
    super.initState();
    _carregarDados(widget.idpartilha);
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _carregarDados(widget.idpartilha);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime _converterDataHora(String data, String hora) {
    List<String> partesData = data.split('/');
    List<String> partesHora = hora.split(':');

    int ano = int.parse(partesData[2]);
    int mes = int.parse(partesData[1]);
    int dia = int.parse(partesData[0]);
    int horas = int.parse(partesHora[0]);
    int minutos = int.parse(partesHora[1]);

    return DateTime(ano, mes, dia, horas, minutos);
  }

  Future<void> _carregarDados(int idPartilha) async {
    try {
      Map<String, dynamic> dados =
          await Funcoes_Partilhas().buscarDetalhesPartilha(idPartilha);
      setState(() {
        titulo = dados['titulo'] ?? '';
        descricao = dados['descricao'] ?? '';
        caminhoImagem = dados['caminho_imagem'] ?? '';
        data = dados['data'] ?? '';
        hora = dados['hora'] ?? '';
        idUsuario = dados['id_usuario'];
        //idEvento = dados['id_evento'];
        //idLocal = dados['id_local'];
        areaId = dados['area_id'];
      });

      if (idUsuario != null) {
        _carregarDadosUsuario(idUsuario!);
      }
      final usuarioProvider =
          Provider.of<Usuario_Provider>(context, listen: false);
      user_id = usuarioProvider.usuarioSelecionado!.id_user;

      int numLikes =
          await Funcoes_Likes_das_Partilhas().countLikesPorPartilha(idPartilha);

      bool deu_like = await Funcoes_Likes_das_Partilhas.verificarUserDeuLike(
          user_id, widget.idpartilha);
/////////////////////////////////////////////////////////////////////////////////
      List<Map<String, dynamic>> comentariosCarregados =
          await Funcoes_Comentarios_das_Partilhas()
              .consultaComentariosPorPartilha(idPartilha);

      DateTime _converterDataHora(String data, String hora) {
        List<String> partesData = data.split('/');
        List<String> partesHora = hora.split(':');

        int ano = int.parse(partesData[2]);
        int mes = int.parse(partesData[1]);
        int dia = int.parse(partesData[0]);
        int horas = int.parse(partesHora[0]);
        int minutos = int.parse(partesHora[1]);

        return DateTime(ano, mes, dia, horas, minutos);
      }

      List<Map<String, dynamic>> comentariosOrdenados =
          List.from(comentariosCarregados);
      comentariosOrdenados.sort((a, b) {
        DateTime dataHoraA =
            _converterDataHora(a['data_comentario'], a['hora_comentario']);
        DateTime dataHoraB =
            _converterDataHora(b['data_comentario'], b['hora_comentario']);

        return dataHoraB.compareTo(dataHoraA); // Ordena pelo masi recente
      });
      if (idEvento != null) {
        // Se o ID do evento não for nulo, busca os detalhes do evento
        nomeEvento = await Funcoes_Eventos.consultaNomeEventoPorId(idEvento!);
        List<Map<String, dynamic>> detalhesEvento =
            await Funcoes_Eventos.consultaDetalhesEventoPorId(idEvento!);
        if (detalhesEvento.isNotEmpty) {
          diaEvento = detalhesEvento.first['dia_realizacao'];
          mesEvento = detalhesEvento.first['mes_realizacao'];
          numeroParticipantes = detalhesEvento.first['numero_inscritos'];
          capa_evento = detalhesEvento.first['caminho_imagem'];
        }
      } else if (idLocal != null) {
        // Se o ID do evento for nulo e o ID do local não for nulo, busca os detalhes do local
        nomeLocal = await Funcoes_Publicacoes.consultaNomeLocalPorId(idLocal!);
        List<Map<String, dynamic>> detalhesLocal =
            await Funcoes_Publicacoes.consultaDetalhesPublicacaoPorId(idLocal!);
        if (detalhesLocal.isNotEmpty) {
          classlocal = detalhesLocal.first['classificacao_media'].toString();
          moradalocal = detalhesLocal.first['local'];
          capa_locla = detalhesLocal.first['caminho_imagem'];
        }
      }
      setState(() {
        numeroDeLikes = numLikes;
        isLiked = deu_like;
        comentarios.clear();
        comentarios.addAll(comentariosOrdenados);
      });
    } catch (e) {
      print('deu erro no carregamento dos dados da partilha: $e');
    }
  }

  String converter_mes(int numeroMes) {
    switch (numeroMes) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '';
    }
  }

  Future<void> _carregarDadosUsuario(int idUsuario) async {
    try {
      String nomeCompleto =
          await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(idUsuario);
      String caminhoFoto =
          await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(idUsuario);

      setState(() {
        nomeuser = nomeCompleto;
        caminhoFotouser = caminhoFoto;
      });
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final user_id = usuarioProvider.usuarioSelecionado!.id_user;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: FileImage(File(caminhoFotouser)),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeuser,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$data às $hora',
                      style: TextStyle(
                        color: const Color.fromARGB(170, 255, 255, 255)
                            .withOpacity(0.699999988079071),
                        fontSize: 12,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: widget.cor,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: IconButton(
                  padding: const EdgeInsets.all(3),
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    //mostrarEstruturaEdadosBancoDados();
                  },
                  iconSize: 23,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 244, 244, 244),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: isKeyboardVisible ? 80 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (caminhoImagem.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImagemFullscreen(
                                  caminhoImagem: caminhoImagem),
                            ),
                          );
                        },
                        child: SizedBox(
                            width: double.infinity,
                            child: Image.file(
                              File(caminhoImagem),
                              fit: BoxFit.cover,
                            )),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titulo,
                            style: const TextStyle(
                              color: Color(0xFF49454F),
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            descricao,
                            style: const TextStyle(
                              color: Color(0xFF49454F),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    /*Padding(
                      padding: const EdgeInsets.only(left: 14, top: 15),
                      child: Text(
                        'Fotografado em :',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        if (idEvento != null) {
                          print('Abrir página do evento');
                        } else {
                          int Idlocal = idLocal!;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => pagina_publicacao(
                                idPublicacao: Idlocal,
                                cor: widget.cor,
                              ),
                            ),
                          );
                        }
                        ;
                      },
                      child: Padding(
                          padding: const EdgeInsets.only(
                              left: 14, top: 1, right: 15, bottom: 5),
                          child: SizedBox(
                            height: 70,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: AssetImage(
                                          idEvento != null
                                              ? capa_evento
                                              : capa_locla,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 80,
                                  top: 0,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        idEvento != null
                                            ? nomeEvento
                                            : nomeLocal,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        children: [
                                          if (idEvento ==
                                              null) // Verifica se idEvento é null
                                            Icon(Icons.star_half_rounded,
                                                size: 16, color: widget.cor),
                                          const SizedBox(
                                              width:
                                                  5), // Adiciona um espaço entre o ícone e o texto
                                          Text(
                                            idEvento != null
                                                ? '$diaEvento de ${converter_mes(mesEvento)}'
                                                : classlocal,
                                            style: TextStyle(
                                              color: widget.cor,
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                              idEvento != null
                                                  ? Icons.people_alt_rounded
                                                  : Icons.location_on,
                                              size: 16,
                                              color: const Color(0xFF79747E)),
                                          const SizedBox(width: 5),
                                          Text(
                                            idEvento != null
                                                ? '$numeroParticipantes participantes'
                                                : '$moradalocal ',
                                            style: const TextStyle(
                                              color: Color(0xFF79747E),
                                              fontSize: 13,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                try {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });

                                  if (isLiked) {
                                    // Tentar dar like na API
                                    bool sucesso = await ApiPartilhas()
                                        .criarLike(user_id, widget.idpartilha);
                                    if (sucesso) {
                                      await Funcoes_Likes_das_Partilhas
                                          .userDaLike(
                                              user_id, widget.idpartilha);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Deu like!'),
                                          duration: Duration(seconds: 1),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        isLiked = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Falha ao dar like!'),
                                          duration: Duration(seconds: 1),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } else {
                                    // Tentar remover o like na API
                                    bool sucesso = await ApiPartilhas()
                                        .apagarLike(user_id, widget.idpartilha);
                                    if (sucesso) {
                                      await Funcoes_Likes_das_Partilhas
                                          .userRemoveLike(
                                              user_id, widget.idpartilha);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Removeu o like!'),
                                          duration: Duration(seconds: 1),
                                          backgroundColor:
                                              Color.fromARGB(255, 211, 33, 33),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        isLiked = true;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Falha ao remover o like!'),
                                          duration: Duration(seconds: 1),
                                          backgroundColor: Colors.red,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro: $e'),
                                      duration: Duration(seconds: 1),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                isLiked
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                color: widget.cor,
                              ),
                            ),
                            Text(
                              numeroDeLikes.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.message_outlined, color: widget.cor),
                            const SizedBox(width: 4),
                            Text(
                              '${comentarios.length}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.15,
                              ),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 6.10,
                          top: 1),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 110,
                        height: 1,
                        color: const Color.fromARGB(77, 158, 158, 158),
                      ),
                    ),
                    comentarios.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/sem_mesagens.png',
                                  width: 35,
                                  height: 35,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Sem comentários ainda',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comentarios.length,
                            itemBuilder: (context, index) {
                              var comentario = comentarios[index];
                              /*print(
                            'ID do Comentário ENVIADOOOO: ${comentario['id']}');
                        print('ID do Usuário: ${comentario['user_id']}');
                        print(
                            'Texto do Comentário: ${comentario['texto_comentario']}');
*/
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 14, right: 7, top: 10, bottom: 10),
                                child: CARD_COMENTAARIO_FOTO(
                                  horaComentario: comentario['hora_comentario'],
                                  idPartilha: comentario['partilha_id'],
                                  idComentario: comentario['id'],
                                  userId: comentario['id_usuario'],
                                  dataComentario: comentario['data_comentario'],
                                  textoComentario:
                                      comentario['texto_comentario'],
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 5), // Adicione um espaçamento de 5 pixels
                  child: Material(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.cor,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 10,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
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
                                hintText: 'comentar...',
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
                                try {
                                  String dataComentario =
                                      DateFormat('dd/MM/yyyy')
                                          .format(DateTime.now());
                                  // Dados do comentário
                                  Map<String, dynamic> comentario = {
                                    'id_usuario': user_id,
                                    'texto_comentario': mensagemTexto,
                                    'data_comentario': dataComentario,
                                    'hora_comentario':
                                        TimeOfDay.now().format(context),
                                  };

                                  bool sucesso = await ApiPartilhas()
                                      .criarComentario(
                                          widget.idpartilha, comentario);

                                  if (sucesso) {
                                    await Funcoes_Comentarios_das_Partilhas
                                        .criarComentario(
                                            user_id,
                                            widget.idpartilha,
                                            mensagemTexto,
                                            context);
                                    controller.clear();
                                    FocusScope.of(context)
                                        .unfocus(); // Fecha o teclado virtual
                                    print('Comentário enviado com sucesso!');
                                  } else {
                                    print(
                                        'Falha ao enviar o comentário para a API.');
                                  }
                                } catch (e) {
                                  print('Erro ao enviar comentário: $e');
                                }
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
