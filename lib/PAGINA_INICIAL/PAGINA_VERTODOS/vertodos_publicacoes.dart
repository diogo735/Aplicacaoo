import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_imagens_de_publicacoes.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/PAGINA_INICIAL/widget_cards/card_publicacoes.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class vertodos_publicacoes extends StatefulWidget {
  @override
  _vertodos_publicacoesState createState() => _vertodos_publicacoesState();
}

class _vertodos_publicacoesState extends State<vertodos_publicacoes> {
  List<Map<String, dynamic>> publicacoes = [];
  Map<int, String> imagemPaths =
      {}; // Mapeia publicacao_id para o caminho da imagem
  double _latitude = 0;
  double _longitude = 0;
  @override
  void initState() {
    super.initState();
    _carregarPublicacoes(); // Carregar publicações ao iniciar a tela
  }

Future<void> _getLocation() async {
  Localizacao localizacao = Localizacao();
  try {
    // Obter a posição atual do dispositivo
    Position position = await localizacao.determinaposicao();

    // Atualizar o estado com as coordenadas obtidas
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  } catch (e) {
    print("Erro ao obter a localização: $e");
  }
}
 void _carregarPublicacoes() async {
  await _getLocation();
  Funcoes_Publicacoes funcoesPublicacoes = Funcoes_Publicacoes();
  Funcoes_Publicacoes_Imagens funcoesPublicacoesImagens = Funcoes_Publicacoes_Imagens();
  final centroProvider = Provider.of<Centro_Provider>(context, listen: false);
  final centroSelecionado = centroProvider.centroSelecionado;
  int centroId = centroSelecionado!.id;

  // Crie uma lista mutável a partir da lista retornada
  List<Map<String, dynamic>> publicacoesCarregadas = (await funcoesPublicacoes.consultaPublicacoesPorCentroId(centroId))
      .map((publicacao) => Map<String, dynamic>.from(publicacao))
      .toList();

  for (var publicacao in publicacoesCarregadas) {
    Map<String, dynamic>? primeiraImagem = await funcoesPublicacoesImagens.retorna_primeira_imagem(publicacao['id']);
    imagemPaths[publicacao['id']] = primeiraImagem != null ? primeiraImagem['caminho_imagem'] : 'assets/images/sem_imagem.png';

    String local = publicacao['local'];

    // Obter coordenadas do local da publicação
    Map<String, double> coordenadas = await LocalizacaoOSM().getCoordinatesFromName(local);

    // Salvar as coordenadas na publicação
    publicacao['latitude'] = coordenadas['latitude'];
    publicacao['longitude'] = coordenadas['longitude'];

    // Calcular a distância entre o usuário e o local da publicação
    double distance = calculateDistance(_latitude, _longitude, coordenadas['latitude']!, coordenadas['longitude']!);

    // Armazenar a distância formatada como string na publicação
    publicacao['distance'] = "${distance.toStringAsFixed(1)} Km";  // Certifique-se de que a distância é armazenada como String
  }

  if (!mounted) return;
  setState(() {
    publicacoes = publicacoesCarregadas;
  });
}


   double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    // Calcula a distância em metros
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);
    // Converte para quilômetros e arredonda para uma casa decimal
    double distanceInKilometers =
        double.parse((distanceInMeters / 1000).toStringAsFixed(1));
    return distanceInKilometers;
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
                color: const Color.fromARGB(255, 255, 255, 255),
                child: TabBar(
                  isScrollable: true,
                  indicatorPadding: EdgeInsets.zero,
                  labelColor: Colors.black,
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
                          Icon(Icons.menu_book_rounded,
                              color: Color(0xFF15659F)),
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
                            "Transportes",
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
                    _buildTabContent(), // Todos
                    _buildTabContent(areaId: 2), // Saúde
                    _buildTabContent(areaId: 1), // Desporto
                    _buildTabContent(areaId: 3), // Gastronomia
                    _buildTabContent(areaId: 4), // Formação
                    _buildTabContent(areaId: 7), // Alojamento
                    _buildTabContent(areaId: 6), // Transportes
                    _buildTabContent(areaId: 5), // Lazer
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent({int? areaId}) {
    List<Map<String, dynamic>> filteredPublicacoes = areaId == null
        ? publicacoes
        : publicacoes
            .where((publicacao) => publicacao['area_id'] == areaId)
            .toList();

    if (filteredPublicacoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_events.png',
              width: 50,
              height: 50,
            ),
            const SizedBox(height: 8),
            Text(
              areaId == null
                  ? 'Não há publicações disponíveis.'
                  : 'A categoria selecionada ainda não tem publicações!',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPublicacoes.length,
      itemBuilder: (context, index) {
        int publicacaoId = filteredPublicacoes[index]['id'];
        String imagePath =
            imagemPaths[publicacaoId] ?? 'assets/images/sem_imagem.png';

        return Container(
          margin: const EdgeInsets.only(left: 4, right: 10, top: 22),
          child: CARD_PUBLICACAO(
            nomePublicacao: filteredPublicacoes[index]['nome'],
            local: filteredPublicacoes[index]['local'],
            publicacaoId: publicacaoId,
            classificacao_media:
                filteredPublicacoes[index]['classificacao_media'].toString(),
            imagePath: imagePath,
         distancia: publicacoes[index]['distance']
                                as String, 
          ),
        );
      },
    );
  }
}
