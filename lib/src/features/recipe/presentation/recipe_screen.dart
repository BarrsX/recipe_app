import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/src/features/recipe/domain/models/ingredient_model.dart';
import 'package:recipe_app/src/features/recipe/domain/models/recipe_model.dart';

import 'bloc/recipe_bloc.dart';
import 'bloc/recipe_event.dart';
import 'bloc/recipe_state.dart';

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

class RecipeView extends StatefulWidget {
  final int mealId;

  RecipeView(this.mealId);

  @override
  _RecipeViewState createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  late final RecipeBloc _recipeBloc;

  @override
  void initState() {
    super.initState();

    _recipeBloc = BlocProvider.of<RecipeBloc>(context);
    _recipeBloc.add(LoadRecipeEvent(widget.mealId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeInitState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecipeLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecipeLoadedState) {
            return _buildRecipeView(state.recipe, state.recipeSummary,
                state.relatedRecipes, context);
          } else if (state is RecipeErrorState) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  state.errorMessage,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _recipeBloc.add(LoadRecipeEvent(widget.mealId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ));
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildRecipeView(Recipe recipe, Map<String, String> recipeSummary,
      List<String> relatedRecipes, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            recipe.imageUrl,
            height: 300,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    recipe.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Center(
                      child: SizedBox(
                          child: DataTable(
                        columns: const [
                          DataColumn(label: Text('')),
                          DataColumn(label: Text('')),
                        ],
                        rows: recipeSummary.entries
                            .map(
                              (entry) => DataRow(
                                cells: [
                                  DataCell(Text(
                                      entry.key.toLowerCase() == 'cents' ||
                                              entry.key.toLowerCase() == '\$'
                                          ? 'PRICE'
                                          : entry.key.toUpperCase())),
                                  DataCell(Text(entry.value.toUpperCase())),
                                ],
                              ),
                            )
                            .toList(),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: recipe.extendedIngredients.length,
                        itemBuilder: (BuildContext context, int index) {
                          Ingredient ingredient =
                              recipe.extendedIngredients[index];
                          final hasImage = ingredient.image != null;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: ListTile(
                              leading: hasImage
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          'https://spoonacular.com/cdn/ingredients_100x100/${ingredient.image}'),
                                    )
                                  : null,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient.name!,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient.original!,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      'Instructions:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Container(
                      height: 500,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Expanded(
                            child: SizedBox(
                              height: 500,
                              child: ListView.builder(
                                itemCount: recipe.analyzedInstructions.isEmpty
                                    ? 0
                                    : recipe.analyzedInstructions.length,
                                itemBuilder: (BuildContext context, int index) {
                                  Instruction instruction =
                                      recipe.analyzedInstructions[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(
                                        instruction.number.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      instruction.step ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      'Related Recipes:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Container(
                      height: 250,
                      child: ListView.builder(
                        itemCount: relatedRecipes.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Html(
                              data: '<a${relatedRecipes[index]}</a>',
                              style: {
                                'fontFamily': Style(fontFamily: 'Open Sans'),
                                'fontSize': Style(fontSize: const FontSize(16)),
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
