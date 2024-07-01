// ignore_for_file: use_key_in_widget_constructors, camel_case_types, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/carregar_partilha.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_partilhas.dart';
import 'package:ficha3/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/card_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/card_partilha_pequeno.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/Pagina_de_uma_partilha/pagina_de_uma_partilha.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';

class submenupartilhas extends StatefulWidget {
  final int id_area;
  final Color cor_da_area;

  submenupartilhas({
    required this.id_area,
    required this.cor_da_area,
  });
  @override
  _submenupartilhasState createState() => _submenupartilhasState();
}

class _submenupartilhasState extends State<submenupartilhas> {
  List<Map<String, dynamic>> partilhas = [];

  double bottomMargin = 20.0;
  double rightMargin = 12.0;
  Timer? _timerAPI;
  Timer? _timerDB;
  bool isLeft = false;

  void toggle() {
    setState(() {
      isLeft = !isLeft;
      print('isLeft: $isLeft');
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarPartilhasDaAPI();
    _carregarPartilhas();
    // _iniciarTimers();
  }

  void _iniciarTimers() {
    // Carregar partilhas da API a cada 30 segundos
    _timerAPI = Timer.periodic(
        Duration(seconds: 10), (Timer t) => _carregarPartilhasDaAPI());

    // Carregar partilhas da base de dados a cada 15 segundos
    _timerDB = Timer.periodic(
        Duration(seconds: 15), (Timer t) => _carregarPartilhas());
  }

  Future<void> _carregarPartilhasDaAPI() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        print('Sem conexão com a internet');
        return;
      }

      final centroProvider =
          Provider.of<Centro_Provider>(context, listen: false);
      final centroSelecionado = centroProvider.centroSelecionado;

      if (centroSelecionado != null) {
        print('Iniciando o carregamento dos dados das partilhas da API...');
        await ApiPartilhas().fetchAndStorePartilhas(centroSelecionado.id);
        print('Dados das partilhas da API carregados com sucesso.');
        print('Iniciando o carregamento dos comentários das partilhas...');
        await ApiPartilhas().fetchAndStoreComentarios();
        print('Dados dos comentários das partilhas carregados com sucesso.');
        print('Iniciando o carregamento dos likes das partilhas...');
        await ApiPartilhas().fetchAndStoreLikes(centroSelecionado.id);
        print('Dados dos likes das partilhas carregados com sucesso.');
        if (mounted) {
        setState(() {
          // Atualize seu estado aqui, se necessário
        });
      }
      } else {
        print('Nenhum centro selecionado');
      }
    } on SocketException catch (e) {
      print('Erro de rede: $e');
    } catch (e) {
      print('Erro: $e');
    }
  }

  void _carregarPartilhas() async {
    Funcoes_Partilhas funcoespartilhas = Funcoes_Partilhas();
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;

    if (centroSelecionado != null) {
      int centroId = centroSelecionado.id;

      List<Map<String, dynamic>> partilhasCarregadas = await funcoespartilhas
          .consultaPartilhasComAreaIdECentroId(widget.id_area, centroId);

      if (mounted) {
        setState(() {
          partilhas = partilhasCarregadas;
        });
      }
    } else {
      print('Nenhum centro selecionado');
      throw Exception('Nenhum centro selecionado');
    }
  }

  @override
  void dispose() {
    _timerAPI?.cancel();
    _timerDB?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: partilhas.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/sem_partilhas.png',
                    width: 80,
                    height: 80,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Ainda nao há partilhas !',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 156, 156, 156)),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                Positioned(
                  top: 3,
                  left: 10,
                  child: SizedBox(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: widget.cor_da_area,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: widget.cor_da_area, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        _abrirOrdenarPor();
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sort,
                            size: 20,
                          ), // Ícone
                          SizedBox(
                              width: 4), // Espaçamento entre o ícone e o texto
                          Text(
                            'Ordenar por',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 10,
                  child: SizedBox(
                    width: 100,
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLeft = true;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(5)),
                                border: Border.all(
                                    color: widget.cor_da_area, width: 1),
                                color: isLeft
                                    ? widget.cor_da_area.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                isLeft
                                    ? Icons.grid_view_rounded
                                    : Icons.grid_view_outlined,
                                color: widget.cor_da_area,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isLeft = false;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(5)),
                                border: Border.all(
                                    color: widget.cor_da_area, width: 1),
                                color: !isLeft
                                    ? widget.cor_da_area.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.menu_rounded,
                                color: widget.cor_da_area,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    //color: Colors.blue,
                    padding: const EdgeInsets.only(top: 50),
                    child: partilhas.isEmpty
                        ? const Center(
                            // código omitido por brevidade...
                            )
                        : SingleChildScrollView(
                            child: isLeft
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          3, // Define o número de itens por linha
                                      crossAxisSpacing:
                                          3, // Espaçamento entre os itens na horizontal
                                      mainAxisSpacing:
                                          3, // Espaçamento entre os itens na vertical
                                    ),
                                    itemCount: partilhas.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaginaDaPartilha(
                                                  cor: widget.cor_da_area,
                                                  idpartilha: partilhas[index]
                                                      ['id'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: CARD_PARTILHA_MINI(
                                            idpartilha: partilhas[index]['id'],
                                            context: context,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Column(
                                    children: List.generate(partilhas.length,
                                        (index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 30,
                                          right: 5,
                                          left: 5,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaginaDaPartilha(
                                                  cor: widget.cor_da_area,
                                                  idpartilha: partilhas[index]
                                                      ['id'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: CARD_PARTILHA(
                                            cor: widget.cor_da_area,
                                            idpartilha: partilhas[index]['id'],
                                            context: context,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                          ),
                  ),
                )
              ],
            ),
      floatingActionButton: SpeedDial(
        //animatedIcon: AnimatedIcons.filter_list,
        icon: Icons.file_upload_rounded,
        backgroundColor: widget.cor_da_area,
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
        curve: Curves.bounceIn,
        overlayColor: null,
        overlayOpacity: 0.0,
        buttonSize: Size(150, 60),
        childrenButtonSize: Size(150, 60),
        onPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CriarPartilha(
                cor: widget.cor_da_area,
                idArea: widget.id_area, // Passe o idArea necessário aqui
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                        'Ordenar Partilhas por:',
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
                        Funcoes_Partilhas funcoespartilhas =
                            Funcoes_Partilhas();
                        final centroProvider = Provider.of<Centro_Provider>(
                            context,
                            listen: false);
                        final centroSelecionado =
                            centroProvider.centroSelecionado;
                        int centroId = centroSelecionado!.id;
                        List<Map<String, dynamic>> partilhasOrdenadas =
                            await funcoespartilhas
                                .consultaPartilhasComAreaIdECentroId(
                                    widget.id_area, centroId);
                        setState(() {
                          partilhas = partilhasOrdenadas;
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
                        List<Map<String, dynamic>> partilhasOrdenados =
                            List.from(partilhas);
                        ordenarPorDataCriacao(partilhasOrdenados);
                        setState(() {
                          partilhas = partilhasOrdenados;
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
                              'Mais Recentes',
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
                        List<Map<String, dynamic>> partilhasOrdenadas =
                            List.from(partilhas);
                        ordenarPorCurtidas(partilhasOrdenadas);
                        setState(() {
                          partilhas = partilhasOrdenadas;
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
                              Icons.thumb_up_alt_rounded,
                              color: Color(0xFF79747E),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mais Curtidas',
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

  List<Map<String, dynamic>> ordenarPorDataCriacao(
      List<Map<String, dynamic>> lista) {
    lista.sort((a, b) {
      List<String> componentesA = extrairComponentesDataHora(a);
      List<String> componentesB = extrairComponentesDataHora(b);

      // Converter
      DateTime dataA = criarDateTime(componentesA);
      DateTime dataB = criarDateTime(componentesB);

      return dataB.compareTo(dataA);
    });
    return lista;
  }

  List<String> extrairComponentesDataHora(Map<String, dynamic> partilha) {
    String dataHora = '${partilha['data']} ${partilha['hora']}';
    return dataHora.split(' '); // Retorna uma lista separados
  }

  DateTime criarDateTime(List<String> componentes) {
    List<String> dataComponentes = componentes[0].split('/');
    int dia = int.parse(dataComponentes[0]);
    int mes = int.parse(dataComponentes[1]);
    int ano = int.parse(dataComponentes[2]);

    List<String> horaComponentes = componentes[1].split(':');
    int hora = int.parse(horaComponentes[0]);
    int minuto = int.parse(horaComponentes[1]);

    return DateTime(ano, mes, dia, hora, minuto);
  }

  List<Map<String, dynamic>> ordenarPorCurtidas(
      List<Map<String, dynamic>> lista) {
    lista.sort((a, b) {
      if (a['gostos'] != null && b['gostos'] != null) {
        return b['gostos'].compareTo(a['gostos']);
      }
      return 0;
    });
    return lista;
  }
}
