import 'dart:io';

import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicosfavoritos_user.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_areafavoritas_douser.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_PERFIL/card_area_intereses.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_PERFIL/card_grupos_douser.dart';

class pagina_de_perfil_vista extends StatefulWidget {
  final int idUsuario; // Parâmetro para armazenar o ID do usuário

  pagina_de_perfil_vista({required this.idUsuario});
  // ignore: library_private_types_in_public_api
  _pagina_de_perfil_vistaState createState() => _pagina_de_perfil_vistaState();
}

// ignore: camel_case_types
class _pagina_de_perfil_vistaState extends State<pagina_de_perfil_vista> {
  List<int> areasFavoritas = [];
  List<int> topicosFavoritos = [];
  List<int> gruposMembro = [];
  String nome = '';
  String foto = '';
  String fundo = '';
  String Sobremin = '';
  String centro_id = '';
  @override
  void initState() {
    super.initState();
    _carregardadosuser();
    _carregarAreasFavoritas();
    _carregarTopicosFavoritos();
    _carregarGruposDoUsuario();
  }

  void _carregardadosuser() async {
    String nomeCompleto =
        await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(
            widget.idUsuario);
    String caminhoFoto = await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(
        widget.idUsuario);
    String camingofundo =
        await Funcoes_Usuarios.consultaCaminhoFOTOFUNDOUsuarioPorId(
            widget.idUsuario);
    String getsobremin =
        await Funcoes_Usuarios.obterSobreMimUsuarioPorId(widget.idUsuario);

    int centro_idd =
        await Funcoes_Usuarios.consultaCentroIdPorUsuarioId(widget.idUsuario);
    String nomeCentro =
        await Funcoes_Centros.consultaNomeCentroPorId(centro_idd);
    setState(() {
      nome = nomeCompleto;
      foto = caminhoFoto;
      fundo = camingofundo;
      Sobremin = getsobremin;
      centro_id = nomeCentro;
    });
  }

  void _carregarAreasFavoritas() async {
    try {
      List<int> areasFavoritasCarregadas =
          await Funcoes_AreasFavoritas.obeter_areas_favoritas_do_userid(
              widget.idUsuario);

      // Verifique se o widget ainda está montado antes de chamar setState
      if (!mounted) return;

      setState(() {
        areasFavoritas = areasFavoritasCarregadas;
      });
    } catch (e) {
      print('Erro ao carregar áreas favoritas: $e');
    }
  }

  void _carregarTopicosFavoritos() async {
    try {
      // Carregar os tópicos favoritos do usuário
      List<int> topicosFavoritosCarregados =
          await Funcoes_TopicosFavoritos.obeter_topicos_favoritos_do_userid(
              widget.idUsuario);

      // Verifique se o widget ainda está montado antes de chamar setState
      if (!mounted) return;

      setState(() {
        topicosFavoritos = topicosFavoritosCarregados;
      });
    } catch (e) {
      print('Erro ao carregar tópicos favoritos: $e');
    }
  }

  void _carregarGruposDoUsuario() async {
    try {
      List<int> gruposDoUsuario =
          await Funcoes_User_menbro_grupos.obterGruposDoUsuario(
              widget.idUsuario);
      setState(() {
        gruposMembro = gruposDoUsuario;
      });
    } catch (e) {
      print('Erro ao carregar grupos do usuário: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil de ',
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
            icon: const Icon(Icons.share),
            onPressed: () {},
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
                  image: FileImage(File(fundo)),
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
                          nome,
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
                  Center(
                    child: SizedBox(
                      height: 17.80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF79747E),
                            size: 15.30,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Softinsa de $centro_id',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
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
                              '0',
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
                              '0',
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
                              '0',
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
                            Sobremin,
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
                              'Interesses (${areasFavoritas.length+topicosFavoritos.length})',
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
                          child: areasFavoritas.isNotEmpty
                              ? Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  spacing: 5, // Espaçamento horizontal
                                  runSpacing: 0, // Espaçamento vertical
                                  children: [
                                  // Exibir as áreas favoritas
                                  for (int areaId in areasFavoritas)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          right: 10, bottom: 10),
                                      child: CARD_AREA_INTERESSES(
                                        area_id: areaId,
                                      ),
                                    ),

                                  for (int topicoId in topicosFavoritos)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          right: 10, bottom: 10),
                                      child: CARD_TOPICO_INTERESSES(
                                        topico_id: topicoId,
                                        
                                      ),
                                    ),
                                ],
                                )
                              : const Center(
                                  child: Text(
                                    'Ainda não tem interesses :( ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                        )
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
                          child: gruposMembro.isNotEmpty
                              ? Container(
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
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
                                )
                              : const Center(
                                  child: Text(
                                    'Ainda não faz parte de Grupos :( ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                        )
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
                          Icons.dangerous,
                          color: Color.fromARGB(255, 220, 9, 9),
                          size: 20,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            'Denunciar perfil',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Color.fromARGB(255, 220, 9, 9),
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Color.fromARGB(255, 220, 9, 9),
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
                    backgroundImage: FileImage(File(foto)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
