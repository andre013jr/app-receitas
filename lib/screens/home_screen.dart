// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import '../recipe_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe Cloud Firestore

import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Set<String>, List<dynamic>) onFavoritesUpdated; // Mude para Set<String>

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
  final TextEditingController _searchController = TextEditingController();

  // Agora vamos armazenar os IDs das receitas favoritas
  Set<String> _favoriteMealIds = {}; // Mude para Set<String>
  List<dynamic> _allRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadFavorites(); // Carrega os favoritos do Firestore
  }

  // Carrega os favoritos do usuário logado
  void _loadFavorites() async {
    final user = _auth.currentUser;
    if (user != null) {
      final favDoc = await _firestore.collection('users').doc(user.uid).get();
      if (favDoc.exists && favDoc.data() != null) {
        setState(() {
          // Garante que a lista de IDs de favoritos é do tipo List<dynamic> e converte para Set<String>
          _favoriteMealIds = Set<String>.from(favDoc.data()!['favorites'] ?? []);
        });
      }
    }
  }

  void _loadData() {
    _recipesFuture = RecipeService.fetchRecipes();
    _categoriesFuture = RecipeService.fetchCategories();
    _ingredientsFuture = RecipeService.fetchIngredients();

    _recipesFuture.then((recipes) {
      _allRecipes = recipes;
      widget.onFavoritesUpdated(_favoriteMealIds, _allRecipes); // Atualiza MainScreen com os favoritos iniciais
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

  void _toggleFavorite(String mealId, dynamic recipe) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para adicionar favoritos!')),
      );
      return;
    }

    // Cria uma referência ao documento do usuário no Firestore
    final userDocRef = _firestore.collection('users').doc(user.uid);

    setState(() {
      if (_favoriteMealIds.contains(mealId)) {
        _favoriteMealIds.remove(mealId);
        // Remover do Firestore
        userDocRef.update({
          'favorites': FieldValue.arrayRemove([mealId]),
        });
      } else {
        _favoriteMealIds.add(mealId);
        // Adicionar ao Firestore
        userDocRef.set({
          'favorites': FieldValue.arrayUnion([mealId]),
        }, SetOptions(merge: true)); // Usa merge para não sobrescrever outros campos
      }
    });

    widget.onFavoritesUpdated(_favoriteMealIds, _allRecipes);

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_favoriteMealIds.contains(mealId) ? "Adicionado aos favoritos ❤️" : "Removido dos favoritos 💔"),
        duration: const Duration(seconds: 1),
      ),
    );
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
            Text(
              _auth.currentUser?.displayName ?? "André", // Exibe o nome do usuário logado
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      hint: const Text("Categoria", style: TextStyle(color: Colors.black54)),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedIngredient,
                      hint: const Text("Ingrediente", style: TextStyle(color: Colors.black54)),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
                        // Verifica se o ID da receita está nos favoritos
                        isFavorite: _favoriteMealIds.contains(recipe["idMeal"]),
                        onFavoriteToggle: () => _toggleFavorite(recipe["idMeal"], recipe),
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