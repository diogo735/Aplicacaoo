import 'package:device_calendar/device_calendar.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_inscrever_evento/card_evento_confirma.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_topicos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class PaginaLocalValidado extends StatefulWidget {
  final int cor;

  const PaginaLocalValidado({
    super.key,
    required this.cor,
  });

  @override
  _PaginaLocalValidadoState createState() => _PaginaLocalValidadoState();
}

class _PaginaLocalValidadoState extends State<PaginaLocalValidado> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color getCorPorAreaId(int idArea) {
    switch (idArea) {
      case 2:
        return const Color(0xFF8F3023); // Saúde
      case 1:
        return const Color(0xFF53981D); // Desporto
      case 3:
        return const Color(0xFFA91C7A); // Gastronomia
      case 4:
        return const Color(0xFF3779C6); // Formação
      case 7:
        return const Color(0xFF815520); // Alojamento
      case 6:
        return const Color(0xFFB7BB06); // Transportes
      case 5:
        return const Color(0xFF25ABAB); // Lazer
      default:
        return const Color(0xFF15659F); // Cor padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 50),
                  const Center(
                    child: Text(
                      'Sugestão validada com \nSucesso',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22, // Tamanho do texto
                        fontWeight: FontWeight.bold, // Negrito
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 10),
                  const Icon(
                    Icons.check_rounded,
                    color: Color.fromARGB(255, 21, 101, 159),
                    size: 150,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height / 15),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aviso:\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          TextSpan(
                            text:
                                'Devido ás nossas politicas de segurança, a sua publicaçãosó será divulgada depois se ser revista pelo Gestor do seu Centro, irá receber atualizações do estado da sua publicação na area de Notificações.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 15, left: 15),
            child: Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();

                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: getCorPorAreaId(widget.cor),
                      side: BorderSide(
                        color: getCorPorAreaId(widget.cor),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Certo, voltar ás Sugestões',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
