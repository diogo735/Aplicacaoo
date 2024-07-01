import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';

class Pag_defenicoes_menbro extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicoes_menbro({super.key, required this.idGrupo});

  @override
  _Pag_defenicoes_menbroState createState() => _Pag_defenicoes_menbroState();
}

class _Pag_defenicoes_menbroState extends State<Pag_defenicoes_menbro> {
  @override
  void initState() {
    super.initState();
    //_carregarMenbros();
  }

  void _carregargaleria() async {}

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
                'Configurações pessoais',
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
                  onPressed: () {},
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
              Spacer(),///separa qui para o fundo
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
                          Icons.door_front_door_rounded,
                          size: 25,
                          color: Color(0xFFDC3545),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Sair do Grupo',
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
              SizedBox(height: 10,),
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
                          Icons.thumb_down,
                          size: 25,
                          color: Color(0xFFDC3545),
                        ), // Ícone
                        SizedBox(width: 13),
                        Text(
                          'Denunciar Grupo',
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
