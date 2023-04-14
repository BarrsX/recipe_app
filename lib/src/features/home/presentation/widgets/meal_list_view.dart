import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../recipe/domain/models/recipe.dart';
import '../../../recipe/presentation/recipe_screen.dart';
import '../bloc/home_bloc.dart';

enum MealSortAttribute { readyInMinutes, aggregateLikes, healthScore, none }

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
  MealSortAttribute _sortAttribute = MealSortAttribute.none;
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
    filteredMeals = widget.meals;
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        widget.homeBloc.loadMoreMeals();
        _updateFilteredMeals();
      }
    });
  }

  List<Recipe> filteredMeals = [];

  void _updateFilteredMeals() {
    filteredMeals = widget.meals.where((meal) {
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
      if (_sortAttribute == MealSortAttribute.none) {
        return 0;
      }

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
        default:
          comparison = 0;
      }

      return _isAscending ? comparison : -comparison;
    });

    setState(() {
      filteredMeals = filteredMeals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.homeBloc.loadOrSearchMeals();
        _updateFilteredMeals();
      },
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sortAttribute = MealSortAttribute.readyInMinutes;
                      _isAscending = !_isAscending;
                    });
                    _updateFilteredMeals();
                  },
                  child: Row(
                    children: [
                      const Text('Ready in'),
                      Icon(
                        _sortAttribute == MealSortAttribute.readyInMinutes
                            ? (_isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sortAttribute = MealSortAttribute.aggregateLikes;
                      _isAscending = !_isAscending;
                    });
                    _updateFilteredMeals();
                  },
                  child: Row(
                    children: [
                      const Text('Likes'),
                      Icon(
                        _sortAttribute == MealSortAttribute.aggregateLikes
                            ? (_isAscending
                                ? Icons.arrow_downward
                                : Icons.arrow_upward)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sortAttribute = MealSortAttribute.healthScore;
                      _isAscending = !_isAscending;
                    });
                    _updateFilteredMeals();
                  },
                  child: Row(
                    children: [
                      const Text('Health Score'),
                      Icon(
                        _sortAttribute == MealSortAttribute.healthScore
                            ? (_isAscending
                                ? Icons.arrow_downward
                                : Icons.arrow_upward)
                            : null,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return SizedBox(
                              height: 300,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    CheckboxListTile(
                                      title: const Text('Vegetarian'),
                                      value: _isVegetarianFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isVegetarianFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Vegan'),
                                      value: _isVeganFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isVeganFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Gluten Free'),
                                      value: _isGlutenFreeFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isGlutenFreeFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Dairy Free'),
                                      value: _isDairyFreeFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isDairyFreeFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Very Healthy'),
                                      value: _isVeryHealthyFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isVeryHealthyFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Cheap'),
                                      value: _isCheapFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isCheapFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Very Popular'),
                                      value: _isVeryPopularFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isVeryPopularFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                    CheckboxListTile(
                                      title: const Text('Sustainable'),
                                      value: _isSustainableFilterEnabled,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _isSustainableFilterEnabled = value!;
                                        });
                                        _updateFilteredMeals();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.filter_alt),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              itemCount: filteredMeals.length,
              itemBuilder: (context, index) {
                final meal = filteredMeals[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecipeScreen(meal.id)));
                  },
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(
                                meal.image!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  meal.title!,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.timer,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 5),
                              Text('${meal.readyInMinutes} min'),
                              const SizedBox(width: 20),
                              Icon(Icons.local_fire_department,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 5),
                              Text('${meal.aggregateLikes} likes'),
                              const SizedBox(width: 20),
                              Icon(Icons.emoji_food_beverage_outlined,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 5),
                              Text('${meal.healthScore}%'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
      String text, bool isSelected, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Text(text),
          if (isSelected) const Icon(Icons.check),
        ],
      ),
    );
  }
}
