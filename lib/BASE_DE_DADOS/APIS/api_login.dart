import 'dart:convert';
import 'package:ficha3/BASE_DE_DADOS/APIS/TOKENJTW.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';


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

  Future<Map<String, dynamic>> loginByGoogle(String email) async {
    final url = Uri.parse('$baseUrl/users/verificar_email_google?email=$email');
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
      return jsonDecode(response.body);
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      throw Exception('Failed to check email');
    }
  }
}
