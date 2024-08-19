import 'dart:io';

import 'package:flutter/material.dart';

Widget buildStackedImages(List<String> fotos) {
  List<Widget> stackedWidgets = [];
  double offset = 0; // Inicia o offset em 0

  int maxVisibleAvatars = 5;
  for (int i = 0; i < fotos.length; i++) {
    if (i < maxVisibleAvatars - 1 ||
        (i == maxVisibleAvatars - 1 && fotos.length <= maxVisibleAvatars)) {
      stackedWidgets.add(
        Positioned(
          left: offset,
          child: CircleAvatar(
            radius: 20, 
            backgroundImage: FileImage(File(fotos[i])), 
          ),
        ),
      );
      offset +=
          25; // Aumenta o offset para a próxima imagem ser parcialmente sobreposta
    } else if (i == maxVisibleAvatars - 1) {
      
      int remainingCount = fotos.length - maxVisibleAvatars;

      
      stackedWidgets.add(
        Positioned(
          left: offset,
          child: CircleAvatar(
            radius: 20,
            backgroundImage: FileImage(File(fotos[i])), // Usa a última foto visível
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    // Adiciona um overlay preto transparente
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
                Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: Colors.white,
                    ), // Estilo do texto
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      break; // Sai do loop, já que não precisamos de mais avatares
    }
  }

  return SizedBox(
    height: 40, // Altura do container
    child: Stack(
      children: stackedWidgets,
    ),
  );
}
