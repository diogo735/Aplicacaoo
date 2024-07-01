import 'package:ficha3/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/PAGINA_INICIAL/widget_cards/card_publicacoes.dart';
import 'package:provider/provider.dart';

class vertodos_publicacoes extends StatefulWidget {
  @override
  _vertodos_publicacoesState createState() => _vertodos_publicacoesState();
}

class _vertodos_publicacoesState extends State<vertodos_publicacoes> {
  List<Map<String, dynamic>> publicacoes = []; // Lista de eventos

  @override
  void initState() {
    super.initState();
    _carregarPublicacoes(); // Carregar eventos ao iniciar a tela
  }


  void _carregarPublicacoes() async {
    final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
    final centroSelecionado = centroProvider.centroSelecionado;
    int centroId = centroSelecionado!.id;
    Funcoes_Publicacoes funcoespublicacoes = Funcoes_Publicacoes();
    List<Map<String, dynamic>> publicacoesCarregadas =
        await funcoespublicacoes.consultaPublicacoesPorCentroId(centroId);
    setState(() {
      publicacoes = publicacoesCarregadas;
    });
  }



 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Publicações',
          style: TextStyle(
            fontSize: 24,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          )),
      backgroundColor: const Color(0xFF15659F),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Container(
      color: const Color.fromARGB(255, 233, 233, 233),
      child: DefaultTabController(
        length: 8, // Define o número de abas
        child: Column(
          children: [
            Container(
              color: Color.fromARGB(255, 255, 255, 255), // Cor de fundo da TabBar // Cor de fundo da TabBar
              child: TabBar(
                isScrollable: true,
                indicatorPadding: EdgeInsets.zero, // Torna a TabBar deslizável
                labelColor: Colors.black, // Cor do texto da aba selecionada
                unselectedLabelColor: Colors.black.withOpacity(0.4),
                indicatorColor: const Color(0xFF15659F),
                tabs: [
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.format_list_bulleted_rounded,
                            color: Color(0xFF15659F)),
                        SizedBox(width: 8),
                        Text(
                          "Todos",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monitor_heart_rounded,
                            color: Color(0xFF15659F)),
                        SizedBox(width: 8),
                        Text(
                          "Saude",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.rotate(
                          angle: 135 * 3.14 / 180,
                          child: const Icon(
                            Icons.fitness_center_rounded,
                            color: Color(0xFF15659F),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Desporto",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant, color: Color(0xFF15659F)),
                        SizedBox(width: 8),
                        Text(
                          "Gastronomia",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded, color: Color(0xFF15659F)),
                        SizedBox(width: 8),
                        Text(
                          "Formação",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.house_rounded, color: Color(0xFF15659F)),
                        SizedBox(width: 8),
                        Text(
                          "Alojamento",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_bus, color: Color(0xFF15659F)),
                        SizedBox(width: 8),
                        Text(
                          "Trasnportes",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.forest_rounded, color: Color(0xFF15659F)),
                        SizedBox(width: 8),
                        Text(
                          "Lazer",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ),
              ),
           Expanded(
              child: TabBarView(
                children: [
                  // Conteúdo da aba 1
                  Container(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                      child: !publicacoes.any((publicacao) => publicacao['area_id'] == 1)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Saude\n'
                                   'ainda nao tem publicações !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        if(publicacoes[index]['area_id']==1){
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                   Container(
                      child: !publicacoes.any((publicacao) => publicacao['area_id'] == 2)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Desporto\n'
                                    'ainda nao tem publicações !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        if(publicacoes[index]['area_id']==2){
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                   Container(
                      child: !publicacoes.any((publicacao) => publicacao['area_id'] == 3)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Gastronomia\n'
                                    'ainda nao tem publicações !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          :ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        if(publicacoes[index]['area_id']==3){
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                   Container(
                      child: !publicacoes.any((publicacao) => publicacao['area_id'] == 4)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Formação\n'
                                    'ainda nao tem publicações !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        if(publicacoes[index]['area_id']==4){
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                   Container(
                      child: !publicacoes.any((publicacao) => publicacao['area_id'] == 5)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Alojamento\n'
                                   'ainda nao tem publicações !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        if(publicacoes[index]['area_id']==5){
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                   Container(
                      child: !publicacoes.any((publicacao) => publicacao['area_id'] == 6)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Transportes\n'
                                    'ainda nao tem publicações !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          :ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        if(publicacoes[index]['area_id']==6){
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                   Container(
                      child: !publicacoes.any((publicacao) => publicacao['area_id'] == 7)
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/no_events.png',
                                    width: 50,
                                    height: 50,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Lazer\n'
                                    'ainda nao tem publicações !\n',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: publicacoes.length,
                      itemBuilder: (context, index) {
                        if(publicacoes[index]['area_id']==7){
                        return Container(
                          margin: const EdgeInsets.only(
                              left: 4, right: 10, top: 22),
                          child: CARD_PUBLICACAO(
                            nomePublicacao: publicacoes[index]['nome'],
                            local: publicacoes[index]['local'],
                            classificacao_media:
                                publicacoes[index]['classificacao_media'].toString(),
                            imagePath: publicacoes[index]['caminho_imagem'],
                            
                          ),
                        );
                        }else{
                          return SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}