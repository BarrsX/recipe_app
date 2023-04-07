import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/models/recipe.dart';

class RecipeRepository {
  /// Get the recipe from the API
  Future getRecipe(int mealId, String spoonacularApiKey) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/$mealId/information?apiKey=$spoonacularApiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Recipe recipe = Recipe.fromJson(data);
        return recipe;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
