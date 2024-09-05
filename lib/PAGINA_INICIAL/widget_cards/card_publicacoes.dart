import 'dart:io';
import 'package:flutter/material.dart';

Widget CARD_PUBLICACAO({
  required int publicacaoId,
  required String nomePublicacao,
  required String local,
  required String classificacao_media,
  required String imagePath, 
  required String distancia// Agora recebemos o caminho da imagem diretamente
}) {
  
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
                  image: File(imagePath).existsSync()
                      ? FileImage(File(imagePath))
                      : const AssetImage('assets/images/sem_imagem.png') as ImageProvider,
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
          // Texto "NOME DO LOCAL"
          Positioned(
            top: _calculateTopPosition(nomePublicacao),
            left: 10,
            child: SizedBox(
              width: 271.61,
              height: 60.39,
              child: Text(
                nomePublicacao,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22.95,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.24,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // LOCALIZAÇÃO DA PUBLICACAO
          Positioned(
            top: 191,
            left: 8,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 3),
                Text(
                  local.length > 14 ? '${local.substring(0, 14)}...' : local,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.30,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 0.10,
                    letterSpacing: 0.14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // CALSSIFICAÇÃO MEDIA
          const Positioned(
            bottom: 5,
            right: 145,
            child: Icon(
              Icons.star_half_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          Positioned(
            bottom: 14,
            right: 123,
            child: Text(
              classificacao_media,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.30,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 0.10,
                letterSpacing: 0.14,
              ),
            ),
          ),
          // A DISTANCIA QUE ESTÁ DO USER
          Positioned(
            bottom: 6,
            right: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 1),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Text(
                      " a $distancia",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.30,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 0.10,
                        letterSpacing: 0.14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

double _calculateTopPosition(String nomePublicacao) {
  // Criar um TextPainter com o texto e estilo
  TextPainter tp = TextPainter(
    text: TextSpan(
      text: nomePublicacao,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22.95,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w800,
        letterSpacing: 0.24,
      ),
    ),
    textAlign: TextAlign.left,
    textDirection: TextDirection.ltr,
    maxLines: 2, // Definir o número máximo de linhas
  );
  tp.layout(maxWidth: 271.61);

  // Verificar se o texto cabe em uma linha
  double textHeight = tp.size.height;
  return (textHeight <= 22.95 * 2) ? 153.0 : 125.0;
}
