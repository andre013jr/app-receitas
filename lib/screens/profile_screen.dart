// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_app/screens/login_screen.dart';
import 'recipe_detail_screen.dart';
import 'edit_profile_screen.dart'; // Import the new edit profile screen

class ProfileScreen extends StatefulWidget {
  final Set<String> favoriteMealIds;
  final List<dynamic> allRecipes;

  const ProfileScreen(this.favoriteMealIds, this.allRecipes, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser; // To hold the current user data

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser; // Get the user once
  }

  // Function to refresh user data, called after returning from edit screen
  void _refreshUserProfile() {
    setState(() {
      _currentUser = FirebaseAuth.instance.currentUser; // Re-fetch user data
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = widget.allRecipes
        .where((recipe) => widget.favoriteMealIds.contains(recipe["idMeal"]))
        .toList();

    // Use _currentUser for display
    final userName =
        _currentUser?.displayName ?? _currentUser?.email ?? "Usuário";
    final userAvatarUrl = _currentUser?.photoURL ??
        'https://source.unsplash.com/1600x900/?portrait';

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
              if (!mounted) return; // Check if widget is still in tree
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
                  backgroundImage: NetworkImage(userAvatarUrl),
                  radius: 30,
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
                  // Navigate to EditProfileScreen and await its result
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  // When returning from EditProfileScreen, refresh the profile data
                  _refreshUserProfile();
                },
              ),
            ),
            const SizedBox(height: 20),
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
                          onFavoriteToggle: () {
                            // No action needed here as this is for display only
                          },
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
