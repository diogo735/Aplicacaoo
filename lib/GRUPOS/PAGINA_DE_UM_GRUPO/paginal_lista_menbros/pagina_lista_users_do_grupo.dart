

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/paginal_lista_menbros/ver_perfil_outros_user/pagina_de_perfil.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:provider/provider.dart';


class Pag_Users_do_grupo extends StatefulWidget {
  final int idGrupo;

  const Pag_Users_do_grupo({super.key, required this.idGrupo});

  @override
  _Pag_Users_do_grupoState createState() => _Pag_Users_do_grupoState();
}

class _Pag_Users_do_grupoState extends State<Pag_Users_do_grupo> {
  List<Map<String, dynamic>> lista_menbros = [];
  Map<String, dynamic>? adminUser;
  late int id_admin;
  late int user_id;
  @override
  void initState() {
    super.initState();
    _carregarMenbros();
  }

  void _carregarMenbros() async {
    List<int> idsdos_users =
        await Funcoes_User_menbro_grupos.obterUsuariosDoGrupo(widget.idGrupo);
    List<Map<String, dynamic>> users = [];

    for (int userId in idsdos_users) {
      String nomeCompleto =
          await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(userId);
      String caminhoFoto =
          await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(userId);

      users.add({
        'id': userId,
        'nome': nomeCompleto,
        'premissao_de_administrador': caminhoFoto,
      });
    }
    int id_admin2 =
        await Funcoes_Grupos.obterAdministradorId(widget.idGrupo) ?? 0;
    Map<String, dynamic>? adminUserData;

    if (id_admin2 != 0) {
      String nomeAdmin =
          await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(id_admin2);
      String caminhoFotoAdmin =
          await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(id_admin2);

      adminUserData = {
        'id': id_admin2,
        'nome': nomeAdmin,
        'caminho_foto': caminhoFotoAdmin,
      };
    }

    setState(() {
      id_admin = id_admin2;
      lista_menbros = users;
      adminUser = adminUserData;
    });
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Membros do Grupo',
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            ),
          ),
          backgroundColor: const Color(0xFF15659F),
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
                        'Administrador/a',
                        style: TextStyle(
                          color: Color(0xFF15659F),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.50,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFCAC4D0),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => pagina_de_perfil_vista(
                                idUsuario: id_admin),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: user_card(
                          context: context,
                          nomeuser:
                              adminUser != null && adminUser!['id'] == user_id
                                  ? 'Eu'
                                  : (adminUser != null
                                      ? adminUser!['nome']
                                      : 'erro!'),
                          imagePath: adminUser != null
                              ? adminUser!['caminho_foto']
                              : 'assets/images/sem_imagem.jpg',
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 5),
                      child: Text(
                        'Membros (${lista_menbros.length > 0 ? lista_menbros.length - 1 : lista_menbros.length})',
                        style: TextStyle(
                          color: Color(0xFF15659F),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: ShapeDecoration(
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

                        if (user['id'] == id_admin) {
                          return Container();
                        } else {
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
                                imagePath: user['caminho_foto'],
                              ),
                            ),
                          );
                        }
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
            backgroundImage: AssetImage(imagePath),
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
