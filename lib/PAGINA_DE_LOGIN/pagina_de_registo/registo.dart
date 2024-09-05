import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
  bool _isloading = false;
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

  Future<String> _uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.imgbb.com/1/upload'),
    );
    request.fields['key'] = '4d755673a2dc94483064445f4d5c54e9';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);
      return jsonData['data']['url'];
    } else {
      throw Exception('Failed to upload image');
    }
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

  Future<void> _pickImage2() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _caminhoFundoController.text = image.path;
      });
    }
  }

  Future<String> _senhaTemp() async {
    var tempPass = await ApiRecuperarPasse.generateTemporaryPassword();
    return tempPass;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isloading = true; // Iniciar o carregamento
      });

      // Capturar os dados do formulário
      final nome = _nomeController.text;
      final sobrenome = _sobrenomeController.text;
      final email = _emailController.text;
      final senha=_passwordController.text;
      //final senhaTemporaria = await _senhaTemp();
      final sobreMin = _sobreMinController.text;
      final centroId = _selectedCentro;
      String? caminhoFoto = _caminhoFotoController.text.isNotEmpty
          ? _caminhoFotoController.text
          : null;
      String? caminhoFundo = _caminhoFundoController.text.isNotEmpty
          ? _caminhoFundoController.text
          : null;

      try {
        // Fazer upload da imagem de foto (se selecionada)
        if (caminhoFoto != null) {
          File fotoFile = File(caminhoFoto);
          caminhoFoto = await _uploadImage(fotoFile); // URL da foto
        }

        // Fazer upload da imagem de fundo (se selecionada)
        if (caminhoFundo != null) {
          File fundoFile = File(caminhoFundo);
          caminhoFundo = await _uploadImage(fundoFile); // URL do fundo
        }

        // Criar o novo usuário com os links das imagens
        Map<String, dynamic> novoUsuario = {
          "nome": nome,
          "sobrenome": sobrenome,
          "email": email,
          "pass": senha,//senhaTemporaria,
          "sobre_min": sobreMin,
          "centro_id": int.parse(centroId!),
          "caminho_foto": caminhoFoto,
          "caminho_fundo": caminhoFundo,
        };

        print('Dados enviados para o servidor: $novoUsuario');

        await apiuser.criarUsuario(novoUsuario);

        // Mostrar uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrado com sucesso!')),
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
          SnackBar(content: Text('Erro ao registrar usuário: $e')),
        );
      } finally {
        setState(() {
          _isloading = false; // Finalizar o carregamento
        });
      }
    }
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
                      onPressed: _pickImage2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                 ElevatedButton(
                  onPressed: _isloading ? null : _submitForm,
                  child: _isloading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 26, 90, 217),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
