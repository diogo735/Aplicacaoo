import 'dart:io';

import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/pagina_de_uma_area.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:ficha3/usuario_provider.dart';

class Pag_Areas extends StatelessWidget {
  const Pag_Areas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 30,
              color: Color(0xFF0A55C4),
            ),
            SizedBox(width: 12),
            Text(
              'Áreas',
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
                Navigator.pushReplacementNamed(context, '/pagina_de_perfil');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: Provider.of<Usuario_Provider>(context)
                              .usuarioSelecionado
                              ?.foto !=
                          null
                      ? FileImage(File(Provider.of<Usuario_Provider>(context)
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
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  criar_blocos_areas(
                      context,
                      'Saúde',
                      'assets/images/area_saude.png',
                      const Color(0xFF8F3023),
                      1),
                  Spacer(),
                  criar_blocos_areas(
                      context,
                      'Desporto',
                      'assets/images/area_desporto.png',
                      const Color(0xFF53981D),
                      2),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  criar_blocos_areas(
                      context,
                      'Gastronomia',
                      'assets/images/area_gastronomia.png',
                      const Color(0xFFA91C7A),
                      3),
                  Spacer(),
                  criar_blocos_areas(
                    context,
                    'Formação',
                    'assets/images/area_formação.png',
                    const Color(0xFF3779C6),
                    4,
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  criar_blocos_areas(
                      context,
                      'Alojamento',
                      'assets/images/area_alojamento.png',
                      const Color(0xFF815520),
                      5),
                  Spacer(),
                  criar_blocos_areas(
                      context,
                      'Trasnportes',
                      'assets/images/area_transportes.png',
                      const Color(0xFFB7BB06),
                      6),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 160),
              Row(
                children: [
                  criar_blocos_areas(
                      context,
                      'Lazer',
                      'assets/images/area_lazer.png',
                      const Color(0xFF25ABAB),
                      7),
                  Spacer(),
                  criar_blocos_areas(
                      context,
                      'Ver Info',
                      'assets/images/ver_info.png',
                      const Color.fromARGB(255, 255, 255, 255),
                      0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget criar_blocos_areas(
    BuildContext context,
    String texto,
    String imagemCaminho,
    Color corCirculo,
    int idArea,
  ) {
    return idArea == 0
        ? Container(
            width: MediaQuery.of(context).size.width / 2.32,
            height: MediaQuery.of(context).size.height / 5.75,
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF15659F),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: corCirculo,
                  ),
                  child: Center(
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(imagemCaminho),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Pag_de_uma_area(
                    id_area: idArea,
                    cor_da_area: corCirculo,
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2.32,
              height: MediaQuery.of(context).size.height / 5.75,
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF15659F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: corCirculo,
                    ),
                    child: Center(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(imagemCaminho),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    texto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
