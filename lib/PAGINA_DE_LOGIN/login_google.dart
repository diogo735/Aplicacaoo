import 'package:ficha3/BASE_DE_DADOS/APIS/api_login.dart';
import 'package:ficha3/PAGINA_loading_user.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginGoogle extends StatelessWidget {
  const LoginGoogle({Key? key}) : super(key: key);

  Future<void> signIn(BuildContext context) async {
    final apiLogin =
        ApiLogin(baseUrl: 'https://backend-teste-q43r.onrender.com');
    try {
      final user = await GoogleSignInApi.login();
      if (user != null) {

       
        final result = await apiLogin.loginByGoogle(user.email);
        print('Login Result com o google: $result');

        if (result['message'] == 'Conta email registada') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString(
              'userId', result['userId'].toString()); // Use user.id do Google
         await GoogleSignInApi.logout();
          ScaffoldMessenger.of(context)
              .showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text('Login correto'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              )
              .closed
              .then((_) {
            //Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingScreen(userId: result['userId']),
              ),
            );
          });
          if (result['userId'] == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: ID do usuário não encontrado")),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'])),
          );
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao entrar com Google: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GOOGLE Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => signIn(context),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future<void> logout() => _googleSignIn.signOut();
}
