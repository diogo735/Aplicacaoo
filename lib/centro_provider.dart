import 'package:flutter/material.dart';

class Centro {
  final int id;
  final String nome;
  final String morada;
  final String imagem;

  Centro({required this.id, required this.nome, required this.morada, required this.imagem});
}

class Centro_Provider extends ChangeNotifier {
  Centro? _centroSelecionado;

  Centro? get centroSelecionado => _centroSelecionado;

  void selecionarCentro(Centro centro) {
    _centroSelecionado = centro;
    notifyListeners();
  }
  void deslogarCentro() {
    _centroSelecionado = null;
    notifyListeners();
  }
}
