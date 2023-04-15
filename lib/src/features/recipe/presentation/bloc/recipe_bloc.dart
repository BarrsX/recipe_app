import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/recipe_repository.dart';
import '../../domain/models/recipe.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository _recipeRepository = RecipeRepository();

  RecipeBloc() : super(RecipeInitState()) {
    on((LoadRecipeEvent event, emit) => mapLoadRecipeEventToState(event, emit));
  }

  /// Map the [LoadRecipeEvent] to the [RecipeState]
  void mapLoadRecipeEventToState(LoadRecipeEvent event, Emitter emit) async {
    emit(RecipeLoadingState());
    try {
      final data = await _recipeRepository.getRecipeById(event.mealId);
      Recipe recipe = Recipe.fromJson(data['result']);

      emit(RecipeLoadedState(
          recipe: recipe,
          recipeSummary: recipe.summaryInfo,
          relatedRecipes: recipe.relatedRecipes,
          relatedRecipesIds: recipe.relatedRecipesIds));
    } catch (e) {
      emit(RecipeErrorState(e.toString()));
    }
  }
}
