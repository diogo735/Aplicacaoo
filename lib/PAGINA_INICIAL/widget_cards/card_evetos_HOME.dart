import 'dart:io';

import 'package:flutter/material.dart';

Widget CARD_EVENTO({
  required String nomeEvento,
  required int dia,mes,ano,
  required String horas,
  required String local,
  required String numeroParticipantes,
  required String imagePath,
}){
  String formatarData(int dia, int mes, int ano) {
  
  List<String> meses = [
    '', // Mês 0 não é utilizado
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  String nomeMes = meses[mes];
  return '$dia de $nomeMes, $ano';
}
  return Padding(
    padding: const EdgeInsets.only(left: 5.0),
    child: Container(
      width: 325,
      height: 220,
      child: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.78),
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: Colors.black.withOpacity(0.35),
                backgroundBlendMode: BlendMode.multiply,
              ),
            ),
          ),
          // Texto "Campeonato de Futebol"
           Positioned(
            top: 160,
            left: 10,
            child: SizedBox(
              width: 271.61,
              height: 13.39,
              child: Text(
              nomeEvento,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22.95,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                  height: 0.04,
                  letterSpacing: 0.24,
                ),
              ),
            ),
          ),
          // Data e horário
          Positioned(
            top: 180,
            left: 10,
            child: Row(
              children: [
                 Text(
                  formatarData(dia, mes, ano),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.30,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.10,
                    letterSpacing: 0.14,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Container(
                  width: 4.83,
                  height: 4.83,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                 Text(
                  horas,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.30,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.10,
                    letterSpacing: 0.14,
                  ),
                )
              ],
            ),
          ),
          // Local do evento
          Positioned(
            top: 196, // Ajuste conforme necessário
            left: 8,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 3), // Espaçamento entre o ícone e o texto
                Text(
                  formatText(local, 30),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.30,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.10,
                    letterSpacing: 0.14,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom:
                5, // Ajuste conforme necessário para o espaçamento em relação à parte inferior
            right:
                29, // Ajuste conforme necessário para o espaçamento em relação à esquerda
            child: Icon(
              Icons.people_alt_rounded, // Seu ícone aqui
              color: Colors.white,
              size: 20, // Tamanho do ícone
            ),
          ),
          Positioned(
            bottom:
                14, // Ajuste conforme necessário para o espaçamento em relação à parte inferior
            right:
                10, // Ajuste conforme necessário para o espaçamento em relação à direita
            child: Text(
              numeroParticipantes, // Seu texto aqui
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.30,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 0.10,
                letterSpacing: 0.14,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
String formatText(String text, int maxLength) {
  if (text.length > maxLength) {
    return text.substring(0, maxLength) + '...';
  }
  return text;
}
