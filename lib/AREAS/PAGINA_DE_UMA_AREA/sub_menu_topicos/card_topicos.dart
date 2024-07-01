import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';

Widget CARD_TOPICO({
  required Color cor,
  required int idtopico,
  required BuildContext context,
}) {
  late String imagemDoTopico = '';
  late String nomeDoTopico = '';

  Future<void> buscarDetalhesTopico(int idtopico) async {
    List<dynamic> detalhesTopico = await Future.wait([
      Funcoes_Topicos.getCaminhoImagemDoTopico(idtopico),
      Funcoes_Topicos.obternomedoTopico(idtopico),
    ]);
    imagemDoTopico = detalhesTopico[0] as String;
    nomeDoTopico = detalhesTopico[1] as String;
  }

  return FutureBuilder(
    future: buscarDetalhesTopico(idtopico),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return const Text('Erro ao carregar os detalhes do topico');
      } else {
        return Container(
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 55,
                height: 55,
                child: Image.asset(
                  imagemDoTopico,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height:10),
              Text(
                nomeDoTopico,
                style:  TextStyle(
                  color: cor,
                  fontSize: 19,
                  fontFamily: 'Ubuntu',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ],
          ),
        );
      }
    },
  );
}
