// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import 'package:recipe_app/screens/main_screen.dart';

class LoginScreen extends StatefulWidget { // Mude para StatefulWidget
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instância do Firebase Auth

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Se o login for bem-sucedido, navegue para a MainScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado para esse e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta para esse e-mail.';
      } else {
        message = 'Erro de login: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF75B9BE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildTextField(
              controller: _emailController, // Associe o controller
              icon: Icons.email,
              hint: 'email',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController, // Associe o controller
              icon: Icons.lock,
              hint: 'senha',
              isPassword: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login, // Chame o método de login
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF042628),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, // Adicione o controller
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller, // Use o controller aqui
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none, // Remova a borda se quiser
        ),
        enabledBorder: OutlineInputBorder( // Define a borda quando o campo não está focado
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder( // Define a borda quando o campo está focado
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF75B9BE), width: 2), // Cor de destaque
        ),
        suffixIcon: isPassword ? const Icon(Icons.visibility) : null,
      ),
    );
  }
}