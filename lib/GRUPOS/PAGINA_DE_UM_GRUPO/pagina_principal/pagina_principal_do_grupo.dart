import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_user_menbro_grupos.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_calendario_do_grupo/calendario_do_grupo.dart';
import 'package:ficha3/PROVIDERS_GLOBAL_NA_APP/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_mesnagens_grupos.dart';
import 'dart:async';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_principal/card_mensagem_grupo.dart';
import 'package:provider/provider.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_usuarios.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/paginal_lista_menbros/pagina_lista_users_do_grupo.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_da_galeria_E_docs/pagina_galeria_docs.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_menbro/pagina_defenicoes_menbro.dart';
import 'package:ficha3/GRUPOS/PAGINA_DE_UM_GRUPO/pagina_defenicoes_do_grupo/grupo_defenicoes_dono/pagina_defeniçoes_dono.dart';

class pagina_principal_grupo extends StatefulWidget {
  final int idGrupo;

  const pagina_principal_grupo({super.key, required this.idGrupo});
  @override
  _pagina_principal_grupoState createState() => _pagina_principal_grupoState();
}

class _pagina_principal_grupoState extends State<pagina_principal_grupo> {
  late Timer _timer;
  Map<String, dynamic>? grupo;
  List<Map<String, dynamic>> mensagens = [];
  final controller = TextEditingController();

