import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RecipeRepository {
  late final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  final User user = FirebaseAuth.instance.currentUser!;

  /// Get the recipe from the API by the meal id
  Future getRecipeById(int mealId) async {
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final idToken = await user.getIdToken();

    final url = Uri.parse(
        'https://us-central1-recipe-app-d6b31.cloudfunctions.net/getRecipeById');

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken'
          },
          body: jsonEncode({
            'data': {'mealId': mealId}
          }));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
