class TokenService {
  static final TokenService _instance = TokenService._internal();
  String? _jwtToken;

  // Construtor privado para o padrão Singleton
  TokenService._internal();

  // Fábrica para acessar a instância
  factory TokenService() {
    return _instance;
  }

  // Define o token JWT
  void setToken(String token) {
    _jwtToken = token;
  }

  // Recupera o token JWT
  String? getToken() {
    return _jwtToken;
  }

  // Verifica se o token JWT está presente
  bool hasToken() {
    return _jwtToken != null && _jwtToken!.isNotEmpty;
  }
}
