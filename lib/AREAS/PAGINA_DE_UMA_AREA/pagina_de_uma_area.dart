import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areafavoritas_douser.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areas.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/sub_menu_eventos.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_forum/sub_menu_forum.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_grupos/sub_menu_grupos.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/sub_menu_partilhas.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_topicos/sub_menu_topicos.dart';
import 'package:provider/provider.dart';

class Pag_de_uma_area extends StatefulWidget {
  final int id_area;
  final Color cor_da_area;

  const Pag_de_uma_area(
      {Key? key, required this.id_area, required this.cor_da_area})
      : super(key: key);

  @override
  _Pag_de_uma_areaState createState() => _Pag_de_uma_areaState();
}

class _Pag_de_uma_areaState extends State<Pag_de_uma_area> {
  bool isFavorited = false;
  String nome_Da_Area = '';

  @override
  void initState() {
    super.initState();
    _carregarNomeArea();
    _verificarSeFavorita();
  }

  void _verificarSeFavorita() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final user_id = usuarioProvider.usuarioSelecionado!.id_user;

    List<int> areasFavoritas =
        await Funcoes_AreasFavoritas.obeter_areas_favoritas_do_userid(user_id);

    setState(() {
      isFavorited = areasFavoritas.contains(widget.id_area);
    });
  }

