import 'dart:async';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_usuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_notificacoes.dart';

class NotificacaoService extends ChangeNotifier {
  Timer? _timer;
  final ApiUsuarios apiUsuarios = ApiUsuarios();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificacaoService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void startFetchingNotificacoesPeriodicamente(int usuarioId) {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) async {
      await _fetchNotificacoes(usuarioId);
      await _checkForUnreadNotifications(usuarioId);
    });
  }

  void stopFetchingNotificacoes() {
    _timer?.cancel();
  }

  Future<void> _fetchNotificacoes(int usuarioId) async {
    try {
      await apiUsuarios.fetchAndStoreNotificacoes(usuarioId);
      notifyListeners();
    } catch (error) {
      print('Erro ao buscar notificações: $error');
    }
  }

  Future<void> _checkForUnreadNotifications(int usuarioId) async {
    try {
      List<Map<String, dynamic>> notificacoes =
          await Funcoes_Notificacoes.consultaNotificacoesPorUsuario(usuarioId);

      for (var notificacao in notificacoes) {
        // Cria uma cópia mutável da notificação
        Map<String, dynamic> notificacaoModificavel =
            Map<String, dynamic>.from(notificacao);

        // Print do estado antes de mostrar a notificação
        print(
            'Antes de mostrar a notificação: ${notificacaoModificavel['mensagem']} - lida: ${notificacaoModificavel['lida']}, ja_mostrei_notificacao: ${notificacaoModificavel['ja_mostrei_notificacao']}');

        if (notificacaoModificavel['lida'] == 0 &&
            notificacaoModificavel['ja_mostrei_notificacao'] == 0) {
          // Mostra a notificação
          await _showNotification(notificacaoModificavel['mensagem']);

          // Atualiza o estado da notificação para indicar que foi mostrada
          notificacaoModificavel['ja_mostrei_notificacao'] = 1;

          // Atualiza o estado da notificação no banco de dados
          await Funcoes_Notificacoes.updateNotificacao(
              notificacaoModificavel['id'], {'ja_mostrei_notificacao': 1});
          print(
              'Notificação atualizada no banco de dados com id: ${notificacaoModificavel['id']}');
          // Print do estado depois de mostrar a notificação
          print(
              'Depois de mostrar a notificação: ${notificacaoModificavel['mensagem']} - lida: ${notificacaoModificavel['lida']}, ja_mostrei_notificacao: ${notificacaoModificavel['ja_mostrei_notificacao']}');
        }
      }
    } catch (error) {
      print('Erro ao verificar notificações não lidas: $error');
    }
  }

  Future<void> _showNotification(String mensagem) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // ID do canal
      'your_channel_name', // Nome do canal
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID da notificação
      'Nova Notificação', // Título da notificação
      mensagem, // Corpo da notificação
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  @override
  void dispose() {
    stopFetchingNotificacoes();
    super.dispose();
  }
}