  List<Map<String, dynamic>> listaUsuarios = [];
  late int user_id;
  final FocusNode _focusNode = FocusNode();
  bool showMemberList = false;
  bool _showTextField = false;
  bool mostrarresposta = false;
  Map<String, dynamic>? mensagemtoreply;
  Map<int, String> userNames = {};
  @override
  void initState() {
    super.initState();
    _carregarDados();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _carregarDados();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _carregarDados() async {
    final grupoCarregado =
        await Funcoes_Grupos.detalhes_do_grupo(widget.idGrupo);
    final mensagensCarregadas =
        await Funcoes_Mensagens_Grupos.obterMensagensPorGrupoID(widget.idGrupo);

    List<int> idsdos_users =
        await Funcoes_User_menbro_grupos.obterUsuariosDoGrupo(widget.idGrupo);
    List<Map<String, dynamic>> users = [];

    for (int userId in idsdos_users) {
      String nomeCompleto =
          await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(userId);
      String caminhoFoto =
          await Funcoes_Usuarios.consultaCaminhoFotoUsuarioPorId(userId);

      users.add({
        'id': userId,
        'nome': nomeCompleto,
        'caminho_foto': caminhoFoto,
      });
    }

    List<Map<String, dynamic>> mensagensOrdenadas =
        List.from(mensagensCarregadas);
    mensagensOrdenadas.sort((a, b) {
      DateTime dataA = DateTime(
        a['ano'],
        a['mes'],
        a['dia'],
        a['hora'],
        a['minutos'],
        a['segundos'],
      );
      DateTime dataB = DateTime(
        b['ano'],
        b['mes'],
        b['dia'],
        b['hora'],
        b['minutos'],
        b['segundos'],
      );
      return dataB.compareTo(dataA);
    });

    setState(() {
      grupo = grupoCarregado;
      mensagens = mensagensCarregadas;
      listaUsuarios = users;
      _carregarNomesUsuarios();
    });
  }

  void _carregarNomesUsuarios() async {
    for (var mensagem in mensagens) {
      String userName = await Funcoes_Usuarios.consultaNomeCompletoUsuarioPorId(
          mensagem['user_id']);
      userNames[mensagem['user_id']] = userName;
      setState(() {
        userNames = userNames;
      });
    }
  }

  void replicarmensagem(int idmensagem) {
    final mensagem = mensagens.firstWhere((msg) => msg['id'] == idmensagem,
        orElse: () => {});
    setState(() {
      mostrarresposta = true;
      _showTextField = true;
      mensagemtoreply = mensagem;
      _focusNode.requestFocus();
    });
  }

  void inserirMensagem() async {
    String mensagemTexto = controller.text.trim();
    if (mensagemTexto.isNotEmpty) {
      DateTime now = DateTime.now();
      await Funcoes_Mensagens_Grupos().inserirMensagemNoBancoDeDados(
        segundos: now.second,
        grupoId: widget.idGrupo,
        userId: user_id,
        textoMensagem: mensagemTexto,
        dia: now.day,
        mes: now.month,
        ano: now.year,
        hora: now.hour,
        minutos: now.minute,
      );

      controller.clear();
      FocusScope.of(context).unfocus();
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider =
        Provider.of<Usuario_Provider>(context, listen: false);
    user_id = 2;////usuarioProvider.usuarioSelecionado!.id_user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF15659F),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 3.0),
            child: IconButton(
              padding: const EdgeInsets.all(3),
              icon: const Icon(Icons.settings),
              onPressed: () {
                if (user_id == grupo!['admintrador_id']) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pag_defenicoes_dono(
                        idGrupo: widget.idGrupo,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pag_defenicoes_menbro(
                        idGrupo: widget.idGrupo,
                      ),
                    ),
                  );
                }
              },
              iconSize: 23,
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 246, 246, 246),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      grupo?['foto_de_capa'] ??
                          'assets/images/imagens_grupos/sem_capa.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15),
                            CircleAvatar(
                              radius: 37,
                              backgroundImage: AssetImage(
                                grupo?['caminho_imagem'] ??
                                    'assets/images/imagens_grupos/sem_avatar.png',
                              ),
                            ),
                            Text(
                              grupo?['nome'] ?? 'Sem Nome',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.50,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF23FF00),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  '15 online',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.people,
                                      color: const Color(0xFF15659F),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Pag_Users_do_grupo(
                                                    idGrupo: widget.idGrupo,
                                                  )));
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 9,
                                ),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.image_search,
                                        color: const Color(0xFF15659F),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Pag_Galeria_do_grupo(
                                                      idGrupo: widget.idGrupo,
                                                    )));
                                      }),
                                ),
                                SizedBox(
                                  width: 9,
                                ),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  child: IconButton(
                                      icon: Icon(
                                        Icons.calendar_month_rounded,
                                        color: const Color(0xFF15659F),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CALENDARIO_DO_GRUPO(
                                                      idGrupo: widget.idGrupo,
                                                    )));
                                      }),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                            SizedBox(height: 9),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(15, 15, 0, 65),
                    reverse: true,
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) {
                      //final mensagem = mensagens[index];
                      final mensagem = mensagens[mensagens.length - 1 - index];

                      return Column(
                        children: [
                          SizedBox(height: 10),
                          SwipeTo(
                            iconColor: const Color(0xFF15659F),
                            onRightSwipe: (details) {
                              print(
                                  'ID da mensagem ENVIADDO: ${mensagens[mensagens.length - 1 - index]['id']}');
                              replicarmensagem(
                                  mensagens[mensagens.length - 1 - index]['id']
                                      as int);
                            },
                            swipeSensitivity: 5,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: CARD_COMENTAARIO_grupo(
                                idComentario: mensagem['id'] as int,
                                userId: mensagem['user_id'] as int,
                                dia: mensagem['dia'].toString(),
                                mes: mensagem['mes'].toString(),
                                ano: mensagem['ano'].toString(),
                                horas: mensagem['hora'].toString(),
                                minutos: mensagem['minutos'].toString(),
                                textoComentario:
                                    mensagem['texto_mensagem'] as String,
                                idgrupo: widget.idGrupo,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 5,
            right: 5,
            child: Container(
              width: MediaQuery.of(context).size.width - 10,
              decoration: BoxDecoration(
                color: const Color(0xFF15659F),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox.shrink(),
                  IconButton(
                    onPressed: () {},
                    icon: Transform.rotate(
                      angle: 45 * 3.1415926535 / 180,
                      child: const Icon(
                        Icons.link,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox.shrink(),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'mensagem...',
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontFamily: 'ABeeZee'),
                        border: InputBorder.none,
                      ),
                      onChanged: (text) {
                        setState(() {
                          showMemberList =
                              text.endsWith('@') && _focusNode.hasFocus;
                        });
                      },
                      focusNode: _focusNode,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () async {
                      inserirMensagem();
                    },
                    icon: Transform.rotate(
                      angle: 320 * 3.1415926535 / 180,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 65,
            left: 5,
            right: 5,
            child: Visibility(
                visible: showMemberList,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.separated(
                    itemCount: listaUsuarios.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        // Linha divisória fina
                        color: Color.fromARGB(141, 21, 102, 159),
                        thickness: 0.5,
                        height: 0,
                      );
                    },
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              AssetImage(listaUsuarios[index]['caminho_foto']),
                        ),
                        title: Text(
                          listaUsuarios[index]['nome'],
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                        ),
                        onTap: () {
                          insertMentionedUser(listaUsuarios[index]['nome']);
                          setState(() {
                            showMemberList = false;
                          });
                        },
                      );
                    },
                  ),
                )),
          ),
          if (mostrarresposta && mensagemtoreply != null)
            Positioned(
              bottom: 65,
              left: 5,
              right: 5,
              child: Visibility(
                visible: mostrarresposta,
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(minHeight: 50),
                      width: MediaQuery.of(context).size.width - 10,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color.fromARGB(92, 19, 84, 130),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 241, 243, 242),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF15659F),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                  ),
                                ),
                                width: 7,
                                height: calculateHeight(
                                    mensagemtoreply?['texto_mensagem'] ?? ''),
                              ),
                              SizedBox(width: 5),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 5, right: 3, bottom: 3),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userNames[
                                                mensagemtoreply?['user_id']] ??
                                            '...',
                                        style: TextStyle(
                                          color: const Color(0xFF15659F),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        mensagemtoreply?['texto_mensagem'] ??
                                            '',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(136, 21, 102, 159),
                                          fontSize: 14,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            mostrarresposta = false;
                            mensagemtoreply = null;
                          });
                        },
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: Color.fromARGB(255, 49, 105, 145),
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

  double calculateHeight(String text) {
    int textLength = text.length;
    if (textLength < 40) {
      return 50;
    } else if (textLength >= 40 && textLength <= 80) {
      return 70;
    } else {
      return 90;
    }
  }
