import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';

class PaginaEvento extends StatefulWidget {
  final int idEvento;

  const PaginaEvento({super.key, required this.idEvento});

  @override
  _PaginaEventoState createState() => _PaginaEventoState();
}

class _PaginaEventoState extends State<PaginaEvento> {
  late String nomeEvento = '';
  late String dia = '';
  late String mes = '';
  late String ano = '';
  late String horas = '';
  late String local = '';
  late String numeroParticipantes = '';
  late String imagePath = '';
  late int idArea = 0;
  late String tipoEvento = '';

  @override
  void initState() {
    super.initState();
    _carregarDetalhesEvento();
  }

  Future<void> _carregarDetalhesEvento() async {
    try {
      List<Map<String, dynamic>> resultado =
          await Funcoes_Eventos.consultaDetalhesEventoPorId(widget.idEvento);
      if (resultado.isNotEmpty) {
        final evento = resultado.first;
        setState(() {
          nomeEvento = evento['nome'];
          dia = evento['dia_realizacao'].toString();
          mes = _obterNomeMes(evento['mes_realizacao']);
          ano = evento['ano_realizacao'].toString();
          horas = evento['horas'];
          local = evento['local'];
          numeroParticipantes = evento['numero_inscritos'].toString();
          imagePath = evento['caminho_imagem'];
          idArea = evento['area_id']; // Adiciona esta linha
          tipoEvento = evento['tipodeevento_id']
              .toString(); // Pode mapear para o nome do tipo se necessário
        });
      }
    } catch (e) {
      // Lidar com o erro
      print('Erro ao carregar detalhes do evento: $e');
    }
  }

  Color getCorPorAreaId(int idArea) {
    switch (idArea) {
      case 1:
        return const Color(0xFF8F3023); // Saúde
      case 2:
        return const Color(0xFF53981D); // Desporto
      case 3:
        return const Color(0xFFA91C7A); // Gastronomia
      case 4:
        return const Color(0xFF3779C6); // Formação
      case 5:
        return const Color(0xFF815520); // Alojamento
      case 6:
        return const Color(0xFFB7BB06); // Transportes
      case 7:
        return const Color(0xFF25ABAB); // Lazer
      default:
        return const Color(0xFF15659F); // Cor padrão
    }
  }

  String _obterNomeMes(int mes) {
    switch (mes) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Evento',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            )),
        backgroundColor: getCorPorAreaId(idArea),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: IconButton(
              padding: const EdgeInsets.all(3),
              icon: const Icon(Icons.share),
              onPressed: () {},
              iconSize: 23,
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 242, 242, 242),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //////////////imagem
            if (imagePath.isNotEmpty)
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 3.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(imagePath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: MediaQuery.of(context).size.height /
                          (3.5 * 10), // Altura do contêiner vermelho
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 242, 242, 242),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //const SizedBox(height: 10),//////////nome
                  Text(
                    nomeEvento,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
////////horas
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          color: getCorPorAreaId(idArea)),
                      const SizedBox(width: 5),
                      Text(
                        '$dia de $mes $ano',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                          width: 20), // Espaçamento entre data e hora
                      Icon(Icons.access_time_filled_rounded,
                          color: getCorPorAreaId(idArea)),
                      const SizedBox(width: 5),
                      Text(
                        '$horas',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.location_on,
                          color: getCorPorAreaId(idArea),
                          size: 25,
                        ),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Text(
                        'Localização',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      '$local',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Adicione aqui a ação do botão
                        },
                        icon: Image.asset(
                          'assets/images/local_vermapa.png', // Caminho da imagem nos assets
                          width: 20, // Largura da imagem
                          height: 20, // Altura da imagem
                          color:
                              Colors.white, // Se você quiser colorir a imagem
                        ),
                        label: Text(
                          'Ver no Mapa',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF53981D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10), // Padding interno
                        ),
                      )),

                  Text(
                    'Número de Participantes: $numeroParticipantes',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tipo de Evento: $tipoEvento',
                    style: const TextStyle(fontSize: 16),
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
