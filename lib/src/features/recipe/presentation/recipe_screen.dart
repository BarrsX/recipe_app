import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/recipe_bloc.dart';

import 'widgets/recipe_view.dart';

class RecipeScreen extends StatelessWidget {
  final int mealId;

  const RecipeScreen(this.mealId, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeBloc(),
      child: RecipeView(mealId),
    );
  }
}
