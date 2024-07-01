import 'dart:io';

import 'package:flutter/material.dart';

Widget CARD_EVENTO_DO_CALENDARIO(
  BuildContext context, {
  required Color cor,
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

  double screenWidth = MediaQuery.of(context).size.width;
  return Padding(
    padding: const EdgeInsets.only(left: 0.0),
    child: Container(
      width: screenWidth - 10,
      height: nomeEvento.length > 23 ? 95 : 80,
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
                left: 4, right: 3), // Define o espaçamento à esquerda
            child: SizedBox(
              height: 35,
              width: 35,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.asset(
                  imagem_topico,
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
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  nomeEvento,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
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
                     Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: cor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatar_Data(dia, mes),
                      style:  TextStyle(
                        color: cor,
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
          SizedBox(
            height: nomeEvento.length > 23 ? 95 : 80,
            width: 85,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.10),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
