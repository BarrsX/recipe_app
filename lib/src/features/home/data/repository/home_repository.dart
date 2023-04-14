import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

import '../../../recipe/domain/models/recipe.dart';

class HomeRepository {
  final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;

  /// Get more meals from the API
  Future<List<Recipe>> getMoreMeals() async {
    final User user = FirebaseAuth.instance.currentUser!;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final idToken = await user.getIdToken();

    final url = Uri.parse(
        'https://us-central1-recipe-app-d6b31.cloudfunctions.net/getMoreMeals');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken'
        },
        body: jsonEncode({
          'data': {'query': ''}
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Recipe> mealsList = [];

        if (data['result']['recipes'] is List) {
          mealsList = (data['result']['recipes'] as List)
              .map((mealJson) => Recipe.fromJson(mealJson))
              .toList();
        } else if (data['result']['recipes'] is Map) {
          mealsList = [Recipe.fromJson(data['result']['recipes'])];
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
  Future<Map<String, dynamic>> getSuggestionList(String query) async {
    final User user = FirebaseAuth.instance.currentUser!;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final idToken = await user.getIdToken();

    final url = Uri.parse(
        'https://us-central1-recipe-app-d6b31.cloudfunctions.net/getSuggestionList');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken'
        },
        body: jsonEncode({
          'data': {'query': query}
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return [] as Map<String, dynamic>;
  }

  /// Load meals from the API or search for meals based on the query
  Future<Map<String, dynamic>> loadOrSearchMeals(
      String query,
      BehaviorSubject<List<Recipe>> meals,
      BehaviorSubject<bool> isLoading,
      BehaviorSubject<bool> isError,
      BehaviorSubject<bool> ascendingOrder) async {

    final User user = FirebaseAuth.instance.currentUser!;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final idToken = await user.getIdToken();

    try {
      final response = await http.post(
        Uri.parse(
            'https://us-central1-recipe-app-d6b31.cloudfunctions.net/loadOrSearchMeals'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken'
        },
        body: jsonEncode({
          'data': {'query': query}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        isLoading.add(false);
        isError.add(true);
      }
    } catch (e) {
      print('Error: $e');
      isLoading.add(false);
      isError.add(true);
    }
    return [] as Map<String, dynamic>;
  }
}
