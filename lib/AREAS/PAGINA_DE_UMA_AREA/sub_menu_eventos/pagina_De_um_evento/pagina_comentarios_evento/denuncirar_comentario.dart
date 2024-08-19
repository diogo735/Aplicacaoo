import 'package:ficha3/BASE_DE_DADOS/APIS/api_eventos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class DenunciaDialog extends StatefulWidget {
  final String nome;
  final String caminhoFoto;
  final String texto;
  final int id_comentario_denunciado;
  final int id_evento;

  const DenunciaDialog({
    Key? key,
    required this.nome,
    required this.caminhoFoto,
    required this.texto,
    required this.id_comentario_denunciado,
    required this.id_evento,
  }) : super(key: key);

  @override
  _DenunciaDialogState createState() => _DenunciaDialogState();
}

class _DenunciaDialogState extends State<DenunciaDialog> {
  String? _selectedReason; // Para armazenar a razão selecionada
  bool _showError = false; // Para controlar a exibição da mensagem de erro

  // Lista de razões para denúncia
  final List<String> _reasons = [
    'Conteúdo ofensivo',
    'Assédio ou bullying',
    'Spam',
    'Informações falsas',
    'Discurso de ódio',
    'Outro'
  ];
  late int user_id;
  final TextEditingController _comentarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = usuarioProvider.usuarioSelecionado!.id_user;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 1.2,
          child: LayoutBuilder(
            // Usar LayoutBuilder para controlar a altura
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 24.0,
                                ),
                              ),
                              const Expanded(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Denunciar Comentário!',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Comentário que vai denunciar:',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundImage:
                                          FileImage(File(widget.caminhoFoto)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.nome,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  widget.texto,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Motivo:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          DropdownButton<String>(
                            value: _selectedReason,
                            hint: const Text('o que ta de errado'),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedReason = newValue;
                                _showError = false;
                              });
                            },
                            items: _reasons
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
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
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 161, 2, 37)),
                              ),
                              hintText: 'descreva mais sobre o motivo...',
                            ),
                            cursorColor: const Color.fromARGB(255, 161, 2, 37),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu comentário';
                              }
                              return null;
                            },
                            maxLines: 5,
                          ),
                          const SizedBox(height: 30),
                          Center(
                              child: ElevatedButton.icon(
                            onPressed: () async {
                              if (_selectedReason != null) {
                                final apiEventos = ApiEventos();
                                String resultado =
                                    await apiEventos.criarDenuncia(
                                  widget.id_comentario_denunciado,
                                  widget.id_evento,
                                  user_id,
                                  _selectedReason!,
                                  _comentarioController.text,
                                );

                                if (resultado == "Comentario Denuciado!") {
                                  // Exibe um diálogo de sucesso
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.red, size: 60),
                                            SizedBox(height: 16),
                                            Text(
                                              'Comentário Denunciado!',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Fecha o diálogo
                                              Navigator.of(context)
                                                  .pop(); // Fecha o diálogo original
                                            },
                                            child: const Text('OK',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else if (resultado ==
                                    "Sem conexão com a internet.") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.wifi_off,
                                              color: Colors.white),
                                          const SizedBox(width: 8),
                                          Text(resultado),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(resultado),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                }
                              } else {
                                setState(() {
                                  _showError = true;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.report,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Enviar Denúncia',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16), // Padding interno
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
