// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

Widget CARD_EVENTO({
  required Color cor,
  required String nomeEvento,
  required int dia,
  mes,
  ano,
  required String horas,
  required String local,
  required String numeroParticipantes,
  required String imagePath,
  required int tipo_evento,
  required int tocpico_evento,
  required BuildContext context,
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

  // Obtém o tamanho da tela
  final screenWidth = MediaQuery.of(context).size.width;

  // Carrega dados do tipo de evento e do tópico de evento simultaneamente
  return FutureBuilder<List<Map<String, String>>>(
    future: Future.wait([
      Funcoes_TipodeEvento.obterDadosTipoEvento(tipo_evento),
      Funcoes_Topicos.obterDadosTopico(tocpico_evento),
    ]),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Erro: ${snapshot.error}');
      } else {
        // Obtenha os resultados dos futuros
        final Map<String, String> tipoEventoData = snapshot.data![0];
        final Map<String, String> topicoEventoData = snapshot.data![1];

        final String tipoEvento = tipoEventoData['nome']!;
        final String imagemTipoEvento = tipoEventoData['imagem']!;

        final String nomeTopico = topicoEventoData['nome']!;
        final String imagemTopico = topicoEventoData['imagem']!;

        return _buildEventoWidget(
          cor: cor,
          nomeEvento: nomeEvento,
          data: formatarData(dia, mes, ano),
          horas: horas,
          local: local,
          numeroParticipantes: numeroParticipantes,
          imagePath: imagePath,
          tipoEvento: tipoEvento,
          tipo_evento: tipo_evento,
          imagemTipoEvento: imagemTipoEvento,
          screenWidth: screenWidth,
          context: context,
          nomeTopico: nomeTopico,
          imagemTopico: imagemTopico,
        );
      }
    },
  );
}

Widget _buildEventoWidget({
  required Color cor,
  required String nomeTopico,
  required String imagemTopico,
  required BuildContext context,
  required String nomeEvento,
  required String data,
  required String horas,
  required String local,
  required String numeroParticipantes,
  required String imagePath,
  required String tipoEvento,
  required int tipo_evento,
  required double screenWidth,
  required String imagemTipoEvento,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 8.0),
    child: LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white, // Define a cor de fundo
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0.5,
                    blurRadius: 7,
                    offset: const Offset(0, 4), // Sombra à direita e abaixo
                  ),
                ],
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Imagem com altura fixa
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(imagePath)),
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
                    // Conteúdo flexível
                    Container(
                      color: const Color.fromARGB(255, 255, 255, 255)
                          .withOpacity(0.35),
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                               IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1, color: cor),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.file(
                                        File(
                                            imagemTopico), // Aqui você pode usar outra imagem ou a mesma, conforme necessário
                                        width: 20,
                                        height: 20,
                                        color: cor.withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        nomeTopico, 
                                        style: TextStyle(
                                          color: cor,
                                          fontSize: 14,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                             ,
                              const SizedBox(
                                  width:
                                      10), // Espaço entre os dois IntrinsicWidth
                               IntrinsicWidth(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 5),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(width: 1, color: cor),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.file(
                                        File(imagemTipoEvento),
                                        width: 20,
                                        height: 20,
                                        color: cor.withOpacity(0.8),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        tipoEvento,
                                        style: TextStyle(
                                          color: cor,
                                          fontSize: 14,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            nomeEvento,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.25,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                data,
                                style: TextStyle(
                                  color: cor,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.15,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 2.83,
                                height: 2.83,
                                decoration: BoxDecoration(
                                  color: cor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                horas,
                                style: TextStyle(
                                  color: cor,
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.15,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xB21D1B20),
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    local.length > 29
                                        ? '${local.substring(0, 29)}...'
                                        : local,
                                    style: const TextStyle(
                                      color: Color(0xB21D1B20),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
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
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    Icons.people_alt_rounded,
                                    color: cor,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botão de ação flutuante (posicionado corretamente)
            Positioned(
              top: MediaQuery.of(context).size.height / 4 - 35,
              right: 10,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0.5,
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    // Ação ao pressionar o botão
                  },
                  icon: Icon(
                    Icons.share,
                    color: cor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
