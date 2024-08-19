import 'dart:io';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/paginal_lista_menbros/ver_perfil_outros_user/pagina_de_perfil.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';

class PagListaParticipantesEvento extends StatefulWidget {
  final int idEvento;
  final Color cor;

  const PagListaParticipantesEvento(
      {Key? key, required this.idEvento, required this.cor})
      : super(key: key);

  @override
  _PagListaParticipantesEventoState createState() =>
      _PagListaParticipantesEventoState();
}

class _PagListaParticipantesEventoState
    extends State<PagListaParticipantesEvento> {
  List<Map<String, dynamic>> lista_menbros = [];

  @override
  void initState() {
    super.initState();
    _carregarMenbros();
  }

 void _carregarMenbros() async {
  // Obtendo os IDs dos membros participantes do evento
  List<int> idsdos_users = await Funcoes_Participantes_Evento.getParticipantesEvento(widget.idEvento);
  List<Map<String, dynamic>> users = [];

  for (int userId in idsdos_users) {
    String nomeCompleto = await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(userId);
    String caminhoFoto = await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(userId);

    // Adicionando o usuário ao array de usuários
    Map<String, dynamic> user = {
      'id': userId,
      'nome': nomeCompleto,
      'caminhoFoto': caminhoFoto, 
      
    };
    users.add(user);
    

    // Print de cada usuário obtido
    //print('Usuário: ${user['id']}, Nome: ${user['nome']}, Foto: ${user['caminhoFoto']}');
  }

  setState(() {
    lista_menbros = users;
  });
}


  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    var user_id = usuarioProvider.usuarioSelecionado!.id_user;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Participantes do Evento',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            ),
          ),
          backgroundColor: widget.cor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 243, 243, 243),
        body: Stack(children: [
          SingleChildScrollView(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 5),
                      child: Text(
                        '${lista_menbros.length} Participantes no Total',
                        style: TextStyle(
                          color: widget.cor,
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.50,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFCAC4D0),
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: lista_menbros.length,
                      itemBuilder: (context, index) {
                        final user = lista_menbros[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => pagina_de_perfil_vista(
                                      idUsuario: user['id']),
                                ),
                              );
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: user_card(
                                context: context,
                                nomeuser:
                                    user['id'] == user_id ? 'Eu' : user['nome'],
                                imagePath: user['caminhoFoto'],
                              ),
                            ),
                          );
                        
                      },
                    )
                  ]))
        ]));
  }
}

Widget user_card({
  required String nomeuser,
  required String imagePath,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, top: 15, bottom: 5),
    child: Container(
      // color: Colors.red,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30, // Ajuste o raio conforme necessário
            backgroundImage: FileImage(File(imagePath)),
          ),
          const SizedBox(width: 15),
          Text(
            nomeuser,
            style: const TextStyle(
              color: Color(0xFF49454F),
              fontSize: 18,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    ),
  );
}
