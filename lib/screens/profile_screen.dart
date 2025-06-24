// lib/screens/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'recipe_detail_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Set<String> favoriteMealIds;
  final List<dynamic> allRecipes;

  const ProfileScreen(this.favoriteMealIds, this.allRecipes, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  String? _userBio; // Variável para armazenar a biografia

  @override
  void initState() {
    super.initState();
    _refreshUserProfile();
  }

  void _refreshUserProfile() {
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserBio(); // Carrega a biografia ao atualizar o perfil
    setState(() {});
  }

  // Função para carregar a biografia do Firestore
  Future<void> _loadUserBio() async {
    if (_currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (mounted && userDoc.exists && userDoc.data()!.containsKey('bio')) {
        setState(() {
          _userBio = userDoc.data()!['bio'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = widget.allRecipes
        .where((recipe) => widget.favoriteMealIds.contains(recipe["idMeal"]))
        .toList();

    final userName =
        _currentUser?.displayName ?? _currentUser?.email ?? "Usuário";
    final userAvatarUrl = _currentUser?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  // Lógica para exibir um ícone padrão se a URL for nula ou inválida
                  backgroundImage: (userAvatarUrl != null && userAvatarUrl.isNotEmpty)
                      ? NetworkImage(userAvatarUrl)
                      : null,
                  child: (userAvatarUrl == null || userAvatarUrl.isEmpty)
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                title: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: _currentUser?.email != null
                    ? Text(_currentUser!.email!)
                    : null,
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  _refreshUserProfile();
                },
              ),
            ),
            const SizedBox(height: 20),
            // Seção da Biografia
            if (_userBio != null && _userBio!.isNotEmpty) ...[
              const Text(
                'Sobre Mim',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _userBio!,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 20),
            ],
            const Text(
              'Minhas Receitas Favoritas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: favoriteRecipes.isEmpty
                  ? const Center(child: Text("Nenhuma receita favorita 😢"))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: favoriteRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = favoriteRecipes[index];
                        return RecipeCard(
                          imageUrl: recipe["strMealThumb"],
                          title: recipe["strMeal"],
                          isFavorite: true,
                          onFavoriteToggle: () {},
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(
                                    mealId: recipe["idMeal"], recipe: recipe),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}