void insertMentionedUser(String username) {
  final String text = controller.text;
  final int cursorPosition = controller.selection.baseOffset;
  final int adjustedCursorPosition = cursorPosition.clamp(0, text.length);

  String newText;
  int newCursorPosition;

  if (text.isEmpty || (adjustedCursorPosition > 0 && text == '@')) {

    // se for  apenas "@"
    newText = '@$username ';
    newCursorPosition = username.length + 2;
  } else if (adjustedCursorPosition > 0 && text[adjustedCursorPosition - 1] == '@') {
    // se tem "@" com ou sem espaço antes

    bool hasLeadingSpace = adjustedCursorPosition > 1 && text[adjustedCursorPosition - 2] == ' ';
    if (hasLeadingSpace) {
      // existe um espaço antes do "@"
      newText = '${text.substring(0, adjustedCursorPosition - 1)}@$username ${text.substring(adjustedCursorPosition)}';
      newCursorPosition = adjustedCursorPosition - 1 + username.length + 2;
    } else {
      //  não existe um espaço antes do "@"
      newText = '${text.substring(0, adjustedCursorPosition - 1)} @$username ${text.substring(adjustedCursorPosition)}';
      newCursorPosition = adjustedCursorPosition + username.length + 2;
    }
  } else {
    // Caso padrão
    newText = '${text.substring(0, adjustedCursorPosition)}@$username ${text.substring(adjustedCursorPosition)}';
    newCursorPosition = adjustedCursorPosition + username.length + 2;
  }


  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: newCursorPosition),
  );
}



}
