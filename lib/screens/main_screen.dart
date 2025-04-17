import 'package:flutter/material.dart';
import 'package:recipe_app/recipe_service.dart';
import 'package:recipe_app/widgets/bottom_nav_bar.dart';

import 'home_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Set<int> favoriteIndexes = {};
  List<dynamic> allRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() async {
    final recipes = await RecipeService.fetchRecipes();
    setState(() {
      allRecipes = recipes;
    });
  }

  void _onFavoritesUpdated(Set<int> fav, List<dynamic> recipes) {
    setState(() {
      favoriteIndexes = fav;
      allRecipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        onFavoritesUpdated: _onFavoritesUpdated,
      ),
      ProfileScreen(
        favoriteIndexes,
        allRecipes,
      ),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
