import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/extended_ingredient.dart';
import '../../domain/models/recipe.dart';
import '../../domain/models/step.dart';
import '../bloc/recipe_bloc.dart';
import '../bloc/recipe_event.dart';
import '../bloc/recipe_state.dart';
import '../recipe_screen.dart';

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
    // TODO: add home button to recipe view
    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(state is RecipeLoadedState
                  ? state.recipe.title ?? 'Recipe'
                  : 'Recipe')),
          // TODO: might be able to remove this bloc builder
          body: BlocBuilder<RecipeBloc, RecipeState>(
            builder: (context, state) {
              if (state is RecipeInitState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RecipeLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RecipeLoadedState) {
                return _buildRecipeView(state.recipe, state.recipeSummary,
                    state.relatedRecipes, state.relatedRecipesIds, context);
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
      },
    );
  }

  Widget _buildRecipeView(
    Recipe recipe,
    Map<String, String>? recipeSummary,
    List<String>? relatedRecipes,
    List<int>? relatedRecipesIds,
    BuildContext context,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            recipe.image ?? '',
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
                    recipe.title ?? 'No Title',
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
                          rows: recipeSummary!.entries
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
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Ingredients:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: SizedBox(
                            height: 300,
                            child: GridView.builder(
                              itemCount: recipe.extendedIngredients?.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                ExtendedIngredient ingredient =
                                    recipe.extendedIngredients![index];
                                final hasImage = ingredient.image != null;
                                return InkWell(
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Theme.of(context).dialogBackgroundColor,
                                        contentPadding:
                                            const EdgeInsets.all(16.0),
                                        content: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (hasImage) ...[
                                              Image.network(
                                                'https://spoonacular.com/cdn/ingredients_100x100/${ingredient.image}',
                                                height: 100,
                                                width: 100,
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                                  // show placeholder image when an error occurs
                                                  return const SizedBox(
                                                    height: 100,
                                                    width: 100,
                                                    child: Placeholder(),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 16.0),
                                            ],
                                            Text(
                                              // TODO: titlecase names
                                              ingredient.nameClean ??
                                                  'Ingredient',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16.0),
                                            if (ingredient.aisle != null) ...[
                                              Text(
                                                'Aisle: ${ingredient.aisle}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 16.0),
                                            ],
                                            if (ingredient.measures !=
                                                null) ...[
                                              Text(
                                                'US: ${ingredient.measures!.us?.amount?.toStringAsFixed(2) ?? '-'} ${ingredient.measures!.us?.unitLong ?? '-'}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Metric: ${ingredient.measures!.metric?.amount?.toStringAsFixed(2) ?? '-'} ${ingredient.measures!.metric?.unitLong ?? '-'}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.0),
                                    child: ListTile(
                                      leading: hasImage
                                          ? CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                'https://spoonacular.com/cdn/ingredients_100x100/${ingredient.image}',
                                              ),
                                            )
                                          : null,
                                      subtitle: Column(
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 8.0),
                                                Text(
                                                  ingredient.nameClean ??
                                                      'Ingredient',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ),
                                                SizedBox(
                                                  height: 56.0,
                                                  child: Text(
                                                    ingredient.original!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Instructions:',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    recipe.analyzedInstructions!.isNotEmpty
                                        ? recipe.analyzedInstructions![0].steps!
                                            .length
                                        : 0,
                                itemBuilder: (BuildContext context, int index) {
                                  InstructionStep? steps = recipe
                                      .analyzedInstructions![0].steps![index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        child: Text(
                                          steps.number.toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        steps.step ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Text(
                      'Related Recipes:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: relatedRecipes?.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: GestureDetector(
                                child: Text(
                                  relatedRecipes![index].substring(
                                      relatedRecipes[index].indexOf('>') + 1),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return RecipeScreen(
                                          relatedRecipesIds![index]);
                                    },
                                  ),
                                ),
                              ),
                              leading: Icon(
                                Icons.restaurant,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
