import 'dart:io';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/galeria_imagem.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:flutter/material.dart';

class pag_todas_imagens extends StatefulWidget {
  final Color cor;
  final int id_publicacao;

  const pag_todas_imagens(
      {super.key, required this.id_publicacao, required this.cor});

  @override
  _pag_todas_imagensState createState() => _pag_todas_imagensState();
}

class _pag_todas_imagensState extends State<pag_todas_imagens> {
  String nomedolocal = '';

  @override
  void initState() {
    super.initState();
    _carregarNomeLocal();
  }

  Future<void> _carregarNomeLocal() async {
    String nome =
        await Funcoes_Publicacoes.consultaNomeLocalPorId(widget.id_publicacao);
    setState(() {
      nomedolocal = nome;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          nomedolocal,
          style: const TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: widget.cor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: FutureBuilder<List<String>>(
        future: Funcoes_Publicacoes_Imagens()
            .consultaCaminhosImagensPorPublicacao(widget.id_publicacao),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: widget.cor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar as imagens'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Nenhuma imagem encontrada'),
            );
          } else {
            List<String> caminhosImagens = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 0,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: (caminhosImagens.length / 3).ceil() * 2,
                    itemBuilder: (BuildContext context, int index) {
                      int actualIndex =
                          (index / 2).floor() * 3 + (index % 2 == 0 ? 0 : 1);
                      if (index % 2 == 0) {
                        // linha de 1 imagem
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageGallery(
                                  imagePaths: caminhosImagens,
                                  initialIndex: actualIndex,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Container(
                              height: MediaQuery.of(context).size.width - 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: FileImage(
                                      File(caminhosImagens[actualIndex])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // linha de 2 imagens
                        return Row(
                          children: [
                            for (int i = 0; i < 2; i++)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 1,
                                  ),
                                  child: actualIndex + i <
                                          caminhosImagens.length
                                      ? GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageGallery(
                                                  imagePaths: caminhosImagens,
                                                  initialIndex:
                                                      actualIndex + i,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: FileImage(File(
                                                    caminhosImagens[
                                                        actualIndex + i])),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
