import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_dono/pagina_defenicoes_menbros/menbros_atuais.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_dono/pagina_defenicoes_menbros/menbros_pendentes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:flutter/widgets.dart';

class Pag_defenicao_menbros extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicao_menbros({super.key, required this.idGrupo});

  @override
  _Pag_defenicao_menbrosState createState() => _Pag_defenicao_menbrosState();
}

class _Pag_defenicao_menbrosState extends State<Pag_defenicao_menbros> {
  Map<String, dynamic>? grupo;
 int user_totoais=0;
  @override
  void initState() {
    super.initState();
    _carregardetalhesdogrupo();
  }

  void _carregardetalhesdogrupo() async {
    final grupoCarregado =
        await Funcoes_Grupos.detalhes_do_grupo(widget.idGrupo);

        List<int> idsdos_users =
        await Funcoes_User_menbro_grupos.obterUsuariosDoGrupo(widget.idGrupo);
    setState(() {
      grupo = grupoCarregado;
      user_totoais=idsdos_users.length;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color.fromARGB(255, 241, 241, 241),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                  
                 onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Pag_defenicoes_menbros_pendentes(
                                idGrupo: widget.idGrupo,),
                          ),
                        );
                      },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 25,
                          color: const Color(0xFF15659F),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Membros Pendentes (0)',
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
                  onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Pag_mebros_atuais(
                                idGrupo: widget.idGrupo,),
                          ),
                        );
                      },
                  child: Align(
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
                          'Membros Atuais (${user_totoais > 0 ? user_totoais- 1 : user_totoais})',
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
             
            ],
          ),
        ));
  }
}
