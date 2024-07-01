import 'package:ficha3/PAGINA_DE_LOGIN/login_email.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/login_facebook.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/login_google.dart';
import 'package:flutter/material.dart';

class PaginaLogin extends StatelessWidget {
  const PaginaLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            // Adicione um Expanded para empurrar o conteúdo para o centro
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Logo
                  SizedBox(height: MediaQuery.of(context).size.height / 12),
                  Image.asset(
                    'assets/images/logotipo-softinsa.png',
                    height: 300,
                    width: 300,
                  ),
                  //const SizedBox(height: 30), // Add some spacing between the logo and buttons
                  const Botoes(),
                  Spacer(),
                  //SizedBox(height: MediaQuery.of(context).size.height / 6),
                  const Text(
                    'Ainda não fazes parte da Equipa?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/registo');
                    },
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 44, 101, 200),
                        fontSize: 18,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    child: const Text(
                      'Regista-te agora',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF0955C3),
                        height: 0.09,
                      ),
                    ),
                  ),
                  //const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Botoes extends StatelessWidget {
  const Botoes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // BOTAO DO EMAIL
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 21, 101, 159),
                textStyle: const TextStyle(fontSize: 22),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/email');
                //Navigator.push(context,
                // MaterialPageRoute(builder: (context) => LoginEmail()));
              },
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 25,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Continuar com email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            // BOTAO DO GOOGLE
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.blue, width: 2),
                ),
                onPressed: () async {
                  final loginGoogle = const LoginGoogle();
                  await loginGoogle.signIn(context);
                },
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Image.asset('lib/PAGINA_DE_LOGIN/icons/google.png',
                            height: 20, width: 20),
                      ),
                      const SizedBox(
                        child: Text('Continuar com o Google',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 17,
                            )),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 15),

            // BOTAO FACEBOOK
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () async {
                  final loginFace = LoginFace();
                  final userData = await loginFace.login();
                  if (userData != null) {
                    // Handle successful login, e.g., navigate to another screen or save user data
                    print("Login successful!");
                    print(userData);
                  } else {
                    // Handle login failure
                    print("Login failed");
                  }
                },
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(right: 12),
                        child: Image.asset('lib/PAGINA_DE_LOGIN/icons/facebook.png',
                            height: 20, width: 20),
                      ),
                      const SizedBox(
                        child: Text('Continuar com Facebook',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            )),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
