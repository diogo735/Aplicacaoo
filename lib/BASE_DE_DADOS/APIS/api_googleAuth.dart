import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class GoogleApiAuth {
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'https://mail.google.com/']);

  Future<GoogleSignInAccount?> signIn(BuildContext context) async {
    GoogleSignInAccount? user;

    // Verifica se o usuário já está logado
    if (await googleSignIn.isSignedIn()) {
      user = googleSignIn.currentUser;
      print('já logado: $user');
    } else {
      user = await googleSignIn.signIn();
      print('$user');
    }

    return user;
  }

  Future signOut() => googleSignIn.signOut();
}

