import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:recipe_app/src/features/recipe/domain/models/recipe_model.dart';

import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  late final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  final Map<String, dynamic> _recipe = {};

  RecipeBloc() : super(RecipeInitState()) {
    on<LoadRecipeEvent>(
        (event, emit) => mapLoadRecipeEventToState(event, emit));
  }

  void mapLoadRecipeEventToState(
      LoadRecipeEvent event, Emitter<RecipeState> emit) async {
    emit(RecipeLoadingState());
    try {
      final url = Uri.parse(
          'https://api.spoonacular.com/recipes/${event.mealId}/information?apiKey=$spoonacularApiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Recipe recipe = Recipe.fromJson(data);
        emit(RecipeLoadedState(
            recipe: recipe,
            recipeSummary: recipe.summaryInfo,
            relatedRecipes: recipe.relatedRecipes));
      } else {
        emit(RecipeErrorState(response.body));
      }
    } catch (e) {
      emit(RecipeErrorState(e.toString()));
    }
  }
}
