import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../../../recipe/domain/models/recipe.dart';

class HomeRepository {
  /// Get more meals from the API
  Future<List<Recipe>> getMoreMeals(String spoonacularApiKey) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/random?number=10&addRecipeInformation=true&apiKey=$spoonacularApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Recipe> mealsList = [];

        if (data['recipes'] is List) {
          mealsList = (data['recipes'] as List)
              .map((mealJson) => Recipe.fromJson(mealJson))
              .toList();
        } else if (data['recipes'] is Map) {
          mealsList = [Recipe.fromJson(data['recipes'])];
        }

        return mealsList;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return [];
  }

  /// Get the list of suggestions for the search query
  Future<Iterable<String>> getSuggestionList(
      String query, String spoonacularApiKey) async {
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/autocomplete?number=5&query=$query&apiKey=$spoonacularApiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final suggestions = data.map((obj) => obj['title'] as String);

        return suggestions;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return [];
  }

  /// Load meals from the API or search for meals based on the query
  Future<void> loadOrSearchMeals(
      String query,
      String spoonacularApiKey,
      BehaviorSubject<List<Recipe>> meals,
      BehaviorSubject<bool> isLoading,
      BehaviorSubject<bool> isError,
      BehaviorSubject<bool> ascendingOrder) async {
    final url = query.isEmpty
        ? Uri.parse(
            'https://api.spoonacular.com/recipes/random?number=15&addRecipeInformation=true&apiKey=$spoonacularApiKey')
        : Uri.parse(
            'https://api.spoonacular.com/recipes/complexSearch?query=$query&addRecipeInformation=true&apiKey=$spoonacularApiKey');

    String mealKey = query.isEmpty ? 'recipes' : 'results';
    isLoading.add(true);
    isError.add(false);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<Recipe> mealsList = (data[mealKey] as List)
            .map((mealJson) => Recipe.fromJson(mealJson))
            .toList();

        meals.add(mealsList);

        isLoading.add(false);

        ascendingOrder.value
            ? _sortMeals(mealsList, 'asc')
            : _sortMeals(mealsList, 'dsc');
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        isLoading.add(false);
        isError.add(true);
      }
    } catch (e) {
      print(e);
      isLoading.add(false);
      isError.add(true);
    }
  }

  /// Sort the meals list based on the order
  void _sortMeals(List<Recipe> mealsList, String order) {
    if (order == 'asc') {
      mealsList.sort((a, b) {
        return a.readyInMinutes?.compareTo(b.readyInMinutes as int) as int;
      });
    } else {
      mealsList.sort((a, b) {
        return b.readyInMinutes?.compareTo(a.readyInMinutes as int) as int;
      });
    }
  }
}
