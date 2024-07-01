// ignore_for_file: use_key_in_widget_constructors, camel_case_types, library_private_types_in_public_api

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/card_topicos.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/pagina_topico/pagina_topico.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';

class submenutopicos extends StatefulWidget {
  final int id_area;
  final Color cor_da_area;

  submenutopicos({
    required this.id_area,
    required this.cor_da_area,
  });
  @override
  _submenutopicosState createState() => _submenutopicosState();
}

class _submenutopicosState extends State<submenutopicos> {
  List<Map<String, dynamic>> topicos = [];

  double bottomMargin = 20.0;
  double rightMargin = 12.0;

  @override
  void initState() {
    super.initState();

    _carregarTopicos();
  }

  void _carregarTopicos() async {
    Funcoes_Topicos funcoesTopicos = Funcoes_Topicos();
    List<Map<String, dynamic>> topicosCarregados =
        await funcoesTopicos.consultaTopicosPorArea(widget.id_area);
    setState(() {
      topicos = topicosCarregados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: topicos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/sem_resultados.png',
                      width: 85,
                      height: 85,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      "Sem topicos!",
                      style: TextStyle(
                        fontSize: 15, // Tamanho da fonte
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(162, 99, 98, 98),

                        // Adicione outros estilos conforme necessário
                      ),
                    )
                  ],
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                itemCount: topicos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                             builder: (context) => paginatopico(idtopico: topicos[index]['id'],cor: widget.cor_da_area,))
                        );
                      },
                      child: CARD_TOPICO(
                        cor:widget.cor_da_area,
                        idtopico: topicos[index]['id'],
                        context: context,
                      ),
                    ),
                  );
                },
              ));
  }
}
