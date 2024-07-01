import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';

class Pag_defenicoes_menbros_pendentes extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicoes_menbros_pendentes({super.key, required this.idGrupo});

  @override
  _Pag_defenicoes_menbros_pendentesState createState() =>
      _Pag_defenicoes_menbros_pendentesState();
}

class _Pag_defenicoes_menbros_pendentesState
    extends State<Pag_defenicoes_menbros_pendentes> {
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
            'Mnebros Pendentes',
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
        body: Center(
            child: Stack(children: [
          SingleChildScrollView(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/sem_menbros_pendentes.png',
                      width: 85,
                      height: 85,
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, bottom: 5),
                      child: Text(
                        'Sem Menbros Pendentes !',
                        style: TextStyle(
                          color: Color.fromARGB(255, 127, 128, 128),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.0, bottom: 5),
                      child: Text(
                        'AINDA NAO FIZ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 127, 128, 128),
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ]))
        ])));
  }
}
