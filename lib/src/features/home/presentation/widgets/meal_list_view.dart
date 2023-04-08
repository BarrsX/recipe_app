import 'package:flutter/material.dart';
import '../../../recipe/domain/models/recipe.dart';
import '../bloc/home_bloc.dart';
import '../../../recipe/presentation/recipe_screen.dart';

enum MealSortAttribute { readyInMinutes, aggregateLikes, healthScore }

class MealListView extends StatefulWidget {
  final List<Recipe> meals;
  final HomeBloc homeBloc;

  const MealListView({Key? key, required this.meals, required this.homeBloc})
      : super(key: key);

  @override
  _MealListViewState createState() => _MealListViewState();
}

class _MealListViewState extends State<MealListView> {
  final ScrollController _scrollController = ScrollController();
  MealSortAttribute _sortAttribute = MealSortAttribute.readyInMinutes;
  bool _isAscending = true;

  bool _isVegetarianFilterEnabled = false;
  bool _isVeganFilterEnabled = false;
  bool _isGlutenFreeFilterEnabled = false;
  bool _isDairyFreeFilterEnabled = false;
  bool _isVeryHealthyFilterEnabled = false;
  bool _isCheapFilterEnabled = false;
  bool _isVeryPopularFilterEnabled = false;
  bool _isSustainableFilterEnabled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        widget.homeBloc.loadMoreMeals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var filteredMeals = widget.meals.where((meal) {
      return (!_isVegetarianFilterEnabled || meal.vegetarian == true) &&
          (!_isVeganFilterEnabled || meal.vegan == true) &&
          (!_isGlutenFreeFilterEnabled || meal.glutenFree == true) &&
          (!_isDairyFreeFilterEnabled || meal.dairyFree == true) &&
          (!_isVeryHealthyFilterEnabled || meal.veryHealthy == true) &&
          (!_isCheapFilterEnabled || meal.cheap == true) &&
          (!_isVeryPopularFilterEnabled || meal.veryPopular == true) &&
          (!_isSustainableFilterEnabled || meal.sustainable == true);
    }).toList();

    filteredMeals.sort((a, b) {
      int comparison;
      switch (_sortAttribute) {
        case MealSortAttribute.aggregateLikes:
          comparison = b.aggregateLikes!.compareTo(a.aggregateLikes!);
          break;
        case MealSortAttribute.healthScore:
          comparison = b.healthScore!.compareTo(a.healthScore!);
          break;
        case MealSortAttribute.readyInMinutes:
          comparison = a.readyInMinutes!.compareTo(b.readyInMinutes!);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });
    for (var meal in filteredMeals) {
      precacheImage(NetworkImage(meal.image ?? ''), context);
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Sort by: '),
              // TODO: Prevent filter popup from closing after clicking a filter
              PopupMenuButton<MealSortAttribute>(
                color: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                initialValue: _sortAttribute,
                onSelected: (attribute) {
                  if (_sortAttribute == attribute) {
                    setState(() {
                      _isAscending = !_isAscending;
                    });
                  } else {
                    setState(() {
                      _sortAttribute = attribute;
                      _isAscending = true;
                    });
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<MealSortAttribute>>[
                  const PopupMenuItem(
                    value: MealSortAttribute.readyInMinutes,
                    child: Text('Ready In Minutes'),
                  ),
                  const PopupMenuItem(
                    value: MealSortAttribute.aggregateLikes,
                    child: Text('Aggregate Likes'),
                  ),
                  const PopupMenuItem(
                    value: MealSortAttribute.healthScore,
                    child: Text('Health Score'),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Text('Filter by: '),
              PopupMenuButton(
                color: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                itemBuilder: (_) => [
                  CheckedPopupMenuItem(
                    checked: _isVegetarianFilterEnabled,
                    value: 'Vegetarian',
                    child: const Text('Vegetarian'),
                  ),
                  CheckedPopupMenuItem(
                    checked: _isVeganFilterEnabled,
                    value: 'Vegan',
                    child: const Text('Vegan'),
                  ),
                  CheckedPopupMenuItem(
                    checked: _isGlutenFreeFilterEnabled,
                    value: 'Gluten Free',
                    child: const Text('Gluten Free'),
                  ),
                  CheckedPopupMenuItem(
                    checked: _isDairyFreeFilterEnabled,
                    value: 'Dairy Free',
                    child: const Text('Dairy Free'),
                  ),
                  CheckedPopupMenuItem(
                    checked: _isVeryHealthyFilterEnabled,
                    value: 'Very Healthy',
                    child: const Text('Very Healthy'),
                  ),
                  CheckedPopupMenuItem(
                    checked: _isCheapFilterEnabled,
                    value: 'Cheap',
                    child: const Text('Cheap'),
                  ),
                  CheckedPopupMenuItem(
                    checked: _isVeryPopularFilterEnabled,
                    value: 'Very Popular',
                    child: const Text('Very Popular'),
                  ),
                  CheckedPopupMenuItem(
                    checked: _isSustainableFilterEnabled,
                    value: 'Sustainable',
                    child: const Text('Sustainable'),
                  ),
                ],
                onSelected: (String filter) {
                  setState(() {
                    switch (filter) {
                      case 'Vegetarian':
                        _isVegetarianFilterEnabled =
                            !_isVegetarianFilterEnabled;
                        break;
                      case 'Vegan':
                        _isVeganFilterEnabled = !_isVeganFilterEnabled;
                        break;
                      case 'Gluten Free':
                        _isGlutenFreeFilterEnabled =
                            !_isGlutenFreeFilterEnabled;
                        break;
                      case 'Dairy Free':
                        _isDairyFreeFilterEnabled = !_isDairyFreeFilterEnabled;
                        break;
                      case 'Very Healthy':
                        _isVeryHealthyFilterEnabled =
                            !_isVeryHealthyFilterEnabled;
                        break;
                      case 'Cheap':
                        _isCheapFilterEnabled = !_isCheapFilterEnabled;
                        break;
                      case 'Very Popular':
                        _isVeryPopularFilterEnabled =
                            !_isVeryPopularFilterEnabled;
                        break;
                      case 'Sustainable':
                        _isSustainableFilterEnabled =
                            !_isSustainableFilterEnabled;
                        break;
                    }
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = filteredMeals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 16),
                      child: Image.network(
                        meal.image ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.title ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (meal.veryPopular != null && meal.veryPopular!)
                          Container(
                            padding: const EdgeInsets.only(left: 8),
                            child: const Icon(Icons.star,
                                size: 20, color: Colors.yellow),
                          ),
                      ],
                    ),
                    subtitle: Text(_getSubtitle(meal, _sortAttribute),
                        style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              RecipeScreen(meal.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSubtitle(Recipe meal, MealSortAttribute sortAttribute) {
    switch (sortAttribute) {
      case MealSortAttribute.aggregateLikes:
        return '${meal.aggregateLikes} Total Likes';
      case MealSortAttribute.healthScore:
        return 'Health Score: ${meal.healthScore}';
      case MealSortAttribute.readyInMinutes:
      default:
        return 'Ready in ${meal.readyInMinutes} minutes';
    }
  }
}
