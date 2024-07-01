import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';

Widget CARD_GRUPO({
  required Color cor,
  required int grupo_id,
}) {
  return FutureBuilder<Map<String, String>>(
    future: _obterDetalhesGrupo(grupo_id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else {
          final detalhesGrupo = snapshot.data;
          if (detalhesGrupo != null) {
            return Container(
              height: 105,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    
                    color: const Color.fromARGB(255, 176, 176, 176)
                        .withOpacity(0.5), // Cor da sombra
                    spreadRadius: 0.5, // Raio de propagação da sombra
                    blurRadius: 7, // Raio de desfoque da sombra
                    offset: const Offset(0, 0.5), // Deslocamento da sombra
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: Image.asset(
                        detalhesGrupo['caminhoImagem'] ??
                            'assets/images/ver_info.png',
                        width: 105,
                        height: 105,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detalhesGrupo['nomeGrupo'] ?? '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w700,
                                height: 0.06,
                                letterSpacing: 0.15,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  detalhesGrupo['nomeTopico'] ?? '',
                                  style: TextStyle(
                                    color: cor,
                                    fontSize: 13,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration:  BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: cor,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${detalhesGrupo['numeroParticipantes']} membros',
                                  style:  TextStyle(
                                    color: cor,
                                    fontSize: 13,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 9,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 8), // Espaçamento à direita
                              child: Align(
                                alignment: Alignment
                                    .bottomRight, // Alinha o botão à direita
                                child: ElevatedButton(
                                  onPressed: () {
                                    ////////////
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    minimumSize: const Size(115, 32),
                                  ),
                                  child: const Text(
                                    'Juntar-se',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Text('Dados do grupo não encontrados.');
          }
        }
      }
      return const CircularProgressIndicator(); // ou outro widget de carregamento
    },
  );
}

Future<Map<String, String>> _obterDetalhesGrupo(int grupo_id) async {
  final grupo = await Funcoes_Grupos.obterGrupoPorId(grupo_id);
  if (grupo != null) {
    final String nomeGrupo = grupo['nome'] ?? '';
    final String numeroParticipantes =
        grupo['numero_participantes']?.toString() ?? '';
    final String caminhoImagem = grupo['caminho_imagem'] ?? '';
    final int topicoIdGrupo = grupo['topico_id'] ?? 0;
    String nomeTopico = '';

    // Verifica se o ID do tópico é válido (diferente de zero)
    if (topicoIdGrupo != 0) {
      String? nomeTopicoNullable =
          await Funcoes_Topicos.obternomedoTopico(topicoIdGrupo);
      nomeTopico = nomeTopicoNullable ??
          ''; // Se nomeTopicoNullable for nulo, atribui uma string vazia
     // print('Nome do grupo: $nomeGrupo');
     // print('Nome do tópico: $nomeTopico');
    }

    return {
      'nomeTopico': nomeTopico,
      'numeroParticipantes': numeroParticipantes,
      'caminhoImagem': caminhoImagem,
      'nomeGrupo': nomeGrupo
    };
  } else {
    // Retorne um mapa vazio caso o grupo seja nulo
    return {};
  }
}
