import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_partilhasfotos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_publicacoes.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/Pagina_de_uma_partilha/pagina_de_uma_partilha.dart';

Widget CARD_PARTILHA({
  required Color cor,
  required int idpartilha,
  required BuildContext context,
}) {
  late String titulo = "";
  late int? idUsuario;
  late int? idEvento;
  late int? idLocal;
  late String nomeCompleto = "";
  late String caminhoFotoUser = "";
  late String imagem_Da_partilha = "";
  late String capa_evento = "";
  late String nomeEvento = "";
  late int diaEvento = 0;
  late int mesEvento = 0;
  late String gostos_ = '99';
  late int numeroParticipantes = 0;
  late String nomeLocal = "";
  late String classlocal = "";
  late String moradalocal = "";
  late String capa_locla = "";
  late String hora_partilha = "";
  late String data_partilha = "";

  Future<void> buscarDetalhesPartilha(int idPartilha) async {
    Funcoes_Partilhas funcoesPartilhas = Funcoes_Partilhas();
    Map<String, dynamic> detalhesPartilha =
        await funcoesPartilhas.buscarDetalhesPartilha(idPartilha);

    titulo = detalhesPartilha['titulo'];
    idUsuario = detalhesPartilha['id_usuario'];
    imagem_Da_partilha = detalhesPartilha['caminho_imagem'];

    //gostos_ = detalhesPartilha['gostos'].toString();
    // Converta a string de 'createdAt' em um objeto DateTime
    DateTime createdAt = DateTime.parse(detalhesPartilha['data']);

    // Separe a data e a hora usando o objeto DateTime
    data_partilha =
        "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}";
    hora_partilha =
        "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";

    if (idUsuario != null) {
      nomeCompleto =
          await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(idUsuario!);
      caminhoFotoUser =
          await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(idUsuario!);
    }
  }

  String converter_mes(int numeroMes) {
    switch (numeroMes) {
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

  return FutureBuilder(
    future: buscarDetalhesPartilha(idpartilha),
    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return const Text('Erro ao carregar os detalhes da partilha');
      } else {
        return Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5),
          child: IntrinsicHeight(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Cor da sombra
                    spreadRadius: 2, // Raio de difusão
                    blurRadius: 4, // Raio de desfoque
                    offset: const Offset(0, 4), // Offset da sombra
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 10),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: FileImage(File(caminhoFotoUser)),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nomeCompleto,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$data_partilha ás $hora_partilha',
                                  style: const TextStyle(
                                    color: Color.fromARGB(182, 121, 116, 126),
                                    fontSize: 11,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Positioned(
                              top: 1.0,
                              right: 1,
                              child: Row(
                                children: [
                                  PopupMenuButton(
                                    itemBuilder: (BuildContext context) {
                                      return <PopupMenuEntry>[
                                        const PopupMenuItem(
                                          child: Text('Denunciar'),
                                        ),
                                      ];
                                    },
                                    icon: const Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ), /////////////////////////////////////////////imigem
                  SizedBox(
                      width: double.infinity,
                      child: Image.file(
                        File(imagem_Da_partilha),
                        fit: BoxFit.cover,
                      )),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        color: Color(0xFF49454F),
                        fontSize: 16,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),
                  /* Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                            width: 0.5, color: Colors.grey), // Linha superior
                        bottom: BorderSide(
                            width: 0.5, color: Colors.grey), // Linha inferior
                      ),
                    ),
                    child: SizedBox(
                      height: 70,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    idEvento != null ? capa_evento : capa_locla,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  idEvento != null ? nomeEvento : nomeLocal,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (idEvento ==
                                        null) // Verifica se idEvento é null
                                      Icon(Icons.star_half_rounded,
                                          size: 16, color: cor),
                                    const SizedBox(
                                        width:
                                            5), // Adiciona um espaço entre o ícone e o texto
                                    Text(
                                      idEvento != null
                                          ? '$diaEvento de ${converter_mes(mesEvento)}'
                                          : classlocal,
                                      style: TextStyle(
                                        color: cor,
                                        fontSize: 14,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                        idEvento != null
                                            ? Icons.people_alt_rounded
                                            : Icons.location_on,
                                        size: 16,
                                        color: const Color(0xFF79747E)),
                                    const SizedBox(width: 5),
                                    Text(
                                      idEvento != null
                                          ? '$numeroParticipantes participantes'
                                          : '$moradalocal ',
                                      style: const TextStyle(
                                        color: Color(0xFF79747E),
                                        fontSize: 13,
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.15,
                                      ),
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
                 */ /*Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // Ação quando o ícone de like for pressionado
                        },
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        color: const Color(0xFF53981D),
                      ),
                      Text(
                        '$gostos_', // Número de curtidas ou mensagens
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(
                        width: 1,
                      ),
                      IconButton(
                        onPressed: () {
                          // Ação quando o ícone de mensagem for pressionado
                        },
                        icon: const Icon(Icons.message_outlined),
                        color: const Color(0xFF53981D),
                      ),
                      const Text(
                        '3', // Número de curtidas ou mensagens
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ],
                  ),*/
                ],
              ),
            ),
          ),
        );
      }
    },
  );
}
