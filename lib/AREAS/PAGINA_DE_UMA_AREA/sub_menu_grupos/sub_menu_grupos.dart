// ignore_for_file: use_key_in_widget_constructors, camel_case_types, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_grupos/card_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


class submenugrupos extends StatefulWidget {
  final int id_area;
  final Color cor_da_area;

  submenugrupos({
    required this.id_area,
    required this.cor_da_area,
  });
  @override
  _submenugruposState createState() => _submenugruposState();
}

class _submenugruposState extends State<submenugrupos> {
  List<Map<String, dynamic>> grupos = [];
  List<Map<String, dynamic>> topicos = [];

  double bottomMargin = 20.0;
  double rightMargin = 12.0;

  @override
  void initState() {
    super.initState();
    _carregarGrupos();
    _carregarTopicos();
  }

  void _carregarGrupos() async {
    Funcoes_Grupos funcoesgrupos = Funcoes_Grupos();
    List<Map<String, dynamic>> gruposCarregados =
        await funcoesgrupos.obterGruposPorArea(widget.id_area);
    setState(() {
      grupos = gruposCarregados;
      print("carregargrupos");
    });
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
      body: grupos.isEmpty
          ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/sem_grupos.png',
                          width:
                              80, 
                          height: 80,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Sem grupos !',
                          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 156, 156, 156)),
                        ),
                      ],
                    ),
                  )
          : ListView.builder(
              itemCount: grupos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: CARD_GRUPO(
                    cor:widget.cor_da_area,
                    grupo_id: grupos[index]['id'],
                  ),
                );
              },
            ),
      floatingActionButton: grupos.isNotEmpty ? _buildSpeedDial() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

Widget _buildSpeedDial() {
  return SpeedDial(
    //animatedIcon: AnimatedIcons.filter_list,
        icon: Icons.filter_alt_outlined,
        backgroundColor: widget.cor_da_area,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        curve: Curves.bounceIn,
        overlayColor: null,
        overlayOpacity: 0.0,
        buttonSize: const Size(150, 60),
        childrenButtonSize: const Size(150, 60), // Tamanho dos botões filhos
        children: [
          SpeedDialChild(
            child: Material(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: widget.cor_da_area),
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color.fromARGB(
                  255, 255, 255, 255), // Cor de fundo do botão
              child: Container(
                alignment: Alignment.center, // Alinhamento do texto
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_outlined,
                        color: widget.cor_da_area), 
                    SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                    Text(
                      'Filtrar por',
                      style: TextStyle(
                        color: widget.cor_da_area, // Cor do texto
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Peso da fonte do texto
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: widget.cor_da_area,
            onTap: () {
              _abrirFiltrarPor();
            },
          ),
          SpeedDialChild(
            child: Material(
              shape: RoundedRectangleBorder(
                side:  BorderSide(width: 1, color: widget.cor_da_area),
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color.fromARGB(
                  255, 255, 255, 255), // Cor de fundo do botão
              child: Container(
                alignment: Alignment.center, // Alinhamento do texto
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sort,
                        color: widget.cor_da_area), // Adiciona o ícone aqui
                    SizedBox(width: 8), // Espaçamento entre o ícone e o texto
                    Text(
                      'Ordenar por',
                      style: TextStyle(
                        color: widget.cor_da_area, // Cor do texto
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Peso da fonte do texto
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: widget.cor_da_area,
            onTap: () {
              _abrirOrdenarPor();
            },
          ),
          // Adicione mais botões conforme necessário
        ],
      );
}



  void _abrirOrdenarPor() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Ordenar Grupos por:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.3,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFCAC4D0),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Funcoes_Grupos funcoesgrupos = Funcoes_Grupos();
                        List<Map<String, dynamic>> gruposOrdenados =
                            await funcoesgrupos.consultaGrupos();
                        setState(() {
                          grupos = gruposOrdenados;
                          //print("Grupos ordenados:");
                          //for (var grupo in grupos) {
                          // print(grupo[
                          //   'nome']);
                          // }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 21, 20, 22),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/icon_destaque.png',
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Em Destaque',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        List<Map<String, dynamic>> gruposOrdenados =
                            List.from(grupos);
                        ordenarPorNumeroMembros(gruposOrdenados);
                        setState(() {
                          grupos = gruposOrdenados;
                          //print("Grupos ordenados:");
                          //for (var grupo in grupos) {
                          // print(grupo[
                          //   'nome']);
                          // }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF79747E),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: const SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_rounded,
                              color: Color(0xFF79747E),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mais Membros',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        List<Map<String, dynamic>> gruposOrdenados =
                            List.from(grupos);
                        ordenarPorDataCriacao(gruposOrdenados);
                        setState(() {
                          grupos = gruposOrdenados;
                          //print("Grupos ordenados:");
                          //for (var grupo in grupos) {
                          // print(grupo[
                          //   'nome']);
                          // }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF79747E),
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/icon_maisnovos.png',
                              width: 25,
                              height: 25,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Mais Novos',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontFamily: 'ABeeZee',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            )
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> ordenarPorNumeroMembros(
      List<Map<String, dynamic>> lista) {
    lista.sort((a, b) {
      if (a['numero_participantes'] != null &&
          b['numero_participantes'] != null) {
        return b['numero_participantes'].compareTo(a['numero_participantes']);
      }
      return 0;
    });
    return lista;
  }

  List<Map<String, dynamic>> ordenarPorDataCriacao(
      List<Map<String, dynamic>> lista) {
    lista.sort((a, b) {
      if (a['ano_criacao'] != null &&
          a['mes_criacao'] != null &&
          a['dia_criacao'] != null &&
          b['ano_criacao'] != null &&
          b['mes_criacao'] != null &&
          b['dia_criacao'] != null) {
        // Crie objetos DateTime para cada grupo
        DateTime dataA =
            DateTime(a['ano_criacao'], a['mes_criacao'], a['dia_criacao']);
        DateTime dataB =
            DateTime(b['ano_criacao'], b['mes_criacao'], b['dia_criacao']);

        // Compare as datas de criação
        return dataB.compareTo(dataA);
      }
      return 0;
    });
    return lista;
  }

  void _abrirFiltrarPor() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                      child: Text(
                        'Filtrar Grupos por:',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.3,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFCAC4D0),
                          ),
                        ),
                      ),
                    ),
                    for (var topico in topicos)
                      ElevatedButton(
                        onPressed: () async {
                          Funcoes_Grupos funcoesgrupos = Funcoes_Grupos();
                          List<Map<String, dynamic>> gruposOrdenados =
                              await funcoesgrupos.consultaGrupos();
                          grupos = gruposOrdenados;

                          List<Map<String, dynamic>> gruposDoTopico =
                              filtrarGruposPorTopico(grupos, topico['id']);
                          setState(() {
                            grupos = gruposDoTopico;
                          });

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 21, 20, 22),
                          backgroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15), // Adicionar espaçamento à esquerda
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  topico[
                                      'topico_imagem'], // Caminho da imagem do tópico
                                  width: 30,
                                  height: 30,
                                ),
                                const SizedBox(width: 15),
                                Text(
                                  topico['nome_topico'], // Nome do tópico
                                  style:  TextStyle(
                                    color: widget.cor_da_area,
                                    fontSize: 19,
                                    fontFamily: 'ABeeZee',
                                    fontWeight: FontWeight.w400,
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            )
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> filtrarGruposPorTopico(
      List<Map<String, dynamic>> grupos, int idTopico) {
    return grupos.where((grupo) => grupo['topico_id'] == idTopico).toList();
  }
}
