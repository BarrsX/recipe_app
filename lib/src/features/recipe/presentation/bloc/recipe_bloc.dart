import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  late final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  late Map<String, dynamic> _recipe = {};
  late Map<String, String> _recipeSummary = {};
  late List<String> _relatedRecipes = [];

  RecipeBloc() : super(RecipeInitState()) {
    on<LoadRecipeEvent>(
        (event, emit) => mapLoadRecipeEventToState(event, emit));
  }

  void mapLoadRecipeEventToState(
      LoadRecipeEvent event, Emitter<RecipeState> emit) async {
    print('mapLoadRecipeEventToState');
    emit(RecipeLoadingState());
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/${event.mealId}/information?apiKey=$spoonacularApiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        _recipe = data;
        _recipeSummary = _buildSummaryInfo(_recipe['summary']);
        _relatedRecipes = _separateRelatedRecipes(_recipe['summary']);
        emit(RecipeLoadedState(
          recipe: _recipe,
          recipeSummary: _recipeSummary,
          relatedRecipes: _relatedRecipes,
        ));
      } else {
        emit(RecipeErrorState());
      }
    } catch (e) {
      emit(RecipeErrorState());
    }
  }

  Map<String, String> _buildSummaryInfo(String payload) {
    Map<String, String> nutritionData = {};
    List<String> matchers = [
      'protein',
      'fat',
      'calories',
      '\$',
      'cents',
      'score',
      'dairy',
      'gluten',
      'keto'
    ];
    final regex = RegExp(r'<b>(.*?)<\/b>');
    final matches = regex.allMatches(payload);

    for (Match match in matches) {
      if (match.group(1) != null) {
        String? text = match.group(1);

        if (matchers.any((keyword) => text!.contains(keyword))) {
          nutritionData[matchers[matchers
              .indexWhere((keyword) => text!.contains(keyword))]] = text!;
        }
      }
    }

    return nutritionData;
  }

  List<String> _separateRelatedRecipes(String payload) {
    List<String> relatedRecipes = [];
    final regex = RegExp(r'<a(.*?)<\/a>');
    final matches = regex.allMatches(payload);

    for (Match match in matches) {
      if (match.group(1) != null) {
        relatedRecipes.add(match.group(1)!);
      }
    }

    return relatedRecipes;
  }
}
