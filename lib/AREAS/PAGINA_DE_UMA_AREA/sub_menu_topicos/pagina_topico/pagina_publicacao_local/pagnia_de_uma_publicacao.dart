import 'dart:io';

import 'package:flutter/material.dart';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_horario_publicacao.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_de_publicacoes.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_comentarios_publicacao/card_comentario.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_comentarios_publicacao/pagina_todos_comentairos.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/criar_comentario_pagina.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/mapa_local.dart';
import 'dart:async';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/pagina_todas_imagens.dart';

class pagina_publicacao extends StatefulWidget {
  final int idPublicacao;
  final Color cor;

  const pagina_publicacao(
      {super.key, required this.idPublicacao, required this.cor});
  @override
  _pagina_publicacaoState createState() => _pagina_publicacaoState();
}

class _pagina_publicacaoState extends State<pagina_publicacao> {
  List<String> caminhos_Imagens = [];
  List<Map<String, dynamic>> comentarios = [];
  String nomedolocal = '';
  PageController _pageController = PageController();
  int _currentPage = 1;
  String descricao = '';
  String localizacao = '';
  String contacto = '';
  String website = '';
  String email = '';
  int userid = 00;
  String data_pub = '';
  String nomedouser = '';
  String caminho_foto = '';
  late Timer _timer;
  List<Map<String, dynamic>> horarios = [];
  String? horarioAtual = '';
  String? estadoEstabelecimento = 'Indisponível';

  @override
  void initState() {
    super.initState();
    _carregarDados();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _carregarDados();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  _carregarDados() async {
    await _carregarImagens();
    await _carregarNomeLocal();
    await _carregarDetalhesPublicacao();
    await _carregarHorariosPublicacao();
    await _carregarNomeCompletoUsuario();
    await _carregarCaminhoFotoUsuario();
    await _carregarComentariosPublicacao();
    setState(() {
      horarioAtual = obterHorarioParaDiaAtual(horarios);
      estadoEstabelecimento = obterEstadoEstabelecimento();
    });
  }

  _carregarHorariosPublicacao() async {
    List<Map<String, dynamic>> horariosCarregados =
        await Funcoes_Publicacoes_Horario.consultarHorariosPorPublicacao(
            widget.idPublicacao);
    setState(() {
      horarios = horariosCarregados;
    });
  }

  _carregarComentariosPublicacao() async {
    List<Map<String, dynamic>> comentariosCarregados =
        await Funcoes_Comentarios_Publicacoes()
            .consultaComentariosPorPublicacao(widget.idPublicacao);
    setState(() {
      comentarios = comentariosCarregados;
    });
  }

  _carregarNomeCompletoUsuario() async {
    String nomeCompleto =
        await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(userid);
    setState(() {
      nomedouser = nomeCompleto;
    });
  }

  _carregarCaminhoFotoUsuario() async {
    String caminhoFoto =
        await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(userid);
    setState(() {
      caminho_foto = caminhoFoto;
    });
  }

  _carregarDetalhesPublicacao() async {
    List<Map<String, dynamic>> detalhes =
        await Funcoes_Publicacoes.consultaDetalhesPublicacaoPorId(
            widget.idPublicacao);
    if (detalhes.isNotEmpty) {
      setState(() {
        descricao = detalhes.first['descricao_local'];
        localizacao = detalhes.first['local'];
        email = detalhes.first['email'] ?? '';
        website = detalhes.first['pagina_web'] ?? '';
        contacto = detalhes.first['telemovel'] ?? '';
        userid = detalhes.first['user_id'];
        DateTime dateTime = DateTime.parse(detalhes.first['data_publicacao']);
      data_pub = DateFormat('dd/MM/yyyy \'às\' HH:mm').format(dateTime);
      });
    }
  }

  TimeOfDay? _timeOfDayFromString(String hora) {
    if (hora == 'Fechado') {
      return null; // Retorna null se o horário for "Fechado"
    }

    final partes = hora.split(':');
    return TimeOfDay(
      hour: int.parse(partes[0]),
      minute: int.parse(partes[1]),
    );
  }

  String? obterEstadoEstabelecimento() {
    int diaAtual = DateTime.now().weekday;
    TimeOfDay agora = TimeOfDay.now();

    List<String> diasSemana = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];

    for (var horario in horarios) {
      String diaHorario = horario['dia_semana'];
      if (diasSemana.indexOf(diaHorario) + 1 == diaAtual) {
        String horaAberto = horario['hora_aberto'];
        String horaFechar = horario['hora_fechar'];

        // Verifica se o horário é "Fechado"
        if (horaAberto == 'Fechado' || horaFechar == 'Fechado') {
          return 'Fechado';
        }

        // Converte as horas para TimeOfDay
        TimeOfDay? horaAbertura = _timeOfDayFromString(horaAberto);
        TimeOfDay? horaFechamento = _timeOfDayFromString(horaFechar);

        if (horaAbertura == null || horaFechamento == null) {
          return 'Fechado';
        }

        // Converte TimeOfDay para DateTime para comparação
        DateTime agoraDT = DateTime(0, 0, 0, agora.hour, agora.minute);
        DateTime aberturaDT =
            DateTime(0, 0, 0, horaAbertura.hour, horaAbertura.minute);
        DateTime fechamentoDT =
            DateTime(0, 0, 0, horaFechamento.hour, horaFechamento.minute);

        if (agoraDT.isAfter(aberturaDT) && agoraDT.isBefore(fechamentoDT)) {
          return 'Aberto Agora';
        } else {
          return 'Fechado';
        }
      }
    }
    return 'Indisponível';
  }

