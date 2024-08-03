import 'dart:io';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_partilhas.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:ficha3/centro_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ficha3/MAIN.dart';

import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_centro.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoadingScreen extends StatefulWidget {
  final int userId;

  LoadingScreen({required this.userId});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late int user_id;
  String nome = '';
  String sobrenome = '';
  String caminhoFoto = '';

  @override
  void initState() {
    super.initState();
    criarPastaParaGuardarImagens();
    _carregarDados();
  }

  Future<void> criarPastaParaGuardarImagens() async {
    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final newFolder = Directory('${directory!.path}/ALL_IMAGES');
      if (!(await newFolder.exists())) {
        await newFolder.create(recursive: true);
      }
      print('Pasta criada em: ${newFolder.path}');
    } else {
      print('Permissão negada.');
    }
  }

  Future<Map<String, dynamic>> fetchUserDetails(int userId) async {
    final String apiUrl =
        'https://backend-teste-q43r.onrender.com/users/detalhes_user/$userId';

         String? jwtToken = TokenService().getToken(); 
    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(Uri.parse(apiUrl),headers: {
        'Authorization': 'Bearer $jwtToken', 
      });

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<void> _carregarDados() async {
    try {
      var userDetails = await fetchUserDetails(widget.userId);
      setState(() {
        nome = userDetails['nome'];
        sobrenome = userDetails['sobrenome'];
        caminhoFoto = userDetails['caminho_foto'];
      });

      print('Iniciando o carregamento dos dados dos centros...');
      await ApiService().fetchAndStoreCentros();
      print('Dados dos centros carregados com sucesso.');

      print('Iniciando o carregamento dos dados dos usuários...');
      await ApiUsuarios().fetchAndStoreUsuarios();
      print('Dados dos usuários carregados com sucesso.');

      // Definir provedores
      await _definirProvedores(widget.userId);

      // Carregar partilhas depois de definir os provedores
      final centroProvider =
          Provider.of<Centro_Provider>(context, listen: false);
      final centroSelecionado = centroProvider.centroSelecionado;
      if (centroSelecionado != null) {
        print('Iniciando o carregamento dos dados das partilhas...');
        await ApiPartilhas().fetchAndStorePartilhas(centroSelecionado.id);
        print('Dados das partilhas carregados com sucesso.');

        print('Iniciando o carregamento dos comentários das partilhas...');
        await ApiPartilhas().fetchAndStoreComentarios();
        print('Dados dos comentários das partilhas carregados com sucesso.');

        print('Iniciando o carregamento dos likes das partilhas...');
        await ApiPartilhas().fetchAndStoreLikes(centroSelecionado.id);
        print('Dados dos likes das partilhas carregados com sucesso.');
      } else {
        print('Nenhum centro selecionado');
        throw Exception('Nenhum centro selecionado');
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MinhaPaginaInicial(userId: widget.userId.toString())),
        (Route<dynamic> route) =>
            false, // Isto assegura que todas as rotas anteriores sejam removidas
      );
    } catch (e) {
      print('Erro ao carregar os dados: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/sem_wifi.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 5),
              Text(
                'Não foi possível carregar os dados !!!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Verifique sua conexão com a internet e tente novamente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _carregarDados();
              },
              child: Text('Tentar Novamente',
                  style: TextStyle(color: Color(0xFF15659F))),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _definirProvedores(int userId) async {
    // Se houver usuários carregados, selecione o usuário com o userId passado
    var usuarioSelecionado =
        await Funcoes_Usuarios.consultaUsuarioPorId(userId);
    if (usuarioSelecionado != null) {
      Provider.of<Usuario_Provider>(context, listen: false).selecionarUsuario(
        Usuario(
          centro_id: usuarioSelecionado['centro_id'],
          id_user: usuarioSelecionado['id'],
          nome: usuarioSelecionado['nome'],
          sobrenome: usuarioSelecionado['sobrenome'],
          foto: usuarioSelecionado['caminho_foto'],
          fundo: usuarioSelecionado['caminho_fundo'],
          sobre_min: usuarioSelecionado['sobre_min'],
        ),
      );

      // Informações do centro na base de dados
      List<Map<String, dynamic>> centrosCarregados =
          await Funcoes_Centros.consultaCentros();
      var centroAssociado = centrosCarregados.firstWhere(
          (centro) => centro['id'] == usuarioSelecionado['centro_id']);

      Provider.of<Centro_Provider>(context, listen: false).selecionarCentro(
        Centro(
          id: centroAssociado['id'],
          nome: centroAssociado['nome'],
          morada: centroAssociado['morada'],
          imagem: centroAssociado['imagem_centro'],
        ),
      );
      print(
          'Usuário selecionado: id=${usuarioSelecionado['id']}, nome=${usuarioSelecionado['nome']} ${usuarioSelecionado['sobrenome']}');
      print(
          'Centro selecionado: id=${centroAssociado['id']}, nome=${centroAssociado['nome']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 20,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Bem vindo(a) ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF15659F),
                fontSize: 32,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
                height: 1.5,
                letterSpacing: 0.15,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 5),
            CircleAvatar(
              radius: 65,
              backgroundImage: caminhoFoto.isNotEmpty
                  ? NetworkImage(caminhoFoto)
                  : AssetImage('assets/images/user_padrao.jpg')
                      as ImageProvider,
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 15),
            Text(
              '$nome $sobrenome',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
            Spacer(),
            customCircularProgress(),
            SizedBox(height: 35),
            Text(
              '... por favor aguarde alguns segundos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7E868D),
                fontSize: 16,
                fontFamily: 'ABeeZee',
                fontWeight: FontWeight.w400,
                height: 0.09,
              ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}

Widget customCircularProgress() {
  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: 60,
        height: 60,
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF15659F)),
        ),
      ),
      Image.asset(
        'assets/images/circulo_progresso.png',
        width: 35,
        height: 35,
        fit: BoxFit.cover,
      ),
    ],
  );
}
