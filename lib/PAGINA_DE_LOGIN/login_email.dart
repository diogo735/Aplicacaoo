import 'package:ficha3/BASE_DE_DADOS/APIS/api_login.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_facebook.dart';
import 'login_google.dart';
import 'registo.dart';
import 'package:ficha3/PAGINA_loading_user.dart';
import 'package:ficha3/MAIN.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginEmail extends StatefulWidget {
  const LoginEmail({Key? key}) : super(key: key);

  @override
  _LoginEmailState createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool isChecked = false;
  bool isLoading = false;
  String errorMessage = '';

  final apiLogin = ApiLogin(baseUrl: 'https://backend-teste-q43r.onrender.com');

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    //print('Email: $email');
    //print('Password: $password');

    try {
      final result = await apiLogin.login(email, password);
      print('Login Result: $result');
      if (result['message'] == 'Email e senha corretos') {
        if (isChecked) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('userId', result['userId'].toString());
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text('Login correto'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1)
              ),
            )
            .closed
            .then((_) {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LoadingScreen(userId: result['userId'])),
          );
        });
      } else {
        setState(() {
          errorMessage = result['message'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (error) {
      print('Login Error: $error'); // Adiciona log do erro
      setState(() {
        errorMessage = 'Erro ao fazer login. Tente novamente mais tarde.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: false,
        body: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: (MediaQuery.of(context).size.height) / 16),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Image.asset(
                  'assets/images/logotipo-softinsa.png',
                  height: (MediaQuery.of(context).size.height) / 7,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: (MediaQuery.of(context).size.width) / 2.3),
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: const Divider(
                  thickness: 3,
                  color: Color(0xFF15659F),
                ),
              ),
              // Login form
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Container(
                  alignment: Alignment.centerLeft, // Alinha o texto à esquerda
                  child: Text(
                    'Email',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: 'exemplo@softinsa.pt',
                    hintStyle: TextStyle(color: Color(0xFF6C757D)),
                    filled: true,
                    fillColor: Color.fromARGB(255, 241, 237, 237),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Container(
                  alignment: Alignment.centerLeft, // Alinha o texto à esquerda
                  child: Text(
                    'Password',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: '● ● ● ● ● ● ● ● ● ●',
                    hintStyle: TextStyle(color: Color(0xFF6C757D)),
                    filled: true,
                    fillColor: Color.fromARGB(255, 241, 237, 237),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          tristate: false,
                          value: isChecked,
                          activeColor: const Color.fromARGB(255, 21, 101, 159),
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                        const Text(
                          'Lembrar de mim',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      'Recuperar Password',
                      style: TextStyle(
                        color: Color(0xFF15659F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height) / 36,
              ),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 21, 101, 159)),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 21, 101, 159),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sessão',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

              SizedBox(
                height: (MediaQuery.of(context).size.height) / 22,
              ),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(right: 20.0),
                      child: const Divider(
                        color: Color.fromARGB(255, 164, 168, 171),
                        height: 36,
                      ),
                    ),
                  ),
                  const Text(
                    'Ou continuar com',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 165, 172, 177)),
                  ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20.0),
                      child: const Divider(
                        color: Color.fromARGB(255, 164, 168, 171),
                        height: 36,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height) / 26,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 231, 228, 228),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Image.asset(
                          'lib/PAGINA_DE_LOGIN/icons/facebook.png',
                          height: 30,
                          width: 30,
                        ),
                        onPressed: () async {
                          final loginFace = LoginFace();
                          final userData = await loginFace.login();
                          if (userData != null) {
                            print("Login successful!");
                            print(userData);
                          } else {
                            print("Login failed");
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width) / 13,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 231, 228, 228),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () async {
                          final loginGoogle = LoginGoogle();
                          await loginGoogle.signIn(context);
                        },
                        icon: Image.asset(
                          'lib/PAGINA_DE_LOGIN/icons/google.png',
                          height: 28,
                          width: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //const Spacer(),
              SizedBox(
                height: (MediaQuery.of(context).size.height) / 26,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Novo na equipa?'),
                  TextButton(
                    child: const Text(
                      'Regista-te agora',
                      style: TextStyle(
                        color: Color.fromARGB(255, 44, 101, 200),
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 44, 101, 200),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Registo()));
                    },
                  ),
                ],
              ),
              /////////////////////flata aqui o que esta no bloco de notas
            ],
          ),
        ));
  }
}
