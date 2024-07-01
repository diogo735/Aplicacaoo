import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';

class Pag_defenicao_notificacao extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicao_notificacao({super.key, required this.idGrupo});

  @override
  _Pag_defenicao_notificacaoState createState() =>
      _Pag_defenicao_notificacaoState();
}

final WidgetStateProperty<Icon?> thumbIcon =
    WidgetStateProperty.resolveWith<Icon?>(
  (Set<WidgetState> states) {
    if (states.contains(MaterialState.selected)) {
      return const Icon(
        Icons.check,
        color: Colors.white,
      );
    }
    return const Icon(Icons.close);
  },
);

class _Pag_defenicao_notificacaoState extends State<Pag_defenicao_notificacao> {
  Map<String, dynamic>? grupo;
  bool _notificationsEnabled = true;
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Notificações do Grupo',
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
                height: 55,
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
                  onPressed: () {},
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_on_rounded,
                          size: 25,
                          color: Color(0xFF15659F),
                        ), // Ícone
                        SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Desativar Notificações',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              /*
                              Text(
                                '',
                                style: TextStyle(
                                  color: Color(0xFF79747E),
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                                
                              ),*/
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            thumbIcon: thumbIcon,
                            value: _notificationsEnabled,
                            onChanged: (newValue) {
                              setState(() {
                                _notificationsEnabled = newValue;
                              });
                            },
                            activeColor: Color(0xFF15659F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              Padding(
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deu erro!'),
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
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
            ],
          ),
        ));
  }
}
