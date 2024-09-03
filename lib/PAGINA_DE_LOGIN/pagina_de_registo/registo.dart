import 'package:ficha3/BASE_DE_DADOS/APIS/api_recuperar_passe.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Registo extends StatefulWidget {
  @override
  _RegistoState createState() => _RegistoState();
}

class _RegistoState extends State<Registo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _sobreMinController = TextEditingController();
  final TextEditingController _caminhoFotoController = TextEditingController();
  final TextEditingController _caminhoFundoController = TextEditingController();
  final apiuser = ApiUsuarios();

  String? _selectedCentro;
  final List<Map<String, dynamic>> _centros = [];

  @override
  void initState() {
    super.initState();
    _listarCentros();
  }

  Future<void> _listarCentros() async {
    final centrosList = await Funcoes_Centros.consultaCentros();
    setState(() {
      _centros.addAll(centrosList);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _caminhoFotoController.text = image.path;
      });
    }
  }

  Future<String> _senhaTemp() async {
    var tempPass = await ApiRecuperarPasse.generateTemporaryPassword();
    return tempPass;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuário'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sobrenomeController,
                  decoration: InputDecoration(labelText: 'Sobrenome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu sobrenome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _sobreMinController,
                  decoration: InputDecoration(labelText: 'Sobre mim'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição sobre você';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Centro'),
                  value: _selectedCentro,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCentro = newValue;
                    });
                  },
                  items: _centros.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> centro) {
                    return DropdownMenuItem<String>(
                      value: centro['id'].toString(),
                      child: Text(centro['nome']),
                    );
                  }).toList(),
                  /*
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, selecione um centro';
                    }
                    return null;
                  },*/
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _caminhoFotoController,
                  decoration: InputDecoration(
                    labelText: 'Caminho da Foto (Opcional)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: _pickImage,
                    ),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _caminhoFundoController,
                  decoration: InputDecoration(
                    labelText: 'Caminho do Fundo  (Opcional)',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: _pickImage,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Capturar os dados do formulário
                      final nome = _nomeController.text;
                      final sobrenome = _sobrenomeController.text;
                      final email = _emailController.text;
                      final senhaTemporaria = await _senhaTemp();
                      final sobreMin = _sobreMinController.text;
                      final centroId = _selectedCentro;
                      final caminhoFoto = _caminhoFotoController.text.isEmpty
                          ? null
                          : _caminhoFotoController.text;
                      final caminhoFundo = _caminhoFundoController.text.isEmpty
                          ? null
                          : _caminhoFundoController.text;

                      // Inserir os dados do usuário no banco de dados
                      Map<String, dynamic> novoUsuario = {
                        "nome": nome,
                        "sobrenome": sobrenome,
                        "email": email,
                        "pass": senhaTemporaria,
                        "sobre_min": sobreMin,
                        //"centro_id": int.parse(centroId!),
                        "centro_id": 1,
                        "caminho_foto": caminhoFoto,
                        "caminho_fundo": caminhoFundo,
                      };

                      print('Dados enviados para o servidor: $novoUsuario');

                      try {
                        await apiuser.criarUsuario(novoUsuario);

                        // Mostrar uma mensagem de sucesso
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registrado com sucesso!')),
                        );

                        // Limpar o formulário
                        _formKey.currentState!.reset();
                        setState(() {
                          _selectedCentro = null;
                          _caminhoFotoController.clear();
                          _caminhoFundoController.clear();
                        });
                      } catch (e) {
                        // Exibir mensagem de erro se algo der errado
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Erro ao registrar usuário: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
