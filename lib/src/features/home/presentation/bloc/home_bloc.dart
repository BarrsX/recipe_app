import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import '../../../recipe/domain/models/recipe.dart';
import '../../data/repository/home_repository.dart';

class HomeBloc {
  final String spoonacularApiKey = dotenv.env['SPOONACULAR_API_KEY']!;
  final HomeRepository _homeRepository = HomeRepository();

  final BehaviorSubject<List<Map<String, dynamic>>> suggestionList =
      BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);
  final BehaviorSubject<List<Recipe>> meals =
      BehaviorSubject<List<Recipe>>.seeded([]);
  final BehaviorSubject<bool> isLoading = BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<bool> isError = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> ascendingOrder =
      BehaviorSubject<bool>.seeded(true);

  Future<Iterable<String>> getSuggestionList(String query) async {
    return await _homeRepository.getSuggestionList(query, spoonacularApiKey);
  }

  Future<void> loadOrSearchMeals([String query = '']) async {
    await _homeRepository.loadOrSearchMeals(
        query, spoonacularApiKey, meals, isLoading, isError, ascendingOrder);
  }

  void loadMoreMeals() async {
    try {
      // Load more meals from the API
      final List<Recipe> newMeals =
          await _homeRepository.getMoreMeals(spoonacularApiKey);

      // Append the new meals to the existing list
      final List<Recipe> currentMeals = meals.value ?? [];
      final List<Recipe> updatedMeals = [...currentMeals, ...newMeals];
      meals.add(updatedMeals);

      // Set isLoading to false
      isLoading.add(false);
    } catch (error) {
      print('Error while loading more meals: $error');
      // Set isError to true
      isError.add(true);
    }
  }

  void resetSearch() {
    meals.add([]);
    isLoading.add(true);
    isError.add(false);

    loadOrSearchMeals();
  }

  void sortMeals(List<Recipe> mealsList, String order) {
    if (order == 'asc') {
      mealsList.sort((a, b) {
        return a.readyInMinutes?.compareTo(b.readyInMinutes as int) as int;
      });
    } else {
      mealsList.sort((a, b) {
        return b.readyInMinutes?.compareTo(a.readyInMinutes as int) as int;
      });
    }

    meals.add(mealsList);
  }

  void dispose() {
    suggestionList.close();
    meals.close();
    isLoading.close();
    isError.close();
    ascendingOrder.close();
  }
}
