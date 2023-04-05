import '../../../recipe/presentation/recipe_screen.dart';
import '../../domain/models/meal_model.dart';
import 'package:flutter/material.dart';
import '../bloc/home_bloc.dart';

class MealListView extends StatelessWidget {
  final List<Meal> meals;
  final HomeBloc homeBloc;

  const MealListView({Key? key, required this.meals, required this.homeBloc}) : super(key: key);

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
                  meal.image ??
                      'https://media.istockphoto.com/photos/food-for-healthy-brain-picture-id1299079243?b=1&k=20&m=1299079243&s=612x612&w=0&h=0nD8xtP3eNikgVuP955dLLwXw1Ch6l1uH4nqcYB8e9I=',
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                meal.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle:
                  Text('Ready in ${meal.readyInMinutes} minutes'),
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
    );
  }
}
