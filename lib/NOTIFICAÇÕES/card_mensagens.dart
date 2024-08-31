import 'package:flutter/material.dart';

class NotificacaoWidget extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final IconData icone;
  final Color corIcone;
  final String tempo;

  NotificacaoWidget({
    required this.titulo,
    required this.mensagem,
    required this.icone,
    required this.corIcone,
    required this.tempo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: corIcone.withOpacity(0.2),
          child: Icon(icone, color: corIcone),
        ),
        title: Row(
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: corIcone,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '• $tempo',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        subtitle: Text(
          mensagem,
          style: TextStyle(color: Colors.black),
        ),
        trailing: Icon(Icons.more_vert),
        onTap: () {
          // Ação ao clicar na notificação
        },
      ),
    );
  }
}

