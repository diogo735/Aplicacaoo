import 'package:flutter/material.dart';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_comentarios_de_publicacoes.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_comentarios_publicacao/card_comentario.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/criar_comentario_pagina.dart';
// ignore: camel_case_types

import 'dart:async';

class pag_cometarios_pub extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_publicacao;
final Color cor;
  // ignore: non_constant_identifier_names
  const pag_cometarios_pub({super.key, required this.id_publicacao,required this.cor});

  @override
  // ignore: library_private_types_in_public_api
  _pag_cometarios_pubState createState() => _pag_cometarios_pubState();
}

// ignore: camel_case_types
class _pag_cometarios_pubState extends State<pag_cometarios_pub> {
  List<Map<String, dynamic>> comentarios = [];
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _carregarComentariosPublicacao();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _carregarComentariosPublicacao();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _carregarComentariosPublicacao() async {
    List<Map<String, dynamic>> comentariosCarregados =
        await Funcoes_Comentarios_Publicacoes()
            .consultaComentariosPorPublicacao(widget.id_publicacao);
    

    setState(() {
      comentarios.clear();
      comentarios.addAll(comentariosCarregados.reversed);
    });
  }

  String _converterData(String dataOriginal) {
    List<String> partes = dataOriginal.split('/');
    String dataConvertida = '${partes[2]}-${partes[1]}-${partes[0]}';
    return dataConvertida;
  }

  // ignore: non_constant_identifier_names
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

  // ignore: non_constant_identifier_names
  int quantos_tem_esta_classificacao(int classificacao) {
    int quantidade = 0;
    for (var comentario in comentarios) {
      if (comentario['classificacao'] == classificacao) {
        quantidade++;
      }
    }
    return quantidade;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todos os Comentarios',
          style: TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: widget.cor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: IconButton(
              padding: const EdgeInsets.all(3),
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => criar_cometario_pub(cor: widget.cor,
                          id_publicacao: widget.id_publicacao)),
                );
              },
              iconSize: 23,
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(
                calcular_media_classificacao().toStringAsFixed(1),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(height: 1),
              RatingStars(
                starSize: 19,
                rating: calcular_media_classificacao(),
                fillColor: Colors.amber,
                emptyColor: Colors.grey,
              ),
              const SizedBox(height: 1),
              Text(
                "${comentarios.length} comentário(s)",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.15,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClassificacaoComentarios(
                    cor: widget.cor,
                      classificacao: 'Excelente',
                      quantidadeComentarios: quantos_tem_esta_classificacao(5),
                      comentariostotal: comentarios.length),
                  ClassificacaoComentarios(
                    cor: widget.cor,
                      classificacao: 'Muito Bom',
                      quantidadeComentarios: quantos_tem_esta_classificacao(4),
                      comentariostotal: comentarios.length),
                  ClassificacaoComentarios(
                    cor: widget.cor,
                      classificacao: 'Razoável',
                      quantidadeComentarios: quantos_tem_esta_classificacao(3),
                      comentariostotal: comentarios.length),
                  ClassificacaoComentarios(
                    cor: widget.cor,
                      classificacao: 'Fraco',
                      quantidadeComentarios: quantos_tem_esta_classificacao(2),
                      comentariostotal: comentarios.length),
                  ClassificacaoComentarios(
                    cor: widget.cor,
                      classificacao: 'Péssimo',
                      quantidadeComentarios: quantos_tem_esta_classificacao(1),
                      comentariostotal: comentarios.length),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 110,
                height: 1,
                color: const Color.fromARGB(135, 158, 158, 158),
              ),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comentarios.length,
                itemBuilder: (context, index) {
                  var comentario = comentarios[index];
                 // print('ID do Comentário ENVIADOOOO: ${comentario['id']}');
                  //print('ID do Usuário: ${comentario['user_id']}');

                  //print(
                     // 'Texto do Comentário: ${comentario['texto_comentario']}');

                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 14, right: 7, top: 10, bottom: 10),
                    child: CARD_COMENTAARIO_PUB(
                      idComentario: comentario['id'],
                      userId: comentario['user_id'],
                      dataComentario: comentario['data_comentario'],
                      classificacao: comentario['classificacao'],
                      textoComentario: comentario['texto_comentario'],
                      idPublicacao: comentario['publicacao_id'],
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
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

class ClassificacaoComentarios extends StatelessWidget {
  final String classificacao;
  final int quantidadeComentarios;
  final int comentariostotal;
  final Color cor;

  const ClassificacaoComentarios({
    super.key,
    required this.classificacao,
    required this.cor,
    required this.quantidadeComentarios,
    required this.comentariostotal,
  });

  @override
  Widget build(BuildContext context) {
    double progresso =
        comentariostotal > 0 ? quantidadeComentarios / comentariostotal : 0;
    return Padding(
      padding: const EdgeInsets.only(right: 14, left: 14, bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              classificacao,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Container(
              height: 18,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: LinearProgressIndicator(
                value: progresso,
                backgroundColor: Colors.grey[300],
                valueColor:
                     AlwaysStoppedAnimation<Color>(cor),
              ),
            ),
          ),
          const SizedBox(width: 15),
          SizedBox(
            width: 20,
            child: Text(
              quantidadeComentarios.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
