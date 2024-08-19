import 'dart:io';
import 'package:device_calendar/device_calendar.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_geolocaliza%C3%A7%C3%A3o.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_tipodeevento.dart';

Widget CARD_EVENTO_VERTODOS({
  required BuildContext context,
  required int id,
  required int id_topico,
  required String nomeEvento,

  required int dia,
  mes,
  ano,
  required String horas,
  required String imagePath,
  required int tipo_evento,
}) {
  String formatarData(int dia, int mes, int ano) {
    List<String> meses = [
      '', // Mês 0 não é utilizado
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    String nomeMes = meses[mes];
    return '$dia de $nomeMes, $ano';
  }

  Future<String> _getAddressUsingOSM(double latitude, double longitude) async {
    LocalizacaoOSM localizacaoOSM = LocalizacaoOSM();
    return await localizacaoOSM.getEnderecoFromCoordinates(latitude, longitude);
  }

 Future<Map<String, dynamic>> _obterDadosEventoETopico(
    int tipo_evento, int idTopico, int idEvento) async {
  // Carrega os dados do tipo de evento
  Map<String, String> dadosTipoEvento =
      await Funcoes_TipodeEvento.obterDadosTipoEventoComleto(tipo_evento);

  // Carrega os dados do tópico
  Map<String, String> dadosTopico =
      await Funcoes_Topicos.obterDadosTopico(idTopico);

  // Carrega os detalhes do evento
  Map<String, dynamic>? detalhesEvento =
      await Funcoes_Eventos.consultaDetalhesEventoPorId2(idEvento);

  // Se os detalhes do evento não forem encontrados, retorne os dados básicos
  if (detalhesEvento == null) {
    return {
      'nomeTipoEvento': dadosTipoEvento['nome_tipo']!,
      'imagemTipoEvento': dadosTipoEvento['caminho_imagem']!,
      'nomeTopico': dadosTopico['nome']!,
      'imagemTopico': dadosTopico['imagem']!,
      'morada': 'Morada desconhecida',
      'numeroParticipantes': 0,
    };
  }

  // Carrega a morada usando as coordenadas
  double latitude = detalhesEvento['latitude'];
  double longitude = detalhesEvento['longitude'];
  String morada = await _getAddressUsingOSM(latitude, longitude);

  // Carrega o número de participantes
  int numeroParticipantes = await Funcoes_Participantes_Evento.getNumeroDeParticipantes(idEvento);

  // Retorne todos os dados necessários
  return {
    'nomeTipoEvento': dadosTipoEvento['nome_tipo']!,
    'imagemTipoEvento': dadosTipoEvento['caminho_imagem']!,
    'nomeTopico': dadosTopico['nome']!,
    'imagemTopico': dadosTopico['imagem']!,
    'numeroParticipantes': numeroParticipantes,
    'morada': morada,
    ...detalhesEvento,
  };
}




return FutureBuilder<Map<String, dynamic>>(
  future: _obterDadosEventoETopico(tipo_evento, id_topico, id),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
     print("11111"); 
     return Center(
        
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 5),
          child: const CircularProgressIndicator(
            color: Color(0xFF15659F),
          ),
        ),
      );
    } else if (snapshot.hasError) {
      return Text('Erro: ${snapshot.error}');
    } else {
      if (snapshot.hasData) {
        final String nomeTipoEvento = snapshot.data!['nomeTipoEvento'] ?? 'N/A';
        final String imagemTipoEvento = snapshot.data!['imagemTipoEvento'] ?? '';
        final String nomeTopico = snapshot.data!['nomeTopico'] ?? 'N/A';
        final String imagemTopico = snapshot.data!['imagemTopico'] ?? '';
        final String morada = snapshot.data!['morada'] ?? 'N/A';
        final int numeroParticipantes = snapshot.data!['numeroParticipantes'] ?? 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaginaEvento(
                  idEvento: id,
                ),
              ),
            );
          },
          child: _buildEventoWidget(
            context: context,
            local: morada,
            nomeEvento: nomeEvento,
            data: formatarData(dia, mes, ano),
            horas: horas,
            imagePath: imagePath,
            nomeTopico: nomeTopico,
            imagemTopico: imagemTopico,
            imagemTipoEvento: imagemTipoEvento,
            nometipoEvento: nomeTipoEvento,
            numeroParticipantes: numeroParticipantes,
          ),
        );
      } else {
        return const Text('Nenhum dado encontrado.');
      }
    }
  },
);


}

Widget _buildEventoWidget({
  required BuildContext context,
  required String nomeEvento,
  required String data,
  required int numeroParticipantes,
  required String local,
  required String horas,
  required String imagePath,
  required String nometipoEvento,
  required String nomeTopico,
  required String imagemTopico,
  required String imagemTipoEvento,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 5.0),
    child: Stack(
      children: [
        // Container para a sombra
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: MediaQuery.of(context).size.width - 10,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Cor da sombra
                spreadRadius: 0.5, // Raio de propagação da sombra
                blurRadius: 7, // Raio de desfoque da sombra
                offset: const Offset(0, 0.5), // Deslocamento da sombra
              ),
            ],
            borderRadius: BorderRadius.circular(5), // Borda arredondada
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Column(
              children: [
                // Parte superior com a imagem
                Container(
                  height: 220, // Altura da imagem
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(imagePath)),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                  ),
                  foregroundDecoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.10),
                    backgroundBlendMode: BlendMode.multiply,
                  ),
                ),
                // Parte inferior com o texto
                Container(
                  color: const Color.fromARGB(255, 255, 255, 255)
                      .withOpacity(0.35),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 10,
                        runSpacing:
                            5, // Espaçamento entre as linhas (caso precise quebrar para uma nova linha)
                        children: [
                          // Primeiro IntrinsicWidth
                          IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFF15659F)),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.file(
                                    File(imagemTopico),
                                    width: 20,
                                    height: 20,
                                    color: const Color(0xFF15659F),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    nomeTopico,
                                    style: const TextStyle(
                                      color: Color(0xFF15659F),
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Segundo IntrinsicWidth
                          IntrinsicWidth(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 1, color: Color(0xFF15659F)),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.file(
                                    File(imagemTipoEvento),
                                    width: 20,
                                    height: 20,
                                    color: const Color(0xFF15659F),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    nometipoEvento,
                                    style: const TextStyle(
                                      color: Color(0xFF15659F),
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        nomeEvento,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 10),
                      // Data e horário
                      Row(
                        children: [
                          Text(
                            data,
                            style: const TextStyle(
                              color: Color(0xFF15659F),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0.09,
                              letterSpacing: 0.15,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 4.83,
                            height: 4.83,
                            decoration: const BoxDecoration(
                              color: Color(0xFF15659F),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            horas,
                            style: const TextStyle(
                              color: Color(0xFF15659F),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              height: 0.09,
                              letterSpacing: 0.15,
                            ),
                          )
                        ],
                      ),
                      // Local do evento
                      const SizedBox(height: 15),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xB21D1B20),
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                local.length > 30 ? '${local.substring(0, 30)}...' : local,
                                style: const TextStyle(
                                  color: Color(0xB21D1B20),
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 0.09,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
                          ),
                           Row(
                            children: [
                              Text(
                               '$numeroParticipantes',
                                style: const TextStyle(
                                  color: Color(0xFF1D1B20),
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                  height: 0.09,
                                  letterSpacing: 0.15,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.people_alt_rounded,
                                color: Color(0xFF15659F),
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
