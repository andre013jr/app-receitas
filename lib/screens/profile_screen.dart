// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:recipe_app/screens/login_screen.dart'; // Para navegação ao deslogar
import 'recipe_detail_screen.dart'; // Para navegar para os detalhes da receita

class ProfileScreen extends StatelessWidget {
  final Set<String> favoriteMealIds; // Agora espera um Set de String (IDs)
  final List<dynamic> allRecipes;

  const ProfileScreen(this.favoriteMealIds, this.allRecipes, {super.key});

  @override
  Widget build(BuildContext context) {
    // Filtra as receitas que estão na lista de todas as receitas e cujos IDs estão em favoriteMealIds
    final favoriteRecipes = allRecipes
        .where((recipe) => favoriteMealIds.contains(recipe["idMeal"]))
        .toList();

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email ?? "Usuário";
    final userAvatarUrl = user?.photoURL ?? 'https://source.unsplash.com/1600x900/?portrait'; // Imagem de perfil padrão

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Ícone de logout
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Desloga o usuário
              Navigator.pushAndRemoveUntil( // Navega para a tela de login e remove todas as rotas anteriores
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
                subtitle: user?.email != null ? Text(user!.email!) : null, // Exibe o e-mail
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Você pode adicionar uma tela de edição de perfil aqui
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          isFavorite: true, // Sempre favorito na aba de favoritos
                          onFavoriteToggle: () {
                            // Não faz nada aqui, pois a lista de favoritos é apenas para exibição
                            // O toggle de favorito acontece na HomeScreen
                          },
                          onTap: () {
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(mealId: recipe["idMeal"], recipe: recipe),
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