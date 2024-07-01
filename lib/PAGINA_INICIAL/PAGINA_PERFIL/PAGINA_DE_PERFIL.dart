import 'dart:io';

import 'package:ficha3/centro_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areafavoritas_douser.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_PERFIL/card_area_intereses.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_PERFIL/card_grupos_douser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class pagina_de_perfil extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _pagina_de_perfilState createState() => _pagina_de_perfilState();
}

// ignore: camel_case_types
class _pagina_de_perfilState extends State<pagina_de_perfil> {
  List<int> areasFavoritas = [];
  List<int> gruposMembro = [];

  @override
  void initState() {
    super.initState();
    _carregarAreasFavoritas();
    _carregarGruposDoUsuario();
  }

  void _carregarAreasFavoritas() async {
    try {
      int? idUsuario = Provider.of<Usuario_Provider>(context, listen: false)
          .usuarioSelecionado
          ?.id_user;
      int usuarioId = idUsuario ?? 0;
      List<int> areasFavoritasCarregadas =
          await Funcoes_AreasFavoritas.obeter_areas_favoritas_do_userid(
              usuarioId);
      setState(() {
        areasFavoritas = areasFavoritasCarregadas;
      });
    } catch (e) {
      print('Erro ao carregar áreas favoritas: $e');
    }
  }

  void _carregarGruposDoUsuario() async {
    try {
      int? idUsuario = Provider.of<Usuario_Provider>(context, listen: false)
          .usuarioSelecionado
          ?.id_user;
      int usuarioId = idUsuario ?? 0;
      List<int> gruposDoUsuario =
          await Funcoes_User_menbro_grupos.obterGruposDoUsuario(usuarioId);
      setState(() {
        gruposMembro = gruposDoUsuario;
      });
    } catch (e) {
      print('Erro ao carregar grupos do usuário: $e');
    }
  }

 Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
    // Limpa os provedores
    Provider.of<Usuario_Provider>(context, listen: false).deslogarUsuario();
    Provider.of<Centro_Provider>(context, listen: false).deslogarCentro();

    
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            title: const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 24,
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
              ),
            ),
            backgroundColor: const Color(0xFF15659F),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                //const Icon(Icons.settings),
                onPressed: () {
                  
                  _logout();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: Provider.of<Usuario_Provider>(context)
                                  .usuarioSelecionado
                                  ?.fundo !=
                              null
                          ? FileImage(File(
                              Provider.of<Usuario_Provider>(context)
                                  .usuarioSelecionado!
                                  .fundo))
                          : AssetImage('assets/images/default_background.jpg')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white, // Cor branca
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(29),
                          topRight: Radius.circular(29),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 240),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 75,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 26,
                            child: Text(
                              '${Provider.of<Usuario_Provider>(context).usuarioSelecionado?.nome ?? ''} ${Provider.of<Usuario_Provider>(context).usuarioSelecionado?.sobrenome ?? ''}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF15659F),
                                fontSize: 28,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800,
                                height: 0.02,
                                letterSpacing: 0.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Center(
                        child: SizedBox(
                          height: 17.80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Color(0xFF79747E),
                                size: 15.30,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Softinsa de Viseu',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF79747E),
                                  fontSize: 15.30,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 0.10,
                                  letterSpacing: 0.14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        ///eventos partilhas
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Column(
                              children: [
                                Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w900,
                                    height: 0.06,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                                SizedBox(height: 25),
                                Text(
                                  'Eventos',
                                  style: TextStyle(
                                    color: Color(0xFF646464),
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    height: 0.12,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                height: 39,
                                width: 1,
                                color: const Color(0xFF979797),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Column(
                              children: [
                                Text(
                                  '2',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w900,
                                    height: 0.06,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                                SizedBox(height: 25),
                                Text(
                                  'Partilhas',
                                  style: TextStyle(
                                    color: Color(0xFF646464),
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    height: 0.12,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                height: 39,
                                width: 1,
                                color: const Color(0xFF979797),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Column(
                              children: [
                                Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w900,
                                    height: 0.06,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                                SizedBox(height: 25),
                                Text(
                                  'Publicações',
                                  style: TextStyle(
                                    color: Color(0xFF646464),
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    height: 0.12,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        ///sobre min
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Sobre mim',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                    height: 0.06,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              child: Text(
                                Provider.of<Usuario_Provider>(context)
                                        .usuarioSelecionado
                                        ?.sobre_min ??
                                    '',
                                textAlign: TextAlign.left,
                                maxLines: null,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        ///INTERESSES
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Interesses (${areasFavoritas.length})',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                    height: 0.06,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Container(
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                spacing: 5, // Espaçamento horizontal
                                runSpacing: 0, // Espaçamento vertical
                                children: [
                                  for (int areaId in areasFavoritas)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          right: 10, bottom: 10),
                                      child: CARD_AREA_INTERESSES(
                                        area_id: areaId,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      ///Grupos
                      Container(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Membro (${gruposMembro.length})',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                    height: 0.06,
                                    letterSpacing: 0.15,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            Container(
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                spacing: 5,
                                runSpacing: 0,
                                children: [
                                  for (int grupoId in gruposMembro)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          right: 10, bottom: 20),
                                      child: CARD_GRUPOS_USER(
                                        grupo_id: grupoId,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                      ///partilhas perfil
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.share,
                              color: Color(0xFF15659F),
                              size: 20,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                'Partilhar perfil',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Color(0xFF15659F),
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  height: 0.09,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Positioned(
                  //avatar
                  left: 0,
                  right: 0,
                  top: 140,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.10, color: Colors.white),
                      ),
                      child: CircleAvatar(
                        radius: 73.47,
                        backgroundImage: Provider.of<Usuario_Provider>(context)
                                    .usuarioSelecionado
                                    ?.foto !=
                                null
                            ? FileImage(File(
                                Provider.of<Usuario_Provider>(context)
                                    .usuarioSelecionado!
                                    .foto!))
                            : AssetImage('assets/images/default_user_image.png')
                                as ImageProvider,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Future<bool> _onWillPop() async {
    //para o botao do tele
    Navigator.pushReplacementNamed(context, '/home');
    return true;
  }
}
