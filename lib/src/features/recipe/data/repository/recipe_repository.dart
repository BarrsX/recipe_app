import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/recipe.dart';

class RecipeRepository {
  late final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  /// Get the recipe from the API by the meal id
  Future getRecipeById(int mealId) async {
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
