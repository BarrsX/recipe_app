import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../../domain/models/meal_model.dart';

class HomeBloc {
  final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  final BehaviorSubject<List<Map<String, dynamic>>> suggestionList =
      BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);
  final BehaviorSubject<List<Meal>> meals =
      BehaviorSubject<List<Meal>>.seeded([]);
  final BehaviorSubject<bool> isLoading = BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<bool> isError = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> ascendingOrder =
      BehaviorSubject<bool>.seeded(true);

  Future<Iterable<String>> getSuggestionList(String query) async {
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

  Future<void> loadOrSearchMeals([String query = '']) async {
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

        List<Meal> mealsList = (data[mealKey] as List)
            .map((mealJson) => Meal.fromJson(mealJson))
            .toList();

        meals.add(mealsList);

        isLoading.add(false);

        ascendingOrder.value
            ? sortMeals(mealsList, 'asc')
            : sortMeals(mealsList, 'dsc');
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

  void resetSearch() {
    meals.add([]);
    isLoading.add(true);
    isError.add(false);

    loadOrSearchMeals();
  }

  void sortMeals(List<Meal> mealsList, String order) {
    if (order == 'asc') {
      mealsList.sort((a, b) {
        return a.readyInMinutes.compareTo(b.readyInMinutes);
      });
    } else {
      mealsList.sort((a, b) {
        return b.readyInMinutes.compareTo(a.readyInMinutes);
      });
    }

    meals.add(mealsList);
  }

  void dispose() {
    suggestionList.close();
    meals.close();
    isLoading.close();
    isError.close();
    ascendingOrder.close();
  }
}
