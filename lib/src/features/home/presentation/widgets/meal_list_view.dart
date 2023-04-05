import 'package:recipe_app/src/features/recipe/domain/models/recipe.dart';

import '../../../recipe/presentation/recipe_screen.dart';
import 'package:flutter/material.dart';
import '../bloc/home_bloc.dart';

class MealListView extends StatelessWidget {
  final List<Recipe> meals;
  final HomeBloc homeBloc;

  const MealListView({Key? key, required this.meals, required this.homeBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
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
              title: Text(
                meal.title ?? 'No Title',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
