import '../../domain/models/recipe.dart';

abstract class RecipeState {}

class RecipeInitState extends RecipeState {}

class RecipeLoadingState extends RecipeState {}

class RecipeLoadedState extends RecipeState {
  final Recipe recipe;
  final Map<String, String>? recipeSummary;
  final List<String>? relatedRecipes;
  final List<int>? relatedRecipesIds;

  RecipeLoadedState({
    required this.recipe,
    required this.recipeSummary,
    required this.relatedRecipes,
    required this.relatedRecipesIds,
  });
}

class RecipeErrorState extends RecipeState {
  final String errorMessage;

  RecipeErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
