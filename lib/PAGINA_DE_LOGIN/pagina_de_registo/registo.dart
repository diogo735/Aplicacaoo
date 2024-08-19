import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:flutter/material.dart';

import '../login_email.dart';

class Registo extends StatefulWidget {
  Registo({Key? key}) : super(key: key);

  @override
  _RegistoState createState() => _RegistoState();
}

class _RegistoState extends State<Registo> {
  late TextEditingController _emailController;
  late TextEditingController _contactoController;
  String? _selectedValue;
  String? _emailError;
  String? _contactoError;
  bool isChecked = false;
  late DatabaseHelper db;
  List<Map<String, dynamic>> centros = [];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_emailListen);
    _contactoController = TextEditingController();
    _contactoController.addListener(_contactoListen);
    db = DatabaseHelper();
    _listarCentros();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contactoController.dispose();
    super.dispose();
  }

  void _emailListen() {
    setState(() {
      if (_emailController.text.isEmpty) {
        _emailError = 'O campo de email não pode estar vazio';
      } else {
        _emailError = null;
      }
    });
  }

  void _contactoListen() {
    setState(() {
      if (_contactoController.text.isEmpty) {
        _contactoError = 'O campo de contato não pode estar vazio';
      } else {
        _contactoError = null;
      }
    });
  }

  Future<void> _listarCentros() async {
    // Aqui você adicionaria a lógica para carregar a lista de centros da base de dados
    // Exemplo: final centrosList = await db.getCentros();
    setState(() {
      //centros = centrosList;
    });
  }

  bool _todosCamposValidos() {
    return (_emailController.text.isNotEmpty) &&
        (_contactoController.text.isNotEmpty) &&
        isChecked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
        ),
        title: const Text(
          'Registo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                _buildEmailField(),
                const SizedBox(height: 10),
                const Text(
                  'Centro a que pertences',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildDropdown(),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Contacto',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildContactoField(),
                const SizedBox(
                  height: 10,
                ),
                _buildCheckbox(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Já tens uma conta?',
                    style: TextStyle(
                      color: Color.fromARGB(255, 112, 112, 112),
                      height: 1.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => LoginEmail(),
                        ),
                      );
                    },
                    child: const Text(
                      'Iniciar sessão',
                      style: TextStyle(
                        color: Color.fromARGB(255, 21, 101, 159),
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(
                            255, 21, 101, 159), // Cor do sublinhado
                        height: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 21, 101, 159),
                        textStyle: const TextStyle(fontSize: 20),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () async {
                        if (_todosCamposValidos()) {
                          final email = _emailController.text;

                          // Aqui você pode adicionar a lógica para a próxima tela ou envio de dados

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Erro ao enviar o email. Por favor, tente novamente.')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Por favor, preencha todos os campos e aceite a política de privacidade.')),
                          );
                        }
                      },
                      child: const Text(
                        'Registar-se',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        hintText: 'Insere o teu email',
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        errorText: _emailError,
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      hint: const Text(
        'Selecione um centro',
        style: TextStyle(
          color: Colors.grey,
        ),
      ),
      value: _selectedValue,
      items: centros.map((centro) {
        return DropdownMenuItem<String>(
          value: centro['nome'],
          child: Text(centro['nome']),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedValue = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione um centro';
        }
        return null;
      },
    );
  }

  Widget _buildContactoField() {
    return TextField(
      keyboardType: TextInputType.number,
      controller: _contactoController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        hintText: 'Digite seu contato aqui',
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        errorText: _contactoError,
      ),
    );
  }

  Widget _buildCheckbox() {
    return Row(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomLeft,
          child: Checkbox(
            value: isChecked,
            activeColor: const Color.fromARGB(
                255, 21, 101, 159), // Define a cor azul quando marcada
            onChanged: (bool? value) {
              setState(() {
                isChecked = value ?? false;
              });
            },
          ),
        ),
        RichText(
          text: const TextSpan(
            text: 'Concordo com os ',
            style: TextStyle(fontSize: 14, color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                text: 'termos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              TextSpan(
                text: ' e ',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              TextSpan(
                text: 'condições',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
