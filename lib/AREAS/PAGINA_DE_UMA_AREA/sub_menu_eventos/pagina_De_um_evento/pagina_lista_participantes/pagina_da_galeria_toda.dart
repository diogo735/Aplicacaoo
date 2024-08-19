import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_publicacao_local/pagina_todasimagems/galeria_imagem.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_eventos.dart';

class PagTodasImagensEvento extends StatefulWidget {
  final Color cor;
  final int idEvento;

  const PagTodasImagensEvento({
    Key? key,
    required this.idEvento,
    required this.cor,
  }) : super(key: key);

  @override
  _PagTodasImagensEventoState createState() => _PagTodasImagensEventoState();
}

class _PagTodasImagensEventoState extends State<PagTodasImagensEvento> {
  List<String> caminhosImagens = [];
  String nomeDoLocal = '';

  @override
  void initState() {
    super.initState();
    _carregarImagens();
    _carregarNomeLocal();
  }

  Future<void> _carregarNomeLocal() async {
    String nome =
        await Funcoes_Eventos.consultaNomeEventoPorId(widget.idEvento);
    setState(() {
      nomeDoLocal = nome;
    });
  }

  Future<void> _carregarImagens() async {
    Funcoes_Eventos_Imagens funcoesImagens = Funcoes_Eventos_Imagens();
    List<String> caminhos =
        await funcoesImagens.consultaCaminhosImagensPorEvento(widget.idEvento);

    setState(() {
      caminhosImagens = caminhos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          nomeDoLocal,
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
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (caminhosImagens.length / 3).ceil() * 2,
              itemBuilder: (BuildContext context, int index) {
                int actualIndex =
                    (index / 2).floor() * 3 + (index % 2 == 0 ? 0 : 1);
                if (index % 2 == 0) {
                  // Linha de 1 imagem
                  return actualIndex < caminhosImagens.length
                      ? GestureDetector(
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
                        )
                      : Container(); // Empty container if no image is available
                } else {
                  // Linha de 2 imagens
                  return Row(
                    children: [
                      for (int i = 0; i < 2; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: actualIndex + i < caminhosImagens.length
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageGallery(
                                            imagePaths: caminhosImagens,
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
                                          image: FileImage(
                                            File(caminhosImagens[actualIndex + i]),
                                          ),
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
      ),
    );
  }
}