  _carregarImagens() async {
    List<Map<String, dynamic>> imagens =
        await Funcoes_Publicacoes_Imagens().consultaPublicacoesImagens();
    List<String> caminhos = [];
    for (var imagem in imagens) {
      if (imagem['publicacao_id'] == widget.idPublicacao) {
        caminhos.add(imagem['caminho_imagem']);
        //print(imagem['caminho_imagem']);
      }
    }
    setState(() {
      caminhos_Imagens = caminhos;
    });
  }

  _carregarNomeLocal() async {
    String nome =
        await Funcoes_Publicacoes.consultaNomeLocalPorId(widget.idPublicacao);
    setState(() {
      nomedolocal = nome;
    });
  }

  String? obterHorarioParaDiaAtual(List<Map<String, dynamic>> horarios) {
    int diaAtual = DateTime.now().weekday;

    List<String> diasSemana = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];

    for (var horario in horarios) {
      String diaHorario = horario['dia_semana'];
      if (diasSemana.indexOf(diaHorario) + 1 == diaAtual) {
        String horaAberto = horario['hora_aberto'];
        String horaFechar = horario['hora_fechar'];
        return 'das $horaAberto às $horaFechar';
      }
    }
    return null; // Explicitamente retornar null se não houver horário para o dia atual
  }

  double calcular_media_classificacao() {
    if (comentarios.isEmpty) {
      return 0.0;
    }
    double somaClassificacoes = 0;
    for (var comentario in comentarios) {
      somaClassificacoes += comentario['classificacao'];
    }
    return somaClassificacoes / comentarios.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Informações do Local',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
              )),
          backgroundColor: widget.cor,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: IconButton(
                padding: const EdgeInsets.all(3),
                icon: const Icon(Icons.share),
                onPressed: () {},
                iconSize: 23,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 242, 242, 242),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                /////////////////////////imagens////////////////////////////////////
                height: MediaQuery.of(context).size.height / 3,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: caminhos_Imagens.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => pag_todas_imagens(
                                  cor: widget.cor,
                                  id_publicacao: widget.idPublicacao,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 25,
                              height: MediaQuery.of(context).size.height / 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.file(
                                  File(caminhos_Imagens[
                                      index]), // Converte o caminho em um objeto File
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page + 1;
                        });
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      right: 15,
                      child: Container(
                        width: 50,
                        height: 30,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$_currentPage/${caminhos_Imagens.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ), ///////////////////////////////titulo/////////////////////////
              Padding(
                padding: const EdgeInsets.only(left: 7),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nomedolocal,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ),
              Row(
                ///////////////////////////avaliacao////////////////////////////////

                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${calcular_media_classificacao().toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Color(0xFF79747E),
                          fontSize: 17,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.33,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  RatingStars(
                    starSize: 20,
                    rating: calcular_media_classificacao(),
                    fillColor: Colors.amber,
                    emptyColor: Colors.grey,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    '${comentarios.length}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  const Icon(
                    Icons.message_rounded,
                    color: Colors.black,
                    size: 17,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ), ///////////////////////////descricao////////////////////////////////
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
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
                    'Descrição do Local',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(descricao,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.15,
                      )),
                ),
              ),
              ///////////////////////////////horario|||||||||||||||||||||||||||||||||||
              Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors
                        .transparent, // Define a cor do divisor como transparente
                  ),
                  child: ExpansionTile(
                    iconColor: widget.cor,
                    collapsedIconColor: widget.cor,
                    title: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            estadoEstabelecimento! == 'Aberto Agora'
                                ? Icons.schedule_rounded
                                : Icons.history_toggle_off_rounded,
                            color: estadoEstabelecimento == 'Aberto Agora'
                                ? const Color(0xFF53981D)
                                : Colors.red,
                            size: 25,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          estadoEstabelecimento!,
                          style: TextStyle(
                            color: estadoEstabelecimento! == 'Aberto Agora'
                                ? const Color(0xFF53981D)
                                : Colors.red,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(left: 31),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          // Exibe "Fechado" apenas se a variável `horarioAtual` for "Fechado"
                          horarioAtual == 'Fechado'
                              ? 'Fechado'
                              : horarioAtual ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    children: [
                      // Conteúdo expandido
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: horarios.length,
                        itemBuilder: (context, index) {
                          String diaSemana = horarios[index]['dia_semana']
                              .replaceAll('-feira', '');
                          String horaAbertura = horarios[index]['hora_aberto'];
                          String horaFechamento =
                              horarios[index]['hora_fechar'];

                          // Ajuste o tamanho do dia da semana para que todos tenham o mesmo tamanho
                          String diaSemanaAjustado = diaSemana.padRight(10);

                          // Verifique se o horário é "Fechado"
                          String horarioExibido;
                          if (horaAbertura == 'Fechado' ||
                              horaFechamento == 'Fechado') {
                            horarioExibido = 'Fechado';
                          } else {
                            horarioExibido = '$horaAbertura - $horaFechamento';
                          }

                          return Padding(
                            padding:
                                const EdgeInsets.only(left: 45, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  // Texto para o dia da semana
                                  SizedBox(
                                    width: 100, // Largura desejada
                                    child: Text(
                                      diaSemanaAjustado,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    horarioExibido,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )),

              const SizedBox(
                height: 5,
              ),
              /////////////////////////////////////////////localização///////////////
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: widget.cor,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    'Localização',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              MapaLocal(idPublicacao: widget.idPublicacao),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 35),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Endereço:",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: localizacao,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.15,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              /////////////////////////////////////////////comentarios///////////////
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.message_rounded,
                        color: widget.cor,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    'Comentários e Avaliaçoes',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
              if (comentarios.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 5),
                  child: Row(
                    children: [
                      Text(
                        calcular_media_classificacao().toStringAsFixed(1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingStars(
                            starSize: 13,
                            rating: calcular_media_classificacao(),
                            fillColor: Colors.amber,
                            emptyColor: Colors.grey,
                          ),
                          Text(
                            "com base em ${comentarios.length} comentário(s)",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.15,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => criar_cometario_pub(
                                    id_publicacao: widget.idPublicacao,
                                    cor: widget.cor)),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all<Color>(Colors.white),
                          foregroundColor:
                              WidgetStateProperty.all<Color>(widget.cor),
                          overlayColor: WidgetStateProperty.all<Color>(
                              Colors.green[100]!),
                          side: WidgetStateProperty.all<BorderSide>(
                              BorderSide(color: widget.cor, width: 1)),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        child: const Text("Comentar"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: CARD_COMENTAARIO_PUB(
                      idComentario: comentarios[0]['id'],
                      userId: comentarios[0]['user_id'],
                      dataComentario: comentarios[0]['data_comentario'],
                      classificacao: comentarios[0]['classificacao'],
                      textoComentario: comentarios[0]['texto_comentario'],
                      idPublicacao: comentarios[0]['publicacao_id'],
                    )),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => pag_cometarios_pub(
                                  cor: widget.cor,
                                  id_publicacao: widget.idPublicacao,
                                )),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(widget.cor),
                      foregroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 255, 255, 255)),
                      overlayColor: WidgetStateProperty.all<Color>(
                          widget.cor.withOpacity(0.3)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: const Text("Mostrar todos os comentários"),
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.only(
                      left: 30.0, right: 30, top: 10, bottom: 5),
                  child: Center(
                    child: Text(
                      "Sem comentários ainda!",
                      style: TextStyle(
                        color: Color.fromARGB(255, 148, 148, 148),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  padding: const EdgeInsets.only(
                    left: 14.0,
                    right: 14,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => criar_cometario_pub(
                                cor: widget.cor,
                                id_publicacao: widget.idPublicacao)),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.white),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(widget.cor),
                      overlayColor: WidgetStateProperty.all<Color>(
                          widget.cor.withOpacity(0.3)),
                      side: WidgetStateProperty.all<BorderSide>(
                          BorderSide(color: widget.cor, width: 1)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    child: const Text("Comentar"),
                  ),
                ),
              ],
              const SizedBox(
                height: 15,
              ),
              /////////////////////////////////////////////mais informações///////////////
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.info_rounded,
                        color: widget.cor,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    'Mais Infromações',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              if (contacto != '')
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    onPressed: () => _openPhoneApp(contacto),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 255, 255, 255)),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(widget.cor),
                      overlayColor: WidgetStateProperty.all<Color>(
                          widget.cor.withOpacity(0.3)),
                      side: WidgetStateProperty.all<BorderSide>(
                          BorderSide(color: widget.cor, width: 1)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.call,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(contacto!),
                      ],
                    ),
                  ),
                ),
              const SizedBox(
                height: 2,
              ),
              if (website != '')
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                      onPressed: () => _launchUrl(website),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color.fromARGB(255, 255, 255, 255)),
                        foregroundColor:
                            WidgetStateProperty.all<Color>(widget.cor),
                        overlayColor: WidgetStateProperty.all<Color>(
                            widget.cor.withOpacity(0.3)),
                        side: WidgetStateProperty.all<BorderSide>(
                            BorderSide(color: widget.cor, width: 1)),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.public,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            website.length > 26
                                ? "${website.substring(0, 24)}..."
                                : website,
                          ),
                        ],
                      )),
                ),
              const SizedBox(
                height: 2,
              ),
              if (email != '')
                Container(
                  width: MediaQuery.of(context).size.width - 10,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    onPressed: () => abrirGmail(email),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 255, 255, 255)),
                      foregroundColor:
                          WidgetStateProperty.all<Color>(widget.cor),
                      overlayColor: WidgetStateProperty.all<Color>(
                          widget.cor.withOpacity(0.3)),
                      side: WidgetStateProperty.all<BorderSide>(
                          BorderSide(color: widget.cor, width: 1)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.email,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(email),
                      ],
                    ),
                  ),
                ),
              if (email == '' || contacto == '' || website == '')
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sem informaçoes adicionais !',
                        style: TextStyle(
                            color: Color.fromARGB(255, 148, 148, 148))),
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.emoji_people,
                        color: widget.cor,
                        size: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  const Text(
                    'Publicado por ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.15,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 7.0, left: 20),
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: FileImage(File(caminho_foto)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nomedouser,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'em $data_pub',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.dangerous,
                        color: Color.fromARGB(255, 235, 7, 7),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Text(
                    'Denunciar Local',
                    style: TextStyle(
                        color: Color.fromARGB(255, 235, 7, 7),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.15,
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 235, 7, 7)),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ));
  }
}

void abrirGmail(String mail) async {
  String url = 'mailto:' + mail;
  await launch(url);
}

void _openPhoneApp(String numero) async {
  String url = 'tel:' + numero;
  await launch(url);
}

Future<void> _launchUrl(String site) async {
  final Uri _url = Uri.parse(site);
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
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
