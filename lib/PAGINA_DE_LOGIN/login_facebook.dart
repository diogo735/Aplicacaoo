import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginFace {
  Future<Map<String, dynamic>?> login() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      return userData;
    } else {
      print(result.status);
      print(result.message);
      return null;
    }
  }
}
