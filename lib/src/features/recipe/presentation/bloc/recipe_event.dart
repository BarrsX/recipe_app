abstract class RecipeEvent {}

class LoadRecipeEvent extends RecipeEvent {
  final int mealId;

  LoadRecipeEvent(this.mealId);
}
