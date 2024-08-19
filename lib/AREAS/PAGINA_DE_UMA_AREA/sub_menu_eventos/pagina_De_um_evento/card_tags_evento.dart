import 'dart:io';

import 'package:flutter/material.dart';

Widget cardAreaInteressesCustom({
  required String nomeArea,
  required Color corArea,
  required String imagemArea,
}) {
  //print('imagem:$imagemArea');
  return IntrinsicWidth(
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: corArea, width: 1.5),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 3.0, left: 5.0, right: 8, bottom: 3),
                child: Image.file(
                  File(
                      imagemArea), // imagemArea deve ser o caminho do arquivo da imagem
                  width: 27,
                  height: 27,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    nomeArea,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: corArea,
                      fontSize: 16.48,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8)
            ],
          ),
        ],
      ),
    ),
  );
}

Widget cardTipoInteressesCustom({
  required String nomeArea,
  required Color corArea,
  required String imagemArea,
}) {
  //print('imagem:$imagemArea');
  return IntrinsicWidth(
    child: Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: corArea, width: 1.5),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 3.0, left: 5.0, right: 8, bottom: 3),
                child: Image.file(
                  File(
                      imagemArea), // imagemArea deve conter o caminho do arquivo
                  width: 27,
                  height: 27,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    nomeArea,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: corArea,
                      fontSize: 16.48,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8)
            ],
          ),
        ],
      ),
    ),
  );
}
