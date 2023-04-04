import 'package:recipe_app/src/features/recipe/domain/models/recipe_model.dart';

abstract class RecipeState {}

class RecipeInitState extends RecipeState {}

class RecipeLoadingState extends RecipeState {}

class RecipeLoadedState extends RecipeState {
  final Recipe recipe;
  final Map<String, String> recipeSummary;
  final List<String> relatedRecipes;

  RecipeLoadedState({
    required this.recipe,
    required this.recipeSummary,
    required this.relatedRecipes,
  });
}

class RecipeErrorState extends RecipeState {
  final String errorMessage;

  RecipeErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

