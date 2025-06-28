import 'package:flutter/material.dart';
import 'package:recipe_app/widgets/recipe_card.dart';
import '../recipe_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(Set<String>, List<dynamic>) onFavoritesUpdated;

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
  Set<String> _selectedIngredients = {};
  final TextEditingController _searchController = TextEditingController();

  Set<String> _favoriteMealIds = {};
  List<dynamic> _allRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _favoritesSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _listenToFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  void _listenToFavorites() {
    final user = _auth.currentUser;
    if (user != null) {
      _favoritesSubscription = _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((favDoc) {
        if (favDoc.exists && favDoc.data() != null && mounted) {
          setState(() {
            _favoriteMealIds =
                Set<String>.from(favDoc.data()!['favorites'] ?? []);
          });
          widget.onFavoritesUpdated(_favoriteMealIds, _allRecipes);
        }
      });
    }
  }

  void _loadData() {
    _recipesFuture = RecipeService.fetchRecipes();
    _categoriesFuture = RecipeService.fetchCategories();
    _ingredientsFuture = RecipeService.fetchIngredients();

    _recipesFuture.then((recipes) {
      if (mounted) {
        _allRecipes = recipes;
        widget.onFavoritesUpdated(_favoriteMealIds, _allRecipes);
      }
    });
  }

  void _filterRecipes() {
    if (mounted) {
      setState(() {
        _recipesFuture = _getFilteredRecipes();
      });
    }
  }

  Future<List<dynamic>> _getFilteredRecipes() async {
    if (_searchController.text.isNotEmpty) {
      return RecipeService.fetchRecipesByName(_searchController.text);
    }

    bool hasCategoryFilter = _selectedCategory != null;
    bool hasIngredientFilter = _selectedIngredients.isNotEmpty;

    if (!hasCategoryFilter && !hasIngredientFilter) {
      return RecipeService.fetchRecipes();
    }

    List<Future<List<dynamic>>> futures = [];

    if (hasCategoryFilter) {
      futures.add(RecipeService.fetchRecipesByCategory(_selectedCategory!));
    }
    if (hasIngredientFilter) {
      for (final ingredient in _selectedIngredients) {
        futures.add(RecipeService.fetchRecipesByIngredient(ingredient));
      }
    }

    final List<List<dynamic>> results = await Future.wait(futures);

    if (results.isEmpty) {
      return [];
    }
    if (results.length == 1) {
      return results[0];
    }

    Map<String, dynamic> intersectionMap = {
      for (var recipe in results[0]) recipe['idMeal']: recipe
    };

    for (int i = 1; i < results.length; i++) {
      final currentIds = results[i].map((recipe) => recipe['idMeal']).toSet();
      intersectionMap.removeWhere((key, value) => !currentIds.contains(key));
    }

    return intersectionMap.values.toList();
  }

  void _toggleFavorite(String mealId) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para adicionar favoritos!')),
      );
      return;
    }

    final userDocRef = _firestore.collection('users').doc(user.uid);
    final bool isCurrentlyFavorite = _favoriteMealIds.contains(mealId);

    if (isCurrentlyFavorite) {
      await userDocRef.update({
        'favorites': FieldValue.arrayRemove([mealId]),
      });
    } else {
      await userDocRef.set({
        'favorites': FieldValue.arrayUnion([mealId]),
      }, SetOptions(merge: true));
    }

    if (!_favoriteMealIds.contains(mealId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removido dos favoritos 💔"),
          duration: Duration(seconds: 1),
        ),
      );
    }
    ;
  }

  void _showIngredientMultiSelect() async {
    final List<String>? allIngredients = await _ingredientsFuture;
    if (allIngredients == null) return;

    final tempSelectedIngredients = Set<String>.from(_selectedIngredients);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selecione os Ingredientes'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allIngredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = allIngredients[index];
                    return CheckboxListTile(
                      title: Text(ingredient),
                      value: tempSelectedIngredients.contains(ingredient),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedIngredients.add(ingredient);
                          } else {
                            tempSelectedIngredients.remove(ingredient);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedIngredients = tempSelectedIngredients;
                  _searchController.clear();
                });
                _filterRecipes();
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
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
            const Text("☀️ Bom dia!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text(
              _auth.currentUser?.displayName ?? "Visitante",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Pesquisar receita...",
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                ),
                onChanged: (value) => _filterRecipes(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filtrar por:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = null;
                      _selectedIngredients.clear();
                      _searchController.clear();
                    });
                    _filterRecipes();
                  },
                  child: const Text("Limpar filtros"),
                )
              ],
            ),
            _buildDropdown(
              future: _categoriesFuture,
              value: _selectedCategory,
              hint: "Categoria",
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _searchController.clear();
                });
                _filterRecipes();
              },
            ),
            const SizedBox(height: 8),
            _buildMultiSelectButton(),
            const SizedBox(height: 8),
            _buildSelectedIngredientChips(),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _recipesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text("Erro ao carregar receitas 😢"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text("Nenhuma receita encontrada."));
                  }

                  final recipes = snapshot.data!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        isFavorite: _favoriteMealIds.contains(recipe["idMeal"]),
                        onFavoriteToggle: () =>
                            _toggleFavorite(recipe["idMeal"]),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(
                                mealId: recipe["idMeal"],
                                recipe: recipe,
                              ),
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

  Widget _buildMultiSelectButton() {
    return GestureDetector(
      onTap: _showIngredientMultiSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ingredientes",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedIngredientChips() {
    if (_selectedIngredients.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: _selectedIngredients.map((ingredient) {
        return Chip(
          label: Text(ingredient),
          onDeleted: () {
            setState(() {
              _selectedIngredients.remove(ingredient);
            });
            _filterRecipes();
          },
        );
      }).toList(),
    );
  }

  Widget _buildDropdown({
    required Future<List<String>> future,
    required String? value,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return FutureBuilder<List<String>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: const TextStyle(color: Colors.black54)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: snapshot.data!.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}
