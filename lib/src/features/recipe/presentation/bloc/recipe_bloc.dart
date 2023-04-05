import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/recipe_repository.dart';
import '../../domain/models/recipe.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';


class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository _recipeRepository = RecipeRepository();
  late final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  final Map<String, dynamic> _recipe = {};


  RecipeBloc() : super(RecipeInitState()) {
    on(
        (LoadRecipeEvent event, emit) => mapLoadRecipeEventToState(event, emit));
  }


  void mapLoadRecipeEventToState(
      LoadRecipeEvent event, Emitter emit) async {
    emit(RecipeLoadingState());
    try {
      Recipe recipe = await _recipeRepository.getRecipe(
          event.mealId, spoonacularApiKey);


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