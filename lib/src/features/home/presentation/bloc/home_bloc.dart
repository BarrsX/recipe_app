import 'package:rxdart/rxdart.dart';

import '../../../recipe/domain/models/recipe.dart';
import '../../data/repository/home_repository.dart';

class HomeBloc {
  final HomeRepository _homeRepository = HomeRepository();

  final BehaviorSubject<List<Map<String, dynamic>>> suggestionList =
      BehaviorSubject<List<Map<String, dynamic>>>.seeded([]);
  final BehaviorSubject<List<Recipe>> meals =
      BehaviorSubject<List<Recipe>>.seeded([]);
  final BehaviorSubject<bool> isLoading = BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<bool> isError = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<bool> ascendingOrder =
      BehaviorSubject<bool>.seeded(true);
  final BehaviorSubject<List<Recipe>> searchMeals =
      BehaviorSubject<List<Recipe>>.seeded([]);

  /// Dispose the streams
  void dispose() {
    suggestionList.close();
    meals.close();
    isLoading.close();
    isError.close();
    ascendingOrder.close();
    searchMeals.close();
  }

  /// Get the list of suggestions for the search query
  Future<Iterable<String>> getSuggestionList(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final data = await _homeRepository.getSuggestionList(query);
    final result = data['result'] as List<dynamic>;
    final suggestions = result.isNotEmpty
        ? result.map((obj) => obj['title'] as String).toList()
        : [];
    return suggestions as Iterable<String>;
  }

  /// Load more meals from the API
  void loadMoreMeals() async {
    try {
      final List<Recipe> newMeals = await _homeRepository.getMoreMeals();

      final List<Recipe> currentMeals = meals.value;
      final List<Recipe> updatedMeals = [...currentMeals, ...newMeals];
      meals.add(updatedMeals);

      isLoading.add(false);
    } catch (error) {
      print('Error while loading more meals: $error');
      isError.add(true);
    }
  }

  /// Load or search meals from the API based on the query
  Future<void> loadOrSearchMeals([String query = '']) async {
    isLoading.add(true);
    isError.add(false);

    String mealKey = query.isEmpty ? 'recipes' : 'results';
    final data = await _homeRepository.loadOrSearchMeals(
        query, meals, isLoading, isError, ascendingOrder);

    List<Recipe> mealsList = (data['result'][mealKey] as List)
        .map((mealJson) => Recipe.fromJson(mealJson))
        .toList();
    searchMeals.add(mealsList);

    if (!meals.isClosed) {
      meals.add(mealsList);
    }

    isLoading.add(false);
  }

  /// Reset the search
  void resetSearch() {
    meals.add([]);
    isError.add(false);
    isLoading.add(false);
    loadOrSearchMeals();
  }
}
