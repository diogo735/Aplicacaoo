// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:flutter/material.dart';

class Usuario {
  final int id_user;
  final String nome;
  final String sobrenome;
  final String foto;
  final String fundo;
  final String sobre_min;
  final int centro_id;
  

  Usuario({required this.id_user,required this.centro_id,required this.nome, required this.sobrenome, required this.foto,required this.fundo,required this.sobre_min});

  get id => null;
}
class Usuario_Provider extends ChangeNotifier {
  Usuario? _usuarioSelecionado;

  Usuario? get usuarioSelecionado => _usuarioSelecionado;

  void selecionarUsuario(Usuario usuario) {
    _usuarioSelecionado = usuario;
    notifyListeners();
  }
  void deslogarUsuario() {
    _usuarioSelecionado = null;
    notifyListeners();
  }
}