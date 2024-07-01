import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_dono/pagina_defenicoes_menbros/pagina_defenicoes_mebros.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_dono/pagina_definicoes_privacidade.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_menbro/pagina_definicoes_notificacoes.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_dono/pagina_disposição.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_dono/pagina_detalhes_do_grupo.dart';



class Pag_defenicoes_dono extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicoes_dono({super.key, required this.idGrupo});

  @override
  _Pag_defenicoes_donoState createState() => _Pag_defenicoes_donoState();
}

class _Pag_defenicoes_donoState extends State<Pag_defenicoes_dono> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Definições',
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
        backgroundColor: Color.fromARGB(255, 241, 241, 241),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Configurações de Dono',
                style: TextStyle(
                  color: Color(0xFF15659F),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
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
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                  ),
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pag_defenicao_disposicao(
                        idGrupo: widget.idGrupo,
                      ),
                    ),
                  );},
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 25,
                          color: const Color(0xFF15659F),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Disposição',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF15659F),
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),



              
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                  ),
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pag_defenicao_detalhesgrupo(
                        idGrupo: widget.idGrupo,
                      ),
                    ),
                  );},
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info,
                          size: 25,
                          color: const Color(0xFF15659F),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Detalhes',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF15659F),
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                  ),
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pag_defenicao_menbros(
                        idGrupo: widget.idGrupo,
                      ),
                    ),
                  );},
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_rounded,
                          size: 25,
                          color: const Color(0xFF15659F),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Membros',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF15659F),
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                  ),
                   onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pag_defenicao_privacidade(
                        idGrupo: widget.idGrupo,
                      ),
                    ),
                  );},
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.privacy_tip,
                          size: 25,
                          color: const Color(0xFF15659F),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Privacidade',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF15659F),
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              const Text(
                'Configurações de Pessoais',
                style: TextStyle(
                  color: Color(0xFF15659F),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
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
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                  ),
                  onPressed: () {Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pag_defenicao_notificacao(
                        idGrupo: widget.idGrupo,
                      ),
                    ),
                  );},
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mobile_friendly_rounded,
                          size: 25,
                          color: const Color(0xFF15659F),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Notificações',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF15659F),
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Spacer(),

              ///separa qui para o fundo
              const Text(
                'Ações',
                style: TextStyle(
                  color: Color(0xFF15659F),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
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
              SizedBox(
                height: 13,
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.redAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 15),
                  ),
                  onPressed: () {},
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_rounded,
                          size: 25,
                          color: Color(0xFFDC3545),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Eliminar Grupo',
                          style: TextStyle(
                            color: Color(0xFFDC3545),
                            fontSize: 18,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
