import 'package:flutter/material.dart';
import 'package:recipe_app/screens/home_screen.dart';
import 'package:recipe_app/screens/main_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Cadastra-se',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              _buildTextField(icon: Icons.email, hint: 'EMAIL'),
              const SizedBox(height: 20),
              _buildTextField(icon: Icons.person, hint: 'NOME DE USUARIO'),
              const SizedBox(height: 20),
              _buildTextField(icon: Icons.phone_android, hint: 'TELEFONE'),
              const SizedBox(height: 20),
              _buildTextField(icon: Icons.badge, hint: 'CPF'),
              const SizedBox(height: 20),
              _buildTextField(
                icon: Icons.lock,
                hint: 'SENHA',
                isPassword: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
               onPressed: () {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => const MainScreen()),
  );
},
                 style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF042628),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        suffixIcon: isPassword ? const Icon(Icons.visibility) : null,
      ),
    );
  }
}
