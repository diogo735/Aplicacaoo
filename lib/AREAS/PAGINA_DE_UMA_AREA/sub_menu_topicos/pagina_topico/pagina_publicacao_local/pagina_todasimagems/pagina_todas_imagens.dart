import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/galeria_imagem.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types

import 'dart:async';

class pag_todas_imagens extends StatefulWidget {
  final Color cor;
  final int id_publicacao;

  const pag_todas_imagens({super.key, required this.id_publicacao,required this.cor});

  @override
  _pag_todas_imagensState createState() => _pag_todas_imagensState();
}

// ignore: camel_case_types
class _pag_todas_imagensState extends State<pag_todas_imagens> {
  List<String> caminhos_Imagens = [];
  late Timer _timer;
  String nomedolocal = '';
  @override
  void initState() {
    super.initState();
    _carregarImagens();
    _carregarNomeLocal();
  }

  _carregarNomeLocal() async {
    String nome =
        await Funcoes_Publicacoes.consultaNomeLocalPorId(widget.id_publicacao);
    setState(() {
      nomedolocal = nome;
    });
  }

  _carregarImagens() async {
    List<Map<String, dynamic>> imagens =
        await Funcoes_Publicacoes_Imagens().consultaPublicacoesImagens();
    List<String> caminhos = [];
    for (var imagem in imagens) {
      if (imagem['publicacao_id'] == widget.id_publicacao) {
        caminhos.add(imagem['caminho_imagem']);
        print(imagem['caminho_imagem']);
      }
    }
    setState(() {
      caminhos_Imagens = caminhos;
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
      body: SingleChildScrollView(
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
              itemCount: (caminhos_Imagens.length / 3).ceil() * 2,
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
                            imagePaths: caminhos_Imagens,
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
                            image: AssetImage(caminhos_Imagens[actualIndex]),
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
                            child: actualIndex + i < caminhos_Imagens.length
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageGallery(
                                            imagePaths: caminhos_Imagens,
                                            initialIndex: actualIndex + i,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.width / 2,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(caminhos_Imagens[
                                              actualIndex + i]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(), // Empty container if no image is available
                          ),
                        ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
