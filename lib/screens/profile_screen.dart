import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:recipe_app/widgets/recipe_card_grid.dart';

class ProfileScreen extends StatelessWidget {
  final Set<int> favoriteIndexes;
  final List<dynamic> allRecipes;

  const ProfileScreen(this.favoriteIndexes, this.allRecipes, {super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = allRecipes
        .asMap()
        .entries
        .where((entry) => favoriteIndexes.contains(entry.key))
        .map((entry) => entry.value)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
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
                  backgroundImage: NetworkImage('https://source.unsplash.com/1600x900/?portrait'),
                  radius: 30,
                ),
                title: Text(
                  'Alena Sabyan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Meus Favoritos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: favoriteRecipes.isEmpty
                  ? Center(child: Text("Nenhuma receita favorita 😢"))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          onFavoriteToggle: () {}, // Não precisa de toggle aqui
                          onTap: () {},
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
