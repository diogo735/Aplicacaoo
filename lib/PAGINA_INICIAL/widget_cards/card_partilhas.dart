import 'dart:io';

import 'package:flutter/material.dart';

Widget CARD_PARTILHA({
  required BuildContext context,
  required String nomeEvento_OU_Local,
  required String fotouser,
  required String nomeuser,
  required String imagePath,
}) {
  // Definir a largura máxima do texto
  // Largura máxima do contêiner

  // Criar um TextPainter com o texto e estilo
  TextPainter textPainter = TextPainter(
    text: TextSpan(
      text: nomeEvento_OU_Local,
      style: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF15659F),
      ),
    ),
    maxLines: 2,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: MediaQuery.of(context).size.width - 10);

  // Verificar o número real de linhas do texto
  int numLinhas = textPainter.computeLineMetrics().length;

  // Calculando a altura do contêiner inferior com base no número de linhas de texto
  double alturaContainerInferior = numLinhas * 20.0 + 22.0; // 20.0 é a altura aproximada de uma linha de texto com a fonte de tamanho 16

  return Padding(
    padding: const EdgeInsets.only(left: 5.0),
    child: Container(
      width: MediaQuery.of(context).size.width - 10,
      height: alturaContainerInferior + 243.0, // Altura total considerando a parte superior com a imagem
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
            height: alturaContainerInferior + 243.0, // Altura total considerando a parte superior com a imagem
          ),
          // Container principal
          Container(
            width: MediaQuery.of(context).size.width - 10,
            height: alturaContainerInferior + 243.0, // Altura total considerando a parte superior com a imagem
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
                    // Parte inferior com o texto
                    Expanded(
                      child: Container(
                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.35),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar do usuário
                              CircleAvatar(
                                radius: 23,
                                backgroundImage: FileImage(File(fotouser)),
                              ),
                              SizedBox(width: 13),
                              // Informações do usuário e nome do evento
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Informações do usuário
                                    Row(
                                      children: [
                                        Text(
                                          nomeuser,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'esteve em',
                                          style: TextStyle(
                                            color: Color(0xFF79747E),
                                            fontSize: 12,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            height: 0.11,
                                            letterSpacing: 0.10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Nome do evento
                                    SizedBox(height: 3),
                                    Text(
                                      nomeEvento_OU_Local,
                                      style: TextStyle(
                                        color: const Color(0xFF15659F),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(0xFF15659F),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    
                                  ],
                                ),
                              ),
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
    ),
  );
}
