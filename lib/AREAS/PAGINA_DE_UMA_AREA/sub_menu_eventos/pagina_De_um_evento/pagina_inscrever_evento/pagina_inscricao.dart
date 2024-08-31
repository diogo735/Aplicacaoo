import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_inscrever_evento/pagina_confirmacao_inscricao.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class PagInscricaoEvento extends StatefulWidget {
  final int idEvento;
  final Color cor;

  const PagInscricaoEvento({
    super.key,
    required this.idEvento,
    required this.cor,
  });

  @override
  _PagInscricaoEventoState createState() => _PagInscricaoEventoState();
}

class _PagInscricaoEventoState extends State<PagInscricaoEvento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telemovelController = TextEditingController();
  late int user_id;
  bool _isChecked = false;
  @override
  void initState() {
    super.initState();
    _carregarNomeCompleto();
  }

  Future<void> _carregarNomeCompleto() async {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;

    String nomeCompleto =
        await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(user_id);

    setState(() {
      _nomeController.text = nomeCompleto;
      user_id = user_id;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telemovelController.dispose();
    super.dispose();
  }

  void _inscrever() async {
    if (_formKey.currentState!.validate() && _isChecked) {
      // Mostra um indicador de carregamento enquanto a solicitação API está em andamento
      /*showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );*/

      ApiEventos apiEventos = ApiEventos();
      String resultado = await apiEventos.adicionarParticipanteEvento(
          user_id, widget.idEvento);

     
      if (resultado == "Inscrito com sucesso!") {
        await Funcoes_Participantes_Evento.inscreverUsuarioEmEvento(user_id, widget.idEvento);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PagConfirmacaoInscricao(
              idEvento: widget.idEvento,
              cor: widget.cor,
            ),
          ),
        );
      } else if (resultado == "Sem conexão com a internet.") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                Text(resultado),
              ],
            ),
            backgroundColor: const Color.fromARGB(255, 255, 0, 0),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text(resultado),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }

  String? _validarTelemovel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu número de telemóvel';
    }
    final telemovelRegex = RegExp(r'^\d{9}$');
    if (!telemovelRegex.hasMatch(value)) {
      return 'O telemóvel deve conter 9 dígitos';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscrição no Evento',
            style: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            )),
        backgroundColor: widget.cor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/icons_inscricao.png',
                          width: 30.0,
                          height: 30.0,
                        ),
                        const SizedBox(width: 8.0),
                        const Text(
                          'Finalize a sua Inscrição',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold // Cor do texto
                              ),
                        ),
                      ],
                    ),
                    const Text(
                      'Esta informação será compartilhada apenas com o administrador da sua empresa e o organizador do evento.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nome Completo',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 209, 209, 209),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome completo';
                        }
                        return null;
                      },
                      enabled: false, // Desabilita o campo para edição
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Email',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'introduzir e-mail...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Colors.grey,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: widget.cor,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Telemóvel',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _telemovelController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'introduzir telemóvel...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Colors.grey,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: widget.cor,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: _validarTelemovel,
                    ),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value!;
                            });
                          },
                          activeColor:
                              widget.cor, // Cor do checkbox quando marcado
                          checkColor: Colors.white,
                        ),
                        const Expanded(
                          child: Text(
                            'Eu declaro que a informação que forneci em cima é fidedigna e cumpre com os requisitos',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0, right: 15, left: 15),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _inscrever,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.cor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Confirmar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
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
    );
  }
}
