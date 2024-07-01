import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_grupos.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Pag_defenicao_disposicao extends StatefulWidget {
  final int idGrupo;

  const Pag_defenicao_disposicao({super.key, required this.idGrupo});

  @override
  _Pag_defenicao_disposicaoState createState() =>
      _Pag_defenicao_disposicaoState();
}

class _Pag_defenicao_disposicaoState extends State<Pag_defenicao_disposicao> {
  Map<String, dynamic>? grupo;
  File? imagemselecionada_FUNDO;
  String? caminhoNovaImagem_FUNDO;
  File? imagemselecionada_AVATAR;
  String? caminhoNovaImagem_AVATAR;

  @override
  void initState() {
    super.initState();
    _carregardetalhesdogrupo();
  }

  void _carregardetalhesdogrupo() async {
    final grupoCarregado =
        await Funcoes_Grupos.detalhes_do_grupo(widget.idGrupo);
    setState(() {
      grupo = grupoCarregado;
    });
  }

  Future _escolherimagemdaGalleria_AVATAR() async {
    final imagemretornada =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagemretornada == null) return;
    setState(() {
      imagemselecionada_AVATAR = File(imagemretornada.path);
      caminhoNovaImagem_AVATAR = imagemretornada.path;
    });
  }

  Future _tirarfotografiadaimagemCamara_AVATAR() async {
    final imagemretornada =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (imagemretornada == null) return;
    setState(() {
      imagemselecionada_AVATAR = File(imagemretornada.path);
      caminhoNovaImagem_AVATAR = imagemretornada.path;
    });
  }

  Future _escolherimagemdaGalleria_FUNDO() async {
    final imagemretornada =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagemretornada == null) return;
    setState(() {
      imagemselecionada_FUNDO = File(imagemretornada.path);
      caminhoNovaImagem_FUNDO = imagemretornada.path;
    });
  }

  Future _tirarfotografiadaimagemCamara_FUNDO() async {
    final imagemretornada =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (imagemretornada == null) return;
    setState(() {
      imagemselecionada_FUNDO = File(imagemretornada.path);
      caminhoNovaImagem_FUNDO = imagemretornada.path;
    });
  }

  void _mostraropcoesparaselecionarImagem(BuildContext context, int qual_foi) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Escolher da Galeria'),
                onTap: () {
                  if (qual_foi == 1) {
                    _escolherimagemdaGalleria_AVATAR();
                  } else if (qual_foi == 2) {
                    _escolherimagemdaGalleria_FUNDO();
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Tirar Foto'),
                onTap: () {
                  if (qual_foi == 1) {
                    _tirarfotografiadaimagemCamara_AVATAR();
                  } else if (qual_foi == 2) {
                    _tirarfotografiadaimagemCamara_FUNDO();
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Aparencia do Grupo(inacadado)',
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
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Avatar',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                          Text(
                            'Opcional',
                            style: TextStyle(
                              color: Color(0xFF79747E),
                              fontSize: 13,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w300,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _mostraropcoesparaselecionarImagem(context, 1);
                            },
                            child: CircleAvatar(
                                radius: 35,
                                backgroundImage:
                                    imagemselecionada_AVATAR != null
                                        ? Image.file(imagemselecionada_AVATAR!)
                                            .image
                                        : AssetImage(
                                            grupo?['caminho_imagem'] ??
                                                'assets/images/imagens_grupos/sem_capa.png',
                                          )),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: Color(0xFF15659F),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                onPressed: () =>
                                    _mostraropcoesparaselecionarImagem(
                                        context, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 0.50,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFCAC4D0),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plano de Fundo',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w400,
                            height: 0,
                          ),
                        ),
                        Text(
                          'Opecional',
                          style: TextStyle(
                            color: Color(0xFF79747E),
                            fontSize: 13,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  _mostraropcoesparaselecionarImagem(context, 2);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        grupo?['foto_de_capa'] ??
                            'assets/images/imagens_grupos/sem_capa.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: imagemselecionada_FUNDO != null
                      ? Image.file(
                          imagemselecionada_FUNDO!,
                          fit: BoxFit.cover,
                        )
                      : SizedBox(),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Color(0xFF15659F),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 15,
                    ),
                    onPressed: () =>
                        _mostraropcoesparaselecionarImagem(context, 2),
                  ),
                ),
              ),
            ],
          ),
          if (caminhoNovaImagem_FUNDO != null) Text(caminhoNovaImagem_FUNDO!),
          Spacer(),
          if (imagemselecionada_AVATAR != null ||
              imagemselecionada_FUNDO != null)
            Padding(
                padding: EdgeInsets.all(15),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 1,
                      foregroundColor: Colors.blueAccent,
                      backgroundColor: Color(0xFF15659F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                    ),
                    onPressed: () {},
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save,
                            size: 25,
                            color: Colors.white,
                          ), // Ícone
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
                )),
        ]));
  }
}
