import 'dart:io';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_lista_participantes/pagina_da_galeria_toda.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/galeria_imagem.dart';
import 'package:flutter/material.dart';

class ImageGalleryLayout extends StatelessWidget {
  final List<String> imagePaths;
  final int idEvento;
  final Color cor;

  ImageGalleryLayout({
    Key? key,
    required this.imagePaths,
    required this.idEvento,
    required this.cor, // Novo parâmetro para a cor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 5), // Espaçamento horizontal
      child: Container(
        height: MediaQuery.of(context).size.height /
            3, // Altura ajustada para 1/3 da tela
        child: Row(
          children: [
            Expanded(
              flex:
                  1, // Ocupa 1/2 do espaço disponível (por serem dois Expanded com o mesmo flex)
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageGallery(
                        imagePaths: imagePaths,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File((imagePaths.isNotEmpty
                          ? imagePaths[0]
                          : ''))), // Primeira imagem
                      fit: BoxFit.cover,
                    ),
                    borderRadius:
                        BorderRadius.circular(10), // Cantos arredondados
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1, // O mesmo espaço que o primeiro Expanded
              child: Column(
                // Adiciona uma coluna para dividir verticalmente
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageGallery(
                              imagePaths: imagePaths,
                              initialIndex: 1,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File((imagePaths.length > 1
                                ? imagePaths[1]
                                : ''))), // Segunda imagem, parte superior
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PagTodasImagensEvento( idEvento: idEvento,cor: cor),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10), // Cantos arredondados para a terceira imagem
                          image: DecorationImage(
                            image: FileImage(File((imagePaths.length > 2
                                ? imagePaths[2]
                                : ''))), // Terceira imagem, parte inferior
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: imagePaths.length > 3
                            ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                      10), // Sobreposição escura para melhorar a visibilidade do texto
                                ),
                                child: Text(
                                  '+${imagePaths.length - 3}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox(),
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
}

class ImageGalleryLayout2 extends StatelessWidget {
  final List<String> imagePaths;
  final String nome;
  final Color cor;

  ImageGalleryLayout2({
    Key? key,
    required this.imagePaths,
    required this.nome,
    required this.cor, // Novo parâmetro para a cor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 5), // Espaçamento horizontal
      child: Container(
        
        height: MediaQuery.of(context).size.height /
            3, // Altura ajustada para 1/3 da tela
        child: Row(
          children: [
            Expanded(
              flex:
                  1, // Ocupa 1/2 do espaço disponível (por serem dois Expanded com o mesmo flex)
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageGallery(
                        imagePaths: imagePaths,
                        initialIndex: 0,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File((imagePaths.isNotEmpty
                          ? imagePaths[0]
                          : ''))), // Primeira imagem
                      fit: BoxFit.cover,
                    ),
                    borderRadius:
                        BorderRadius.circular(10), // Cantos arredondados
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 1, // O mesmo espaço que o primeiro Expanded
              child: Column(
                // Adiciona uma coluna para dividir verticalmente
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageGallery(
                              imagePaths: imagePaths,
                              initialIndex: 1,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File((imagePaths.length > 1
                                ? imagePaths[1]
                                : ''))), // Segunda imagem, parte superior
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                       
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              10), // Cantos arredondados para a terceira imagem
                          image: DecorationImage(
                            image: FileImage(File((imagePaths.length > 2
                                ? imagePaths[2]
                                : ''))), // Terceira imagem, parte inferior
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: imagePaths.length > 3
                            ? Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                      10), // Sobreposição escura para melhorar a visibilidade do texto
                                ),
                                child: Text(
                                  '+${imagePaths.length - 3}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            : const SizedBox(),
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
}