import 'package:flutter/material.dart';
import '../../../recipe/domain/models/recipe.dart';
import '../bloc/home_bloc.dart';
import '../../../recipe/presentation/recipe_screen.dart';

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
    for (var meal in widget.meals) {
      precacheImage(NetworkImage(meal.image ?? ''), context);
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemCount: widget.meals.length,
        itemBuilder: (context, index) {
          final meal = widget.meals[index];
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
              subtitle: Text('Ready in ${meal.readyInMinutes} minutes'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => RecipeScreen(meal.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
