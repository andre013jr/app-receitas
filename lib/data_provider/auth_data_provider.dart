// lib/data_provider/auth_data_provider.dart (VERSÃO CORRIGIDA)

import 'package:firebase_auth/firebase_auth.dart';

class AuthDataProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ATUALIZAÇÃO AQUI: O método agora aceita 'username'
  Future<UserCredential> registerWithEmail(String email, String password, String username) async {
    // 1. Cria o usuário com e-mail e senha
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // 2. ATUALIZA o nome de usuário (DisplayName)
    // A lógica que estava na tela agora vive aqui, no lugar certo!
    if (userCredential.user != null) {
      await userCredential.user!.updateDisplayName(username);
    }
    
    // 3. Retorna as credenciais do usuário
    return userCredential;
  }

  Future<UserCredential> loginWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() {
    return _auth.signOut();
  }
}