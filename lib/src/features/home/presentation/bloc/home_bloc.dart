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

  /// Dispose the streams
  void dispose() {
    suggestionList.close();
    meals.close();
    isLoading.close();
    isError.close();
    ascendingOrder.close();
  }

  /// Get the list of suggestions for the search query
  Future<Iterable<String>> getSuggestionList(String query) async {
    final data = await _homeRepository.getSuggestionList(query);
    final result = data['result'] as List<dynamic>;
    final suggestions = result != null
        ? result.map((obj) => obj['title'] as String).toList()
        : [];
    return suggestions as Iterable<String>;
  }

  /// Load more meals from the API
  void loadMoreMeals() async {
    try {
      final List<Recipe> newMeals = await _homeRepository.getMoreMeals();

      final List<Recipe> currentMeals = meals.value ?? [];
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

    if (!meals.isClosed) {
      meals.add(mealsList);
    }

    if (!isLoading.isClosed) {
      isLoading.add(false);
    }

    ascendingOrder.value
        ? sortMeals(mealsList, 'asc')
        : sortMeals(mealsList, 'dsc');
  }

  /// Reset the search
  void resetSearch() {
    meals.add([]);
    isLoading.add(true);
    isError.add(false);

    loadOrSearchMeals();
  }

  /// Sort the meals based on the order
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

    if (!meals.isClosed) {
      meals.add(mealsList);
    }
  }
}
