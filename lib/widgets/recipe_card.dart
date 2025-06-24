import 'package:flutter/material.dart';

class RecipeCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const RecipeCard({
    required this.imageUrl,
    required this.title,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const favoriteColor = Color(0xFF75B9BE);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
     // ... dentro do seu widget build
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adicione esta linha
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem com ícone de favorito
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Tooltip(
                  message: isFavorite ? 'Adicionado aos favoritos!' : 'Remover dos favoritos',
                  child: GestureDetector(
                    onTap: () {
                      onFavoriteToggle();
                      if (!isFavorite) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Adicionado à página de favoritos ❤️"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey<bool>(isFavorite),
                          color: isFavorite ? favoriteColor : Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          // O espaço para "Infos calorias e tempo" será criado aqui quando você adicionar os widgets
        ],
      ),
// ...
      ),
    );
  }
}
