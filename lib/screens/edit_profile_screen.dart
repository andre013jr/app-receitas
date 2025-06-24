// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _displayNameController = TextEditingController();
  User? _currentUser; // Holds the current authenticated user

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get the current user
    if (_currentUser != null) {
      _displayNameController.text =
          _currentUser!.displayName ?? ''; // Populate with current display name
    }
  }

  @override
  void dispose() {
    _displayNameController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  // Function to save profile changes
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Validate the form fields
      try {
        String newDisplayName = _displayNameController.text.trim();

        // Check if there's an actual change to avoid unnecessary updates
        if (_currentUser != null &&
            newDisplayName != _currentUser!.displayName) {
          await _currentUser!.updateDisplayName(
              newDisplayName); // Update display name in Firebase
          // You can also add logic here to update photoURL if you implement image selection
          // await _currentUser!.updatePhotoURL('new_photo_url');

          if (!mounted)
            return; // Check if the widget is still in the tree before showing SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhuma alteração detectada.')),
          );
        }

        Navigator.of(context)
            .pop(); // Go back to the previous screen (ProfileScreen)
      } on FirebaseAuthException catch (e) {
        // Handle Firebase authentication errors
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: ${e.message}')),
        );
      } catch (e) {
        // Handle other potential errors
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _currentUser == null
          ? const Center(
              child:
                  Text('Usuário não logado.')) // Show message if user is null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Removed CircleAvatar here
                    // Removed SizedBox(height: 20) here
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome de Usuário',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira seu nome de usuário.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Display user email (not editable through updateProfile)
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('Email'),
                      subtitle: Text(_currentUser!.email ?? 'Não disponível'),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile, // Call the save function
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context)
                            .primaryColor, // Use primary color for button
                        foregroundColor: Colors.white, // Text color
                      ),
                      child: const Text(
                        'Salvar Alterações',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
