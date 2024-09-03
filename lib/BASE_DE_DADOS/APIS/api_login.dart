import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:ficha3/BASE_DE_DADOS/APIS/api_recuperar_passe.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/PaginaLogin.dart';
import 'package:ficha3/PAGINA_DE_LOGIN/recuperar_passe.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiLogin {
  final String baseUrl;

  ApiLogin({required this.baseUrl});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/verificar_email?email=$email&password=$password');
    String? jwtToken = TokenService().getToken(); // Obtém o token de TokenService

    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',  // Usa o token JWT do TokenService
      }
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody;
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to login');
    }
  }

/*
  // Método para realizar o login
  Future<Map<String, dynamic>> login(String email, String password) async {
    String? jwtToken = TokenService().getToken();
    final Uri url = Uri.parse(
        '$baseUrl/users/verificar_email?email=$email&password=$password');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }*/

  // Método para verificar login com Google
  Future<Map<String, dynamic>> loginByGoogle(String email) async {
    final url = Uri.parse('$baseUrl/users/verificar_email_google?email=$email');
    String? jwtToken = TokenService().getToken();

    if (jwtToken == null) {
      throw Exception('JWT Token is not set.');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to check email');
    }
  }

  Future<void> loginUser(BuildContext context, String email, String password,
    ApiLogin apiLogin) async {
  try {
    // Attempt to login and get the response
    final loginResponse = await apiLogin.login(email, password);

    // Check if the login was successful
    if (loginResponse['message'] == 'Email e senha corretos') {
      // Check if the password is temporary
      if (password.startsWith("temp_")) {
        // Redirect to the password reset page
        await ApiRecuperarPasse().sendVerificationCode(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordResetPage(email: email),
          ),
        );
      } else {
        // Proceed with the normal login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaginaLogin(),
          ),
        );
      }
    } else {
      // Handle incorrect login credentials
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${loginResponse['message']}')),
      );
    }
  } catch (e) {
    // Handle errors during the login process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao fazer login: $e')),
    );
  }
}

}
