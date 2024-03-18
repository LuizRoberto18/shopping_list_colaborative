import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> entrarUsuario({required String email, required String senha}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
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
      }
      return e.code;
    }
    return null;
  }
}