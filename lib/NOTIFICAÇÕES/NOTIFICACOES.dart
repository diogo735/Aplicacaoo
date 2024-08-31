import 'dart:io';

import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_notificacoes.dart';
import 'package:ficha3/BASE_DE_DADOS/ver_estruturaBD.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_principal/pagina_principal_do_grupo.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Pag_Notificacoes extends StatefulWidget {
  const Pag_Notificacoes({super.key});

  @override
  _Pag_NotificacoesState createState() => _Pag_NotificacoesState();
}

class _Pag_NotificacoesState extends State<Pag_Notificacoes>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<Map<String, dynamic>> _notificacoes = [];
  List<Map<String, dynamic>> _mensagens = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Inicialize o plugin de notificações
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    final usuarioId = Provider.of<Usuario_Provider>(context, listen: false).usuarioSelecionado?.id_user;
    if (usuarioId != null) {
      final notificacoes = await Funcoes_Notificacoes.consultaNotificacoesPorUsuario(usuarioId);

      setState(() {
 
_mensagens = notificacoes.where((notificacao) => 
    notificacao['tipo'] == 'Evento Aprovado' || 
    notificacao['tipo'] == 'Novo Participante' ||
    notificacao['tipo'] == 'Novo Evento no Seu Tópico Favorito' ||
    notificacao['tipo'] == ' Nova Publicação no seu Tópico Favorito'
).toList();


_notificacoes = notificacoes.where((notificacao) => 
    notificacao['tipo'] != 'Evento Aprovado' && 
    notificacao['tipo'] != 'Novo Participante' &&
    notificacao['tipo'] != 'Novo Evento no Seu Tópico Favorito'&&
    notificacao['tipo'] != ' Nova Publicação no seu Tópico Favorito'
   
).toList();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.notifications,
              size: 30,
              color: Color(0xFF0A55C4),
            ),
            SizedBox(width: 12),
            Text(
              'Notificações',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF0A55C4),
                fontWeight: FontWeight.w800,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/pagina_de_perfil');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: Provider.of<Usuario_Provider>(context)
                              .usuarioSelecionado
                              ?.foto !=
                          null
                      ? FileImage(File(Provider.of<Usuario_Provider>(context)
                          .usuarioSelecionado!
                          .foto!))
                      : const AssetImage('assets/images/user_padrao.jpg')
                          as ImageProvider,
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF15659F),
          tabs: const [
            Tab(text: 'Notificações'),
            Tab(text: 'Mensagens'),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF6F6F6),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsTab(),
          _buildMessagesTab(),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    if (_notificacoes.isEmpty) {
      return const Center(
        child: Text(
          'Não existem notificações !!!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _notificacoes.length,
      itemBuilder: (context, index) {
        final notificacao = _notificacoes[index];
        return Dismissible(
          key: Key(notificacao['id'].toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            try {
              await ApiUsuarios().deleteNotificacao(notificacao['id']);
              _notificacoes.removeAt(index);
            } catch (error) {
              // Se falhar, re-adiciona o item à lista para não perder dados
              setState(() {
                _notificacoes.insert(index, notificacao);
              });
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: Icon(Icons.email_rounded, color: Color(0xFF15659F)),
            title: Text(
              notificacao['tipo'] ?? 'Notificação',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15659F),
              ),
            ),
            subtitle: Text(
              notificacao['mensagem'] ?? 'Sem descrição',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(223, 137, 136, 136),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // Ação ao clicar na notificação
            },
          ),
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    if (_mensagens.isEmpty) {
      return const Center(
        child: Text(
          'Não existem mensagens !!!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _mensagens.length,
      itemBuilder: (context, index) {
        final notificacao = _mensagens[index];
        return Dismissible(
          key: Key(notificacao['id'].toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            try {
              await ApiUsuarios().deleteNotificacao(notificacao['id']);
              _mensagens.removeAt(index);
            } catch (error) {
              // Se falhar, re-adiciona o item à lista para não perder dados
              setState(() {
                _mensagens.insert(index, notificacao);
              });
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: Icon(Icons.email_rounded, color: Color(0xFF15659F)),
            title: Text(
              notificacao['tipo'] ?? 'Notificação',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15659F),
              ),
            ),
            subtitle: Text(
              notificacao['mensagem'] ?? 'Sem descrição',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(223, 137, 136, 136),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              // Ação ao clicar na notificação
            },
          ),
        );
      },
    );
  }
}
