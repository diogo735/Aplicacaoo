import 'dart:math';
import 'package:ficha3/BASE_DE_DADOS/funcoes_tabelas/funcoes_codigoverificacao.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/recuperar_passe.dart';
import 'package:flutter/material.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_googleAuth.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/mailer.dart';

class ApiRecuperarPasse {
  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(900000) + 100000)
        .toString();
  }

  static String generateTemporaryPassword() {
  final random = Random();
  final randomNumbers = List.generate(4, (_) => random.nextInt(10)).join();
  
  return "temp_$randomNumbers";
}

  //Exemplo base
  Future sendEmail(BuildContext context) async {
    final googleApiAuth = GoogleApiAuth();
    final user = await googleApiAuth.signIn(context);

    if (user == null) {
      print('Não foi possível encontrar usuário');
      await googleApiAuth.signOut();
      return;
    }

    final email = user.email;
    final auth = await user.authentication;
    final token = auth.accessToken!;
    print('Aqui1');
    print('Autenticado com $email');
    print('token $token');

    final smtpServer = gmailSaslXoauth2(email, token);
    final message = Message()
      ..from = Address(email, 'Caroline')
      ..recipients = ['carolwasti@gmail.com']
      ..subject = 'Pedido de Nova Senha - Softshares'
      ..text =
          '''Um pedido para recuperar senha foi feito. Seu código de verificação é: ''';

    try {
      await send(message, smtpServer);
      print('Email enviado com sucesso!');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email enviado com sucesso!'),
        ),
      );
    } on MailerException catch (e) {
      print(e);
    }
  }

  //ENVIA CÓDIGO DE REDEFINIÇÃO DA PASSE
  Future sendVerificationCode(BuildContext context) async {
    final googleApiAuth = GoogleApiAuth();
    final user = await googleApiAuth.signIn(context);
    final code = _generateVerificationCode();

    if (user == null) {
      await googleApiAuth.signOut();
      print('Não foi possível encontrar usuário');
      return;
    }

    final email = user.email;
    final auth = await user.authentication;
    final token = auth.accessToken!;
    print('Aqui1');
    print('Autenticado com $email');
    print('token $token');

    await FuncoesCodigoverificacao.saveCodeForUser(email, code);

    final smtpServer = gmailSaslXoauth2(email, token);
    final message = Message()
      ..from = Address(email, 'Gestora Softshare')
      ..recipients = [
        'carolwasti@gmail.com'
      ] // Use o e-mail do destinatário desejado
      ..subject = 'Pedido de Nova Senha - Softshares'
      ..text =
          '''Um pedido para recuperar senha foi feito. Seu código de verificação é: 
        $code ''';

    try {
      //await send(message, smtpServer);
      print('Email enviado com sucesso!');
      print('SEU CODIGO ------> $code');

      await Future.delayed(Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
            heightFactor: 1.0, // Ajusta o espaçamento vertical
            child: Text(
              'Email enviado com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0, // Tamanho da fonte maior
                fontWeight: FontWeight.bold, // Texto em negrito (opcional)
              ),
            ),
          ),
          duration: Duration(seconds: 1), // Define a duração do SnackBar
          behavior: SnackBarBehavior
              .floating, // Mantém o SnackBar flutuante (opcional)
          shape: RoundedRectangleBorder(
            // Define uma borda arredondada (opcional)
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.all(16), // Define as margens do SnackBar
        ),
      );

      // Aguarda 3 segundos antes de redirecionar
      await Future.delayed(Duration(seconds: 1));

      // Redireciona para a página de recuperação de senha
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PasswordResetPage(
                    email: user.email,
                  )));
    } on MailerException catch (e) {
      print('Erro ao enviar o email: $e');

      // Exibe uma mensagem de erro caso o e-mail não seja enviado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao enviar email. Tente novamente.'),
        ),
      );
    }
  }

  static Future sendTemporaryPass(BuildContext context, String tempPass) async {
    final googleApiAuth = GoogleApiAuth();
    final user = await googleApiAuth.signIn(context);

    if (user == null) {
      await googleApiAuth.signOut();
      print('Não foi possível encontrar usuário');
      return;
    }

    final email = user.email;
    final auth = await user.authentication;
    final token = auth.accessToken!;
    print('Aqui1');
    print('Autenticado com $email');
    print('token $token');

    final smtpServer = gmailSaslXoauth2(email, token);
    final message = Message()
      ..from = Address(email, 'Gestora Softshare')
      ..recipients = ['carolwasti@gmail.com']
      ..subject = 'Pedido de Nova Senha - Softshares'
      ..text = '''Sua senha é: $tempPass. Altere para uma passe segura. ''';

    try {
      //await send(message, smtpServer);
      print('Email enviado com sucesso!');
      print('SEU CODIGO ------> $tempPass');

      await Future.delayed(Duration(seconds: 1));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Center(
            heightFactor: 1.0,
            child: Text(
              'Email enviado com sucesso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: EdgeInsets.all(16), // Define as margens do SnackBar
        ),
      );

      // Aguarda 3 segundos antes de redirecionar
      await Future.delayed(Duration(seconds: 1));

      // Redireciona para a página de recuperação de senha
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PasswordResetPage(
                    email: user.email,
                  )));
    } on MailerException catch (e) {
      print('Erro ao enviar o email: $e');

      // Exibe uma mensagem de erro caso o e-mail não seja enviado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao enviar email. Tente novamente.'),
        ),
      );
    }
  }
}
