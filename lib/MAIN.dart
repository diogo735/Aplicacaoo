import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_eventos/pagina_De_um_evento/pagina_evento.dart';
import 'package:ficha3/AREAS/PAGINA_DE_UMA_AREA/sub_menu_partilhas/carregar_partilha.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_centro.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_login.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/basededados.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_centros.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';

import 'package:ficha3/PAGINA_DE_LOGIN/PaginaLogin.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/login_email.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/login_google.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/pagina_de_registo/registo.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_PERFIL/PAGINA_DE_PERFIL.dart';
import 'package:ficha3/PAGINA_INICIAL/PAGINA_VERTODOS/vertodos_eventos.dart';
import 'package:ficha3/PAGINA_loading_user.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/centro_provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/notificacao_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AREAS/Pagina_Das_areas_todas.dart';

import 'package:ficha3/GRUPOS/grupos.dart';

import 'package:ficha3/PAGINA_INICIAL/HOME.dart';

import 'package:ficha3/NOTIFICAÇÕES/NOTIFICACOES.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';

import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.basededados;
  TokenService().setToken(
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwiZW1haWwiOiJhZG1pbnZpc2V1QHNvZnRpbnNhLnB0IiwiaWF0IjoxNzIyMjkzNzM3LCJleHAiOjE3Mjc1NDk3Mzd9.0S97khTjH4SIdImVjae--MmvNDQqPHf3tQaI4lslB2U");
  final prefs = await SharedPreferences.getInstance();
  final bool estalogado = prefs.getBool('isLoggedIn') ?? false;
  final String? userId = prefs.getString('userId');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Usuario_Provider>(
          create: (context) => Usuario_Provider(),
        ),
        ChangeNotifierProvider(create: (_) => NotificacaoService()),
        ChangeNotifierProvider<Centro_Provider>(
          create: (context) => Centro_Provider(),
        ),
      ],
      child: MeuApp(estalogado: estalogado, userId: userId),
    ),
  );
}

class MeuApp extends StatelessWidget {
  final bool estalogado;
  final String? userId;

  MeuApp({required this.estalogado, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftShares',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // ThemeData&& userId
      //initialRoute: estalogado ? '/home' : '/', <- é para ser assim/pagina_de_um_evento
      initialRoute: '/PAGINA_COM_LOGO',
      routes: {
        '/home': (BuildContext context) => MinhaPaginaInicial(userId: userId),
        '/PAGINA_COM_LOGO': (context) => PAGINA_ICNICO_APENAS_LOGO(),
        '/': (context) => const PaginaLogin(),
        '/vereventos': (context) => vertodos_eventos(),
        '/pagina_de_um_evento': (context) => const PaginaEvento(idEvento: 1),
        //'/criar_partilha':(context) =>CriarPartilha(cor: Colors.blue,idArea: 2,),
        '/registo': (context) => Registo(),
        '/email': (context) => const LoginEmail(),
        '/loading': (context) => LoadingScreen(
              userId: 1,
            ),
        '/google': (context) => const LoginGoogle(),
        '/pagina_de_perfil': (context) => pagina_de_perfil(),
      },
    );
  }
}

class MinhaPaginaInicial extends StatefulWidget {
  final String? userId;

  MinhaPaginaInicial({this.userId});

  @override
  _MinhaPaginaInicialState createState() => _MinhaPaginaInicialState();
}

class _MinhaPaginaInicialState extends State<MinhaPaginaInicial> {
  int _indiceSelecionado = 0;
  List<Widget> _opcoes = [];



  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _definirProvedores(int.parse(widget.userId!));
    }
    _opcoes = [
      InicioPage(),
      const Pag_Areas(),
      const Pag_Grupos(),
      Pag_Notificacoes(),
    ];

    _loadCentros();
    
    int? userId = widget.userId != null ? int.tryParse(widget.userId!) : null;
 final notificacaoService = Provider.of<NotificacaoService>(context, listen: false);

    if (userId != null) {
      notificacaoService.startFetchingNotificacoesPeriodicamente(userId);
    } else {
      print('Erro: userId não é um número válido.');
    }
  }
 

  Future<void> _definirProvedores(int userId) async {
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

  Future<void> _loadCentros() async {
    //   await ApiService().fetchAndStoreCentros();
    //  setState(() {});
  }

  void _onItemTapped(int index) {
    setState(() {
      _indiceSelecionado = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        // Ícones escuros na barra de status
      ),
    );
    return Scaffold(
      body: Center(
        child: _opcoes.elementAt(_indiceSelecionado),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels:
            false, //não mostrar os rotulos para os intens selecionados
        showUnselectedLabels:
            false, //nao mostrar rótulos para itens nao selecionados
        unselectedItemColor:
            const Color(0xFFB9B6BB), // cor dos intens nao selecionados
        iconSize: 25.0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Areas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaoes',
          ),
        ],
        currentIndex: _indiceSelecionado,
        selectedItemColor: const Color(0xFF15659F),
        onTap: _onItemTapped,
      ),
    );
  }
}

class PAGINA_ICNICO_APENAS_LOGO extends StatefulWidget {
  @override
  _PAGINA_ICNICO_APENAS_LOGOState createState() =>
      _PAGINA_ICNICO_APENAS_LOGOState();
}

class _PAGINA_ICNICO_APENAS_LOGOState extends State<PAGINA_ICNICO_APENAS_LOGO> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      final bool estalogado = prefs.getBool('isLoggedIn') ?? false;
      final String? userId = prefs.getString('userId');
      final String rota = estalogado ? '/home' : '/';

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => rota == '/home'
                ? MinhaPaginaInicial(userId: userId)
                : const PaginaLogin()),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor:
            const Color(0xFF15659F), // Define a cor transparente
        systemNavigationBarIconBrightness:
            Brightness.light, // Deixa os ícones da barra de navegação claros
        // Deixa os ícones da barra de status claros
      ),
    );
    return Scaffold(
      backgroundColor: const Color(0xFF15659F),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height / 3),
            Image.asset(
              'assets/images/logo_sem_fundo.png',
              width: 125,
              height: 125,
            ),
            const SizedBox(height: 20),
            const Text(
              'SoftShares',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 4),
            const CupertinoActivityIndicator(
              color: Colors.white,
              radius: 21.0,
            ),
          ],
        ),
      ),
    );
  }
}
