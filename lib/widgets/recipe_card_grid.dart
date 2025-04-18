import 'package:flutter/material.dart';
import 'package:recipe_app/recipe_service.dart';
import 'recipe_card.dart';


class RecipeGrid extends StatefulWidget {
  @override
  _RecipeGridState createState() => _RecipeGridState();
}

class _RecipeGridState extends State<RecipeGrid> {
  List<Map<String, dynamic>> recipes = [];
  Set<int> favoriteIndexes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final basicRecipes = await RecipeService.fetchRecipes();
      
      // Carrega os detalhes (categoria, área etc) para cada receita
      final detailedRecipes = await Future.wait(basicRecipes.map((recipe) async {
        final id = recipe["idMeal"];
        final details = await RecipeService.fetchRecipeDetails(id);
        return {
          ...recipe,
          "strCategory": details["strCategory"] ?? "",
          "strArea": details["strArea"] ?? "",
        };
      }));

      setState(() {
        recipes = detailedRecipes.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Erro ao carregar receitas: $error");
    }
  }

  void toggleFavorite(int index) {
    setState(() {
      if (favoriteIndexes.contains(index)) {
        favoriteIndexes.remove(index);
      } else {
        favoriteIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (recipes.isEmpty) {
      return Center(child: Text("Nenhuma receita encontrada 😢"));
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return RecipeCard(
            imageUrl: recipe["strMealThumb"],
            title: recipe["strMeal"],
            
            isFavorite: favoriteIndexes.contains(index),
            onFavoriteToggle: () => toggleFavorite(index),
            onTap: () {}, // pode navegar para detalhes se quiser
          );
        },
      ),
    );
  }
}
