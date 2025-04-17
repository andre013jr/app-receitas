import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap; // Adicionado para navegar

  RecipeCard({
    required this.imageUrl,
    required this.title,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap, // Novo parâmetro
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Chama a função ao tocar no card
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
      ),
    );
  }
}
