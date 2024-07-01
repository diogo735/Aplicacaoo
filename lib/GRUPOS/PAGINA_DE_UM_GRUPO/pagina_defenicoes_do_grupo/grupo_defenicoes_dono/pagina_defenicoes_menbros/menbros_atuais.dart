import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/paginal_lista_menbros/ver_perfil_outros_user/pagina_de_perfil.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';

class Pag_mebros_atuais extends StatefulWidget {
  final int idGrupo;

  const Pag_mebros_atuais({super.key, required this.idGrupo});

  @override
  _Pag_mebros_atuaisState createState() => _Pag_mebros_atuaisState();
}

class _Pag_mebros_atuaisState extends State<Pag_mebros_atuais> {
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
        'caminho_foto': caminhoFoto,
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
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 15.0, bottom: 5),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                pagina_de_perfil_vista(idUsuario: id_admin),
                          ),
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: user_card(
                          context: context,
                          nomeuser: adminUser != null &&
                                  adminUser!['id'] == user_id
                              ? 'Eu'
                              : (adminUser != null ? adminUser!['nome'] : ''),
                          imagePath: adminUser != null
                              ? adminUser!['caminho_foto']
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 5),
                      child: Text(
                        'Membros (${lista_menbros.length > 0 ? lista_menbros.length - 1 : lista_menbros.length})',
                        style: const TextStyle(
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
                      physics: const NeverScrollableScrollPhysics(),
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
                                    idUsuario: user['id'],
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: user_card(
                                        context: context,
                                        nomeuser: user['id'] == user_id
                                            ? 'Eu'
                                            : user['nome'],
                                        imagePath: user['caminho_foto'] ?? '',
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.group_remove_rounded,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                              ],
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Eliminar ${user['nome']} ?',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                const Text(
                                                  'Insira abaixo uma mensagem do motivo(Opcional):',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                                const SizedBox(height: 8),
                                                TextFormField(
                                                  cursorColor:
                                                      const Color(0xFF15659F),
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF15659F)),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF15659F)),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xFF15659F)),
                                                    ),
                                                    hintText:
                                                        'Insira a mensagem(ainda nao fiz quando fizer as notificações)',
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                    // Cor do cursor
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () async {
                                                  await Funcoes_User_menbro_grupos
                                                      .removerUsuarioDoGrupo(
                                                          user['id'],
                                                          widget.idGrupo);
                                                  Navigator.of(context).pop();
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'User Removido com Sucesso!'),
                                                      duration:
                                                          Duration(seconds: 3),
                                                      backgroundColor:
                                                          Colors.green,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                  setState(() {
                                                    _carregarMenbros();
                                                  });
                                                },
                                                child: const Text('Eliminar',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Cancelar',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      'Expulsar',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
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
