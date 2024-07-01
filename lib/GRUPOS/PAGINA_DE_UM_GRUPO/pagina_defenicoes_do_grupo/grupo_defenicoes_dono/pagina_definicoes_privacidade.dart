import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';

class Pag_defenicao_privacidade extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicao_privacidade({super.key, required this.idGrupo});

  @override
  _Pag_defenicao_privacidadeState createState() =>
      _Pag_defenicao_privacidadeState();
}

class _Pag_defenicao_privacidadeState extends State<Pag_defenicao_privacidade> {
  Map<String, dynamic>? grupo;
  int? _selectedValue;
  late int _initialValue = 0;
  bool visible = false;
  @override
  void initState() {
    super.initState();

    _carregardetalhesdogrupo();
  }

  void _carregardetalhesdogrupo() async {
    final grupoCarregado =
        await Funcoes_Grupos.detalhes_do_grupo(widget.idGrupo);
    setState(() {
      grupo = grupoCarregado;
      if (grupo != null) {
        _selectedValue = grupo!['privacidade_grupo'];
        _initialValue = _selectedValue!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Privacidade do Grupo',
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
              const Text(
                'Tipo de Grupo',
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
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                height: 90,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 5),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedValue = 0; // Defina o valor desejado aqui
                    });
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_open_rounded,
                          size: 25,
                          color: Color(0xFF15659F),
                        ), // Ícone
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Grupo Publico',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Todas as pessoas podem se juntar a este grupo, não é presiso aprovação',
                                style: TextStyle(
                                  color: Color(0xFF79747E),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Radio<int>(
                          value: 0,
                          groupValue: _selectedValue,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedValue = value!;
                            });
                          },
                          activeColor: Color(0xFF15659F),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: double.infinity,
                height: 75,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    foregroundColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.only(left: 15, right: 5),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedValue = 1; // Defina o valor desejado aqui
                    });
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 25,
                          color: Color(0xFF15659F),
                        ), // Ícone
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Grupo Privado',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Os membros fazem um pedido para puderem participar do grupo',
                                style: TextStyle(
                                  color: Color(0xFF79747E),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Radio<int>(
                          value: 1,
                          groupValue: _selectedValue,
                          onChanged: (int? value) {
                            setState(() {
                              _selectedValue = value!;
                            });
                          },
                          activeColor: Color(0xFF15659F),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              Visibility(
                visible: _selectedValue != _initialValue,
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        foregroundColor: Colors.blueAccent,
                        backgroundColor: Color(0xFF15659F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.only(left: 15, right: 15),
                      ),
                      onPressed: () async {
                        if (_selectedValue != _initialValue) {
                          bool sucesso =
                              await Funcoes_Grupos.atualizarPrivacidadeDoGrupo(
                                  widget.idGrupo, _selectedValue!);
                          if (sucesso) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Privacidade do grupo alterada com sucesso!'),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            setState(() {
                              _carregardetalhesdogrupo();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Deu erro!'),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save,
                              size: 25,
                              color: Colors.white,
                            ), // Ícone
                            SizedBox(width: 13),
                            Text(
                              'Guardar alterações',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
