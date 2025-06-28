import 'package:flutter/material.dart';
import 'package:recipe_app/recipe_service.dart';
import 'package:recipe_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Set<String> _favoriteMealIds = {};
  List<dynamic> _allRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAllRecipes();
    _listenToFavoritesChanges();
  }

  void _loadAllRecipes() async {
    try {
      final recipes = await RecipeService.fetchRecipes();
      setState(() {
        _allRecipes = recipes;
      });
    } catch (e) {
      print("Erro ao carregar todas as receitas: $e");
    }
  }

  void _listenToFavoritesChanges() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            setState(() {
              _favoriteMealIds =
                  Set<String>.from(snapshot.data()!['favorites'] ?? []);
            });
          } else {
            setState(() {
              _favoriteMealIds = {};
            });
          }
          _onFavoritesUpdated(_favoriteMealIds, _allRecipes);
        });
      } else {
        setState(() {
          _favoriteMealIds = {};
        });
        _onFavoritesUpdated(_favoriteMealIds, _allRecipes);
      }
    });
  }

  void _onFavoritesUpdated(Set<String> favMealIds, List<dynamic> recipes) {
    setState(() {
      _favoriteMealIds = favMealIds;
      _allRecipes = recipes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        onFavoritesUpdated: _onFavoritesUpdated,
      ),
      ProfileScreen(
        _favoriteMealIds,
        _allRecipes,
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
