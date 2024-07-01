import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';

import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';

Future<Widget> MENSAGEM_FORUM({
  required int idUser,
  required String textMensagem,
  required int hora,
  required int minutos,
  required int dia,
  required int mes,
}) async {
  String horas = '$hora'.padLeft(2, '0');
  String minutoss = '$minutos'.padLeft(2, '0');
  String data = '${'$dia'.padLeft(2, '0')}/${mes.toString().padLeft(2, '0')}';

  String nomeCompleto =
      await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(idUser);
  String caminhoFoto =
      await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(idUser);

  bool diaAtual = DateTime.now().day == int.parse('$dia'.padLeft(2, '0')) &&
      DateTime.now().month ==
          int.parse('$mes'.padLeft(2, '0'));

  return Consumer<Usuario_Provider>(
    builder: (context, usuarioProvider, _) {
      final usuario = usuarioProvider.usuarioSelecionado;
      bool isUsuarioAtual = usuario != null && usuario.id_user == idUser;

      return Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: FileImage(File(caminhoFoto)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUsuarioAtual ? 'Eu' : nomeCompleto,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            diaAtual
                                ? '$horas:$minutoss'
                                : data + ' ás ' + '$horas:$minutoss',
                            style: const TextStyle(
                              color: Color(0xFF89939C),
                              fontSize: 14,
                              fontFamily: 'ABeeZee',
                              fontWeight: FontWeight.w400,
                              height: 0.11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                textMensagem,
              ),
              const SizedBox(height: 10),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                size: 20,
              ),
              onPressed: () {
                ///
              },
            ),
          ),
        ],
      );
    },
  );
}
