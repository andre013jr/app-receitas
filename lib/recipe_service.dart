import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  static Future<List<dynamic>> fetchRecipes() async {
    final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["meals"];
    } else {
      throw Exception("Erro ao carregar receitas");
    }
  }

  static Future<Map<String, dynamic>> fetchRecipeDetails(String mealId) async {
    final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/lookup.php?i=$mealId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["meals"][0]; // Retorna os detalhes da receita
    } else {
      throw Exception("Erro ao carregar detalhes da receita");
    }
  }

  static Future<List<String>> fetchCategories() async {
  final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/list.php?c=list");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data["meals"] as List).map((item) => item["strCategory"] as String).toList();
  } else {
    throw Exception("Erro ao carregar categorias");
  }
}

static Future<List<String>> fetchIngredients() async {
  final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/list.php?i=list");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data["meals"] as List).map((item) => item["strIngredient"] as String).toList();
  } else {
    throw Exception("Erro ao carregar ingredientes");
  }
}static Future<List<dynamic>> fetchRecipesByCategory(String category) async {
  final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/filter.php?c=$category");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["meals"];
  } else {
    throw Exception("Erro ao carregar receitas por categoria");
  }
}

static Future<List<dynamic>> fetchRecipesByIngredient(String ingredient) async {
  final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/filter.php?i=$ingredient");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["meals"];
  } else {
    throw Exception("Erro ao carregar receitas por ingrediente");
  }
}
static Future<List<dynamic>> fetchRecipesByName(String name) async {
  final url = Uri.parse("https://www.themealdb.com/api/json/v1/1/search.php?s=$name");
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data["meals"] ?? [];
  } else {
    throw Exception("Erro ao carregar receitas pelo nome");
  }
}


}
