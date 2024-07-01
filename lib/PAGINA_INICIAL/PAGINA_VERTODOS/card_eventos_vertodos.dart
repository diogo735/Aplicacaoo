// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';

Widget CARD_EVENTO_VERTODOS({
   required BuildContext context,
  required String nomeEvento,
  required int dia,mes,ano,
  required String horas,
  required String local,
  required String numeroParticipantes,
  required String imagePath,
  required int tipo_evento,
}) {
  String formatarData(int dia, int mes, int ano) {
  
  List<String> meses = [
    '', // Mês 0 não é utilizado
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  String nomeMes = meses[mes];
  return '$dia de $nomeMes, $ano';
}
  return FutureBuilder<String>(
    future: Funcoes_TipodeEvento.obterTipoEventoDoBancoDeDados(tipo_evento),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Erro: ${snapshot.error}');
      } else {
        final String tipoEvento = snapshot.data!;
        return _buildEventoWidget(
          context: context,
          nomeEvento: nomeEvento,
          data: formatarData(dia, mes, ano),
          horas: horas,
          local: local,
          numeroParticipantes: numeroParticipantes,
          imagePath: imagePath,
          tipoEvento: tipoEvento,
          tipo_evento:
          tipo_evento, // Passando o id_tipo do evento para o widget interno
        );
      }
    },
  );
}

IconData icondeEvento(int tipoEventoId) {
  switch (tipoEventoId) {
    case 1:
      return Icons.mic_external_on_rounded;
    case 2:
      return Icons.work;
    case 3:
      return Icons.theaters;
    case 4:
      return Icons.meeting_room;
    case 5:
      return Icons.local_activity;
    case 6:
      return Icons.music_note;
    case 7:
      return Icons.local_movies;
    case 8:
      return Icons.restaurant;
    case 9:
      return Icons.book;
    case 10:
      return Icons.cake;
    case 11:
      return Icons.flag;
    case 12:
      return Icons.emoji_events;
    case 13:
      return Icons.videogame_asset;
    case 14:
      return Icons.directions_walk;
    case 15:
      return Icons.directions;
    case 16:
      return Icons.star;
    case 17:
      return Icons.more_horiz;
    default:
      return Icons.event; // Ícone padrão para IDs desconhecidos
  }
}

Widget _buildEventoWidget({
   required BuildContext context,
  required String nomeEvento,
  required String data,
  required String horas,
  required String local,
  required String numeroParticipantes,
  required String imagePath,
  required String tipoEvento,
  required int tipo_evento,
}) {
  // Criar um TextPainter com o texto e estilo
  TextPainter tp = TextPainter(
    text: TextSpan(
      text: nomeEvento,
      style: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w800,
        letterSpacing: 0.25,
      ),
    ),
    textAlign: TextAlign.left,
    textDirection: TextDirection.ltr,
    maxLines: 2, // Definir o número máximo de linhas
  );

  

  // Verificar se o texto cabe em uma ou duas linhas
  double height;
  if (nomeEvento.length > 26) {
    height = 384.0; // Texto com mais de 26 caracteres ocupa duas linhas
  } else {
    height = 355.0; // Texto com 26 caracteres ou menos ocupa uma linha
  }

  return Padding(
    padding: const EdgeInsets.only(left: 5.0),
    child: Stack(
      children: [
        // Container para a sombra
        Container(
          margin: EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Cor da sombra
                spreadRadius: 0.5, // Raio de propagação da sombra
                blurRadius: 7, // Raio de desfoque da sombra
                offset: Offset(0, 0.5), // Deslocamento da sombra
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width - 10,
          height: height,
        ),
        // Container principal
        Container(
          width: MediaQuery.of(context).size.width - 10,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), // Defina o raio da borda desejado
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Container(
              color: Colors.white, // Cor de fundo do widget
              child: Column(
                children: [
                  // Parte superior com a imagem
                  Container(
                    height: 220, // Altura da imagem
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Imagem de fundo
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:FileImage(File(imagePath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                          foregroundDecoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.10),
                            backgroundBlendMode: BlendMode.multiply,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Parte inferior com o texto
                  Expanded(
                    child: Container(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.35),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Texto
                            IntrinsicWidth(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 1, color: Color(0xFF15659F)),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      icondeEvento(tipo_evento),
                                      color: const Color(0xFF15659F),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      tipoEvento,
                                      style: const TextStyle(
                                        color: Color(0xFF15659F),
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Título do evento
                            Text(
                              nomeEvento,
                              // Truncar o texto se for maior que o limite
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.25,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Data e horário
                            Row(
                              children: [
                                Text(
                                  data,
                                  style: const TextStyle(
                                    color: Color(0xFF15659F),
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 0.09,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 4.83,
                                  height: 4.83,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF15659F),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  horas,
                                  style: const TextStyle(
                                    color: Color(0xFF15659F),
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w500,
                                    height: 0.09,
                                    letterSpacing: 0.15,
                                  ),
                                )
                              ],
                            ),
                            // Local do evento
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Color(0xB21D1B20),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      local.length > 29 ? '${local.substring(0, 29)}...' : local,
                                      style: const TextStyle(
                                        color: Color(0xB21D1B20),
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        height: 0.09,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      numeroParticipantes,
                                      style: const TextStyle(
                                        color: Color(0xFF1D1B20),
                                        fontSize: 16,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        height: 0.09,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.people_alt_rounded,
                                      color: Color(0xFF15659F),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Número de participantes
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