void toggleFavorite() async {
  // Verifica a conexão com a internet
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8.0),
            Text('Sem conexão com a internet.'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
    return; // Sai da função se não houver conexão com a internet
  }

  print('Botão de estrela foi clicado');
  final usuarioProvider = Provider.of<Usuario_Provider>(context, listen: false);
  final user_id = usuarioProvider.usuarioSelecionado!.id_user;

  // Primeiro, verifica se a área já está marcada como favorita
  List<int> areasFavoritas = await Funcoes_AreasFavoritas.obeter_areas_favoritas_do_userid(user_id);
  bool currentlyFavorited = areasFavoritas.contains(widget.id_area);

  print('Estado atual: $currentlyFavorited');

  setState(() {
    isFavorited = !isFavorited;
  });

  print('Novo estado de isFavorited: $isFavorited');

  try {
    if (isFavorited) {
      bool sucesso = await ApiUsuarios().inserirAreaFavorita(user_id, widget.id_area);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.star_rounded, color: Colors.white),
                const SizedBox(width: 8.0),
                Text('"$nome_Da_Area" marcada como área favorita!'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          isFavorited = false;
        });
      }
    } else {
      bool sucesso = await ApiUsuarios().removerAreaFavorita(user_id, widget.id_area);
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.star_outline, color: Colors.white),
                const SizedBox(width: 8.0),
                Text('"$nome_Da_Area" removida das áreas favoritas.'),
              ],
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() {
          isFavorited = true;
        });
      }
    }
  } catch (e) {
    // Tratamento de exceções relacionadas à rede
    print('Erro ao tentar alterar a área favorita: $e');
    setState(() {
      isFavorited = !isFavorited; // Reverte a mudança no estado
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8.0),
            
            Text('Falha ao conectar ao servidor.'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }
}




  void _carregarNomeArea() async {
    Funcoes_Areas funcoesAreas = Funcoes_Areas();
    String? nome = await funcoesAreas.getNomeAreaPorId(widget.id_area);
    setState(() {
      nome_Da_Area = nome ?? 'not fund';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Número de abas
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(140.0),
          // Ajuste a altura conforme necessário
          child: Column(
            children: [
              AppBar(
                backgroundColor: widget.cor_da_area,
                iconTheme: const IconThemeData(color: Colors.white),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorited ? Icons.star : Icons.star_outline,
                      color: Colors.white,
                    ),
                    onPressed: toggleFavorite,
                  ),
                ],
              ),
              FractionallySizedBox(
                widthFactor: 1.0,
                child: Container(
                  height: 84,
                  color: widget.cor_da_area,
                  child: Column(
                    children: [
                      Text(
                        nome_Da_Area,
                        style: const TextStyle(
                          fontSize: 30,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Color(0xFF23FF00),
                          ),
                          SizedBox(
                              width: 5), // Espaço entre o círculo e o texto
                          Text(
                            '18 users online',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF6F6F6),
        body: Column(
          children: <Widget>[
            Align(
              alignment: const Alignment(0, 0),
              child: Material(
                color: const Color.fromARGB(
                    255, 255, 255, 255), // Cor de fundo da TabBar
                child: TabBar(
                  isScrollable: true,
                  indicatorPadding: EdgeInsets.zero,
                  labelColor: Colors.black, // Cor do texto da aba selecionada
                  unselectedLabelColor: Colors.black.withOpacity(0.4),
                  // Cor do texto das abas não selecionadas com 70% de opacidade
                  indicatorColor: widget.cor_da_area,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  labelStyle: const TextStyle(
                    // Definindo a fonte para o labelStyle
                    letterSpacing: 0,
                  ), // Cor do indicador da aba selecionada
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Para alinhar ícones e texto corretamente
                        children: [
                          Icon(Icons.forum, color: widget.cor_da_area),
                          const SizedBox(
                              width: 8), // Espaço entre ícone e texto
                          const Text(
                            "Fórum",
                            style: TextStyle(
                              fontSize: 16, // Aumenta o tamanho do texto
                              fontWeight: FontWeight
                                  .w500, // Define o estilo da fonte para medium
                            ),
                          ),
                        ],
                      ),
                    ), // Texto para a primeira aba
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Para alinhar ícones e texto corretamente
                        children: [
                          Icon(Icons.group,
                              color: widget.cor_da_area), // Muda a cor do ícone
                          const SizedBox(
                              width: 8), // Espaço entre ícone e texto
                          const Text(
                            "Grupos",
                            style: TextStyle(
                              fontSize: 16, // Aumenta o tamanho do texto
                              fontWeight: FontWeight
                                  .w500, // Define o estilo da fonte para medium
                            ),
                          ),
                        ],
                      ),
                    ), // Texto para a segunda aba
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Para alinhar ícones e texto corretamente
                        children: [
                          Icon(Icons.collections_outlined,
                              color: widget.cor_da_area), // Muda a cor do ícone
                          const SizedBox(
                              width: 8), // Espaço entre ícone e texto
                          const Text(
                            "Album de Partilhas",
                            style: TextStyle(
                              fontSize: 16, // Aumenta o tamanho do texto
                              fontWeight: FontWeight
                                  .w500, // Define o estilo da fonte para medium
                            ),
                          ),
                        ],
                      ),
                    ), // Texto para a terceira aba
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Para alinhar ícones e texto corretamente
                        children: [
                          Icon(Icons.calendar_month,
                              color: widget.cor_da_area), // Muda a cor do ícone
                          const SizedBox(
                              width: 8), // Espaço entre ícone e texto
                          const Text(
                            "Eventos",
                            style: TextStyle(
                              fontSize: 16, // Aumenta o tamanho do texto
                              fontWeight: FontWeight
                                  .w500, // Define o estilo da fonte para medium
                            ),
                          ),
                        ],
                      ),
                    ), // Texto para a quarta aba
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: -90 *
                                3.14159265359 /
                                180, // Ângulo de rotação em radianos (45 graus)
                            child: Icon(Icons.web_stories,
                                color: widget.cor_da_area),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Tópicos",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Container(
                    child: SubmenuForum(
                      id_area: widget.id_area,
                      cor_da_area: widget.cor_da_area,
                    ),
                  ),
                  Container(
                    child: submenugrupos(
                      id_area: widget.id_area,
                      cor_da_area: widget.cor_da_area,
                    ),
                  ),
                  Container(
                    child: submenupartilhas(
                      id_area: widget.id_area,
                      cor_da_area: widget.cor_da_area,
                    ),
                  ),
                  Container(
                      child: submenueventos(
                    id_area: widget.id_area,
                    cor_da_area: widget.cor_da_area,
                  ) //
                      ),
                  Container(
                    child: submenutopicos(
                      id_area: widget.id_area,
                      cor_da_area: widget.cor_da_area,
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
