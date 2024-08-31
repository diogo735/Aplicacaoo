import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_principal/pagina_principal_do_grupo.dart';

class Pag_Grupos extends StatefulWidget {
  const Pag_Grupos({super.key});

  @override
  _Pag_GruposState createState() => _Pag_GruposState();
}

class _Pag_GruposState extends State<Pag_Grupos> {
  List<Map<String, dynamic>> gruposDetalhes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarGrupos();
  }

  Future<void> carregarGrupos() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    final userId = usuarioProvider.usuarioSelecionado!.id_user;
    List<int> gruposObtidos =
        await Funcoes_User_menbro_grupos.obterGruposDoUsuario(userId);

    List<Map<String, dynamic>> detalhes = [];
    for (int grupoId in gruposObtidos) {
      Map<String, dynamic>? detalhesGrupo =
          await Funcoes_Grupos.obterGrupoPorId(grupoId);
      if (detalhesGrupo != null) {
        detalhes.add(detalhesGrupo);
      }
    }

    setState(() {
      gruposDetalhes = detalhes;
      isLoading = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 30,
                  color: Color(0xFF0A55C4),
                ),
                SizedBox(width: 12),
                Text(
                  'Grupos',
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF0A55C4),
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/pagina_de_perfil');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: Provider.of<Usuario_Provider>(context)
                                  .usuarioSelecionado
                                  ?.foto !=
                              null
                          ? FileImage(File(
                              Provider.of<Usuario_Provider>(context)
                                  .usuarioSelecionado!
                                  .foto!))
                          : AssetImage('assets/images/user_padrao.jpg')
                              as ImageProvider,
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFF6F6F6),
          body: Stack(
            children: [
              ListView.builder(
                itemCount: gruposDetalhes.length,
                itemBuilder: (context, index) {
                  final grupo = gruposDetalhes[index];
                  return GestureDetector(
                    onTap: () {
                      // Navegar para a página do grupo
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              pagina_principal_grupo(idGrupo: grupo['id']),
                        ),
                      );
                    },
                    child: CriarCardGrupo(
                      imagemCaminho: grupo['caminho_imagem'],
                      nomeGrupo: grupo['nome'],
                    ),
                  );
                },
              ),
              if (!isLoading && gruposDetalhes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/sem_grupos.png',
                          width: 85,
                          height: 85,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          'Ups!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.50,
                          ),
                        ),
                        Text(
                          'Parece que ainda não faz parte de nenhum grupo. Pode procurar por grupos nas suas áreas de interesse ou pode criar o seu grupo!!',
                          style: TextStyle(
                            color: Color(0xFF79747E),
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.50,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: SpeedDial(
            icon: Icons.add,
            backgroundColor: const Color(0xFF15659F),
            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
            curve: Curves.bounceIn,
            overlayColor: null,
            overlayOpacity: 0.0,
            buttonSize: const Size(150, 60),
            childrenButtonSize: const Size(150, 60),
          ),
        ),
      ],
    );
  }
}

class CriarCardGrupo extends StatelessWidget {
  final String imagemCaminho;
  final String nomeGrupo;

  const CriarCardGrupo({
    super.key,
    required this.imagemCaminho,
    required this.nomeGrupo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 10,
      height: (MediaQuery.of(context).size.height / 8) - 10,
      margin: const EdgeInsets.all(9),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        //color: Colors.blueAccent,
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 4,
            height: MediaQuery.of(context).size.height / 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(imagemCaminho),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              nomeGrupo,
              style: const TextStyle(
                color: Color(0xFF15659F),
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF15659F),
              size: 15,
            ),
          ),
        ],
      ),
    );
  }
}
