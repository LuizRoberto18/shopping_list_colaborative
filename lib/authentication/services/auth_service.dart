import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shopping_list_collaborative/get_control.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> entrarUsuario({required String email, required String senha}) async {
    try {
      GetControll.isLoading.value = true;

      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      GetControll.isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-credential":
          return "Atenção, Verifique suas credenciais!";
        case "wrong-password":
          return "Senha incorreta";
        case "user-not-found":
          return "Usuário não associado ao e-mail fornecido";
      }
      return e.code;
    }
    return null;
  }

  Future<String?> cadastrarUsuario({
    required String email,
    required String senha,
    required String nome,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: senha);
      await userCredential.user!.updateDisplayName(nome);
      print("FUNCIONOU");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          return "O e-mail já está incluso";
      }
      return e.code;
    }
    return null;
  }

  Future<String?> redefinicaoSenha({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "channel-error":
          return "Atenção, informe um e-mail cadastrado!";
        case "not-email":
          return "teste not-email";
        case "too-many-requests":
          return "Tenete novamente mais tarde";
        case "invalid-email":
          return "O e-mail informado é inválido!";
        case "user-not-found":
          return "O email não está cadastrado.";
      }
      print("teste ${e.code}");
      debugPrint("teste ${e.email}");
      debugPrint("teste ${e.message}");
      debugPrint("teste ${e.credential}");
      debugPrint("teste ${e.plugin}");
      debugPrint("teste ${e.phoneNumber}");
      debugPrint("teste ${e.tenantId}");
      debugPrint("teste ${e.stackTrace}");
      return "Teste ${e.code}";
    }
    return null;
  }

  Future<String?> deslogar() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
    return null;
  }
}
