// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // 1. Importar o flutter_bloc
import 'package:recipe_app/bloc/auth_bloc.dart'; // 2. Importar o nosso BLoC
import 'package:recipe_app/screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // A chave do formulário para validação
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  // 3. REMOVIDO: A instância do FirebaseAuth foi movida para o Data Provider.
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // 4. A função _register agora é mais simples.
  // Ela apenas valida o formulário e envia um evento para o BLoC.
  void _register() {
    // Verifica se o formulário é válido
    if (_formKey.currentState!.validate()) {
      // Dispara o evento para o AuthBloc
      context.read<AuthBloc>().add(
        RegisterEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _usernameController.text.trim(), // Adiciona o nome de usuário
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Envolvemos o Scaffold com um BlocListener para reagir a mudanças de estado
    //    sem reconstruir a tela inteira.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // Mostra um diálogo de carregamento
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is Authenticated) {
          // Fecha o diálogo de carregamento e navega para a tela principal
          Navigator.of(context).pop(); // Fecha o diálogo
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else if (state is AuthError) {
          // Fecha o diálogo de carregamento e mostra uma mensagem de erro
          Navigator.of(context).pop(); // Fecha o diálogo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF75B9BE),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          // 6. Usamos um Widget Form para habilitar a validação
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Cadastra-se',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  // 7. Trocamos TextField por TextFormField para usar validadores
                  _buildTextFormField(
                    controller: _emailController,
                    icon: Icons.email,
                    hint: 'EMAIL',
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Por favor, insira um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _usernameController,
                    icon: Icons.person,
                    hint: 'NOME DE USUÁRIO',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um nome de usuário.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    controller: _passwordController,
                    icon: Icons.lock,
                    hint: 'SENHA',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _register, // A função _register agora envia o evento
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
        ),
      ),
    );
  }

  // Helper agora constrói um TextFormField e aceita um validador
  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField( // Trocado para TextFormField
      controller: controller,
      obscureText: isPassword,
      validator: validator, // Adicionado o validador
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF75B9BE), width: 2),
        ),
        // Ícone de visibilidade pode ser melhorado com um StatefulWidget
        // para alternar o obscureText, mas manteremos simples por agora.
        suffixIcon: isPassword ? const Icon(Icons.visibility) : null,
      ),
    );
  }
}