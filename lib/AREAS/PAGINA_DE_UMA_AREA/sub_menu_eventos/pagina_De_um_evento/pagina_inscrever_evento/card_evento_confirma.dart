import 'dart:io';

import 'package:flutter/material.dart';

Widget CARD_EVENTO_Da_confirmacao({
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

  return Padding(
    padding: const EdgeInsets.only(left: 0.0),
    child: Container(
      width: 340,
      height: nomeEvento.length > 23 ? 95 : 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 4, right: 3), // Define o espaçamento à esquerda
            child: Container(
              height: 35,
              width: 35,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
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
          SizedBox(width: 10), // Espaçamento entre as imagens
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 5,
                ),
                Text(
                  nomeEvento,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      size: 17,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '$numeroParticipantes',
                      style: TextStyle(
                        color: Color(0xFF79747E),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: Color(0xFF15659F),
                    ),
                    SizedBox(width: 5),
                    Text(
                      formatar_Data(dia, mes),
                      style: TextStyle(
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
            height: nomeEvento.length > 23 ? 95 : 80,
            width: 85,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
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
