import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import 'package:recipe_app/widgets/recipe_card_grid.dart';
import '../recipe_service.dart';
import 'profile_screen.dart';

import 'package:flutter/material.dart';

import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Set<int>, List<dynamic>) onFavoritesUpdated;

  const HomeScreen({
    Key? key,
    required this.onFavoritesUpdated,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _recipesFuture;
  late Future<List<String>> _categoriesFuture;
  late Future<List<String>> _ingredientsFuture;

  String? _selectedCategory;
  String? _selectedIngredient;
  TextEditingController _searchController = TextEditingController();
  Set<int> favoriteIndexes = {};
  List<dynamic> _allRecipes = []; // Vai armazenar as receitas carregadas

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _recipesFuture = RecipeService.fetchRecipes();
    _categoriesFuture = RecipeService.fetchCategories();
    _ingredientsFuture = RecipeService.fetchIngredients();

    // Armazena receitas quando forem carregadas
    _recipesFuture.then((recipes) {
      _allRecipes = recipes;
    });
  }

  void _filterRecipes() {
    setState(() {
      if (_searchController.text.isNotEmpty) {
        _recipesFuture = RecipeService.fetchRecipesByName(_searchController.text);
      } else if (_selectedCategory != null) {
        _recipesFuture = RecipeService.fetchRecipesByCategory(_selectedCategory!);
      } else if (_selectedIngredient != null) {
        _recipesFuture = RecipeService.fetchRecipesByIngredient(_selectedIngredient!);
      } else {
        _recipesFuture = RecipeService.fetchRecipes();
      }
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      if (favoriteIndexes.contains(index)) {
        favoriteIndexes.remove(index);
      } else {
        favoriteIndexes.add(index);
      }
    });

    // Atualiza a MainScreen com os favoritos
    widget.onFavoritesUpdated(favoriteIndexes, _allRecipes);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text("☀️ Bom dia!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Text("André", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Barra de pesquisa por nome
           // Campo de pesquisa (estilo Apple-like)
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.1),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 14),
      hintText: "Pesquisar receita...",
      hintStyle: TextStyle(color: Colors.grey.shade600),
      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
      border: InputBorder.none,
    ),
    onChanged: (value) {
      _filterRecipes();
    },
  ),
),

            const SizedBox(height: 10),
            const Text("Filtrar por:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Dropdown de Categorias
           FutureBuilder<List<String>>(
  future: _categoriesFuture,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          hint: const Text("Categoria", style: TextStyle(color: Colors.black54)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded),
          items: snapshot.data!.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
              _selectedIngredient = null;
              _searchController.clear();
            });
            _filterRecipes();
          },
        ),
      ),
    );
  },
),


            // Dropdown de Ingredientes
           FutureBuilder<List<String>>(
  future: _ingredientsFuture,
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedIngredient,
          hint: const Text("Ingrediente", style: TextStyle(color: Colors.black54)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded),
          items: snapshot.data!.map((ingredient) {
            return DropdownMenuItem(
              value: ingredient,
              child: Text(ingredient),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedIngredient = value;
              _selectedCategory = null;
              _searchController.clear();
            });
            _filterRecipes();
          },
        ),
      ),
    );
  },
),


            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _recipesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("Erro ao carregar receitas 😢"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Nenhuma receita encontrada."));
                  }

                   final recipes = snapshot.data!;
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      return RecipeCard(
                        imageUrl: recipe["strMealThumb"],
                        title: recipe["strMeal"],
                        isFavorite: favoriteIndexes.contains(index),
                        onFavoriteToggle: () => _toggleFavorite(index),
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