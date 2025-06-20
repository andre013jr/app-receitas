// lib/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:recipe_app/recipe_service.dart';
import 'package:recipe_app/widgets/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe Cloud Firestore


import 'home_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Set<String> _favoriteMealIds = {}; // Agora armazena IDs
  List<dynamic> _allRecipes = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadAllRecipes();
    _listenToFavoritesChanges(); // Ouve por mudanças nos favoritos
  }

  // Carrega todas as receitas da API (para o ProfileScreen poder filtrar)
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

  // Escuta por mudanças nos favoritos do usuário no Firestore
  void _listenToFavoritesChanges() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            setState(() {
              _favoriteMealIds = Set<String>.from(snapshot.data()!['favorites'] ?? []);
            });
          } else {
            setState(() {
              _favoriteMealIds = {}; // Limpa se não houver favoritos
            });
          }
          // Atualiza o ProfileScreen sempre que os favoritos mudarem
          _onFavoritesUpdated(_favoriteMealIds, _allRecipes);
        });
      } else {
        // Se o usuário deslogar, limpa os favoritos
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
      _allRecipes = recipes; // Mantenha _allRecipes atualizada
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        onFavoritesUpdated: _onFavoritesUpdated,
      ),
      ProfileScreen(
        _favoriteMealIds, // Passe os IDs das receitas favoritas
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