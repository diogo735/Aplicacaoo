import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:flutter/widgets.dart';

class Pag_defenicao_detalhesgrupo extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicao_detalhesgrupo({super.key, required this.idGrupo});

  @override
  _Pag_defenicao_detalhesgrupoState createState() =>
      _Pag_defenicao_detalhesgrupoState();
}

class _Pag_defenicao_detalhesgrupoState
    extends State<Pag_defenicao_detalhesgrupo> {
  Map<String, dynamic>? grupo;
  TextEditingController _nomeGrupoController = TextEditingController();
  TextEditingController _descricaoGrupoController = TextEditingController();
  String nome_original = '';
  String descricao_original = '';
  int _currentLength = 0;
  final int _maxLength = 200;

  int _currentLenght_nome = 0;
  final int _maxLength_nome = 14;

  bool _dadosAlterados_descricao = false;
  bool _dadosAlterados_nome = false;

  @override
  void initState() {
    super.initState();
    _carregardetalhesdogrupo();
    _descricaoGrupoController.addListener(_updateLength);
    _nomeGrupoController.addListener(_updateLength);
  }

  void _carregardetalhesdogrupo() async {
    final grupoCarregado =
        await Funcoes_Grupos.detalhes_do_grupo(widget.idGrupo);
    setState(() {
      grupo = grupoCarregado;
      if (grupo != null) {
        _nomeGrupoController.text = grupo!['nome'];
        nome_original = grupo!['nome'];
      }
      if (grupo != null) {
        _descricaoGrupoController.text = grupo!['descricao_grupo'];
        descricao_original = grupo!['descricao_grupo'];
      }
      _currentLength = _descricaoGrupoController.text.length;
      _currentLenght_nome = _nomeGrupoController.text.length;
    });
  }

  @override
  void dispose() {
    _nomeGrupoController.dispose();
    _descricaoGrupoController.dispose();

    super.dispose();
  }

  void _updateLength() {
    setState(() {
      _currentLength = _descricaoGrupoController.text.length;
      _currentLenght_nome = _nomeGrupoController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do Grupo',
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.w800,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color(0xFF15659F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informações',
                style: TextStyle(
                  color: Color(0xFF15659F),
                  fontSize: 20,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.15,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 0.50,
                    color: const Color(0xFFCAC4D0),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Nome do Grupo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  TextField(
                    controller: _nomeGrupoController,
                    cursorColor: Color(0xFF15659F),
                    decoration: InputDecoration(
                      //hintText: grupo != null ? grupo!['nome'] : 'Nome',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF15659F)),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != nome_original) {
                        setState(() {
                          _dadosAlterados_nome = true;
                        });
                      } else {
                        setState(() {
                          _dadosAlterados_nome = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '$_currentLenght_nome /$_maxLength_nome',
                      style: TextStyle(
                        fontSize: 12,
                        color: _currentLenght_nome <= _maxLength_nome
                            ? Colors.black
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Descrição do Grupo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  TextFormField(
                      controller: _descricaoGrupoController,
                      minLines: 5,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      cursorColor: const Color(0xFF15659F),
                      decoration: InputDecoration(
                        //hintText: ,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF15659F)),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != descricao_original) {
                          setState(() {
                            _dadosAlterados_descricao = true;
                          });
                        } else {
                          setState(() {
                            _dadosAlterados_descricao = false;
                          });
                        }
                      }),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '$_currentLength/$_maxLength',
                      style: TextStyle(
                        fontSize: 12,
                        color: _currentLength <= _maxLength
                            ? Colors.black
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 200),
              if ((_dadosAlterados_nome &&
                      _currentLenght_nome <= _maxLength_nome) ||
                  (_dadosAlterados_descricao && _currentLength <= _maxLength))
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 1,
                          backgroundColor: const Color(0xFF15659F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.only(left: 15, right: 15),
                        ),
                        onPressed: () async {
                          bool sucessoNome = false;
                          bool sucessoDescricao = false;
                          if (_dadosAlterados_nome &&
                              _currentLenght_nome <= _maxLength_nome) {
                            String novoNome = _nomeGrupoController.text;
                            sucessoNome =
                                await Funcoes_Grupos.atualizarNomeDoGrupo(
                                    widget.idGrupo, novoNome);
                          }
                          if (_dadosAlterados_descricao &&
                              _currentLength <= _maxLength) {
                            String novadescricao =
                                _descricaoGrupoController.text;
                            sucessoDescricao =
                                await Funcoes_Grupos.atualizarDescricaoDoGrupo(
                                    widget.idGrupo, novadescricao);
                          }
                          if (sucessoNome || sucessoDescricao) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Detalhes do grupo atualizados com sucesso !'),
                                duration: Duration(seconds: 3),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            setState(() {
                              _dadosAlterados_nome = false;
                              _dadosAlterados_descricao = false;
                              _carregardetalhesdogrupo();
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Erro ao atualizar!'),
                                duration: Duration(seconds: 1),
                                backgroundColor:
                                    Color.fromARGB(255, 211, 33, 33),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.save,
                              size: 25,
                              color: Colors.white,
                            ),
                            SizedBox(width: 13),
                            Text(
                              'Guardar alterações',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
