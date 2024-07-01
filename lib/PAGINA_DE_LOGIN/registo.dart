import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:flutter/material.dart';

import 'login_email.dart';


class Registo extends StatelessWidget {
  Registo({Key? key}) : super(key: key);

  final GlobalKey<_CheckboxExampleState> _checkboxKey =
      GlobalKey<_CheckboxExampleState>();
  final GlobalKey<_RegisterPageState> _emailKey =
      GlobalKey<_RegisterPageState>();
  final GlobalKey<_MyDropdownState> _dropdownKey =
      GlobalKey<_MyDropdownState>();
  final GlobalKey<_ContactoState> _contactoKey = GlobalKey<_ContactoState>();

  bool _todosCamposValidos() {
    return (_emailKey.currentState?.isValid() ?? false) &&
        //(_dropdownKey.currentState?.isValid() ?? false) &&
        (_contactoKey.currentState?.isValid() ?? false) &&
        (_checkboxKey.currentState?.getIsChecked() ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RegisterPage(key: _emailKey),
            const SizedBox(height: 10),
            const Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Centro a que pertences',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            MyDropdown(key: _dropdownKey),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contacto',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Contacto(key: _contactoKey),
            const SizedBox(
              height: 10,
            ),
            CheckboxExample(key: _checkboxKey),
            const SizedBox(
              height: 25,
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: const Color.fromARGB(255, 21, 101, 159),
                textStyle: const TextStyle(fontSize: 20),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                if (_todosCamposValidos()) {
                  final email = _emailKey.currentState?.getEmail();

                 /* Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const ConfirmacaoEmail(),
                    ),
                  );*/

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
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _emailController;
  String _email = '';
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_emailListen);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _emailListen() {
    setState(() {
      _email = _emailController.text;
      if (_email.isEmpty) {
        _emailError = 'O campo de email não pode estar vazio';
      } else {
        _emailError = null;
      }
    });
  }

  bool isValid() {
    return _email.isNotEmpty;
  }

  String getEmail() {
    return _email;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: Colors.grey, // Cinza claro para a borda
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: Colors.grey, // Cinza claro para a borda
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: Colors.grey, // Cinza claro para a borda
                ),
              ),
              hintText: 'Insere o teu email',
              hintStyle: const TextStyle(
                color: Colors.grey, // Define a cor do hintText
              ),
              errorText: _emailError,
            ),
          ),
        ),
      ],
    );
  }
}

class MyDropdown extends StatefulWidget {
  const MyDropdown({Key? key}) : super(key: key);

  @override
  _MyDropdownState createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  String? _selectedValue;
  late DatabaseHelper db;
  List<Map<String, dynamic>> centros = [];

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _listarCentros();
  }

  Future<void> _listarCentros() async {
   // final centrosList = await db.;
    setState(() {
     // centros = centrosList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: DropdownButtonFormField<String>(
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
              color: Colors.grey, // Cinza claro para a borda
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: const BorderSide(
              color: Colors.grey, // Cinza claro para a borda
            ),
          ),
        ),
        hint: const Text(
          'Selecione um centro',
          style: TextStyle(
            color: Colors.grey, // Define a cor do hintText
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
      ),
    );
  }
}

class Contacto extends StatefulWidget {
  const Contacto({Key? key}) : super(key: key);

  @override
  _ContactoState createState() => _ContactoState();
}

class _ContactoState extends State<Contacto> {
  late TextEditingController _contactoController;
  String? _contactoError;
  String _contacto = '';

  @override
  void initState() {
    super.initState();
    _contactoController = TextEditingController();
    _contactoController.addListener(_contactoListen);
  }

  @override
  void dispose() {
    _contactoController.dispose();
    super.dispose();
  }

  void _contactoListen() {
    setState(() {
      _contacto = _contactoController.text;
      if (_contacto.isEmpty) {
        _contactoError = 'O campo de contato não pode estar vazio';
      } else {
        _contactoError = null;
      }
    });
  }

  bool isValid() {
    return _contacto.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: TextField(
            keyboardType: TextInputType.number,
            controller: _contactoController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: Colors.grey, // Cinza claro para a borda
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: Colors.grey, // Cinza claro para a borda
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(
                  color: Colors.grey, // Cinza claro para a borda
                ),
              ),
              hintText: 'Digite seu contato aqui',
              hintStyle: const TextStyle(
                color: Colors.grey, // Define a cor do hintText
              ),
              errorText: _contactoError,
            ),
          ),
        ),
      ],
    );
  }
}

class CheckboxExample extends StatefulWidget {
  const CheckboxExample({super.key});

  @override
  State<CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<CheckboxExample> {
  bool isChecked = false;

  bool getIsChecked() {
    return isChecked;
  }

  @override
  Widget build(BuildContext context) {
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
