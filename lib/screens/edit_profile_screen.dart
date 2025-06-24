// lib/screens/edit_profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _photoURLController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  User? _currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser != null) {
      _displayNameController.text = _currentUser!.displayName ?? '';
      _photoURLController.text = _currentUser!.photoURL ?? '';

      // Carrega a biografia do Firestore
      final userDoc =
          await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists && userDoc.data()!.containsKey('bio')) {
        _bioController.text = userDoc.data()!['bio'];
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _photoURLController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String newDisplayName = _displayNameController.text.trim();
        String newPhotoURL = _photoURLController.text.trim();
        String newBio = _bioController.text.trim();

        if (_currentUser != null) {
          // Atualiza o nome e a foto no Firebase Auth
          await _currentUser!.updateDisplayName(newDisplayName);
          await _currentUser!.updatePhotoURL(newPhotoURL);

          // Salva/Atualiza a biografia no Firestore
          await _firestore
              .collection('users')
              .doc(_currentUser!.uid)
              .set({'bio': newBio}, SetOptions(merge: true));

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('Usuário não logado.'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome de Usuário',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
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
                       
                    
                        TextFormField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            labelText: 'Biografia',
                            hintText: 'Fale um pouco sobre você...',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                            ),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
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