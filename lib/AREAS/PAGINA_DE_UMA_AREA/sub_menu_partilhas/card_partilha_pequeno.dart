import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';

Widget CARD_PARTILHA_MINI({
  required int idpartilha,
  required BuildContext context,
}) {
  late String imagem_Da_partilha = "";

  Future<void> buscarDetalhesPartilha(int idPartilha) async {
    Funcoes_Partilhas funcoesPartilhas = Funcoes_Partilhas();
    Map<String, dynamic> detalhesPartilha =
        await funcoesPartilhas.buscarDetalhesPartilha(idPartilha);

    imagem_Da_partilha = detalhesPartilha['caminho_imagem'];
  }

  return FutureBuilder(
    future: buscarDetalhesPartilha(idpartilha),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return const Text('Erro ao carregar os detalhes da partilha');
      } else {
        return Container(
            child: Image.file(
          File(imagem_Da_partilha),
          fit: BoxFit.cover,
        ));
      }
    },
  );
}
