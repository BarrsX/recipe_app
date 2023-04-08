import 'package:recipe_app/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter/material.dart';

import '../../recipe/domain/models/recipe.dart';

import 'widgets/search_field.dart';
import 'widgets/meal_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final HomeBloc _homeBloc = HomeBloc();

  @override
  void initState() {
    _homeBloc.loadOrSearchMeals();
    super.initState();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
  }

  void onPressHome() {
    _homeBloc.resetSearch();
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: onPressHome,
          ),
          title: SearchField(
            searchController: _searchController,
            homeBloc: _homeBloc,
            onHomePressed: onPressHome,
          ),
        ),
        body: Stack(
          children: [
            StreamBuilder<List<Recipe>>(
              stream: _homeBloc.meals,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return MealListView(
                      meals: snapshot.data!, homeBloc: _homeBloc);
                } else if (_homeBloc.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(child: Text('No Results Found'));
                }
              },
            ),
            StreamBuilder(
              stream: _homeBloc.isLoading,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container();
                }
              },
            ),
            StreamBuilder(
              stream: _homeBloc.isError,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'An error occurred',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _homeBloc.loadOrSearchMeals(_searchController.text);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
