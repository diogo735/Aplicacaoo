import 'dart:io';

import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_listaparticipantes_evento.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:ficha3/usuario_provider.dart';
import 'package:provider/provider.dart';

class Pag_denunciar_evento extends StatefulWidget {
  final int id_evento;

  const Pag_denunciar_evento({super.key, required this.id_evento});

  @override
  _Pag_denunciar_eventoState createState() => _Pag_denunciar_eventoState();
}

class _Pag_denunciar_eventoState extends State<Pag_denunciar_evento> {
  String nomeEvento = '';
  String fotoEvento = '';
  String Participantes = '';
  String? _selectedReason;
  bool _showError = false;
  final List<String> _reasons = [
    'Atividades Ilegais',
    'Conteúdo Inapropriado',
    'Fraude ou Engano',
    'Segurança Comprometida',
    'Discurso de ódio',
    'Outro'
  ];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _comentarioController = TextEditingController();
  late int user_id;
  bool _showCommentError = false;

  @override
  void initState() {
    super.initState();
    _carregarInformacoesEventos();
  }

  void _carregarInformacoesEventos() async {
    List<Map<String, dynamic>> resultado =
        await Funcoes_Eventos.consultaDetalhesEventoPorId(widget.id_evento);
    int nparticipantes =
        await Funcoes_Participantes_Evento.getNumeroDeParticipantes(
            widget.id_evento);

    if (resultado.isNotEmpty) {
      Map<String, dynamic> evento = resultado.first;
      setState(() {
        nomeEvento = evento['nome'];
        fotoEvento = evento['caminho_imagem'];
        Participantes = nparticipantes.toString();
      });
    } else {
      print('Nenhum evento encontrado com o ID fornecido.');
    }
  }

  void _sumeterFormulario(int userid) async {
    // Primeiro, verifica se os campos obrigatórios foram preenchidos
    setState(() {
      _showError = _selectedReason == null;
      _showCommentError = _comentarioController.text.isEmpty;
    });

    if (!_showError && !_showCommentError) {
      final apiEventos = ApiEventos();
      String resultado = await apiEventos.criarDenunciaEvento(
        widget.id_evento,
        userid,
        _selectedReason!,
        _comentarioController.text,
      );

      // Tratamento dos resultados após tentar criar a denúncia
      if (resultado == "Evento Denunciado!") {
        // Exibe um diálogo de sucesso
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Text(
                    'Evento Denunciado!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o diálogo de sucesso
                    Navigator.of(context).pop(); // Fecha o diálogo original
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      } else if (resultado == "Sem conexão com a internet.") {
        // Exibe uma Snackbar informando a falta de conexão com a internet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 8),
                Text(resultado),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(); // Fecha o diálogo original
      } else {
        // Exibe uma Snackbar informando qualquer outro erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(); // Fecha o diálogo original
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Denunciar Evento',
          style: TextStyle(
            fontSize: 18,
            color: Colors.red,
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.red),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 244, 244, 244),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: KeyboardDismissOnTap(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Evento que vai denunciar:',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: fotoEvento.isNotEmpty
                                            ? FileImage(File(fotoEvento))
                                            : const AssetImage(
                                                    'assets/images/sem_imagem.png')
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nomeEvento,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '$Participantes participantes',
                                          style: const TextStyle(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Motivo:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 3),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: DropdownButton<String>(
                                  value: _selectedReason,
                                  hint: const Text('o que ta de errado'),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedReason = newValue;
                                      _showError = false;
                                    });
                                  },
                                  items: _reasons.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                              if (_showError)
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Por favor, selecione uma razão.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              const Text(
                                'Descrição:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _comentarioController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                  hintText: 'descreva mais sobre o motivo...',
                                ),
                                cursorColor: Colors.red,
                                maxLines: 5,
                              ),
                              if (_showCommentError)
                                const Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    'Por favor, descreva o seu motivo.',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height / 20,
                          ),
                          child: SizedBox(
                            width: double.infinity, // Largura máxima possível
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _sumeterFormulario(user_id);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal:
                                        15), // Padding de 15 em ambos os lados
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // Cantos arredondados com raio de 8
                                ),
                              ),
                              icon: const Icon(
                                Icons.report, // Ícone de denúncia
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Enviar Denúncia',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
