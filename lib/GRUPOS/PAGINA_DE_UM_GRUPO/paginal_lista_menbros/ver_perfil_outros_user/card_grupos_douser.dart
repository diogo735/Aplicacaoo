import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';

Widget CARD_GRUPOS_USER({
  required int grupo_id,
}) {
  return FutureBuilder<Map<String, dynamic>?>(
    future: Funcoes_Grupos.obterGrupoPorId(grupo_id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else {
          final grupo = snapshot.data;
          if (grupo != null) {
            final Map<String, String> detalhesGrupo =
                _obterDetalhesGrupo(grupo);
            return Container(
              height: 75,
              
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            detalhesGrupo['caminhoImagem'] ??
                                'assets/images/ver_info.png',
                            width: 90,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 20,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detalhesGrupo['nomeGrupo'] ?? '',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.15,
                              )),
                          Text(
                              '${detalhesGrupo['numeroParticipantes']} membros',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w300,
                               
                                letterSpacing: 0.15,
                              )),
                        ],
                      ),
                    
                    ],
                  ),
                ],
              ),
            );
          } else {
            return Text('Grupo não encontrado');
          }
        }
      } else {
        return Container();
      }
    },
  );
}

Map<String, String> _obterDetalhesGrupo(Map<String, dynamic> grupo) {
  final String nomeGrupo = grupo['nome'] ?? '';
  final String numeroParticipantes =
      grupo['numero_participantes']?.toString() ?? '';
  final String caminhoImagem = grupo['caminho_imagem'] ?? '';

  return {
    'nomeGrupo': nomeGrupo,
    'numeroParticipantes': numeroParticipantes,
    'caminhoImagem': caminhoImagem,
  };
}
