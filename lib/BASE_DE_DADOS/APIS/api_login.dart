import 'dart:convert';
import 'package:ficha3/PAGINA_DE_LOGIN/login_google.dart';
import 'package:http/http.dart' as http;

class ApiLogin {
  final String baseUrl;

  ApiLogin({required this.baseUrl});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/users/verificar_email?email=$email&password=$password');
    //print('Request URL: $url'); 
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
     // print('Response Body: $responseBody'); 
      return responseBody;
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}'); // Adiciona log do erro
      throw Exception('Failed to login');
    }
  }

   Future<Map<String, dynamic>> loginByGoogle(String email) async {
    final url = Uri.parse('$baseUrl/users/verificar_email_google?email=$email');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to check email');
    }
  }
}
