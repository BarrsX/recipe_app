import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:recipe_app/src/features/home/presentation/bloc/home_bloc.dart';

import '../recipe/presentation/recipe_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.home),
            onPressed: _homeBloc.resetSearch,
          ),
          title: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search meals',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              onSubmitted: _homeBloc.loadOrSearchMeals,
            ),
            suggestionsCallback: _homeBloc.getSuggestionList,
            itemBuilder: (context, String suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (String suggestion) {
              _searchController.text = suggestion;
              _homeBloc.loadOrSearchMeals(suggestion);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                _homeBloc.ascendingOrder.add(!_homeBloc.ascendingOrder.value);
                _homeBloc.sortMeals(_homeBloc.meals.value,
                    _homeBloc.ascendingOrder.value ? 'asc' : 'dsc');
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            StreamBuilder<List>(
              stream: _homeBloc.meals,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final meal = snapshot.data![index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: Container(
                              width: 80,
                              height: 80,
                              margin: const EdgeInsets.only(right: 16),
                              child: Image.network(
                                // TODO: Fix this for when image is null
                                meal['image'] ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              meal['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                                'Ready in ${meal['readyInMinutes']} minutes'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      RecipeScreen(meal['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
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
        ));
  }
}
