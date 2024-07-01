import 'package:flutter/material.dart';
import '../BASE_DE_DADOS/basededados.dart';
import '../BASE_DE_DADOS/ver_estruturaBD.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_eventos.dart';

/*
class notificacoes_pagina extends StatelessWidget {
  const notificacoes_pagina({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: const Center(
        child: Text(
          'Página de Notificações',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
*/

class EventosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaEventosScreen()),
                );
              },
              child: Text('Mostrar Eventos'),
            ),
            ElevatedButton(
              onPressed: () {
                mostrarEstruturaEdadosBancoDados();
              },
              child: Text('Estrutura BD'),
            )
          ],
        ),
      ),
    );
  }
}

class ListaEventosScreen extends StatefulWidget {
  @override
  _ListaEventosScreenState createState() => _ListaEventosScreenState();
}

class _ListaEventosScreenState extends State<ListaEventosScreen> {
  final dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> eventos = [];

  @override
  void initState() {
    super.initState();
    _buscarEventos();
  }

  Future<void> _buscarEventos() async {
  Funcoes_Eventos funcoesEventos = Funcoes_Eventos();// Crie uma instância de Funcoes_Eventos

    final listaEventos = await funcoesEventos.consultaEventos();
    setState(() {
      eventos = listaEventos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Eventos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _buscarEventos().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('BD atualizada com sucesso'),
                    backgroundColor: Colors.green,
                    duration: Duration(
                        seconds: 2), // Define a duração para 2 segundos
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return ListTile(
            title: Text(evento['nome']),
            subtitle: Text(evento['local']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesEventoScreen(evento: evento),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CriarEventoScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class CriarEventoScreen extends StatefulWidget {
  @override
  _CriarEventoScreenState createState() => _CriarEventoScreenState();
}

class _CriarEventoScreenState extends State<CriarEventoScreen> {
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _dataController = TextEditingController();
  TextEditingController _horasController = TextEditingController();
  TextEditingController _localController = TextEditingController();
  TextEditingController _caminhoimagemController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _dataController,
              decoration: InputDecoration(labelText: 'Data'),
            ),
            TextField(
              controller: _horasController,
              decoration: InputDecoration(labelText: 'Horas'),
            ),
            TextField(
              controller: _localController,
              decoration: InputDecoration(labelText: 'Local'),
            ),
            TextField(
              controller: _caminhoimagemController,
              decoration: InputDecoration(labelText: 'Caminho imagem'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para salvar o evento
                _salvarEvento();
              },
              child: Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _salvarEvento() {
    final String nome = _nomeController.text;
    final String data = _dataController.text;
    final String horas = _horasController.text;
    final String local = _localController.text;
    final String caminho_imagem = _caminhoimagemController.text;

    // Salva o novo evento no banco de dados
    //Funcoes_Eventos.salvarEvento(nome, data, horas, local, caminho_imagem);

    // Após salvar o evento, você pode fazer algo como navegar de volta para a tela anterior
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _horasController.dispose();
    _localController.dispose();
    _caminhoimagemController.dispose();
    super.dispose();
  }
}

class DetalhesEventoScreen extends StatelessWidget {
  final Map<String, dynamic> evento;

  DetalhesEventoScreen({required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Evento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Exibição da imagem do evento
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(evento['caminho_imagem']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16), // Espaçamento entre a imagem e os detalhes
            Text('Caminho da imagem: ${evento['caminho_imagem']}'),
            Text('Nome: ${evento['nome']}'),
            Text('Data: ${evento['data']}'),
            Text('Hora: ${evento['horas']}'),
            Text('Local: ${evento['local']}'),
            // Adicione mais detalhes conforme necessário

            // Botões para editar e apagar evento
            SizedBox(
                height:
                    20), // Espaçamento entre os detalhes do evento e os botões
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    // Navegar para a tela de edição do evento
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditarEventoScreen(evento: evento),
                      ),
                    );
                  },
                  child: Text('Editar'),
                ),
                SizedBox(width: 20), // Espaçamento entre os botões
                ElevatedButton(
                  onPressed: () {
                    // Apagar o evento da base de dados
                    //Funcoes_Eventos.apagarEvento(evento['id']);
                    // Navegar de volta para a tela anterior
                    Navigator.pop(context);
                  },
                  child: Text('Apagar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditarEventoScreen extends StatefulWidget {
  final Map<String, dynamic> evento;

  EditarEventoScreen({required this.evento});

  @override
  _EditarEventoScreenState createState() => _EditarEventoScreenState();
}

class _EditarEventoScreenState extends State<EditarEventoScreen> {
  late TextEditingController _nomeController;
  late TextEditingController _dataController;
  late TextEditingController _horasController;
  late TextEditingController _localController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.evento['nome']);
    _dataController = TextEditingController(text: widget.evento['data']);
    _horasController = TextEditingController(text: widget.evento['horas']);
    _localController = TextEditingController(text: widget.evento['local']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Evento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _dataController,
              decoration: InputDecoration(labelText: 'Data'),
            ),
            TextField(
              controller: _horasController,
              decoration: InputDecoration(labelText: 'Hora'),
            ),
            TextField(
              controller: _localController,
              decoration: InputDecoration(labelText: 'Local'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para salvar as alterações no evento
                _salvarAlteracoes();
              },
              child: Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }

  void _salvarAlteracoes() {
    // Obtenha os novos valores dos campos
    final novoNome = _nomeController.text;
    final novaData = _dataController.text;
    final novasHoras = _horasController.text;
    final novoLocal = _localController.text;

    // Atualize os detalhes do evento no banco de dados
    // Você precisará implementar o método para atualizar os detalhes do evento no banco de dados
    _atualizarEvento(
        widget.evento['id'], novoNome, novaData, novasHoras, novoLocal);

    // Retorne à tela anterior
    Navigator.pop(context);
  }

  void _atualizarEvento(
      int id, String nome, String data, String horas, String local) async {
    // Implemente o método para atualizar os detalhes do evento no banco de dados
    // Exemplo:
    final dbHelper = DatabaseHelper();
   // await Funcoes_Eventos.atualizarEvento(id, nome, data, horas, local);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    _horasController.dispose();
    _localController.dispose();
    super.dispose();
  }
}
