import 'package:flutter/material.dart';


Widget CARD_PUBLICACAO({
  required String nomePublicacao,
  required String local,
  required String classificacao_media,
  required String imagePath,
  required BuildContext context,
}) {
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
  double topPosition = (textHeight <= 22.95 * 2) ? 153.0 : 125.0;


  return  SizedBox(
      width: MediaQuery.of(context).size.width - 15,
      height: 220,
      child: Stack(
        children: [
          // Imagem de fundo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.78),
                image: DecorationImage(
                  image: AssetImage(imagePath),
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
            top: topPosition,
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
                maxLines: 2, // Define o número máximo de linhas
                overflow: TextOverflow
                    .ellipsis, // Define como o texto será truncado se for mais longo que o permitido
              ),
            ),
          ),
          // LOCALIZAÇÃO DA PUBLICACAO
          Positioned(
            top: 191, // Ajuste conforme necessário
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
                  overflow: TextOverflow.ellipsis, // Adiciona reticências se o texto for maior que o limite
                ),
              ],
            ),
          ),
          ///CALSSIFICAÇÃO MEDIA
          const Positioned(
            bottom: 5,
            right: 145,
            child: Icon(
              Icons.star_half_rounded, // Seu ícone aqui
              color: Colors.white,
              size: 24, // Tamanho do ícone
            ),
          ),
          Positioned(
            bottom: 14,
            right: 123,
            child: Text(
              classificacao_media, // Seu texto aqui
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
          /// A DISTANCIA QUE ESTÁ DO USER
          const Positioned(
            bottom: 6,
            right: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(
                    Icons.map_outlined, 
                    color: Colors.white,
                    size: 22, 
                  ),
                ),
                SizedBox(width: 1),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 9),// Alinha o texto com bottom: 14
                    child: Text(
                      " a 15,3 Km",
                      style: TextStyle(
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
    );
  
}
