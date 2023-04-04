abstract class RecipeState {}

class RecipeInitState extends RecipeState {}

class RecipeLoadingState extends RecipeState {}

class RecipeLoadedState extends RecipeState {
  final Map<String, dynamic> recipe;
  final Map<String, String> recipeSummary;
  final List<String> relatedRecipes;

  RecipeLoadedState({
    required this.recipe,
    required this.recipeSummary,
    required this.relatedRecipes,
  });
}

class RecipeErrorState extends RecipeState {}
