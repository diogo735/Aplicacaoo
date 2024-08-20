import 'dart:io';

import 'package:ficha3/BASE_DE_DADOS/ver_estruturaBD.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/usuario_provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_principal/pagina_principal_do_grupo.dart';

class Pag_Notificacoes extends StatefulWidget {
  const Pag_Notificacoes({super.key});

  @override
  _Pag_NotificacoesState createState() => _Pag_NotificacoesState();
}

class _Pag_NotificacoesState extends State<Pag_Notificacoes>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    //carregarGrupos();
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 85, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Não existem notificações !!!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mark_email_read_outlined, size: 85, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Não existem mensagens !!!',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () async {
              await mostrarEstruturaEdadosBancoDados();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Estrutura e dados exibidos no console'),
                ),
              );
            },
            child: Text('Mostrar Estrutura do Banco de Dados'),
          ),
        ],
      ),
    );
  }
}
