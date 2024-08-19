import 'dart:io';

import 'package:flutter/material.dart';

Widget CARD_EVENTO_DO_CALENDARIO2({
  required BuildContext
      context, // Passando o contexto para acessar o MediaQuery
  required String nomeEvento,
  required int dia,
  required int mes,
  required int numeroParticipantes,
  required String imagePath,
  required String imagem_topico,
}) {
  String formatar_Data(int dia, int mes) {
    List<String> meses = [
      '', // Mês 0 não é utilizado
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    String nomeMes = meses[mes];
    return '$dia de $nomeMes';
  }

  
  double containerHeight = MediaQuery.of(context).size.height / 8.3;

  return Padding(
    padding: const EdgeInsets.only(left: .0),
    child: Container(
      height: containerHeight, // Altura dinâmica
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 5, right: 3), // Define o espaçamento à esquerda
            child: Container(
              height: 35,
              width: 35,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.file(
                  File(imagem_topico),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10), // Espaçamento entre as imagens
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centraliza o conteúdo
              children: [
                Text(
                  nomeEvento,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_rounded,
                      size: 17,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$numeroParticipantes',
                      style: const TextStyle(
                        color: Color(0xFF79747E),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: Color(0xFF15659F),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatar_Data(dia, mes),
                      style: const TextStyle(
                        color: Color(0xFF15659F),
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        height: 0.17,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: containerHeight, // Altura dinâmica
            width: 85,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(
                    0.10), // Define a cor de sobreposição para escurecer
                colorBlendMode: BlendMode
                    .darken, // Define o modo de mesclagem para escurecer
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
